-----------------------------------
-- Her Father's Legacy
-----------------------------------
-- Log ID: 8, Quest ID: 63
-- Cornelia : Abyssea - Grauberg (G-12), entity 17818247
-- !addquest 8 63
-----------------------------------
-- Retail (bg-wiki "Her Father's Legacy").
-- |Start=Cornelia (A), Abyssea - Grauberg  |Previous=Getting Lucky
-- |Item Reqs=Pursuer's Wing  |Reward=First time completion: 400 Cruor
-- |Repeatable=Yes
--   "You must zone after completing Getting Lucky before you can start this."
--   1. Speak to Cornelia (A) at (G-12) near Conflux #4 to begin this quest.
--   2. Obtain a Pursuer's Wing from the Faunus Wyvern near Conflux #3, or buy
--      it from the Auction House.
--   3. Trade her the Pursuer's Wing to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Cornelia is 17818247 (zone 254 idx 647) and holds
-- several quests; csidscan.py against `xi-dat dialog 254` separates them. The
-- wyvern-intelligence pair (238 -> 8181/8182, 243 -> 8183-8185) and the
-- Alfard-slain scene (249 -> 8212-8221) belong to her other quests and are left
-- alone. THIS quest is the 245-248 block:
--   245 -> 8192-8211  THE OFFER. 8194 "My quest for intelligence on wyverns--it
--          was for no other purpose than to defeat an even fouler fiend", 8198
--          "will you assist us by defeating the wyverns", and 8199 is the accept
--          prompt: "Defeat the wyverns? ${selection-lines} Consider it done! /
--          Sounds awfully dangerous..." -- the affirmative is FIRST, so OPTION 0
--          ACCEPTS. 8204 then states the actual hand-in: "bring me ${article}
--          ${item-article: 0[2]} as proof of the deed" -- the wing is param 0.
--   246 -> 8204       the reminder, that same proof request on its own.
--   247 -> 8205-8208  THE TURN-IN. "You truly did it! You defeated the wyverns!"
--          through 8208 "I want you to accept this".
--   248 -> 8206       the short version of her thanks.
--
-- MUST ZONE: bg-wiki's walkthrough opens with "You must zone after completing
-- Getting Lucky before you can start this quest", so the gate is that quest
-- completed AND a zone since, not merely its completion.
--
-- ITEM: Pursuer's Wing is the existing PURSUERS_WING (3267).
-- CRUOR: bg-wiki says 400 on FIRST completion, so it is paid inside the
-- quest:complete branch, which only succeeds the first time; repeats replay the
-- turn-in without re-paying.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HER_FATHERS_LEGACY)

local cruorReward = 400

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.GETTING_LUCKY) and
                quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Cornelia'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(245, { [0] = xi.item.PURSUERS_WING })
                end,
            },

            onEventFinish =
            {
                [245] = function(player, csid, option, npc)
                    -- 8199: 0 "Consider it done!", 1 "Sounds awfully dangerous..."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HER_FATHERS_LEGACY) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HER_FATHERS_LEGACY)
                    else
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Cornelia'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.PURSUERS_WING) then
                        return quest:progressEvent(247, { [0] = xi.item.PURSUERS_WING })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(246, { [0] = xi.item.PURSUERS_WING })
                end,
            },

            onEventFinish =
            {
                [247] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
