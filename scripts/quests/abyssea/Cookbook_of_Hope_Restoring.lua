-----------------------------------
-- Cookbook of Hope Restoring
-----------------------------------
-- Log ID: 8, Quest ID: 52
-- Jonette : Abyssea - Misareaux (G-7), entity 17662734
-- qm      : Abyssea - Misareaux, entities 17662735 / 17662738
-- !addquest 8 52
-----------------------------------
-- Retail (bg-wiki "Cookbook of Hope Restoring").
-- |Start=Jonette (A), Abyssea - Misareaux  |Fame=amis |FLevel=1
-- |Item Reqs=KI Torn recipe page  |Repeatable=Yes
-- |Reward=First time: 400 Cruor. Subsequent: 200 Cruor. Chance at an Empyrean +1
--         LEGS seal (Orison/Raider's/Ferine/Unkai).
--   1. "Speak to Jonette (A) at (G-7) by Conflux #3."
--   2. "Interact with the ??? that can appear at the following spots to receive a KI
--      Torn recipe page:
--        Amongst spiders at (I-7), by Conflux #0
--        Amongst colibris (H-8)
--        Amongst peistes (J-11)
--        Amongst bugards (K-11), northwest of Conflux #8
--      The ??? moves every 10 minutes in the order above."
--   3. "Return to Jonette (A) for your reward."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Jonette's own blocks are ONE BYTE each, i.e. stubs;
-- the real programs live on the unnamed HOLDER entity 17662724 ('010d8300'), which
-- carries 186-199 for Soil and Green and 210-214 for this quest. Per-csid attribution
-- from that holder's byte ranges:
--   210 -> 8259-8262  THE OFFER. "I used to work a kitchen before the world as we
--          knew it fell to pieces" / "When we evacuated our homes, I was carrying a
--          sack, inside of which was a cookbook of recipes fit to feast royalty."
--   211 -> 8262-8265  the reminder, ending on "could you be a dear and find my
--          cookbook? After all, if folk can't depend on one another nowada[ys]".
--   212 -> 8266-8268  THE TURN-IN. "Oh, dearie me! This ${keyitem-singular: 1[2]} is
--          from my cookbook!" / "It must've gotten ripped out at some point in time.
--          Not what I was hoping for, but I suppose it's better than nothing."
--   213 -> 8269  her post-completion line, "Thanks for bringing me the recipe."
--   214 -> 8270  the other post line, "the ingredients for the recipe you brought
--          can't be had anymore. If only I had my cookbook in its entire[ty]."
--
-- THE ??? HAVE NO EVENT PROGRAMS, so picking the page up is a plain key-item grant
-- rather than a cutscene, the same shape the event-less Supply Points in Attohwa use.
--
-- ONLY TWO ??? EXIST, not the four bg-wiki describes. npc_list places exactly two
-- entities named 'qm' with the display name '???' in this zone, 17662735 at
-- (213.262, -15.242, 228.619) and 17662738 at (-299.705, -31.492, 175.485). bg-wiki
-- describes ONE ??? that relocates between four spots every ten minutes, so the
-- rotation is a property of a single moving entity rather than four placements, and
-- it is not reproducible from two fixed ones. Both are therefore accepted at any
-- time. That is a placement gap in npc_list, not something to paper over by
-- inventing two more entities.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.COOKBOOK_OF_HOPE_RESTORING)

-- The two ??? that exist. See the header note about bg-wiki's four spots.
local recipeSpots =
{
    [17662735] = true,
    [17662738] = true,
}

-- bg-wiki lists LEGS seals for this quest: 3172/3175/3178/3181.
local legsSeals =
{
    xi.item.ORISON_SEAL_LEGS,
    xi.item.RAIDERS_SEAL_LEGS,
    xi.item.FERINE_SEAL_LEGS,
    xi.item.UNKAI_SEAL_LEGS,
}

local firstCruor  = 400
local repeatCruor = 200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_MISAREAUX,
}

--- Picking up a torn page. Shared by the first run and the repeat.
local spotActions =
{
    onTrigger = function(player, npc)
        if
            not recipeSpots[npc:getID()] or
            player:hasKeyItem(xi.ki.TORN_RECIPE_PAGE)
        then
            return
        end

        npcUtil.giveKeyItem(player, xi.ki.TORN_RECIPE_PAGE)

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Jonette'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(210)
                end,
            },

            onEventFinish =
            {
                [210] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:delKeyItem(xi.ki.TORN_RECIPE_PAGE)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['qm'] = spotActions,

            ['Jonette'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.TORN_RECIPE_PAGE) then
                        return quest:progressEvent(212, xi.ki.TORN_RECIPE_PAGE)
                    end

                    return quest:event(211)
                end,
            },

            onEventFinish =
            {
                [212] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.TORN_RECIPE_PAGE)
                        xi.abyssea.questReward(player, firstCruor, legsSeals)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['qm'] = spotActions,

            ['Jonette'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.TORN_RECIPE_PAGE) then
                        return quest:progressEvent(212, xi.ki.TORN_RECIPE_PAGE)
                    elseif quest:getMustZone(player) then
                        return quest:event(214)
                    end

                    return quest:event(213)
                end,
            },

            onEventFinish =
            {
                [212] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.TORN_RECIPE_PAGE)
                    xi.abyssea.questReward(player, repeatCruor, legsSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.COOKBOOK_OF_HOPE_RESTORING)
                end,
            },
        },
    },
}

return quest
