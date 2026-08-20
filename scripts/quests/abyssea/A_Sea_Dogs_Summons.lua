-----------------------------------
-- A Sea Dog's Summons
-----------------------------------
-- !addquest 8 180
-- Flagged on completion of Champions of Abyssea.
-- Zone into the Hall of the Gods between 18:00 and 5:00. Flags Death and Rebirth upon completion.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_SEA_DOGS_SUMMONS)

quest.reward = {}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                -- bg-wiki: "between the hours of 18:00 and 05:00 (dusk to dawn)".
                -- This was `>= 18 and < 5`, which no hour can satisfy, so the
                -- section never registered and the step was unreachable. The
                -- correct form is already used by Death_and_Rebirth.lua:71 and
                -- Emissaries_of_God.lua:76 in this same directory.
                (VanadielHour() >= 18 or VanadielHour() < 5)
        end,

        [xi.zone.HALL_OF_THE_GODS] =
        {
            onZoneIn = function(player, prevZone)
                return 6
            end,

            onEventFinish =
            {
                [6] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DEATH_AND_REBIRTH)
                    end
                end,
            },
        },
    },
}

return quest
