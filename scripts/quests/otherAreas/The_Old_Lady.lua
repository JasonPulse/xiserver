-----------------------------------
-- The Old Lady
-----------------------------------
-- Log ID: 4, Quest ID: 10
-- Vera !pos -49 -5 20 249
-----------------------------------
local mhauraID = zones[xi.zone.MHAURA]
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.THE_OLD_LADY)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ELDER_MEMORIES) == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MHAURA] =
        {
            ['Vera'] =
            {
                onTrigger = function(player, npc)
                    if player:getMainLvl() >= xi.settings.main.SUBJOB_QUEST_LEVEL then
                        return quest:progressEvent(131, xi.item.WILD_RABBIT_TAIL)
                    else
                        return quest:progressEvent(133)
                    end
                end,
            },

            onEventFinish =
            {
                [131] = function(player, csid, option, npc)
                    if option == 40 then
                        quest:begin(player)
                        quest:setVar(player, 'Prog', 1)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MHAURA] =
        {
            ['Vera'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GILGAMESHS_INTRODUCTORY_LETTER) then
                        return quest:progressEvent(137)
                    end

                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 then
                        return quest:progressEvent(132, xi.item.WILD_RABBIT_TAIL)
                    elseif prog == 2 then
                        return quest:progressEvent(132, xi.item.CUP_OF_DHALMEL_SALIVA)
                    elseif prog == 3 then
                        return quest:progressEvent(132, xi.item.BLOODY_ROBE)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if trade:getItemCount() ~= 1 then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 and trade:hasItemQty(xi.item.WILD_RABBIT_TAIL, 1) then
                        return quest:progressEvent(135, xi.item.CUP_OF_DHALMEL_SALIVA)
                    elseif prog == 2 and trade:hasItemQty(xi.item.CUP_OF_DHALMEL_SALIVA, 1) then
                        return quest:progressEvent(136, xi.item.BLOODY_ROBE)
                    elseif prog == 3 and trade:hasItemQty(xi.item.BLOODY_ROBE, 1) then
                        return quest:progressEvent(137)
                    end
                end,
            },

            onEventFinish =
            {
                [135] = function(player, csid, option, npc)
                    player:tradeComplete()
                    quest:setVar(player, 'Prog', 2)
                end,

                [136] = function(player, csid, option, npc)
                    player:tradeComplete()
                    quest:setVar(player, 'Prog', 3)
                end,

                [137] = function(player, csid, option, npc)
                    player:tradeComplete()
                    player:unlockJob(0)
                    player:messageSpecial(mhauraID.text.SUBJOB_UNLOCKED)
                    quest:setVar(player, 'Prog', 0)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MHAURA] =
        {
            ['Vera'] = quest:progressEvent(138),
        },
    },
}

return quest
