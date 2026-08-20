-----------------------------------
-- The Firebloom Tree
-----------------------------------
-- Log ID: 7, Quest ID: 1
-- Soun_Abralah        : Kazham (H-9), entity 17801258
-- Firebloom_Tree_Root : Yuhtunga Jungle (H-9), entities 17281582-17281585
-- Flame_Spout         : Ifrit's Cauldron, entities 17617205-17617208
-- !addquest 7 1
-----------------------------------
-- Retail (bg-wiki "The Firebloom Tree").
-- |Start=Soun Abralah, Kazham (H-9)  |Fame=Kazham  |FLevel=6  |Repeatable=Yes
-- |Item Reqs=Northern vine  |Reward=5,000 Gil
--   1. Soun Abralah needs a piece of unburnable wood from the Firebloom Tree.
--   2. Visit the Firebloom Tree Roots at Yuhtunga Jungle (H-9) and harvest the
--      Eastern, Northern, Western and Southern vines. "No Hatchets required."
--      "The Western vine is in the tunnel."
--   3. Head to Ifrit's Cauldron and touch 3 Flame Spouts to test the vines.
--   4. "Return to the appropriate Firebloom Tree Root (only one will work, and it
--      will match your remaining Key Item) and obtain wood."
--   5. Return to Soun Abralah for your reward.
--
-- CSIDS DECODED, NOT GUESSED, AND THE OFFER WAS PINNED BY CONTENT. Kazham's dump
-- table opens on Fields of Valor lines, so reading a range around Soun Abralah's
-- csids first showed "Training area: West Ronfaure" and looked like the wrong
-- table. `xi-dat find "Firebloom"` settles it -- Kazham[10081] "Deep in the
-- hearrrt of the Yuhtunga Jungle, there is a giant tree known by the natives as
-- the Firebloom Tree" is his, and 10081 sits inside csid 102. Block sizes agree
-- (102 is 190 bytes, far the largest of his set).
--   Soun Abralah 102 -> 10081-10084  THE OFFER. 10082 names the prize as
--          ${keyitem-singular: 1[2]}, and 10083/10084 lay out the whole method:
--          "retrieve four vines from its four sides... Throw the four vines into
--          the flames. The one that remains unburned is from the most heavily
--          protected side."
--   Soun Abralah 103 -> 10085-10087  the reminder, the three steps restated.
--   Soun Abralah 104 -> 10088/10089  THE TURN-IN. "Look at it! Isn't it
--          beautiful?" / "Only a bow made from this wood can stand the blazing
--          heat of Purgatory Arrows."
--   Soun Abralah 105 -> 10090-10092  his post-completion talk about Perih Vashai
--          and the Azure Bow.
--   Soun Abralah 106 -> 10093/10094  the repeat offer: "Would you have the time to
--          retrieve another piece of ${keyitem-singular: 1[2]}?"
--   Root 17281582 -> 13 harvest / 17 wood, 583 -> 14/18, 584 -> 15/19, 585 -> 16/20
--   Flame_Spout 17617205-17617208 -> csids 11, 12, 13, 14
--   Ifrit's Cauldron messages: 7240 "You have not brought vines from all four
--          sides", 7241-7244 "The <vine> bursts into flames!", 7245-7248 "The
--          <vine> withstands the intense heat of the inferno!", 7249 "Now you must
--          return to the Firebloom Tree."
--
-- WHICH ROOT IS WHICH DIRECTION, BY POSITION not by entity order. The four roots
-- ring a centroid near (-101.8, -100.9):
--     17281582 (-102.9,  -90.7)  largest z   -> SOUTH
--     17281583  (-97.1, -107.5)  smallest z  -> NORTH
--     17281584  (-90.2, -102.0)  largest x   -> EAST
--     17281585 (-117.0, -103.6)  smallest x  -> WEST
-- and the westmost is the one bg-wiki says sits "in the tunnel", which is the
-- cross-check that the axes are the right way round.
--
-- THE SURVIVING VINE IS ROLLED, NOT FIXED. bg-wiki says only one root will work and
-- it matches whichever key item you have left, so the game picks a side per run.
-- Three spouts burn three vines; the fourth is the answer.
--
-- KEY ITEMS: NORTHERN_VINE (204), SOUTHERN_VINE (205), EASTERN_VINE (206),
-- WESTERN_VINE (207), FIREBLOOM_TREE_WOOD (212) all already exist.
-----------------------------------
local cauldronID = zones[xi.zone.IFRITS_CAULDRON]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)

