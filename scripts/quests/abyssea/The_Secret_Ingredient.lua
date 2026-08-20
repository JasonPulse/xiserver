-----------------------------------
-- The Secret Ingredient
-----------------------------------
-- Log ID: 8, Quest ID: 78
-- Nogelle : Abyssea - Altepa (K-5), entity 17670744
-- !addquest 8 78
-----------------------------------
-- Retail (bg-wiki "The Secret Ingredient").
-- |Start=Nogelle (A) (K-5), Abyssea - Altepa  |Repeatable=Yes
-- |Item Reqs=Badlands Salt
-- |Reward=First time completion: 400 Cruor. Subsequent completions: 200 Cruor.
--   1. Speak to Nogelle (A) at (K-5), Conflux #1. He asks you to retrieve a
--      chunk of Badlands Salt. Other types of salt do not work.
--   2. Fish at Conflux #6 until you catch a Badlands Crab, which yields it.
--   3. Trade the salt to Nogelle (A).
--
-- CSIDS DECODED, NOT GUESSED, via csidmsg.load() on Nogelle's block --
-- entries {255:1, 256:85, 257:153, 258:176, 259:231, 260:245, 264:320, 261:379,
-- 262:413, 263:432} -- and find_msg against `xi-dat dialog 218`:
--   255 -> 7997-8005  THE FIRST OFFER. 7998 "I am Nogelle, a culinarian
--          specializing in haute bean cuisine", 7999 he lost his stash of Lufet
--          salt, 8001 "I need to find a suitable substitute", and 8002 is the
--          accept prompt: "Accept the task? ${selection-lines} Leave it to me. /
--          I don't even like beans..." -- the affirmative is FIRST, so OPTION 0
--          ACCEPTS, and 8003 is the decline ("that blasphemous utterance").
--   256 -> 8002-8005  the reminder: "Will you find me a Lufet salt substitute?"
--   257 -> 8012/8013  the empty-handed variant: "No luck, you say?"
--   258 -> 8006-8010  THE FIRST TURN-IN. 8008 "it's nigh identical to the Lufet
--          salt I use[d]", 8010 "This is for you, my gourmet-minded friend."
--   259 -> 8011       his post-completion line.
--   260 -> 8014-8016  THE REPEAT OFFER: "my last batch of bean stew was such a
--          hit that I've already run [out]... hunt down some more for me".
--   264 -> 8017       the repeat accept.
--   261 -> 8018       THE REPEAT TURN-IN: "take this for your troubles."
--   262 -> 8019       the repeat post-completion line.
--   263 -> 8020-8022  THE WRONG-SALT PATH, and worth implementing rather than
--          dropping: 8020 "Not just a mere substitute, but an authentic
--          ${item-singular: 0[2]}?", 8021 "This is the Lufet salt I remember,
--          for sure, but the flavor is all wrong. No, I'm afraid this won't do
--          at all." bg-wiki's "Other types of salt do not work" is this event.
--
-- ITEM RESOLUTION, both by id: bg-wiki's "Badlands Salt" is item_basic name
-- `chunk_of_badlands_salt` (2976) with `badlands_salt` only as its sort name --
-- the container-word trap, so it had no enum and was added as
-- CHUNK_OF_BADLANDS_SALT. The real Lufet salt is the existing
-- CHUNK_OF_LUFET_SALT (1019), and both ids sit in this block's own data[] table
-- (2976 at index 24, 1019 at index 3), which is what confirms the pairing.
--
-- FISHING is not wired here on purpose: the salt comes from a Badlands Crab
-- caught at Conflux #6, which belongs to the fishing tables rather than to this
-- quest. This file implements the quest side -- offer, turn-in, repeat and the
-- wrong-salt rejection -- and takes the salt however the player obtained it.
-----------------------------------
local altepaID = zones[xi.zone.ABYSSEA_ALTEPA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_SECRET_INGREDIENT)

local firstReward  = 400
local repeatReward = 200

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=Yes, and 260/264 are his own re-offer pair.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Nogelle'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_SECRET_INGREDIENT) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(260)
                    end

                    return quest:progressEvent(255)
                end,
            },

            onEventFinish =
            {
                [255] = function(player, csid, option, npc)
                    -- 8002: 0 "Leave it to me.", 1 "I don't even like beans..."
                    if option == 0 then
                        quest:begin(player)
                    end
                end,

                [260] = function(player, csid, option, npc)
                    if option == 0 then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_SECRET_INGREDIENT)
                    end
                end,
            },
        },
    },

    -- Accepted: bring him the Badlands Salt -- and only that.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Nogelle'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.CHUNK_OF_BADLANDS_SALT) then
                        -- 258 the first time, 261 on repeats -- they are separate
                        -- programs, not one reused event.
                        if quest:getVar(player, 'Done') == 0 then
                            return quest:progressEvent(258)
                        end

                        return quest:progressEvent(261)
                    end

                    -- Genuine Lufet salt is refused, per 8021.
                    if npcUtil.tradeHasExactly(trade, xi.item.CHUNK_OF_LUFET_SALT) then
                        return quest:progressEvent(263, { [0] = xi.item.CHUNK_OF_LUFET_SALT })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(257)
                end,
            },

            onEventFinish =
            {
                [263] = function(player, csid, option, npc)
                    -- No confirmTrade: he hands the Lufet salt straight back.
                end,

                [258] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        quest:setVar(player, 'Done', 1)
                        player:addCurrency('cruor', firstReward)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, firstReward, player:getCurrency('cruor'))
                    end
                end,

                [261] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', repeatReward)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, repeatReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
