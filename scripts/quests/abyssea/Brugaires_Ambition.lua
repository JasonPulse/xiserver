-----------------------------------
-- Brugaire's Ambition
-----------------------------------
-- Log ID: 8, Quest ID: 59
-- Brugaire : Abyssea - Grauberg (L-6), entity 17818241
-- !addquest 8 59
-----------------------------------
-- Retail (bg-wiki): |Start=Brugaire (A) (L-6), northeast of Conflux #8
-- |Item Reqs=Prismatic Elixir  |Repeatable=Yes
-- |Reward=First time completion: 400 Cruor. Subsequent: 200 Cruor.
--   He gives a Prismatic Elixir; spawn Teekesselchen, use it, kill the NM,
--   return.
--
-- CSIDS (csidmsg.load + find_msg vs `xi-dat dialog 254`; NPC confirmed by
-- resolve_npc.py -- item 5445 sits at data[12] of his block):
--   250 -> 8144-8151  THE OFFER. 8145 names the Teekesselchen, 8146/8147 the
--          draught "claimed to have a weakening effect", and 8149 is the accept
--          prompt "Be the wielder? ${selection-lines} You can count on me! /
--          Sorry, not interested." -- OPTION 0 ACCEPTS, 8150 is the decline.
--   251 -> 8152/8153/8165  the reminder, with the location: "often seen prowling
--          the area northwest of here", and the task using ${item-singular: 0[2]}.
--   254 -> 8154/8155  THE REPLACEMENT path: "Misplaced the ${item-singular: 0[2]},
--          you say? I will give you this replacement" -- so a lost elixir is
--          recoverable, which is why the trigger below re-issues it.
--   252 -> 8156-8158  THE TURN-IN. 8156 "Your epochal victory over the
--          Teekesselchen", 8158 "Take this as your deserved share."
--   253 -> 8159       his post-completion line.
--
-- SCOPE: the elixir's combat weakening effect is item behaviour, not quest
-- logic, and is not implemented here -- the same boundary drawn for fishing in
-- The_Secret_Ingredient.lua. This file implements the quest: offer, elixir
-- issue and re-issue, NM kill credit via onMobDeath, and the reward.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRUGAIRES_AMBITION)

local firstReward  = 400
local repeatReward = 200

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Brugaire'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(250, { [0] = xi.item.PRISMATIC_ELIXIR })
                end,
            },

            onEventFinish =
            {
                [250] = function(player, csid, option, npc)
                    -- 8149: 0 "You can count on me!", 1 "Sorry, not interested."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRUGAIRES_AMBITION) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRUGAIRES_AMBITION)
                    else
                        quest:begin(player)
                    end

                    quest:setVar(player, 'Slain', 0)
                    npcUtil.giveItem(player, xi.item.PRISMATIC_ELIXIR)
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
            onMobDeath =
            {
                [graubergID.mob.TEEKESSELCHEN] = function(mob, player, optParams)
                    if optParams.isKiller or optParams.noKiller then
                        quest:setVar(player, 'Slain', 1)
                    end
                end,
            },

            ['Brugaire'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Slain') == 1 then
                        return quest:progressEvent(252, { [0] = xi.item.PRISMATIC_ELIXIR })
                    end

                    -- 8154/8155: he replaces a lost draught.
                    if not player:hasItem(xi.item.PRISMATIC_ELIXIR) then
                        return quest:progressEvent(254, { [0] = xi.item.PRISMATIC_ELIXIR })
                    end

                    return quest:event(251, { [0] = xi.item.PRISMATIC_ELIXIR })
                end,
            },

            onEventFinish =
            {
                [254] = function(player, csid, option, npc)
                    npcUtil.giveItem(player, xi.item.PRISMATIC_ELIXIR)
                end,

                [252] = function(player, csid, option, npc)
                    local first = quest:getVar(player, 'Paid') == 0

                    if quest:complete(player) then
                        quest:setVar(player, 'Slain', 0)
                        quest:setVar(player, 'Paid', 1)

                        local cruor = first and firstReward or repeatReward
                        player:addCurrency('cruor', cruor)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
