-----------------------------------
-- Forest for the Trees
-----------------------------------
-- Log ID: 0, Quest ID: 118
-- Ramua        : !pos -184 11 256 231
-- Cheupirudaux : Northern San d'Oria Woodworking Guild (has existing script)
-- Hand in 5 log types: Arrowwood, Ash, Yew, Willow, Walnut
-- CSIDs below are best-guess from client event dump — verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.FOREST_FOR_THE_TREES)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    item     = xi.item.TRAINEE_AXE,
    title    = xi.title.EDITORS_HATCHET_MAN,
}

-- Bit flags on quest var 'Checklist' — one bit per required log type.
local logBits =
{
    [xi.item.ARROWWOOD_LOG] = 1,
    [xi.item.ASH_LOG]       = 2,
    [xi.item.YEW_LOG]       = 4,
    [xi.item.WILLOW_LOG]    = 8,
    [xi.item.WALNUT_LOG]    = 16,
}

local ALL_LOGS_MASK = 31

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 3
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Ramua'] =
            {
                onTrigger = function(player, npc)
                    -- Offer quest only if player has registered with Woodworking Guild
                    -- (craftRank > 0). Otherwise default NPC dialogue runs.
                    if player:getSkillRank(xi.skill.WOODWORKING) > 0 then
                        return quest:progressEvent(635)
                    end
                end,
            },

            onEventFinish =
            {
                [635] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.TIMBER_SURVEY_CHECKLIST)
                        npcUtil.giveItem(player, xi.item.HATCHET)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Ramua'] =
            {
                onTrade = function(player, npc, trade)
                    local checklist = quest:getVar(player, 'Checklist')
                    local newChecklist = checklist
                    local progressed = false

                    for itemId, bit in pairs(logBits) do
                        if
                            utils.mask.getBit(checklist, bit - 1) == false and
                            npcUtil.tradeHas(trade, itemId)
                        then
                            newChecklist = utils.mask.setBit(newChecklist, bit - 1, true)
                            progressed = true
                        end
                    end

                    if newChecklist == ALL_LOGS_MASK then
                        return quest:progressEvent(636)
                    elseif progressed then
                        quest:setVar(player, 'Checklist', newChecklist)
                        player:confirmTrade()
                        return quest:event(636):replaceDefault()
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(636)
                end,
            },

            onEventFinish =
            {
                [636] = function(player, csid, option, npc)
                    if quest:getVar(player, 'Checklist') == ALL_LOGS_MASK then
                        if quest:complete(player) then
                            player:confirmTrade()
                            player:delKeyItem(xi.ki.TIMBER_SURVEY_CHECKLIST)
                            -- Logs are returned per bg-wiki; trade was not actually consumed on progress steps
                        end
                    end
                end,
            },
        },
    },
}

return quest
