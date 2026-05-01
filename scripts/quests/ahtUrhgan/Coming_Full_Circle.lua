-----------------------------------
-- Coming Full Circle
-----------------------------------
-- Log ID: 6, Quest ID: 73
-- Completion via Caedarva Mire tombstone (zone-in flag used as surrogate)
-----------------------------------
-- Mythic chain #4 (final). Retail: trade statless Mythic + relief shard
-- at Caedarva tombstone for the completed lv75 Mythic Weapon. Simplified
-- for 4-player server: zone into Caedarva Mire → complete via Paparoon.
-- Mythic weapon grant is abstracted — swap to real completion step when
-- the Mythic reward pipeline is wired up.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.COMING_FULL_CIRCLE)

quest.reward =
{
    fame     = 80,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FORGING_A_NEW_MYTH)
        end,

        [xi.zone.NASHMAU] =
        {
            ['Paparoon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(230)
                end,
            },

            onEventFinish =
            {
                [230] = function(player, csid, option, npc)
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
