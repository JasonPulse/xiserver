-----------------------------------
-- His Box, His Beloved
-----------------------------------
-- Log ID: 8, Quest ID: 20
-- Apururu        : Abyssea - Tahrongi (H-12), entity 16962091
-- Kopuro-Popuro  : Abyssea - Tahrongi (F-9),  entity 16962098
-- Bottomless_Box : Abyssea - Tahrongi (F-9),  entity 16962099
-- !addquest 8 20
-----------------------------------
-- Retail (bg-wiki "His Box, His Beloved").
-- |Start=Apururu (A) (H-12), Abyssea - Tahrongi  |Fame=atah |FLevel=1
-- |Item Reqs=KI Ripe starfruit  |Reward=200 Cruor
-- |Next=When Good Cardians Go Bad  |Repeatable= (blank, so once only)
--   1. Speak to Apururu at (H-12).
--   2. "Next speak with Kopuro-Popuro (A) at (F-9) in the Western Encampment near
--      Veridical Conflux #03."
--   3. "You'll be tasked with retrieving a KI Ripe starfruit from the Bottomless Box
--      next to him, in order to do this however you must gain its affection.
--      You're suggested to use various emotes such /cheer, /clap, /praise, /smile or
--      /joy to gain the affection of the Bottomless Box."
--      "It is possible however, to receive the item without the use of emotes."
--   4. Return to Apururu to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Apururu 302 -> 7850-7854  THE OFFER. 7851 "You're familiar with the Cardians,
--          are you not?", 7853 "I seem to have exhaustarued my [supply]", 7854
--          "all that remains of our supply is stored at the encamp[ment]".
--   Apururu 303 -> 7855       the reminder, "Our quartermastaru Kopuro-Popuro
--          oversees the supply chest there."
--   Apururu 304 -> 7877 plus msg 201, the activity-points marker. THE TURN-IN:
--          "This is all I need to constructaru a new batch of Cardians."
--   Apururu 305 -> 7883       her post-completion line.
--   Kopuro-Popuro 306 -> 7856  his idle line to the box, "My dear, beloved Boxuxu..."
--   Kopuro-Popuro 307 -> 7857-7859  THE REQUEST. "A starfruit, you say? For Minister
--          Apururu? Why, Boxuxu would be happy to furnish you with what you desire."
--   Kopuro-Popuro 308 -> 7866  the success line, "That's a rarity-warity, my friend.
--          Boxuxu must have taken a fancy to you!"
--   Kopuro-Popuro 309 -> 7868/7873  the not-yet line, "you'll have to work a bit
--          harder to earn her favor" / "Be bright and cheery-weery."
--   Kopuro-Popuro 310 -> 7875/7876  "Don't forgetaru to say your thank-yous" and
--          "Now back to Apururu with you!"
--   Kopuro-Popuro 311 -> 7876  the same send-off on its own.
--   Bottomless_Box 312 -> a 484-byte program. Kopuro-Popuro carries 312 as a ONE-BYTE
--          stub, so this is the holder pattern: the box owns the real program and the
--          client resolves the csid zone-wide.
--
-- THE EMOTE MECHANIC. bg-wiki is explicit that emotes only improve the odds and are
-- not required ("It is possible however, to receive the item without the use of
-- emotes"), and it publishes no rate. So the box is a roll, and emote history is not
-- tracked: there is no server-side signal for "performed /cheer at this entity" that
-- would not be invented here.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HIS_BOX_HIS_BELOVED)

local cruorReward = 200

-- Unpublished. bg-wiki calls the successful pull "a rarity-warity", so it is not
-- generous, and repeated attempts are free.
local starfruitChance = 25

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Apururu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(302)
                end,
            },

            onEventFinish =
            {
                [302] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RIPE_STARFRUIT) then
                        return quest:event(310, xi.ki.RIPE_STARFRUIT)
                    elseif quest:getVar(player, 'Asked') == 1 then
                        return quest:event(309, xi.ki.RIPE_STARFRUIT)
                    end

                    return quest:progressEvent(307, xi.ki.RIPE_STARFRUIT)
                end,
            },

            ['Bottomless_Box'] =
            {
                onTrigger = function(player, npc)
                    -- He has to introduce the box before it will respond.
                    if
                        quest:getVar(player, 'Asked') ~= 1 or
                        player:hasKeyItem(xi.ki.RIPE_STARFRUIT)
                    then
                        return
                    end

                    return quest:progressEvent(312, xi.ki.RIPE_STARFRUIT)
                end,
            },

            ['Apururu'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RIPE_STARFRUIT) then
                        return quest:progressEvent(304, xi.ki.RIPE_STARFRUIT)
                    end

                    return quest:event(303)
                end,
            },

            onEventFinish =
            {
                [307] = function(player, csid, option, npc)
                    quest:setVar(player, 'Asked', 1)
                end,

                [312] = function(player, csid, option, npc)
                    if math.random(1, 100) <= starfruitChance then
                        npcUtil.giveKeyItem(player, xi.ki.RIPE_STARFRUIT)
                    end
                end,

                [304] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.RIPE_STARFRUIT)
                        quest:setVar(player, 'Asked', 0)
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Apururu']       = quest:event(305):replaceDefault(),
            ['Kopuro-Popuro'] = quest:event(306):replaceDefault(),
        },
    },
}

return quest
