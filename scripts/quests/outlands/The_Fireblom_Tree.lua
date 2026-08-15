-----------------------------------
-- The Fireblom Tree
-----------------------------------
-- Log ID: 5, Quest ID: 1
-- Soun Abralah        : Kazham (H-9)
-- Firebloom Tree Root : Yuhtunga Jungle (H-9), four of them
-- Flame Spout         : Ifrit's Cauldron, four of them
-----------------------------------
-- Retail (bg-wiki "The Firebloom Tree" -- note the wiki spells it Firebloom while
-- this file and the log entry spell it Fireblom). Fame k, FLevel 6, Repeatable.
--   1. Speak to Soun Abralah in Kazham; he needs unburnable wood from the
--      Firebloom Tree.
--   2. Visit the Firebloom Tree Roots in Yuhtunga Jungle (H-9) and harvest the
--      Northern, Eastern, Southern and Western vines by clicking the trees. No
--      Hatchet is required. (The Western vine is in the tunnel.)
--   3. Go to Ifrit's Cauldron and test the vines in the Flame Spouts. YOU NEED TO
--      TOUCH THREE Flame Spouts -- each burns one vine away, and the single vine
--      left tells you which side of the tree is the most fire-resistant.
--   4. Return to the matching Firebloom Tree Root -- only that one works -- and
--      take the wood. Again no Hatchet.
--   5. Return to Soun Abralah. Reward: 5,000 gil. No title.
--
-- CSIDs decoded, not guessed. Soun Abralah is entity 17801258; (17801258-16777216)
-- = 1024042, 1024042//4096 = 250 rem 42 -> Kazham, 0x010FA02A. Resolved with the
-- wide scan in xidat/csidscan.py and read against `xi-dat dialog 250`:
--   101 -> 10072-10073  idle lore about the Thalassa Bow
--   102 -> 10076-10084  THE OFFER. 10077 "are your serrrvices for hire?", then
--          10078 "Listen to her offer? ${selection-lines} Yes. No." -- so option 0
--          accepts. 10080 "have you ever heard of ${keyitem-singular: 1[2]}? This
--          rare wood does not even burn when thrown into the inferrrno of Ifrit's
--          Cauldron.", 10081 names the Firebloom Tree in the Yuhtunga Jungle,
--          10083 "you must first retrieve four vines from its four sides. Then you
--          must take those four vines to a place in Ifrit's Cauldron where firrre
--          spits up from the rrrocks.", 10084 "Throw the four vines into the
--          flames. The one that remains unburned is from the most heavily
--          protected side."
--   103 -> 10085-10087  the in-progress reminder, restating the three steps
--   104 -> 10088-10089  THE TURN-IN. 10088 "Look at it! Isn't it beautiful?",
--          10089 "Only a bow made from this wood can stand the blazing heat of
--          'Purgatory Arrows.'"
--   105 -> 10090-10092  post-quest chat about Perih Vashai and the Azure Bow
--   106 -> 10078-10094  the REPEAT offer. 10093 "Would you have the time to
--          retrieve another piece of ${keyitem-singular: 1[2]}?", 10094 "If you're
--          busy..."
--
-- Every entity and key item this needs already exists -- nothing was added:
--   Firebloom_Tree_Root x4, Yuhtunga Jungle (zone 123), each owning TWO csids,
--   the first to cut the vine and the second to cut the wood:
--     17281582 (-102.860, -90.699)  csids 13 / 17
--     17281583 ( -97.108, -107.499) csids 14 / 18
--     17281584 ( -90.248, -102.046) csids 15 / 19
--     17281585 (-117.016, -103.580) csids 16 / 20
--   Their coordinates form a clean cardinal cross about a centre of roughly
--   (-101.8, -100.9). With +X east and +Z south: 17281582 has the highest Z so it
--   is SOUTH, 17281583 the lowest Z so NORTH, 17281584 the highest X so EAST, and
--   17281585 the lowest X so WEST. That is how the table below is keyed.
--   Flame_Spout x4, Ifrit's Cauldron (zone 205), one csid each:
--     17617205 csid 11, 17617206 csid 12, 17617207 csid 13, 17617208 csid 14
--   Key items: NORTHERN_VINE 204, SOUTHERN_VINE 205, EASTERN_VINE 206,
--   WESTERN_VINE 207, FIREBLOOM_TREE_WOOD 212 (scripts/enum/key_item.lua:213-221).
--
-- The previous stub fired csids 100 and 101 on Soun Abralah. 101 is real but is
-- only his idle lore line; 100 is not one of the six programs he owns. It also
-- skipped the vines, the flame spouts and the wood entirely.
--
-- The fire-resistant side is rolled per player and stored in the 'Side' var, so
-- the three-spout elimination is real rather than cosmetic: the spouts burn the
-- three vines that are NOT the answer, which is what leaves exactly one behind.
-----------------------------------
local kazhamID = zones[xi.zone.KAZHAM]

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)

-- Keyed by the root's entity id. `vine` is the key item that root yields, `cut`
-- is the csid that harvests the vine and `wood` the csid that takes the wood.
local roots =
{
    [17281582] = { side = 'S', vine = xi.ki.SOUTHERN_VINE, cut = 13, wood = 17 },
    [17281583] = { side = 'N', vine = xi.ki.NORTHERN_VINE, cut = 14, wood = 18 },
    [17281584] = { side = 'E', vine = xi.ki.EASTERN_VINE,  cut = 15, wood = 19 },
    [17281585] = { side = 'W', vine = xi.ki.WESTERN_VINE,  cut = 16, wood = 20 },
}

