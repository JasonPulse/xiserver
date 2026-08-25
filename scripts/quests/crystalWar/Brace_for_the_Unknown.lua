-----------------------------------
-- Brace for the Unknown
-----------------------------------
-- Log ID: 7, Quest ID: 94
-- Regal_Pawprints : Walk of Echoes, entity 17523321
-- !addquest 7 94
-----------------------------------
-- Retail (bg-wiki "Brace for the Unknown").
-- Step fifteen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Glimmer of Hope  |Next=Provenance
-- |Reward=KI Clairvoy ant, Provenance access
--   1. "Choose to warp to ???? during the previous quest's cutscene to be transported
--      to Provenance. If you chose not to warp, return to the glimmering ??? after
--      the cutscene ends and choose the warp option."
--   2. "After a lengthy cutscene in Provenance, you will be rewarded with a
--      Clairvoy ant and Provenance access."
--
-- The glimmer's own blocks are one-byte stubs (see Glimmer_of_Hope.lua), so the warp
-- offer is driven from here. The arrival cutscene in Provenance is the Regal
-- Pawprints' csid 14, a 20,262-byte program that is by far the largest thing in the
-- zone and the only candidate for "a lengthy cutscene".
--
-- The key item is spelled CLAIRVOY_ANT in the enum, matching bg-wiki's own odd
-- rendering of "Clairvoy ant".
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BRACE_FOR_THE_UNKNOWN)

local woeGlimmer          = 17523321
local provenancePawprints = 17686642
local arrivalCsid         = 14

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WALK_OF_ECHOES] =
        {
            ['Regal_Pawprints'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= woeGlimmer then
                        return
                    end

                    -- bg-wiki: the glimmer offers the warp again if it was declined.
                    player:setPos(0, 0, 0, 0, xi.zone.PROVENANCE)

                    return quest:noAction()
                end,
            },
        },

        [xi.zone.PROVENANCE] =
        {
            ['Regal_Pawprints'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= provenancePawprints then
                        return
                    end

                    return quest:progressEvent(arrivalCsid)
                end,
            },

            onEventFinish =
            {
                [arrivalCsid] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.CLAIRVOY_ANT)
                    end
                end,
            },
        },
    },
}

return quest
