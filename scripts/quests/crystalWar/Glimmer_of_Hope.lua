-----------------------------------
-- Glimmer of Hope
-----------------------------------
-- Log ID: 7, Quest ID: 93
-- Veridical_Conflux : Pashhow Marshlands [S] (J-9), entity 17146658
-- Regal_Pawprints   : Walk of Echoes, entity 17523321
-- !addquest 7 93
-----------------------------------
-- Retail (bg-wiki "Glimmer of Hope").
-- Step fourteen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Third Tour of Duchy  |Next=Brace for the Unknown
-- |Reward=KI Kupofried's corundum
--   1. "With at least one voidstone in possession, proceed to the Veridical Conflux in
--      Pashhow Marshlands (S) to warp to Walk of Echoes."
--   2. "Once inside, click the ??? glimmer where you enter the zone to begin a
--      cutscene in which your voidstone will be exchanged for a Kupofried's corundum
--      (the next quest will begin automatically)."
--
-- THE GLIMMER IS THE WALK OF ECHOES REGAL PAWPRINTS, entity 17523321, whose three
-- blocks (124, 126, 128) are all ONE BYTE, i.e. stubs. Nothing in the zone carries a
-- matching program, so the exchange is performed here as a plain key-item swap rather
-- than by firing a csid that does not exist.
--
-- VOIDSTONES ARE SIX SEPARATE KEY ITEMS (1539-1544), one per tier, and bg-wiki asks
-- only for "at least one". The first one held is the one surrendered. Kupofried's
-- corundum is likewise three ids; the first is granted, matching the first corundum
-- a player earns.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.GLIMMER_OF_HOPE)

local woeGlimmer = 17523321

local voidstones =
{
    xi.ki.VOIDSTONE1,
    xi.ki.VOIDSTONE2,
    xi.ki.VOIDSTONE3,
    xi.ki.VOIDSTONE4,
    xi.ki.VOIDSTONE5,
    xi.ki.VOIDSTONE6,
}

--- The first voidstone the player is carrying, or nil.
local heldVoidstone = function(player)
    for _, ki in ipairs(voidstones) do
        if player:hasKeyItem(ki) then
            return ki
        end
    end

    return nil
end

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
                    local stone = heldVoidstone(player)

                    if npc:getID() ~= woeGlimmer or stone == nil then
                        return
                    end

                    player:delKeyItem(stone)

                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.KUPOFRIEDS_CORUNDUM_1)
                    end

                    return quest:noAction()
                end,
            },
        },
    },
}

return quest
