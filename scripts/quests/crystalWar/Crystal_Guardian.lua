-----------------------------------
-- Crystal Guardian
-----------------------------------
-- Log ID: 7, Quest ID: 96
-- Provenance_Protocrystal : Provenance, entities 17686587 / 17686594
-- Regal_Pawprints         : Provenance, entity 17686642
-- !addquest 7 96
-----------------------------------
-- Retail (bg-wiki "Crystal Guardian").
-- Step seventeen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Provenance  |Next=Endings and Beginnings
--   1. "With the three key item petrifacts in possession from the previous quest,
--      examine the Provenance Protocrystal in Provenance to engage and defeat
--      Provenance Watcher."
--      "All members of the alliance will need all three of the key item petrifacts to
--       participate, and they are lost on entry."
--   2. "Check the Regal Pawprints upon victory for a cutscene which ends this quest
--      and begins the next quest automatically."
--
-- The Protocrystal owns csids 1 (1403 bytes) and 22 (1259). 1 is the entry, 22 the
-- variant. Provenance Watcher is a real mob, placed in zone 222, so the fight itself
-- is the battlefield system's business and this quest only watches for the kill.
--
-- "They are lost on entry" is why the three petrifacts are surrendered at the
-- Protocrystal rather than at the Pawprints afterwards.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.CRYSTAL_GUARDIAN)

local protocrystals =
{
    [17686587] = true,
    [17686594] = true,
}

local provenancePawprints = 17686642
local entryCsid           = 1
local victoryCsid         = 24

local petrifacts =
{
    xi.ki.BEGUILING_PETRIFACT,
    xi.ki.SEDUCTIVE_PETRIFACT,
    xi.ki.MADDENING_PETRIFACT,
}

local hasAllPetrifacts = function(player)
    for _, ki in ipairs(petrifacts) do
        if not player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PROVENANCE] =
        {
            ['Provenance_Protocrystal'] =
            {
                onTrigger = function(player, npc)
                    if
                        not protocrystals[npc:getID()] or
                        not hasAllPetrifacts(player)
                    then
                        return
                    end

                    return quest:progressEvent(entryCsid)
                end,
            },

            -- "Defeat Provenance Watcher." The kill is what the Pawprints then
            -- respond to.
            ['Provenance_Watcher'] =
            {
                onMobDeath = function(mob, player, optParams)
                    quest:setVar(player, 'Slain', 1)
                end,
            },

            ['Regal_Pawprints'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= provenancePawprints or
                        quest:getVar(player, 'Slain') ~= 1
                    then
                        return
                    end

                    return quest:progressEvent(victoryCsid)
                end,
            },

            onEventFinish =
            {
                [entryCsid] = function(player, csid, option, npc)
                    -- "They are lost on entry."
                    for _, ki in ipairs(petrifacts) do
                        player:delKeyItem(ki)
                    end
                end,

                [victoryCsid] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Slain', 0)
                    end
                end,
            },
        },
    },
}

return quest
