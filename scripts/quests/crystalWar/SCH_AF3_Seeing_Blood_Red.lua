-----------------------------------
-- Seeing Blood-red (SCH AF3)
-----------------------------------
-- Log ID: 7, Quest ID: 34
-- Erlene : The Eldieme Necropolis [S]
-- Indescript Markings : Pashhow Marshlands [S]
-- Ulbrecht : Ruhotz Silvermines
-----------------------------------
-- SCH AF3 — Scholar's Mortarboard reward.
--
-- All 4 chain CSIDs verified 2026-06-18 via puppet bridge (Bottest in
-- Eldieme [S] firing !cs 29/31/32/34 in sequence, all screenshotted):
--
--   CSID 29 (offer)        — "track down Professor Schultz yet again /
--                             Nicolaus's clue-tracking hint"
--   CSID 31 (post-letter)  — "hold onto this letter / banishing stones
--                             = silver ore / Ruhotz Silvermines reference"
--   CSID 32 (formula)      — "Go and find that formula / sealed entry
--                             after Battle of Grauberg / port-stratagem"
--   CSID 34 (complete)     — "last graduating pupil of the Schultz
--                             School of Martial Theory / Congratulations"
--
-- The player advances through all 4 events by re-triggering Erlene at
-- each Prog. The full retail chain (Indescript_Markings letter pickup
-- in Pashhow [S], Ulbrecht fight in Ruhotz Silvermines) is collapsed
-- into Erlene-only progression for the simplified server — players
-- still see every cutscene and reach the reward, just without the
-- intermediate-zone trips.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SEEING_BLOOD_RED)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.SANDORIA,
    item     = xi.item.SCHOLARS_MORTARBOARD,
}

quest.sections =
{
    -- Offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.SCH and
                player:getMainLvl() >= 60
        end,

        [xi.zone.THE_ELDIEME_NECROPOLIS_S] =
        {
            ['Erlene'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(29)
                end,
            },

            onEventFinish =
            {
                [29] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:setVar(player, 'Prog', 1)
                    end
                end,
            },
        },
    },

    -- Accepted: chain through 31 → 32 → 34
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.THE_ELDIEME_NECROPOLIS_S] =
        {
            ['Erlene'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 then
                        return quest:progressEvent(31)
                    elseif prog == 2 then
                        return quest:progressEvent(32)
                    elseif prog == 3 then
                        return quest:progressEvent(34)
                    end
                end,
            },

            onEventFinish =
            {
                [31] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,

                [32] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 3)
                end,

                [34] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },
}

return quest
