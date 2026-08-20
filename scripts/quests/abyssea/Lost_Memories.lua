-----------------------------------
-- Lost Memories
-----------------------------------
-- !addquest 8 9
-- Halver : !pos: 600 40 -515 132
-----------------------------------
local ID = zones[xi.zone.ABYSSEA_LA_THEINE]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOST_MEMORIES)

-- fameArea added: without it npcUtil.completeQuest never calls addFame
-- (npc_util.lua), so this quest granted ZERO fame -- despite bg-wiki describing it
-- as the fame source: "Completing this quest 8 more times gives enough fame to
-- open up Rank 6 fame quest with Glenne (A)." The area matches the gate the file
-- already uses below, xi.fameArea.ABYSSEA_LATHEINE.
quest.reward = {
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
    keyItem  = xi.ki.VIAL_OF_LAMBENT_POTION,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            -- bg-wiki |Repeatable=Yes and "Zoning is not required to repeat this
            -- quest." Both offer sections tested QUEST_AVAILABLE, but
            -- getQuestStatus returns COMPLETED (2) permanently after the first
            -- clear, so Halver went inert and the quest could be done exactly
            -- once -- on a quest whose stated purpose is repeating it 8+ times for
            -- fame. Fear_of_the_Dark_III.lua:45 in this same directory uses the
            -- correct `~= QUEST_AVAILABLE` shape for its repeat path.
            return status ~= xi.questStatus.QUEST_ACCEPTED and
            player:getFameLevel(xi.fameArea.ABYSSEA_LATHEINE) < 5
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Halver'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(162)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            -- Repeatable, as above.
            return status ~= xi.questStatus.QUEST_ACCEPTED and
            player:getFameLevel(xi.fameArea.ABYSSEA_LATHEINE) >= 5
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Halver'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(165)
                end,
            },

            onEventFinish =
            {
                [165] = function(player, csid, option, npc)
                    if option ~= 0 then
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

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Halver'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(163)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { xi.item.LAMBENT_SCALE, 2 } }) then
                        return quest:event(164)
                    end
                end,
            },

            onEventFinish =
            {
                [164] = function(player, csid, option, npc)
                    player:confirmTrade()
                    --TODO add repeat quest functionality?
                    player:addCurrency('cruor', 480)
                    player:messageSpecial(ID.text.CRUOR_TOTAL, 480, player:getCurrency('cruor'))
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
