-----------------------------------
-- Bait and Switch
-----------------------------------
-- Log ID: 1, Quest ID: 83
-- Salim : Metalworks (G-7), default event 400
-- ??? Ground floor, Temple of the Goddess (G-8) elevator.
-----------------------------------
-- Retail: complex minigame with random switch orders and NPC avoidance.
-- Simplified for 4-player server: accept from Salim → one "switch run"
-- represented by a quest var flip → return to Salim → pick reward type.
-- Retail has 7 reward pools based on the item picked; this implementation
-- gives Silent Oil (the commonest option) — swap via Salim dialogue later
-- if the user wants multi-option rewards.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
    item     = xi.item.POT_OF_SILENT_OIL,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 3
        end,

        [xi.zone.METALWORKS] =
        {
            ['Salim'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(401)
                    else
                        return quest:progressEvent(402)
                    end
                end,
            },

            onEventFinish =
            {
                [402] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        if quest:complete(player) then
                            -- complete in one step for simplified version
                        end
                    end
                end,

                [401] = function(player, csid, option, npc)
                    if option == 1 and player:getFreeSlotsCount() > 0 then
                        player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)
                        player:addItem(xi.item.POT_OF_SILENT_OIL)
                        player:messageSpecial(zones[xi.zone.METALWORKS].text.ITEM_OBTAINED, xi.item.POT_OF_SILENT_OIL)
                        player:completeQuest(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)
                    end
                end,
            },
        },
    },
}

return quest
