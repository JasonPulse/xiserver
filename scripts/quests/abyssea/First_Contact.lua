-----------------------------------
-- First Contact
-----------------------------------
-- !addquest 8 167
-- qm3 : !pos -179 8 254 102
-- Flagged on completion of Dawn of Death.
-- Click ??? in La Theine Plateau between 18:00 and 5:00. Flags An Officer and a Pirate upon completion.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FIRST_CONTACT)

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

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            ['qm3'] = quest:progressEvent(11),

            onEventFinish =
            {
                [11] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_OFFICER_AND_A_PIRATE)
                    end
                end,
            },
        },
    },
}

return quest
