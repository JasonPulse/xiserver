-----------------------------------
-- The Titus Touch
-----------------------------------
-- Log ID: 8, Quest ID: 80
-- Titus   : Abyssea - Altepa (G-11), entity 17670750
-- Chumimi : Abyssea - Altepa (northern encampment), entity 17670751
-- !addquest 8 80
-----------------------------------
-- Retail (bg-wiki "The Titus Touch").
-- |Start=Titus (A) (G-11), Abyssea - Altepa  |Item Reqs=Windurstian Tea Leaves
-- |Reward=500 Cruor
--   1. Speak to Titus (A) at (G-11), at Conflux #5.
--   2. He requests a clump of Windurstian Tea Leaves.
--   3. After trading them he provides a Military ink package. (He synthesizes a
--      Bottle of military ink, but that item exists only inside the cutscene and
--      is never given to the player.)
--   4. Deliver the package to the physician Chumimi at the northern encampment.
--
-- CSIDS DECODED, NOT GUESSED. Both NPCs were confirmed by
-- tools/coverage/resolve_npc.py before any dialog was read: item 635 sits at
-- data[0] of Titus' block and data[3] of Chumimi's, which is what proves these
-- two entities own this quest rather than merely sharing its NPC names.
--   Titus (entries {309:1, 310:24, 311:142, 312:210, 314:229}):
--     309 -> 8046/8047  THE APPROACH. 8046 "My massive brain burgeons ever forth
--            with inspiration, yet I lack for the key [ingredient]", 8047 "I
--            don't suppose you'd happen to have ${article} ${item-article: 0[2]}
--            upon your pe[rson]" -- the tea leaves are param 0.
--     310 -> 8048-8056  THE SYNTHESIS AND THE ERRAND. 8049 "Titus synthesizes
--            ${number: 1} ${keyitem-plural: 0[2]}!", 8051 "You're not the courier
--            ${choice-player-gender}[boy/girl]?", 8053 "You are to deliver my
--            masterpiece to the physician Chumimi at the northern encampment",
--            and 8054 is the accept prompt "Accept the job?".
--     311 -> 8053-8056  the reminder, the errand without the synthesis.
--   Chumimi (entries {313:1, 315:56, 316:70, 317:143, 318:157, 350:655,
--   319:701}):
--     313 -> 8058-8062  THE DELIVERY AND COMPLETION. 8059 "That perfunctorily
--            packaged parcel...! Don't tell me...it's from Titus, isn't it?",
--            8061 "As if anyone needs a nasal hair remover when lives are at
--            stake!", 8062 "we now have the supplies necessary to put our
--            reportaru to parchment. This is for you." -- the reward line.
--
-- ITEM AND KEY ITEMS: bg-wiki's "Windurstian Tea Leaves" is item_basic
-- `clump_of_windurstian_tea_leaves` (635) -- the container-word trap, so a
-- bare-name grep misses it; resolve_item.py finds it. The package the player
-- carries is MILITARY_INK_PACKAGE (1766). BOTTLE_OF_MILITARY_INK (1765) is the
-- cutscene-only item bg-wiki explicitly says is never handed over, so it is
-- deliberately NOT granted here.
-----------------------------------
local altepaID = zones[xi.zone.ABYSSEA_ALTEPA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_TITUS_TOUCH)

local cruorReward = 500

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(309, { [0] = xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES })
                end,
            },

            onEventFinish =
            {
                [309] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: bring him the leaves, take the package he makes.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.MILITARY_INK_PACKAGE)
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Titus'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES) then
                        return quest:progressEvent(310, { [0] = xi.ki.MILITARY_INK_PACKAGE, [1] = 1 })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(309, { [0] = xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES })
                end,
            },

            onEventFinish =
            {
                [310] = function(player, csid, option, npc)
                    -- 8054 "Accept the job?" -- taking the parcel is the accept.
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, xi.ki.MILITARY_INK_PACKAGE)
                end,
            },
        },
    },

    -- Package in hand: carry it north to Chumimi.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.MILITARY_INK_PACKAGE)
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Chumimi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(313, { [0] = xi.ki.MILITARY_INK_PACKAGE })
                end,
            },

            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(311, { [0] = xi.ki.MILITARY_INK_PACKAGE })
                end,
            },

            onEventFinish =
            {
                [313] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.MILITARY_INK_PACKAGE)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
