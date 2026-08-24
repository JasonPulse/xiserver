-----------------------------------
-- The Whole Place Is Abuzz
-----------------------------------
-- Log ID: 9, Quest ID: 58
-- Rumin-Flumin      : Yahse Hunting Grounds (H-9), entity 17842724
-- Pollinating Swarm : Yahse Hunting Grounds (G-10), entity 17842723
-- Ndah Tolohjin     : Eastern Adoulin, entity 17830098
-- !addquest 9 58
-----------------------------------
-- Retail (bg-wiki "The Whole Place Is Abuzz").
-- |Start=Rumin-Flumin, Yahse Hunting Grounds (H-9)  |Fame=Adoulin
--   1. "Talk to Rumin-Flumin (H-9) Bivouac #3 in Yahse Hunting Grounds to obtain the
--      Land of Milk and Honey hive."
--   2. "Run southwest a bit to the Pollinating Swarm at (G-10)."
--   3. "Click on the Pollinating Swarm and then /heal until it counts 10 bees caught,
--      then stand up."
--   4. "Click on the Pollinating Swarm again to receive the key item Full Land of
--      Milk and Honey hive."
--   5. "Finally talk to Ndah Tolohjin (North) outside the Scouts' Coalition to
--      receive your reward."
--
-- THE TURN-IN IS NOT THE GIVER. bg-wiki is explicit that Rumin-Flumin hands out the
-- hive but Ndah Tolohjin in Eastern Adoulin pays, and speaking to Rumin-Flumin again
-- is marked optional, so the reward hangs off Ndah Tolohjin.
--
-- HOW THE BEE COUNT IS MODELLED. Retail wants the player to sit at the swarm and rest
-- while ten bees accumulate. The server sees the resting state, not a per-bee tick,
-- so the swarm checks that the player is actually healing and then counts a bee per
-- examine, requiring ten. bg-wiki publishes no timing, so this reproduces the
-- outcome, ten bees gathered while resting at the swarm, rather than inventing a
-- tick rate.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_WHOLE_PLACE_IS_ABUZZ)

local swarm      = 17842723
local beesWanted = 10

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

local swarmActions =
{
    onTrigger = function(player, npc)
        if
            npc:getID() ~= swarm or
            not player:hasKeyItem(xi.ki.LAND_OF_MILK_AND_HONEY_HIVE)
        then
            return
        end

        local bees = quest:getVar(player, 'Bees')

        if bees >= beesWanted then
            player:delKeyItem(xi.ki.LAND_OF_MILK_AND_HONEY_HIVE)
            npcUtil.giveKeyItem(player, xi.ki.FULL_LAND_OF_MILK_AND_HONEY_HIVE)
            quest:setVar(player, 'Bees', 0)

            return true
        end

        -- "click on the Pollinating Swarm and then /heal": the bees only come to a
        -- resting pioneer.
        if not player:hasStatusEffect(xi.effect.HEALING) then
            player:printToPlayer('The swarm scatters as you approach. Perhaps they would settle if you rested a while.', xi.msg.channel.NS_SAY)

            return true
        end

        quest:setVar(player, 'Bees', bees + 1)
        player:printToPlayer(string.format('A bee settles into the hive. (%d of %d)', bees + 1, beesWanted), xi.msg.channel.NS_SAY)

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Rumin-Flumin'] =
            {
                onTrigger = function(player, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Bees', 0)
                    npcUtil.giveKeyItem(player, xi.ki.LAND_OF_MILK_AND_HONEY_HIVE)

                    return true
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Pollinating_Swarm'] = swarmActions,

            ['Rumin-Flumin'] =
            {
                onTrigger = function(player, npc)
                    if
                        not player:hasKeyItem(xi.ki.LAND_OF_MILK_AND_HONEY_HIVE) and
                        not player:hasKeyItem(xi.ki.FULL_LAND_OF_MILK_AND_HONEY_HIVE)
                    then
                        npcUtil.giveKeyItem(player, xi.ki.LAND_OF_MILK_AND_HONEY_HIVE)
                    end

                    return true
                end,
            },
        },

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Ndah_Tolohjin'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.FULL_LAND_OF_MILK_AND_HONEY_HIVE) then
                        return
                    end

                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.FULL_LAND_OF_MILK_AND_HONEY_HIVE)
                    end

                    return true
                end,
            },
        },
    },
}

return quest
