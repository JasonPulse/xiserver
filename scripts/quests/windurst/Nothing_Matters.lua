-----------------------------------
-- Nothing Matters
-----------------------------------
-- Log ID: 2, Quest ID: 79
-- Koru-Moru : Windurst Walls (E-7)
-- Prereq: Blast from the Past (enforced via xi.quest.setMustZone in that quest)
-----------------------------------
-- Retail: Koru-Moru alchemy side quest — quiz at Acolyte Hostels,
-- trade Cold Bone + Warm Egg, wait to JP midnight for Vile Elixir.
-- Simplified for 4-player server: trade Cold Bone + Warm Egg directly,
-- receive reward immediately. Quiz portion dropped — it's 6 RNG questions
-- that only gate the bonus Vile Elixir anyway.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.NOTHING_MATTERS)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.WINDURST,
    gil      = 10000,
    item     = xi.item.VILE_ELIXIR,
    title    = xi.title.SEEKER_OF_TRUTH,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 8 and
                player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.BLAST_FROM_THE_PAST) and
                not xi.quest.getMustZone(player, xi.questLog.WINDURST, xi.quest.id.windurst.NOTHING_MATTERS)
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Koru-Moru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(350)
                end,
            },

            onEventFinish =
            {
                [350] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Koru-Moru'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npcUtil.tradeHasExactly(trade, { xi.item.COLD_BONE, xi.item.WARM_EGG })
                    then
                        return quest:progressEvent(351)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(352)
                end,
            },

            onEventFinish =
            {
                [351] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
