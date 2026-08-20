-----------------------------------
-- Shady Business Redux
-----------------------------------
-- Log ID: 8, Quest ID: 15
-- Talib : Abyssea - Konschtat (D-7), entity 16839224
-- !addquest 8 15
-----------------------------------
-- Retail (bg-wiki "Shady Business Redux").
-- |Start=Talib (A) (D-7), Abyssea - Konschtat  |Previous=Rose on the Heath
-- |Item Reqs=Limule Pincer x4  |Reward=400 Cruor  |Repeatable=Yes
--   1. Speak to Talib (A) at (D-7), slightly north/east of Veridical Conflux #03.
--   2. He requests 4 Limule Pincers.
--   3. Trade the items to Talib (A) to complete the quest.
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Talib is 16839224; (16839224-16777216) = 62008,
-- 62008//4096 = 15 rem 568 -> Abyssea - Konschtat, 0x0100F238. `xi-dat events 15`
-- gives him exactly seven: 209, 250, 251, 252, 253, 254, 255. Resolved with
-- csidscan.py against `xi-dat dialog 15` (csidmsg.py returns nothing for this
-- zone):
--   250 -> 7960-7965  THE FIRST-TIME OFFER. 7960 "you must be the one Argus was
--          talkin' about", through 7964, ending on the request itself:
--          7965 "Round up ${number: 1} ${item-given-plurality: 1[2], 0[2]} for
--          me, and you can bet I'll make it worth your while." The ${number: 1}
--          slot is why the count is param 1 and the item is param 0.
--   251 -> 7965/7966  the reminder while it is active: 7966 "How's business?
--          Eh, I've done better. That's why I need your help."
--   252 -> 7967       THE TURN-IN. "Finally a business partner who's good to
--          ${choice-player-gender}[his/her] word. Guess I owe you the same.
--          Here's your cut of the future profits."
--   253 -> 7968       THE REPEAT OFFER. "Back for some more business? Bring me
--          ${number: 1} more ${item-given-plurality: 1[2], 7[2]} and I'll see
--          that you're handsomely paid."
--   254 -> 7967/7969  the repeat turn-in.
--   255 -> 7959       "I ain't got no business with ya, and that means I don't
--          wanna see ya. Get lost!" -- the not-yet-eligible line, which is what
--          makes the Rose on the Heath gate visible in-game rather than silent.
--
-- There is no non-Redux "Shady Business" in the Abyssea log -- `Shady_Business.lua`
-- is a Bastok quest (bastok id 8) and unrelated. "Redux" is part of the retail
-- name, and SHADY_BUSINESS_REDUX = 15 is the only Talib entry, which is why all
-- six of his csids belong to this one quest: bg-wiki marks it Repeatable=Yes, so
-- it carries a first-time offer/turn-in pair (250/252) and a repeat pair
-- (253/254).
--
-- ITEM: Limule Pincer is id 2889 (`item_basic`), which had no enum name and was
-- added as LIMULE_PINCER after checking the id was unused. Note the separate
-- HIGH_QUALITY_LIMULE_PINCER (2916) is a different item and is NOT accepted,
-- matching bg-wiki's |Item Reqs=.
--
-- CRUOR: bg-wiki |Reward=400 Cruor. Awarded via addCurrency + the zone's
-- CRUOR_OBTAINED text, the same way Megadrile_Menace.lua reports its 50.
-----------------------------------
local konschtatID = zones[xi.zone.ABYSSEA_KONSCHTAT]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SHADY_BUSINESS_REDUX)

local pincerCount = 4
local cruorReward = 400

quest.sections =
{
    -- Not yet eligible: he tells you to get lost. bg-wiki |Previous=Rose on the
    -- Heath, so the gate is that quest rather than bare QUEST_AVAILABLE.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                not player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.ROSE_ON_THE_HEATH)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Talib'] = quest:event(255),
        },
    },

    -- Eligible. COMPLETED is accepted too because bg-wiki marks this
    -- Repeatable=Yes, and 253 exists precisely to re-offer it.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.ROSE_ON_THE_HEATH)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Talib'] =
            {
                onTrigger = function(player, npc)
                    -- 250 carries the whole introduction; 253 is the short
                    -- "back for some more business?" re-offer.
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SHADY_BUSINESS_REDUX) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(253, { [1] = pincerCount })
                    end

                    return quest:progressEvent(250, { [1] = pincerCount })
                end,
            },

            onEventFinish =
            {
                [250] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [253] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SHADY_BUSINESS_REDUX)
                end,
            },
        },
    },

    -- Accepted: bring him the pincers.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Talib'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.LIMULE_PINCER, pincerCount } }) then
                        return quest:progressEvent(252)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(251, { [1] = pincerCount })
                end,
            },

            onEventFinish =
            {
                [252] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(konschtatID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
