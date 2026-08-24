-----------------------------------
-- Provenance
-----------------------------------
-- Log ID: 7, Quest ID: 95
-- Regal_Pawprints : Provenance, entity 17686642
-- !addquest 7 95
-----------------------------------
-- Retail (bg-wiki "Provenance (Quest)").
-- Step sixteen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Brace for the Unknown  |Next=Crystal Guardian
--   1. "Obtain the following three key items: Beguiling petrifact, Seductive
--      petrifact, Maddening petrifact." Each is bought for 330,000 cruor from a
--      Voidwatch officer, drops rarely from the matching Voidwatch battles, or is
--      guaranteed from the matching Radiance.
--   2. "After obtaining ONE of the petrifacts, examine the Regal Pawprints in
--      Provenance for a cutscene."
--   3. "With TWO in possession, examine the Regal Pawprints for another cutscene."
--
-- The Regal Pawprints own two blocks: 14 is the 20,262-byte arrival cutscene used by
-- the previous step, and 24 is an 83-byte follow-up. 24 is what the one-petrifact and
-- two-petrifact check-ins use; it is short because it is a brief remark rather than a
-- set piece.
--
-- Acquiring the petrifacts themselves is the Voidwatch economy's job (officer
-- purchase, battle drops, Radiance NMs) and is deliberately not duplicated here.
-- This quest only watches for them.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.PROVENANCE)

local provenancePawprints = 17686642
local checkInCsid         = 24

local petrifacts =
{
    xi.ki.BEGUILING_PETRIFACT,
    xi.ki.SEDUCTIVE_PETRIFACT,
    xi.ki.MADDENING_PETRIFACT,
}

local petrifactsHeld = function(player)
    local held = 0

    for _, ki in ipairs(petrifacts) do
        if player:hasKeyItem(ki) then
            held = held + 1
        end
    end

    return held
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PROVENANCE] =
        {
            ['Regal_Pawprints'] =
            {
                onTrigger = function(player, npc)
                    local held = petrifactsHeld(player)

                    -- One cutscene at one petrifact, another at two, and the third
                    -- carries the quest into Crystal Guardian.
                    if
                        npc:getID() ~= provenancePawprints or
                        held == 0 or
                        held <= quest:getVar(player, 'Seen')
                    then
                        return
                    end

                    return quest:progressEvent(checkInCsid, held)
                end,
            },

            onEventFinish =
            {
                [checkInCsid] = function(player, csid, option, npc)
                    local held = petrifactsHeld(player)

                    quest:setVar(player, 'Seen', held)

                    if held >= #petrifacts then
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
