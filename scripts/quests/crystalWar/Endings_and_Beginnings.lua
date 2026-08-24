-----------------------------------
-- Endings and Beginnings
-----------------------------------
-- Log ID: 7, Quest ID: 97
-- Planar_Rift : Provenance, entity 17686643
-- !addquest 7 97
-----------------------------------
-- Retail (bg-wiki "Endings and Beginnings").
-- Step eighteen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Crystal Guardian  |Next=Ad Infinitum
--   "Exit Provenance through the Planar Rift back to Walk of Echoes for a final
--    cutscene which ends this quest and begins the next quest."
--
-- The Provenance Planar Rift owns csids 15 (97 bytes) and 23 (742). 23 is the
-- substantial one and is what the departure cutscene uses; 15 is the short prompt.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.ENDINGS_AND_BEGINNINGS)

local provenanceRift = 17686643
local departureCsid  = 23

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PROVENANCE] =
        {
            ['Planar_Rift'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= provenanceRift then
                        return
                    end

                    return quest:progressEvent(departureCsid)
                end,
            },

            onEventFinish =
            {
                [departureCsid] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