-- root entity -> { vine key item, harvest csid, wood csid }
local roots =
{
    [17281582] = { xi.ki.SOUTHERN_VINE, 13, 17 },
    [17281583] = { xi.ki.NORTHERN_VINE, 14, 18 },
    [17281584] = { xi.ki.EASTERN_VINE,  15, 19 },
    [17281585] = { xi.ki.WESTERN_VINE,  16, 20 },
}

local spouts =
{
    [17617205] = 11,
    [17617206] = 12,
    [17617207] = 13,
    [17617208] = 14,
}

local allVines =
{
    xi.ki.NORTHERN_VINE,
    xi.ki.SOUTHERN_VINE,
    xi.ki.EASTERN_VINE,
    xi.ki.WESTERN_VINE,
}

--- Burn one of the vines still held, at random. Three spouts leave exactly one,
--- and that survivor is what tells the player which root to go back to.
local burnVine = function(player)
    local held = {}
    for _, ki in ipairs(allVines) do
        if player:hasKeyItem(ki) then
            table.insert(held, ki)
        end
    end

    if #held > 1 then
        player:delKeyItem(held[math.random(1, #held)])
    end
end

local heldVines = function(player)
    local held = {}
    for _, ki in ipairs(allVines) do
        if player:hasKeyItem(ki) then
            table.insert(held, ki)
        end
    end

    return held
end

quest.reward =
{
    gil      = 5000,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes; 106 is his re-offer.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.WINDURST) >= 6
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE) then
                        return quest:progressEvent(106, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                    end

                    return quest:progressEvent(102, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                end,
            },

            onEventFinish =
            {
                [102] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [106] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)
                end,
            },
        },
    },

    -- Accepted: four vines, three spouts, then the root that matches the survivor.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YUHTUNGA_JUNGLE] =
        {
            ['Firebloom_Tree_Root'] =
            {
                onTrigger = function(player, npc)
                    local root = roots[npc:getID()]
                    if root == nil then
                        return
                    end

                    local held = heldVines(player)

                    -- One vine left and it belongs to this root: cut the wood.
                    if
                        #held == 1 and
                        held[1] == root[1] and
                        not player:hasKeyItem(xi.ki.FIREBLOOM_TREE_WOOD)
                    then
                        return quest:progressEvent(root[3], { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                    end

                    -- Otherwise harvest this side's vine, once.
                    if player:hasKeyItem(root[1]) then
                        return
                    end

                    return quest:progressEvent(root[2])
                end,
            },

            onEventFinish =
            {
                [13] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.SOUTHERN_VINE)
                end,

                [14] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.NORTHERN_VINE)
                end,

                [15] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.EASTERN_VINE)
                end,

                [16] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.WESTERN_VINE)
                end,

                [17] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.SOUTHERN_VINE)
                    npcUtil.giveKeyItem(player, xi.ki.FIREBLOOM_TREE_WOOD)
                end,

                [18] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.NORTHERN_VINE)
                    npcUtil.giveKeyItem(player, xi.ki.FIREBLOOM_TREE_WOOD)
                end,

                [19] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.EASTERN_VINE)
                    npcUtil.giveKeyItem(player, xi.ki.FIREBLOOM_TREE_WOOD)
                end,

                [20] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.WESTERN_VINE)
                    npcUtil.giveKeyItem(player, xi.ki.FIREBLOOM_TREE_WOOD)
                end,
            },
        },

        [xi.zone.IFRITS_CAULDRON] =
        {
            ['Flame_Spout'] =
            {
                onTrigger = function(player, npc)
                    local csid = spouts[npc:getID()]
                    if csid == nil then
                        return
                    end

                    local held = heldVines(player)

                    -- 7240: "You have not brought vines from all four sides."
                    if #held < 2 then
                        player:messageSpecial(cauldronID.text.NOT_ALL_FOUR_VINES)
                        return
                    end

                    return quest:progressEvent(csid)
                end,
            },

            onEventFinish =
            {
                [11] = function(player, csid, option, npc)
                    burnVine(player)
                end,

                [12] = function(player, csid, option, npc)
                    burnVine(player)
                end,

                [13] = function(player, csid, option, npc)
                    burnVine(player)
                end,

                [14] = function(player, csid, option, npc)
                    burnVine(player)
                end,

            },
        },

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FIREBLOOM_TREE_WOOD) then
                        return quest:progressEvent(104, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                    end

                    return quest:event(103, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                end,
            },

            onEventFinish =
            {
                [104] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.FIREBLOOM_TREE_WOOD)
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 10090-10092, the Azure Bow and Perih Vashai.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] = quest:event(105):replaceDefault(),
        },
    },
}

return quest
