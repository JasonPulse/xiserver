-----------------------------------
-- Royal Painter Escort
-----------------------------------
-- Log ID: 6, Quest ID: 102
-- Halshaob : Nashmau (H-10)
-----------------------------------
-- Ashu Talif pirate chain quest. Retail: pay Imperial currency, fight
-- pirate crew NMs in Arrapago Reef pirate ship BCNM. Repeatable daily.
-- Simplified for 4-player server: accept + immediate complete. BCNM
-- and NM drops (Barbarossa/Koga gear) skipped.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.ROYAL_PAINTER_ESCORT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.SCOUTING_THE_ASHU_TALIF)
        end,

        [xi.zone.NASHMAU] =
        {
            ['Halshaob'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(510)
                end,
            },

            onEventFinish =
            {
                [510] = function(player, csid, option, npc)
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
