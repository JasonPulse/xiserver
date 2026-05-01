-----------------------------------
-- Seeing Blood-red (SCH AF3)
-----------------------------------
-- Log ID: 7, Quest ID: 34
-- Erlene : The Eldieme Necropolis [S]
-- Indescript Markings : Pashhow Marshlands [S]
-- Ulbrecht : Ruhotz Silvermines
-----------------------------------
-- SCH AF3 — SCH's Artifact Armor head piece (Scholar's Mortarboard).
-- Tracked in JOB_FIXES_TODO.md. Implementation blocked on !cs CSID
-- verification at Erlene in Eldieme Necropolis [S] (candidates 10, 11,
-- 12, 13, 14, 29, 31, 32, 34 — see JOB_FIXES_TODO.md).
-----------------------------------
-- Stub for now: accept via Erlene → complete (no actual AF3 grant).
-- Once CSIDs are verified in-game, wire up the full chain:
--   Erlene event (offer) -> Indescript Markings (letter pickup) ->
--   Ruhotz Silvermines instance vs Ulbrecht -> Erlene (reward).
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SEEING_BLOOD_RED)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.SANDORIA,
}

quest.sections =
{
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
                    return quest:progressEvent(34)
                end,
            },

            onEventFinish =
            {
                [34] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
