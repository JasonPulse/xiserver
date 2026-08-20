-----------------------------------
-- Benevolence Lost
-----------------------------------
-- Log ID: 8, Quest ID: 58
-- Rukususu : Abyssea - Grauberg (F-10), entity 17818237
-- !addquest 8 58
-----------------------------------
-- bg-wiki: |Start=Rukususu (A) (F-10)  |Previous=Voices from Beyond
-- |Item Reqs=Twinkle Powder  |Repeatable=Yes
-- |Reward=First time: 400 Cruor. Subsequent: 200 Cruor.
--   "You must zone after completing Voices from Beyond before you can start."
--   Pixies in Witchfire Glen turned hostile from water contamination; bring him
--   Twinkle Powder from one whose benevolence has been restored.
--
-- CSIDS (csidmsg.load on 17818237; same NPC as Voices_from_Beyond.lua, split by
-- entry offsets {255:1, 256:217, 257:250, 258:494, 260:515, 261:661, 262:689,
-- 263:977} -- 255-258 are that quest, 260-263 are this one):
--   260 -> 8115-8122  THE OFFER. 8117 "mon research nouveau eez regarding
--          pixies!", 8118/8119 the contamination, 8121 names the powder.
--   261 -> 8121/8122  the reminder.
--   262 -> 8128-8136  THE TURN-IN. 8129 "zis could only mean a pixie 'as
--          regained 'er former benevolence!", 8131 "Rukususu snatches the
--          ${keyitem-singular: 0[2]}", 8133 his talisman is complete.
--   263 -> 8137/8138  post-completion.
-- Powder is param 0: PINCH_OF_TWINKLE_POWDER (1241) -- bg-wiki says "Twinkle
-- Powder", item_basic name is `pinch_of_twinkle_powder`.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BENEVOLENCE_LOST)

local firstReward  = 400
local repeatReward = 200

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.VOICES_FROM_BEYOND) and
                quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(260, { [0] = xi.item.PINCH_OF_TWINKLE_POWDER })
                end,
            },

            onEventFinish =
            {
                [260] = function(player, csid, option, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BENEVOLENCE_LOST) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BENEVOLENCE_LOST)
                    else
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

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.PINCH_OF_TWINKLE_POWDER) then
                        return quest:progressEvent(262, { [0] = xi.item.PINCH_OF_TWINKLE_POWDER })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(261, { [0] = xi.item.PINCH_OF_TWINKLE_POWDER })
                end,
            },

            onEventFinish =
            {
                [262] = function(player, csid, option, npc)
                    player:confirmTrade()

                    local first = quest:getVar(player, 'Paid') == 0

                    if quest:complete(player) then
                        quest:setVar(player, 'Paid', 1)
                        local cruor = first and firstReward or repeatReward
                        player:addCurrency('cruor', cruor)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] = quest:event(263):replaceDefault(),
        },
    },
}

return quest
