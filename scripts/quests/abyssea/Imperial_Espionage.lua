-----------------------------------
-- Imperial Espionage
-----------------------------------
-- Log ID: 8, Quest ID: 70
-- Tyamah       : Abyssea - Uleguerand (F-7), entity 17814102
-- Purere       : Abyssea - Uleguerand, entity 17814103
-- Latifah      : Abyssea - Uleguerand, entity 17814104
-- Valderotaux  : Abyssea - Uleguerand, entity 17814105
-- Polly        : Abyssea - Uleguerand, entity 17814106
-- !addquest 8 70
-----------------------------------
-- Retail (bg-wiki "Imperial Espionage").
-- |Start=Tyamah (A), Abyssea - Uleguerand  |Next=Imperial Espionage II
-- |Reward=1,000 Cruor
--   1. Talk to Tyamah (A) at (F-7) Conflux #7.
--   2. Speak to four NPCs: Purere (A) at the same Conflux as Tyamah, Latifah (A)
--      at Conflux #6, Valderotaux (A) at Conflux #5 (through the southern
--      tunnel), and Polly (A) at Conflux #1.
--   3. Return to Tyamah (A) for your reward.
--
-- CSIDS DECODED, NOT GUESSED. Tyamah is 17814102 -> zone 253 idx 598
-- (0x010FD256), and the four witnesses sit on the next four indices, 599-602.
-- `xi-dat events 253` plus csidscan.py against `xi-dat dialog 253`:
--   Tyamah 288 -> 7943       his line before the quest ("I could tell you what
--          I'm doing here, but then I'd have to kill you.")
--   Tyamah 289 -> 7943-7951  THE OFFER. 7946 is the accept prompt: "Offer your
--          aid? ${selection-lines} Gladly. / I think not." -- "Gladly." is the
--          FIRST line, so OPTION 0 ACCEPTS. 7949 carries the task: "I have been
--          charged with investigating the current condition of the four nations
--          of Altana...or what remains of them", and 7951 "any and all details
--          are vital to those who employ my services."
--   Tyamah 290 -> 7949-7951  the reminder, the task without the introduction.
--   Tyamah 295 -> 7956-7959  THE TURN-IN. "Was your reconnaissance mission a
--          fruitful one?" / "you've made yourself most useful. Take this in
--          return."
--   Tyamah 296 -> 7960/7961  his post-completion lines.
--   Tyamah 297 -> 7946 + 7962-7969  this is IMPERIAL ESPIONAGE II, in which he
--          has lost his mind and wants parts of Abyssean fiends. Not used here.
--   Purere      291 -> 7952  Windurst: the Great Star Tree engulfed in flames.
--   Latifah     292 -> 7953  Bastok: the airship into the Metalworks.
--   Valderotaux 293 -> 7954  San d'Oria: Victory Gate breached.
--   Polly       294 -> 7955  the clock tower and the bridge coming down.
-- One csid each, no prompts, which is why the four accounts are tracked
-- server-side rather than by the events themselves.
--
-- THE FOUR NATIONS ARE THE FOUR WITNESSES. 7949 asks after "the four nations of
-- Altana", and 7952-7955 are exactly four first-hand accounts, one per nation
-- (Windurst, Bastok, San d'Oria, and the fourth survivor's unnamed home). That
-- is the pairing bg-wiki's four NPCs describe.
--
-- PROGRESS is a four-bit mask in the quest var 'Reports', one bit per witness,
-- so they can be visited in any order and none can be counted twice.
-----------------------------------
local uleguerandID = zones[xi.zone.ABYSSEA_ULEGUERAND]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.IMPERIAL_ESPIONAGE)

local cruorReward = 1000

-- witness NPC name -> { bit, csid }
local witnesses =
{
    ['Purere']      = { 0, 291 },
    ['Latifah']     = { 1, 292 },
    ['Valderotaux'] = { 2, 293 },
    ['Polly']       = { 3, 294 },
}

local allReports = 0x0F -- four bits

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

-- Every witness behaves identically: show their account, and credit it once.
local witnessTrigger = function(name)
    return function(player, npc)
        local entry = witnesses[name]
        local mask  = quest:getVar(player, 'Reports')

        if bit.band(mask, bit.lshift(1, entry[1])) == 0 then
            quest:setVar(player, 'Reports', bit.bor(mask, bit.lshift(1, entry[1])))
        end

        return quest:event(entry[2])
    end
end

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Tyamah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(289)
                end,
            },

            onEventFinish =
            {
                [289] = function(player, csid, option, npc)
                    -- 7946: 0 "Gladly.", 1 "I think not."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Reports', 0)
                end,
            },
        },
    },

    -- Accepted: hear all four accounts, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Purere']      = { onTrigger = witnessTrigger('Purere') },
            ['Latifah']     = { onTrigger = witnessTrigger('Latifah') },
            ['Valderotaux'] = { onTrigger = witnessTrigger('Valderotaux') },
            ['Polly']       = { onTrigger = witnessTrigger('Polly') },

            ['Tyamah'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Reports') == allReports then
                        return quest:progressEvent(295)
                    end

                    return quest:event(290)
                end,
            },

            onEventFinish =
            {
                [295] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Reports', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(uleguerandID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    -- Completed: 7960/7961, "Please leave me alone with my thoughts for a while."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Tyamah'] = quest:event(296):replaceDefault(),
        },
    },
}

return quest