local sides = { 'N', 'S', 'E', 'W' }

local vineForSide =
{
    N = xi.ki.NORTHERN_VINE,
    S = xi.ki.SOUTHERN_VINE,
    E = xi.ki.EASTERN_VINE,
    W = xi.ki.WESTERN_VINE,
}

local spouts = { [17617205] = 11, [17617206] = 12, [17617207] = 13, [17617208] = 14 }

local allVines =
{
    xi.ki.NORTHERN_VINE,
    xi.ki.SOUTHERN_VINE,
    xi.ki.EASTERN_VINE,
    xi.ki.WESTERN_VINE,
}

local function vineCount(player)
    local n = 0

    for _, vine in ipairs(allVines) do
        if player:hasKeyItem(vine) then
            n = n + 1
        end
    end

    return n
end

local function hasEveryVine(player)
    for _, vine in ipairs(allVines) do
        if not player:hasKeyItem(vine) then
            return false
        end
    end

    return true
end

-- The answer is rolled once per run, the first time it is needed.
local function resistantSide(player)
    local side = quest:getVar(player, 'Side')

    if side == 0 then
        side = math.random(1, #sides)
        quest:setVar(player, 'Side', side)
    end

    return sides[side]
end

-- Each spout burns away one vine that is NOT the answer. Touching three of them
-- therefore leaves exactly the right one, which is what bg-wiki describes.
local function burnOneVine(player)
    local keep = vineForSide[resistantSide(player)]

    for _, vine in ipairs(allVines) do
        if vine ~= keep and player:hasKeyItem(vine) then
            player:delKeyItem(vine)
            return true
        end
    end

    return false
end

local function rootSection()
    local section =
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.FIREBLOOM_TREE_WOOD)
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] = quest:event(103, { [1] = xi.ki.FIREBLOOM_TREE_WOOD }),
        },

        [xi.zone.YUHTUNGA_JUNGLE] =
        {
            ['Firebloom_Tree_Root'] =
            {
                onTrigger = function(player, npc)
                    local root = roots[npc:getID()]

                    if root == nil then
                        return
                    end

                    -- Once the testing has narrowed it down, the matching root --
                    -- and only that one -- gives up the wood.
                    if
                        player:hasKeyItem(root.vine) and
                        not hasEveryVine(player) and
                        root.side == resistantSide(player)
                    then
                        return quest:progressEvent(root.wood, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                    end

                    if not player:hasKeyItem(root.vine) then
                        return quest:progressEvent(root.cut)
                    end
                end,
            },

            onEventFinish = {},
        },

        [xi.zone.IFRITS_CAULDRON] =
        {
            ['Flame_Spout'] =
            {
                onTrigger = function(player, npc)
                    local csid = spouts[npc:getID()]

                    -- MY BUG, fixed: this gated on hasEveryVine, but each spout
                    -- BURNS a vine, so after the first touch the gate closed and
                    -- the remaining two of retail's three touches were impossible
                    -- -- the "one vine remains" signal never happened. bg-wiki:
                    -- "You need to touch 3 Flame Spouts". The spout is usable
                    -- while more than one vine is left; the last one survives.
                    if csid == nil or vineCount(player) < 2 then
                        return
                    end

                    return quest:progressEvent(csid)
                end,
            },

            onEventFinish = {},
        },
    }

    local jungle = section[xi.zone.YUHTUNGA_JUNGLE].onEventFinish
    local cauldron = section[xi.zone.IFRITS_CAULDRON].onEventFinish

    for _, root in pairs(roots) do
        jungle[root.cut] = function(player, csid, option, npc)
            npcUtil.giveKeyItem(player, root.vine)
        end

        jungle[root.wood] = function(player, csid, option, npc)
            if npcUtil.giveKeyItem(player, xi.ki.FIREBLOOM_TREE_WOOD) then
                player:delKeyItem(root.vine)
            end
        end
    end

    for _, csid in pairs(spouts) do
        cauldron[csid] = function(player, csid2, option, npc)
            burnOneVine(player)
        end
    end

    return section
end

quest.sections =
{
    -- 10078 "Listen to her offer? / Yes. / No." -- option 0 accepts.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.WINDURST) >= 6
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(106, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                    end

                    return quest:progressEvent(102, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                end,
            },

            onEventFinish =
            {
                [102] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                        quest:setVar(player, 'Side', 0)
                    end
                end,

                [106] = function(player, csid, option, npc)
                    if option == 0 then
                        player:addQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)
                        quest:setVar(player, 'Side', 0)
                    end
                end,
            },
        },
    },

    rootSection(),

    -- Wood in hand: back to Soun Abralah for the 5,000 gil.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.FIREBLOOM_TREE_WOOD)
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(104, { [1] = xi.ki.FIREBLOOM_TREE_WOOD })
                end,
            },

            onEventFinish =
            {
                [104] = function(player, csid, option, npc)
                    local reward = xi.settings.main.GIL_RATE * 5000

                    player:delKeyItem(xi.ki.FIREBLOOM_TREE_WOOD)
                    player:addGil(reward)
                    player:messageSpecial(kazhamID.text.GIL_OBTAINED, reward)
                    player:completeQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)
                    quest:setVar(player, 'Side', 0)
                end,
            },
        },
    },
}

return quest
