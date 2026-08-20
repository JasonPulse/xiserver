-----------------------------------
-- Smoke over the Coast
-----------------------------------
-- Log ID: 8, Quest ID: 53
-- Hungry_Wolf : Abyssea - Misareaux (G-7), entity 17748007
-- !addquest 8 53
-----------------------------------
-- Retail (bg-wiki): |Start=Hungry Wolf (A) (G-7)  |Repeatable=Yes
-- |Item Reqs=Galkan Sausage/+1/+2/+3
-- |Reward=200~600 Cruor, depending on quality of sausage
--   Speak to Hungry Wolf at (G-7) near Conflux #3, then trade him a sausage.
--
-- CSIDS (csidmsg.load + find_msg vs `xi-dat dialog 237`; NPC confirmed by
-- resolve_npc.py -- item 4395 sits at data[1] of his block):
--   421 -> 7514            his idle line, "I'm hungry...no, I mean, I'm starved."
--   428 -> 7515-7518       THE OFFER. 7516 "My friend, Offa, has been telling me
--          that ${item-plural: 7[2]} are exquisite!" -- the sausage is PARAM 7.
--   429 -> 7519            THE TURN-IN. "Hey! Is that ${article}
--          ${item-article: 7[2]}? Let me have it! Here, I'll give you this!"
-- Cruor scales with tier, per bg-wiki's "depending on quality of sausage".
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SMOKE_OVER_THE_COAST)

-- item -> cruor. bg-wiki gives the 200~600 band; tiers are mapped across it.
local sausages =
{
    [xi.item.GALKAN_SAUSAGE]    = 200,
    [xi.item.GALKAN_SAUSAGE_1]  = 400,
    [xi.item.GALKAN_SAUSAGE_2]  = 500,
    [xi.item.GALKAN_SAUSAGE_3]  = 600,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Hungry_Wolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(428, { [7] = xi.item.GALKAN_SAUSAGE })
                end,
            },

            onEventFinish =
            {
                [428] = function(player, csid, option, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SMOKE_OVER_THE_COAST) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SMOKE_OVER_THE_COAST)
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

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Hungry_Wolf'] =
            {
                onTrade = function(player, npc, trade)
                    for itemId, cruor in pairs(sausages) do
                        if npcUtil.tradeHasExactly(trade, itemId) then
                            player:setLocalVar('[SOTC]cruor', cruor)
                            return quest:progressEvent(429, { [7] = itemId })
                        end
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(421)
                end,
            },

            onEventFinish =
            {
                [429] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        local cruor = player:getLocalVar('[SOTC]cruor')
                        player:setLocalVar('[SOTC]cruor', 0)
                        player:addCurrency('cruor', cruor)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
