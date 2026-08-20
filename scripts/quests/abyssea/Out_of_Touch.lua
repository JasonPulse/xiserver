-----------------------------------
-- Out of Touch
-----------------------------------
-- Log ID: 8, Quest ID: 8
-- Glenne   : Abyssea - La Theine (L-11), entity 17318644
-- Aaveleon : Abyssea - La Theine (roaming), entity 17318645
-- !addquest 8 8
-----------------------------------
-- Retail (bg-wiki "Out of Touch").
-- |Start=Glenne (A) (L-11), Abyssea - La Theine
-- |Reward=1,000 Cruor, Scarlet abyssite of kismet
--   1. Speak to Glenne (A) at (L-11), Veridical Conflux #06.
--   2. She gives you a Rainbow-colored linkpearl.
--   3. Locate and speak to Aaveleon (A). He has a fairly large roaming pattern
--      that covers most of Abyssea - La Theine; widescan greatly aids tracking.
--   4. Return to Glenne (A).
--
-- CSIDS DECODED, NOT GUESSED, with csidscan.py against `xi-dat dialog 132`:
--   Glenne 213 -> 8020/8021  her pre-quest worrying.
--   Glenne 214 -> 8022-8029  THE OFFER. 8022 "My husband is on patrol, and it's
--          well past the time I'm supposed to hear from him", 8024 "Could I
--          trouble you to deliver this ${keyitem-singular: 0[2]} to him?" -- the
--          linkpearl is param 0 -- and 8026 is the accept prompt: "Deliver the
--          linkpearl? ${selection-lines} Of course I will. / Not right now." --
--          the affirmative is FIRST, so OPTION 0 ACCEPTS, 8027 is the decline.
--          8028 names the husband: "My husband's name is Aaveleon."
--   Glenne 215 -> 8028/8029  the reminder, naming him and where he patrols.
--   Glenne 216 -> 8030/8031  THE COMPLETION. "I was able to regain contact with
--          my husband again. Thank you so much!"
--   Glenne 217 -> 8031       her post-completion line.
--   Aaveleon 218 -> 8032     his brush-off before the quest: "Forgive me, but
--          I'm in the midst of patrol duty."
--   Aaveleon 219 -> 8033-8049  THE DELIVERY.
--
-- KEY ITEM: Rainbow-colored linkpearl is the existing
-- RAINBOW_COLORED_LINKPEARL (1589). Note the several other linkpearl key items
-- (Captain Rashid's 1575, Captain Argus's 1576, Captain Helga's 1577) belong to
-- other Abyssea quests and are not interchangeable -- checked by id.
-----------------------------------
local laTheineID = zones[xi.zone.ABYSSEA_LA_THEINE]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.OUT_OF_TOUCH)

local cruorReward = 1000

quest.reward =
{
    keyItem = xi.ki.SCARLET_ABYSSITE_OF_KISMET,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Glenne'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(214, { [0] = xi.ki.RAINBOW_COLORED_LINKPEARL })
                end,
            },

            ['Aaveleon'] = quest:event(218),

            onEventFinish =
            {
                [214] = function(player, csid, option, npc)
                    -- 8026: 0 "Of course I will.", 1 "Not right now."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.RAINBOW_COLORED_LINKPEARL)
                end,
            },
        },
    },

    -- Accepted: find Aaveleon out on patrol.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Delivered == 0
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Aaveleon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(219, { [0] = xi.ki.RAINBOW_COLORED_LINKPEARL })
                end,
            },

            ['Glenne'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(215, { [0] = xi.ki.RAINBOW_COLORED_LINKPEARL })
                end,
            },

            onEventFinish =
            {
                [219] = function(player, csid, option, npc)
                    quest:setVar(player, 'Delivered', 1)
                    player:delKeyItem(xi.ki.RAINBOW_COLORED_LINKPEARL)
                end,
            },
        },
    },

    -- Delivered: report back to Glenne.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Delivered == 1
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Glenne'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(216)
                end,
            },

            ['Aaveleon'] = quest:event(220),

            onEventFinish =
            {
                [216] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Delivered', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(laTheineID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Glenne'] = quest:event(217):replaceDefault(),
        },
    },
}

return quest
