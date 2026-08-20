-----------------------------------
-- It Never Goes Out of Style
-----------------------------------
-- Log ID: 9, Quest ID: 31
-- Veldeth : Marjami Ravine (L-7), entity 17867205
-- !addquest 9 31
-----------------------------------
-- Retail (bg-wiki "It Never Goes Out of Style").
-- |Start=Veldeth, Marjami Ravine  |Repeatable=Yes  |Fame=Seekers of Adoulin
-- |FLevel=5  |Item Reqs=Two Velkk Masks or Two Velkk Necklaces
-- |Reward=500 Experience Points
--   1. Talk to Veldeth near the Frontier Station in Marjami Ravine (L-7).
--   2. Trade Veldeth two Velkk Necklace or two Velkk Mask to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Veldeth is 17867205 -> zone 266 idx 453 (0x0110A1C5). `xi-dat events 266` gives
-- him 38-44 and 62. The dumped dialog file labelled zone N holds zone N-1's text
-- for the Adoulin zones, so Marjami's text is in the file labelled 267; that
-- offset is pinned by this repo's own known-correct ids (Marjami_Ravine/IDs.lua
-- WAYPOINT_ATTUNED = 7705 resolves in dump file 267, not 266). Read against 267:
--   38 -> 7815  NOT A REGISTERED PIONEER. "A stranger in these lands, without so
--         much as ${keyitem-article: 0[2]} to prove ${choice-player-gender}
--         [his/her] worth. Begone until you have procured the requisite
--         authentication." -- the key item is the Pioneer's badge.
--   39 -> 7816  REGISTERED BUT NOT FAMOUS ENOUGH. "A registered pioneer you may
--         be, but I have never heard so much as a peep about your exploits." --
--         this is bg-wiki's |FLevel=5 talking.
--   40 -> 7817-7823  THE OFFER. 7817 "I, Veldeth, am the Peacekeepers' eyes and
--         ears here in Marjami Ravine", and 7819 carries the request: "A total of
--         ${number: 2} ${item-plural: 0[2]} or ${item-plural: 1[2]} should
--         suffice." No ${selection-lines}, so speaking to him starts it.
--   41 -> 7824-7828  THE TURN-IN. "Yes, these will do nicely. Excellent work." /
--         7827 "I have avenged my wife, and hopefully she can be at peace."
--   42 -> 7829  the repeat offer: "Should you happen to come across
--         ${item-plural: 0[2]} or ${item-plural: 1[2]} again, you only need bring
--         them to me."
--   43 -> 7819  the reminder, the request on its own.
--   44 -> 7824/7829  the short turn-in used on repeat runs.
--   62 -> 8213-8224  an unrelated block on this entity, not this quest.
--
-- THE ITEMS AND THE COUNT ARE THE EVENT'S OWN. 7819 renders two item names and a
-- number, which looked like three params. csidmsg.load() shows the block carries
-- its own data[] and reads them out of it:
--     data = [29, 2157, 3928, 3929, 2, 1, 201, 0, 20, 230]
-- 3928 = Velkk necklace, 3929 = Velkk mask, and 2 is the count -- exactly
-- bg-wiki's "Two Velkk Masks or Two Velkk Necklaces". 2157 is the Pioneer's badge
-- key item that 7815 refers to. So the events fire bare.
--
-- THE 2157 / 3928 / 3929 DISAMBIGUATION MATTERS: 2157 is BOTH item id 2157
-- (Imp Horn) and key item id 2157 (Pioneer's badge). The placeholder decides it --
-- 7815 uses ${keyitem-article}, so it is the key item. 3928/3929 appear under
-- ${item-plural}, so those are items. Checked by id in both enums, not by name.
--
-- GATES: bg-wiki |FLevel=5 with |Fame=Seekers of Adoulin, plus the badge that
-- 7815 demands. Both are enforced, and each has its own brush-off event, which is
-- why this quest has two "you may not start" csids rather than one.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.IT_NEVER_GOES_OUT_OF_STYLE)

local velkkCount = 2 -- data[4] of Veldeth's event block

quest.reward =
{
    exp      = 500,
    fameArea = xi.fameArea.ADOULIN,
}

local tradedVelkkGear = function(trade)
    return npcUtil.tradeHasExactly(trade, { { xi.item.VELKK_NECKLACE, velkkCount } }) or
        npcUtil.tradeHasExactly(trade, { { xi.item.VELKK_MASK, velkkCount } })
end

quest.sections =
{
    -- Not yet a registered pioneer: 7815 sends you away for the badge.
    {
        check = function(player, status, vars)
            return status ~= xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.PIONEERS_BADGE)
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Veldeth'] = quest:event(38):replaceDefault(),
        },
    },

    -- Badged but under the fame bar: 7816.
    {
        check = function(player, status, vars)
            return status ~= xi.questStatus.QUEST_ACCEPTED and
                player:getFameLevel(xi.fameArea.ADOULIN) < 5
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Veldeth'] = quest:event(39):replaceDefault(),
        },
    },

    -- Eligible. COMPLETED is accepted because |Repeatable=Yes; 42 is his re-offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Veldeth'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.IT_NEVER_GOES_OUT_OF_STYLE) then
                        return quest:progressEvent(42)
                    end

                    return quest:progressEvent(40)
                end,
            },

            onEventFinish =
            {
                [40] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [42] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.IT_NEVER_GOES_OUT_OF_STYLE)
                end,
            },
        },
    },

    -- Accepted: two of either piece of Velkk gear.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Veldeth'] =
            {
                onTrade = function(player, npc, trade)
                    if tradedVelkkGear(trade) then
                        return quest:progressEvent(41)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(43)
                end,
            },

            onEventFinish =
            {
                [41] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
