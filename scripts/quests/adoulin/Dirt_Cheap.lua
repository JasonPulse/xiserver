-----------------------------------
-- Dirt Cheap
-----------------------------------
-- Log ID: 9, Quest ID: 33
-- Mano-Amano : Yorcia Weald, entity 17855086
-- qm         : Yorcia Weald (I-8), entity 17855108
-- !addquest 9 33
-----------------------------------
-- Retail (bg-wiki "Dirt Cheap").
-- |Start=Mano-Amano, Yorcia Weald  |Next=Flower Power
-- |Fame=Seekers of Adoulin  |Quest Reqs=Fistful of numbing soil
-- |Reward=1000 Experience Points
--   1. Mano-Amano is at the Frontier Station. Speak to him to start the quest.
--   2. "Travel to (I-8) of Yorcia Weald, directly west of the Cirdas Caverns
--      Entrance, and click on the ??? among the numbing blossoms. You will obtain
--      the Fistful of numbing soil."
--      "You can get there fast from Bivouac #2 and going north."
--   3. Return to Mano-Amano for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Mano-Amano is 17855086 -> zone 263 idx 622 (0x0110726E). `xi-dat events 263`
-- gives him 50-58; he carries both this quest and Flower Power. The dumped dialog
-- file labelled zone N holds zone N-1's text for the Adoulin FIELD zones, so
-- Yorcia's text is in the file labelled 264; the offset is pinned by this repo's own
-- known-correct id (Yorcia_Weald/IDs.lua WAYPOINT_ATTUNED = 7543 resolves in dump
-- 264). Read against 264, csidscan splits his two quests -- 8338-8348 is Flower
-- Power (the blossoms) and THIS quest is the 8326-8337 block:
--   50 -> 8325       his idle line about the gloomy sky.
--   51 -> 8326-8333  THE OFFER. 8327 "The Scouts' Coalition is in need of a
--         specialist of my stature to collectaru informacion about numbing
--         blossoms", 8328 "I'm in charge of studying how they grow", and 8329 is
--         the request: "Care to gather some soil samples for me?" 8331 explains why
--         he will not go himself ("if I go so much as half a malm away from a
--         waypointaru I get hopelessly lost"). No ${selection-lines}, so speaking
--         to him starts it.
--   52 -> 8328/8329  the reminder, the request without the excuses.
--   53 -> 8334-8337  THE TURN-IN. "You gathered some dirtaru for me? Muy bien!" /
--         8335 "look at all this pollen-wollen!" / 8337 "Here's a presentaru for you."
--   54-58 -> 8338-8348  Flower Power. Not used here.
--
-- WHICH ??? , AND WHY IT IS NOT A GUESS. Yorcia has seven qm entities and bg-wiki
-- gives only a grid ref, so the one it means is identified by its own wording --
-- "the ??? among the numbing blossoms" -- measured against mob_spawn_points:
--     qm 17855108 (260.8, 230.4)  -> nearest Numbing_Blossom spawns 58, 64, 68
--     qm 17855109 (381.0,  -14.6) -> nearest 223, 230, 231
--     qm 17855112 (-251.3, 173.9) -> nearest 299, 308, 309
-- Only 17855108 has blossoms around it at all, and it has exactly three, which also
-- matches Flower Power's note about "directly north of the frontier station where
-- there are exactly 3 Numbing Blossoms" -- Mano-Amano stands at (357.9, 154.6), so
-- 17855108 is north and slightly west of him, as bg-wiki's route describes.
--
-- The ??? owns csid 6001, whose program is a single-entry stub (data[] is just [0]),
-- so the pickup is a plain key item grant with no event of its own -- the same shape
-- the Shellfish and Strewn Carrion points use.
--
-- KEY ITEM: Fistful of numbing soil is the existing FISTFUL_OF_NUMBING_SOIL (2383).
-- Note 2383 is ALSO item id 2383 (a bottle of black chocobo dye); the placeholder
-- type is what settles it, and this one is a key item. Checked by id in both enums.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.DIRT_CHEAP)

local soilQm = 17855108 -- the ??? among the numbing blossoms

quest.reward =
{
    exp      = 1000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no fame level, so availability is the only gate.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['Mano-Amano'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(51)
                end,
            },

            onEventFinish =
            {
                [51] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: dig the sample, carry it back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= soilQm then
                        return
                    end

                    if player:hasKeyItem(xi.ki.FISTFUL_OF_NUMBING_SOIL) then
                        return
                    end

                    npcUtil.giveKeyItem(player, xi.ki.FISTFUL_OF_NUMBING_SOIL)
                end,
            },

            ['Mano-Amano'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FISTFUL_OF_NUMBING_SOIL) then
                        return quest:progressEvent(53)
                    end

                    return quest:event(52)
                end,
            },

            onEventFinish =
            {
                [53] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.FISTFUL_OF_NUMBING_SOIL)

                    if quest:complete(player) then
                        -- Flower Power's own page: "You must zone after completing
                        -- the previous quest before you can activate this quest."
                        xi.quest.setMustZone(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.FLOWER_POWER)
                    end
                end,
            },
        },
    },

    -- Completed: 8325, back to wishing he were in Adoulin.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['Mano-Amano'] = quest:event(50):replaceDefault(),
        },
    },
}

return quest
