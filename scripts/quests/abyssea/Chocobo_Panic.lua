-----------------------------------
-- Chocobo Panic
-----------------------------------
-- Log ID: 8, Quest ID: 60
-- Kuoh_Rhel : Abyssea - Grauberg (G-7), entity 17818235
-- !addquest 8 60
-----------------------------------
-- Retail (bg-wiki): |Start=Kuoh Rhel (A) (G-7)  |Repeatable=Yes
-- |Item Reqs=Grauberg Greens, or Woozyshroom x10
-- |Reward=Indigo abyssite of confluence (with Woozyshroom); cruor otherwise
--   His pack chocobo won't eat. Feed it Grauberg Greens for cruor, or ten
--   Woozyshrooms for the abyssite -- but the shrooms ruin the bird, which is
--   what 8072/8073 are about, and why that path is the one-off abyssite.
--
-- CSIDS (csidmsg.load + find_msg vs `xi-dat dialog 254`; NPC confirmed by
-- resolve_npc.py -- item 4373 Woozyshroom sits at data[18] of his block):
--   231 -> 8055-8063  THE OFFER. 8056 is the accept prompt "Did Tosuka-Porika
--          send you? ${selection-lines} He sure did! / Tosu...who?" -- and note
--          BOTH answers continue (8057 vs 8059), so neither option declines.
--          8060/8061 state the problem: the chocobo "refusin' to eat anythin'".
--   232 -> 8063        the reminder.
--   234 -> 8071        THE GREENS TURN-IN: "Now mah feathered friend and I can
--          get back to the jolly ol' business o' transporrrtin' goo[ds]".
--   236 -> 8074        THE WOOZYSHROOM TURN-IN, after 8072 "You gave it what!?
--          You mus' never--everrr--feed ${item-plural: 0[2]} to chocobos!"
--          param 0 is the shroom, param 1 the greens.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CHOCOBO_PANIC)

local shroomCount = 10
local cruorReward = 400

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Kuoh_Rhel'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(231,
                        { [0] = xi.item.WOOZYSHROOM, [1] = xi.item.BUNCH_OF_GRAUBERG_GREENS })
                end,
            },

            onEventFinish =
            {
                [231] = function(player, csid, option, npc)
                    -- Both 8056 answers continue the scene, so no option check.
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CHOCOBO_PANIC) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CHOCOBO_PANIC)
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
            ['Kuoh_Rhel'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.BUNCH_OF_GRAUBERG_GREENS) then
                        return quest:progressEvent(234, { [1] = xi.item.BUNCH_OF_GRAUBERG_GREENS })
                    end

                    if npcUtil.tradeHasExactly(trade, { { xi.item.WOOZYSHROOM, shroomCount } }) then
                        return quest:progressEvent(236, { [0] = xi.item.WOOZYSHROOM })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(232)
                end,
            },

            onEventFinish =
            {
                [234] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,

                [236] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.INDIGO_ABYSSITE_OF_CONFLUENCE)
                    end
                end,
            },
        },
    },
}

return quest
