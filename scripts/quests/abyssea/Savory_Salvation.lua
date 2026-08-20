-----------------------------------
-- Savory Salvation
-----------------------------------
-- Log ID: 8, Quest ID: 23
-- Piketo-Puketo       : Abyssea - Tahrongi (F-9), entity 16962097
-- Gnarled_Root        : Abyssea - Tahrongi (G-7), entity 16962117
-- Fragmented_Nutshell : Abyssea - Tahrongi (G-7), entity 16962118
-- !addquest 8 23
-----------------------------------
-- Retail (bg-wiki "Savory Salvation").
-- |Start=Piketo-Puketo (A) (F-9), Abyssea - Tahrongi  |Repeatable=Yes
-- |Item Reqs=Tahrongi tree nut  |Reward=200 Cruor
--   1. Speak to Piketo-Puketo (A) in the Western Encampment at (F-9), near
--      Veridical Conflux #03. He gives you a Vial of flower-wower fertilizer.
--   2. Travel to the large tree at (G-7), near Conflux #04.
--   3. Click the Gnarled Root below in the pathway to inject the fertilizer.
--   4. Click the Fragmented Nutshell up top, on the slope by the tree, for a
--      Tahrongi tree nut.
--   5. Return to Piketo-Puketo (A).
--
-- CSIDS DECODED, NOT GUESSED. Resolved by loading each entity block with
-- csidmsg.load(), which returns (blob, csid->entry offsets, data[]):
--   Piketo-Puketo 16962097, entries {322:1, 323:14, 324:143, 325:202,
--   326:314, 327:342}:
--     322 -> 7905       his pre-quest boast.
--     323 -> 7906-7913  THE OFFER. 7908 "These trees once burgeoned with edible
--            fruit, but no more!", 7909 names him and his ${keyitem-singular:
--            0[2]}, 7910 "one shot into its roots and any tree should readily
--            return to full fruit-bearing glory", 7911 points at the trees "on
--            the path leading to the Meriphataud Mountains".
--     324 -> 7911-7913 + 7922  the reminder: "To the trees lining the path to
--            Meriphataud with you!"
--     325 -> 7918-7920 + 7923  THE TURN-IN. "What's this? ${keyitem-article:
--            1[2]}?" / "Bwahahaha! I knew I was a genius!"
--     327 -> 7921/7922  THE REPEAT OFFER: "My loyal minion returns... Here's
--            your ${keyitem-singular: 0[2]}. You already know what to do."
--   Gnarled_Root 16962117 owns exactly one csid, 328, data[] = [7915, 7916,
--   120, 7917]: 7915 "This would seem a suitable place to apply
--   Piketo-Puketo's ${keyitem...}", 7916 "${name-player} injected the
--   ${keyitem} into the ${name-npc}", 7917 "You hear the thud of an object
--   striking the ground beside you" -- which is the nutshell falling.
--
-- PARAMS ARE GENUINELY NEEDED HERE, unlike Catering_Capers.lua: neither key
-- item id appears in either block's data[] table (Piketo's holds only message
-- ids and small ints, the Root's is [7915, 7916, 120, 7917]), so both are
-- supplied by the caller. Param 0 is the fertilizer, param 1 the nut.
--
-- KEY ITEMS: bg-wiki names "Vial of flower-wower fertilizer", which is
-- VIAL_OF_FLOWER_WOWER_FERTILIZER (1592) -- it sits immediately before
-- TAHRONGI_TREE_NUT (1593) in key_item.lua, consecutive ids for one quest's
-- pair. Note the adjacent BUCKET_OF_COMPOUND_COMPOST (1594) is a different key
-- item and is NOT this quest's device.
--
-- Fragmented_Nutshell (16962118) owns no csids at all, so collecting the nut is
-- a plain server-side grant rather than a cutscene -- the same shape as the
-- Gasponia in Something_in_the_Air.lua.
-----------------------------------
local tahrongiID = zones[xi.zone.ABYSSEA_TAHRONGI]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SAVORY_SALVATION)

local cruorReward = 200

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=Yes, and 327 is his own re-offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Piketo-Puketo'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SAVORY_SALVATION) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(327, { [0] = xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER })
                    end

                    return quest:progressEvent(323, { [0] = xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER })
                end,
            },

            onEventFinish =
            {
                [323] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER)
                end,

                [327] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SAVORY_SALVATION)
                    npcUtil.giveKeyItem(player, xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER)
                end,
            },
        },
    },

    -- Accepted: inject the root, then pick up the nut it shakes loose.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Gnarled_Root'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER) then
                        return
                    end

                    return quest:progressEvent(328, { [0] = xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER })
                end,
            },

            ['Fragmented_Nutshell'] =
            {
                onTrigger = function(player, npc)
                    -- Only yields once the root has been injected (Prog 1).
                    if
                        quest:getVar(player, 'Prog') ~= 1 or
                        player:hasKeyItem(xi.ki.TAHRONGI_TREE_NUT)
                    then
                        return
                    end

                    npcUtil.giveKeyItem(player, xi.ki.TAHRONGI_TREE_NUT)
                end,
            },

            ['Piketo-Puketo'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.TAHRONGI_TREE_NUT) then
                        return quest:progressEvent(325, { [1] = xi.ki.TAHRONGI_TREE_NUT })
                    end

                    return quest:event(324, { [0] = xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER })
                end,
            },

            onEventFinish =
            {
                [328] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.VIAL_OF_FLOWER_WOWER_FERTILIZER)
                    quest:setVar(player, 'Prog', 1)
                end,

                [325] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.TAHRONGI_TREE_NUT)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(tahrongiID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
