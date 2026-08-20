-----------------------------------
-- Missing in Action
-----------------------------------
-- Log ID: 8, Quest ID: 48
-- Iron_Eater : Abyssea - Misareaux (K-7), entity 17662725
-- Fariel     : Abyssea - Misareaux, entity 17662726
-- Mathurin   : Abyssea - Misareaux, entity 17662727
-- Quasim     : Abyssea - Misareaux, entity 17662728
-- !addquest 8 48
-----------------------------------
-- Retail (bg-wiki "Missing in Action").
-- |Start=Iron Eater (A), Abyssea - Misareaux (K-7)  |Reward=1,200 Cruor
--   1. Speak to Iron Eater (A) at (K-7) to activate the quest and receive
--      Iron Eater's pearlsack.
--   2. Travel to Conflux #3 and speak to Mathurin (A).
--   3. Travel to Conflux #5, northeast corner of (G-5), and speak to Quasim (A).
--   4. Travel to Conflux #6, northwest corner of (G-8), and speak to Fariel (A).
--   5. Return and speak to Iron Eater (A).
--
-- CSIDS DECODED, NOT GUESSED. Every program in this zone sits on holder
-- 17662724 (0x010D8304) with 1-byte stubs on the visible NPCs, so csidmsg.py and
-- csidscan.py both come back empty against the NPCs themselves -- the holder is
-- what resolves them:
--   Iron_Eater 151 -> 8137-8150  THE OFFER. 8142 "I was hoping that you could go
--          out there and locate the stranded soldiers in our stead", 8143 is the
--          accept prompt: "Help find the stranded soldiers? ${selection-lines}
--          Just leave it to me! / I'm not in a charitable mood." -- the
--          affirmative is FIRST, so OPTION 0 ACCEPTS, and 8145/8146 are the
--          decline. 8147 introduces him ("I'm Iron Eater, a musketeer of the old
--          Republic"), 8148 hands over the pearlsack, and 8149 states the task:
--          "If you give one to each group of my people you find afield..."
--   Iron_Eater 152 -> 8151/8152  the reminder while the search is running.
--   Iron_Eater 162 -> 8186-8191  THE COMPLETION. "Thanks to your invaluable aid,
--          we were able to regain contact with the stranded soldiers."
--   Iron_Eater 163 -> 8192       the post-completion line.
--
-- THE THREE SOLDIERS each own a clean triple, and their event lists line up
-- one-for-one, which is what pins the roles:
--   Fariel   17662726 -> 153, 156, 159
--   Mathurin 17662727 -> 154, 157, 160
--   Quasim   17662728 -> 155, 158, 161
-- In each triple the first is the pre-quest brush-off (Fariel's 153 -> 8153-8156
-- "You're not of the regiment, I gather"), the second is the linkpearl handover
-- (Fariel's 156 -> 8157-8165, opening on 8157 "Who goes there!?" and 8158 "What?
-- Iron Eater sent you to look for us?"), and the third is the already-contacted
-- line (Fariel's 159 -> 8164/8165).
--
-- PROGRESS is a three-bit mask in the quest var 'Contacted', one bit per
-- soldier, so the three can be visited in any order and none double-counts.
-- bg-wiki lists them in Conflux order 3/5/6 (Mathurin, Quasim, Fariel) but
-- nothing in the dialog enforces a sequence.
--
-- KEY ITEM: Iron Eater's pearlsack is the existing IRON_EATERS_PEARLSACK (1633).
-- Note the separate ESPIONAGE_PEARLSACK (1637) is a different key item.
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MISSING_IN_ACTION)

local cruorReward = 1200

-- entity -> { bit, idleCsid, giveCsid, doneCsid }
local soldiers =
{
    [17662726] = { bit = 0, idle = 153, give = 156, done = 159 }, -- Fariel
    [17662727] = { bit = 1, idle = 154, give = 157, done = 160 }, -- Mathurin
    [17662728] = { bit = 2, idle = 155, give = 158, done = 161 }, -- Quasim
}

local allContacted = 0x07

local soldierTrigger = function(player, npc)
    local entry = soldiers[npc:getID()]
    if entry == nil then
        return
    end

    local mask = quest:getVar(player, 'Contacted')
    if bit.band(mask, bit.lshift(1, entry.bit)) ~= 0 then
        return quest:event(entry.done)
    end

    return quest:progressEvent(entry.give)
end

local soldierFinish = function(player, csid, option, npc)
    for _, entry in pairs(soldiers) do
        if entry.give == csid then
            local mask = quest:getVar(player, 'Contacted')
            quest:setVar(player, 'Contacted', bit.bor(mask, bit.lshift(1, entry.bit)))
            return
        end
    end
end

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Iron_Eater'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(151)
                end,
            },

            ['Fariel']   = quest:event(153),
            ['Mathurin'] = quest:event(154),
            ['Quasim']   = quest:event(155),

            onEventFinish =
            {
                [151] = function(player, csid, option, npc)
                    -- 8143: 0 "Just leave it to me!", 1 "I'm not in a charitable mood."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Contacted', 0)
                    npcUtil.giveKeyItem(player, xi.ki.IRON_EATERS_PEARLSACK)
                end,
            },
        },
    },

    -- Accepted: hand a linkpearl to each of the three groups, in any order.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Fariel']   = { onTrigger = soldierTrigger },
            ['Mathurin'] = { onTrigger = soldierTrigger },
            ['Quasim']   = { onTrigger = soldierTrigger },

            ['Iron_Eater'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Contacted') == allContacted then
                        return quest:progressEvent(162)
                    end

                    return quest:event(152)
                end,
            },

            onEventFinish =
            {
                [156] = soldierFinish,
                [157] = soldierFinish,
                [158] = soldierFinish,

                [162] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Contacted', 0)
                        player:delKeyItem(xi.ki.IRON_EATERS_PEARLSACK)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Iron_Eater'] = quest:event(163):replaceDefault(),
        },
    },
}

return quest
