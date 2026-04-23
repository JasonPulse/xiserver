-----------------------------------
-- Picture Perfect
-----------------------------------
-- Log ID: 4, Quest ID: 31
-- Clarion_Star : Port Bastok (verified in DefaultActions, event 442)
-----------------------------------
-- Retail: Adventuring Fellow chain quest — raised fellow level cap from 50
-- to 55. Simplified for private server: fellow API (get/setFellowValue)
-- isn't bound on this server, so cap raise is dropped. Quest still
-- completes as prereq for Regaining Trust.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.PICTURE_PERFECT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:isFellow()
        end,

        [xi.zone.PORT_BASTOK] =
        {
            ['Clarion_Star'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(443)
                end,
            },

            onEventFinish =
            {
                [443] = function(player, csid, option, npc)
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
