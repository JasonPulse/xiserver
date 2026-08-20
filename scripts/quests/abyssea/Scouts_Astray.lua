-----------------------------------
-- Scouts Astray
-----------------------------------
-- Log ID: 8, Quest ID: 74
-- Rondipur      : Abyssea - Uleguerand (G-11), entity 17814114
-- Cannau        : Abyssea - Uleguerand (G-6),  entity 17814115
-- Wanzo-Unzozo  : Abyssea - Uleguerand (I-5),  entity 17814116
-- Olavia        : Abyssea - Uleguerand,        entity 17814117
-- Strewn_Carrion: Abyssea - Uleguerand (J-11), entity 17814118
-- !addquest 8 74
-----------------------------------
-- Retail (bg-wiki "Scouts Astray").
-- |Start=Rondipur (A), Abyssea - Uleguerand  |Repeatable=Yes
-- |Fame=Abyssea - Uleguerand  |FLevel=2  |Item Reqs=Pea Soup or Emerald Soup
-- |Reward=First time completion: 800 Cruor
--   1. Speak to Rondipur (A) at the base camp (Conflux 1) (G-11).
--   2. Cannau (A) is walking around (G-6). Trade her a Pea Soup or Emerald Soup.
--   3. Find Wanzo-Unzozo (A) near (I-5). Speak with him, then trade him a
--      Flint Stone.
--   4. Find Olavia (A) wandering between the tigers and buffalo. Speak to her.
--      Walk to (J-11) and examine the Strewn Carrion. Then return to Olavia and
--      talk to her.
--   5. Return to Rondipur (A) for your reward.
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Rondipur is 17814114 -> zone 253 idx 610
-- (0x010FD262) and the three scouts sit on the next three indices, with the Strewn
-- Carrion on the one after. `xi-dat events 253` plus csidscan.py against
-- `xi-dat dialog 253`:
--   Rondipur 319 -> 8025       his idle worry ("...Still no contact.")
--   Rondipur 320 -> 8026-8033  THE OFFER. 8027 "I have lost contact with my three
--            scouts", 8029 is the accept prompt: "Search for the scouts?
--            ${selection-lines} I will. / I will not." -- the affirmative is the
--            FIRST line, so OPTION 0 ACCEPTS, and 8031 is the decline. 8032 names
--            all three: "Cannau, dispatched to the northwestern reaches, Olavia in
--            the southeast, and Wanzo-Unzozo, who last reported from north of
--            Bearclaw Pinnacle."
--   Rondipur 321 -> 8032/8033  the reminder, the roster again.
--   Rondipur 343 -> 8051/8052  THE TURN-IN. "I received reports from all three of my
--            scouts. Of course, only Olavia had anything of import to share... And
--            even that was no doubt more your doing than hers."
--   Rondipur 344 -> 8053       his post-completion line.
--   Rondipur 345 -> 8027-8033 + 8054  the repeat offer.
--   Cannau 322 -> 8034, 323 -> 8034/8035 (the ask: "my legs are positively
--            freezing! You wouldn't happen to have ${article} ${item-article: 0[2]}
--            on your person, would you?"), 324 -> 8035 the reminder,
--            325/327 -> 8036 the soup handed over ("Warms the legs and the heart...
--            I should be getting back in touch with Rondipur"), 328 -> 8037 after.
--   Wanzo-Unzozo 329 -> 8038, 330 -> 8038/8039 (the ask: "I don't suppose you've
--            seen anything around that could be used to startaru a nice, cozy
--            fire"), 331 -> 8039 reminder, 332 -> 8040-8042 the flint handed over,
--            333 -> 8043, 335 -> 8044 after.
--   Olavia 336 -> 8045, 337 -> 8045/8046 (the ask: "I spotted the mammoth
--            tiger-beast... but lost sight of him in a blizzard. We have reason to
--            believe he vanished off to the north"), 338 -> 8046 reminder,
--            339/340 -> 8048/8049 her report once you have seen the carrion,
--            342 -> 8050 after.
--   Strewn Carrion -> 8047 "The snowbank is littered with half-gnawed animal
--            carcasses." It owns no csid of its own, so this is a plain message
--            rather than an event, the same shape the Shellfish points use.
--
-- ONLY OLAVIA'S LEG NEEDS TWO STEPS, and 8051 says why: hers is the one report with
-- anything in it. Cannau and Wanzo-Unzozo are single trades; Olavia is speak ->
-- examine the carrion -> speak again. That asymmetry is bg-wiki's and the dialogue's,
-- not a shortcut here.
--
-- ITEMS: Flint Stone is the existing FLINT_STONE (768). Both soups are the container
-- word trap -- item_basic holds them as `bowl_of_pea_soup` and
-- `bowl_of_emerald_soup`. BOWL_OF_PEA_SOUP (4416) already existed; Emerald Soup had
-- no enum and was added as BOWL_OF_EMERALD_SOUP (4327) after checking the id was
-- unused.
--
-- PROGRESS is a three-bit mask in the quest var 'Scouts', one bit per scout, so they
-- can be found in any order -- which bg-wiki's route notes assume.
-----------------------------------
local uleguerandID = zones[xi.zone.ABYSSEA_ULEGUERAND]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCOUTS_ASTRAY)

local cruorReward = 800
local allScouts   = 0x07 -- three bits: Cannau, Wanzo-Unzozo, Olavia

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

local scoutDone = function(player, slot)
    return bit.band(quest:getVar(player, 'Scouts'), bit.lshift(1, slot)) ~= 0
end

local creditScout = function(player, slot)
    quest:setVar(player, 'Scouts', bit.bor(quest:getVar(player, 'Scouts'), bit.lshift(1, slot)))
end

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes, and bg-wiki requires a zone in
    -- between. |FLevel=2 is the only other gate.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 2 and
                not quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCOUTS_ASTRAY) then
                        return quest:progressEvent(345)
                    end

                    return quest:progressEvent(320)
                end,
            },

            ['Cannau']       = quest:event(322):replaceDefault(),
            ['Wanzo-Unzozo'] = quest:event(329):replaceDefault(),
            ['Olavia']       = quest:event(336):replaceDefault(),

            onEventFinish =
            {
                [320] = function(player, csid, option, npc)
                    -- 8029: 0 "I will.", 1 "I will not."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Scouts', 0)
                end,

                [345] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCOUTS_ASTRAY)
                    quest:setVar(player, 'Scouts', 0)
                end,
            },
        },
    },

    -- Accepted: get all three reporting in, then back to Rondipur.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Cannau'] =
            {
                onTrade = function(player, npc, trade)
                    if scoutDone(player, 0) then
                        return
                    end

                    if
                        npcUtil.tradeHasExactly(trade, xi.item.BOWL_OF_PEA_SOUP) or
                        npcUtil.tradeHasExactly(trade, xi.item.BOWL_OF_EMERALD_SOUP)
                    then
                        return quest:progressEvent(325)
                    end
                end,

                onTrigger = function(player, npc)
                    if scoutDone(player, 0) then
                        return quest:event(328)
                    end

                    return quest:event(323)
                end,
            },

            ['Wanzo-Unzozo'] =
            {
                onTrade = function(player, npc, trade)
                    if scoutDone(player, 1) then
                        return
                    end

                    if npcUtil.tradeHasExactly(trade, xi.item.FLINT_STONE) then
                        return quest:progressEvent(332)
                    end
                end,

                onTrigger = function(player, npc)
                    if scoutDone(player, 1) then
                        return quest:event(335)
                    end

                    return quest:event(330)
                end,
            },

            ['Strewn_Carrion'] =
            {
                onTrigger = function(player, npc)
                    -- bg-wiki has you speak to Olavia BEFORE the carrion means
                    -- anything, so the sighting only counts once she has asked.
                    if quest:getVar(player, 'Olavia') ~= 1 then
                        return
                    end

                    player:messageSpecial(uleguerandID.text.STREWN_CARRION)
                    quest:setVar(player, 'Carrion', 1)
                end,
            },

            ['Olavia'] =
            {
                onTrigger = function(player, npc)
                    if scoutDone(player, 2) then
                        return quest:event(342)
                    end

                    -- She only has a report once you have seen the carrion.
                    if quest:getVar(player, 'Carrion') == 1 then
                        return quest:progressEvent(339)
                    end

                    return quest:progressEvent(337)
                end,
            },

            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Scouts') == allScouts then
                        return quest:progressEvent(343)
                    end

                    return quest:event(321)
                end,
            },

            onEventFinish =
            {
                [325] = function(player, csid, option, npc)
                    player:confirmTrade()
                    creditScout(player, 0)
                end,

                [332] = function(player, csid, option, npc)
                    player:confirmTrade()
                    creditScout(player, 1)
                end,

                -- Her ask; the carrion is only meaningful afterwards.
                [337] = function(player, csid, option, npc)
                    quest:setVar(player, 'Olavia', 1)
                end,

                [339] = function(player, csid, option, npc)
                    creditScout(player, 2)
                end,

                [343] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Scouts', 0)
                        quest:setVar(player, 'Carrion', 0)
                        quest:setVar(player, 'Olavia', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(uleguerandID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCOUTS_ASTRAY)
                    end
                end,
            },
        },
    },

    -- Completed: 8053, he may need them brought in line again.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Rondipur'] = quest:event(344):replaceDefault(),
        },
    },
}

return quest
