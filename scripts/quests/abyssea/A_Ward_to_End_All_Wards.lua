-----------------------------------
-- A Ward to End All Wards
-----------------------------------
-- Log ID: 8, Quest ID: 30
-- Belgidiveau : Abyssea - Vunkerl (F-4), entity 17666761
-- !addquest 8 30
-----------------------------------
-- Retail (bg-wiki "A Ward to End All Wards").
-- |Start=Belgidiveau (A) (F-4), Abyssea - Vunkerl  |Repeatable=Yes
-- |Reward=First time completion: 450~550 Cruor, 8~12 Resistance Credits
--         Subsequent completions: 225~275 Cruor and 8~12 Resistance Credits
--   1. Speak to Belgidiveau (A) at (F-4), the base camp (Veridical Conflux #01).
--   2. He wants a part of an Abyssean monster -- an NM pop item or a piece of a
--      Voragean. "Multiple items are 'High Strength' and yield the greatest
--      fame/rewards." Two stackable items that work are Amoeban Pseudopod and
--      Sanguinet. "No Magian Trial drops work."
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Belgidiveau is 17666761 -> zone 217 idx 713
-- (0x010D92C9). `xi-dat events 217` gives him 1040-1045; csidscan.py against
-- `xi-dat dialog 217`:
--   1040 -> 8355-8362  THE FIRST OFFER, with the full introduction ("None other
--          than I, Belgidiveau!"). 8359 carries the request: "you are to
--          retrieve a body part--limb, nail, organ, any will suffice--from one
--          of the fiends that roam the area". 8360 is the accept prompt:
--          "What say you? ${selection-lines} Anything to aid the cause! /
--          Sorry, I have better things to do." -- the affirmative is the FIRST
--          line, so OPTION 0 ACCEPTS, and 8362 is the decline.
--   1041 -> 8360-8363  the same prompt behind 8363 "Come back to make yourself
--          useful, have you?" -- his re-offer after a decline.
--   1042 -> 8364       the reminder while the quest is active.
--   1043 -> 8360-8362 + 8373  the repeat offer, behind 8373 "Back to experience
--          the tremendous sense of satisfaction that can only come from
--          performing menial tasks for Abyssea's best and brightest".
--   1044 -> 8365-8372  THE TURN-IN, and it branches three ways on the strength
--          of what you handed over: 8366/8367 the ward shrugs it off ("Look at
--          it bounce off like a fly on a ruszor's mighty paunch!"), 8368/8369
--          the ward wavers ("I've not seen the ward waver like that before"),
--          8370/8371 the ward is breached ("It breached the ward!?
--          Belgidiveau's impervious ward!? Inconceivable!").
--   1045 -> 8372       the wrong item, on its own entry.
--
-- WHY THE TIER IS PARAM 0. 8366, 8368 and 8370 are three SEPARATE messages
-- rather than one ${choice}, so the event branches rather than substituting, and
-- the block's data[] holds the bare compare constants the branch needs --
--     data = [8355..8360, 0, 8361, 1, 8362, 2, 8363, 8364, 8373, 8365, 1024,
--             60, 44, 180, 8366, 8367, 8368, 8369, 3, 8370, 8371, 8372, 201]
-- with 0/1/2 sitting between the message ids exactly as they do for the 8360
-- menu compare. The wrong-item case is a csid of its own (1045), so 1044 only
-- ever has to distinguish the three valid strengths.
--
-- ITEM TIERS come from bg-wiki's own split: its explicit "High Strength" list is
-- tier 2, the two stackables it calls out separately are tier 0, and the
-- remaining tier-1 NM pop items it mentions without listing are tier 1.
--
-- ITEM NAMES: every item here already had an enum. Djinn Ashes is the container
-- word trap again -- item_basic holds it as name `vial_of_djinn_ashes` / sort
-- name `djinn_ashes`, and the existing enum is VIAL_OF_DJINN_ASHES (3106).
-----------------------------------
local vunkerlID = zones[xi.zone.ABYSSEA_VUNKERL]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_WARD_TO_END_ALL_WARDS)

-- item -> strength tier (0 bounces off, 1 makes the ward waver, 2 breaches it).
local fiendParts =
{
    -- bg-wiki's explicit "High Strength" list.
    [xi.item.AVIAN_REMEX]                  = 2,
    [xi.item.BLACK_WHISKER]                = 2,
    [xi.item.VIAL_OF_DJINN_ASHES]          = 2,
    [xi.item.FORTUNE_WING]                 = 2,
    [xi.item.GNARLED_TAURUS_HORN]          = 2,
    [xi.item.GORY_PINCER]                  = 2,
    [xi.item.HIGH_QUALITY_LIMULE_PINCER]   = 2,
    [xi.item.HIGH_QUALITY_RABBIT_HIDE]     = 2,
    [xi.item.MOCKING_BEAK]                 = 2,
    [xi.item.OPAQUE_WING]                  = 2,
    [xi.item.TRANSPARENT_INSECT_WING]      = 2,

    -- "Many other items work. They tend to be tier 1 NM pop items."
    [xi.item.RUSZOR_HIDE]                  = 1,
    [xi.item.LIMULE_PINCER]                = 1,
    [xi.item.MANIGORDO_TUSK]               = 1,
    [xi.item.OMINOUS_SKULL]                = 1,

    -- The two stackables bg-wiki calls out separately.
    [xi.item.AMOEBAN_PSEUDOPOD]            = 0,
    [xi.item.SANGUINET]                    = 0,
}

-- bg-wiki's cruor ranges, indexed by tier; credits are 8~12 regardless.
local firstCruor  = { [0] = 450, 500, 550 }
local repeatCruor = { [0] = 225, 250, 275 }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

local tradedTier = function(trade)
    for itemId, tier in pairs(fiendParts) do
        if npcUtil.tradeHasExactly(trade, itemId) then
            return tier
        end
    end

    return nil
end

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=Yes, and 1043 is his re-offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Belgidiveau'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_WARD_TO_END_ALL_WARDS) then
                        return quest:progressEvent(1043)
                    end

                    return quest:progressEvent(1040)
                end,
            },

            onEventFinish =
            {
                [1040] = function(player, csid, option, npc)
                    -- 8360: 0 "Anything to aid the cause!", 1 "Sorry, I have
                    -- better things to do."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,

                [1043] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_WARD_TO_END_ALL_WARDS)
                end,
            },
        },
    },

    -- Accepted: bring him a piece of an Abyssean fiend.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Belgidiveau'] =
            {
                onTrade = function(player, npc, trade)
                    local tier = tradedTier(trade)

                    if tier == nil then
                        -- 8372: "Does this look like a fiend's body part to
                        -- you?" He does not take it, so no confirmTrade.
                        return quest:event(1045)
                    end

                    -- The turn-in handler needs the tier again to size the
                    -- reward, and the event's own param is not readable there.
                    player:setLocalVar('AWardTier', tier)

                    return quest:progressEvent(1044, { [0] = tier })
                end,

                onTrigger = function(player, npc)
                    return quest:event(1042)
                end,
            },

            onEventFinish =
            {
                [1044] = function(player, csid, option, npc)
                    local tier  = player:getLocalVar('AWardTier')
                    local first = not player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_WARD_TO_END_ALL_WARDS)

                    player:confirmTrade()

                    if quest:complete(player) then
                        local cruor   = (first and firstCruor or repeatCruor)[tier]
                        local credits = math.random(8, 12)

                        player:addCurrency('cruor', cruor)
                        player:messageSpecial(vunkerlID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
                        player:addCurrency('resistance_credit', credits)
                    end

                    player:setLocalVar('AWardTier', 0)
                end,
            },
        },
    },
}

return quest
