-----------------------------------
-- Chips
-----------------------------------
-- Log ID: 1, Quest ID: 82
-----------------------------------
-- CoP 6-3        : !addmission 6 628
-- CoP 7-1        : !addmission 6 648
-----------------------------------
-- bg-wiki "Chips": |Quest Reqs=[[Promathia Mission 6-3]], and
-- `Promathia Mission 6-3` is |Mission Name=More Questions than Answers, which is
-- xi.mission.id.cop.MORE_QUESTIONS_THAN_ANSWERS = 628. The gate below used
-- ONE_TO_BE_FEARED = 638, i.e. CoP 6-4 -- one mission too strict, so the quest
-- could not be flagged during the whole of 6-3.
-- Ghebi Damomohe : !pos 15.535 -0.111 -7.603
-- Cid            : !pos -12 -12 1 237
-----------------------------------
local metalID = zones[xi.zone.METALWORKS]
-----------------------------------

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.CHIPS)

quest.reward =
{
    item = xi.item.CCB_POLYMER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Ghebi_Damomohe'] =
            {
                onTrigger = function(player, npc)
                    if
                        not quest:getMustZone(player) and
                        (player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.MORE_QUESTIONS_THAN_ANSWERS) or
                        (player:getCurrentMission(xi.mission.log_id.COP) == xi.mission.id.cop.MORE_QUESTIONS_THAN_ANSWERS and
                        xi.mission.getVar(player, xi.mission.log_id.COP, xi.mission.id.cop.MORE_QUESTIONS_THAN_ANSWERS, 'Status') >= 1))
                    then
                        return quest:progressEvent(169)
                    end
                end,
            },

            onEventFinish =
            {
                [169] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    elseif option == 1 then
                        quest:setMustZone(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Cid'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { xi.item.CARMINE_CHIP, xi.item.CYAN_CHIP, xi.item.GRAY_CHIP }) then
                        if
                            player:getFreeSlotsCount() == 0 or
                            player:hasItem(xi.item.CCB_POLYMER)
                        then
                            return player:messageSpecial(metalID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.CCB_POLYMER)
                        else
                            return quest:progressEvent(883)
                        end
                    end
                end,
            },

            onEventFinish =
            {
                [883] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Cid'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { xi.item.CARMINE_CHIP, xi.item.CYAN_CHIP, xi.item.GRAY_CHIP }) then
                        if
                            player:getFreeSlotsCount() == 0 or
                            player:hasItem(xi.item.CCB_POLYMER)
                        then
                            return player:messageSpecial(metalID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.CCB_POLYMER)
                        else
                            return quest:progressEvent(884)
                        end
                    end
                end,
            },

            onEventFinish =
            {
                [884] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
