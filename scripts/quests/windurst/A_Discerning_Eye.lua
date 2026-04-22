-----------------------------------
-- A Discerning Eye (Windurst)
-----------------------------------
-- Log ID: 2, Quest ID: 89
-- Pygmalion : Port Windurst (M-7)
-----------------------------------
-- Retail airship random-NPC RNG; simplified for 4-player server:
-- accept → zone into Windurst-Jeuno airship → return to Pygmalion for 500 gil.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.A_DISCERNING_EYE)

quest.reward =
{
    fame     = 5,
    fameArea = xi.fameArea.WINDURST,
    gil      = 500,
}

local function updateTitle(player)
    local clears = player:getCharVar('DiscerningEyeWindurstClears')
    if clears >= 100 then
        player:setTitle(xi.title.EXTREMELY_DISCERNING_INDIVIDUAL)
    elseif clears >= 20 then
        player:setTitle(xi.title.VERY_DISCERNING_INDIVIDUAL)
    elseif clears >= 5 then
        player:setTitle(xi.title.DISCERNING_INDIVIDUAL)
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Pygmalion'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(240)
                end,
            },

            onEventFinish =
            {
                [240] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_JEUNO_AIRSHIP] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Delivered') == 0 then
                    quest:setVar(player, 'Delivered', 1)
                end

                return -1
            end,
        },

        [xi.zone.PORT_WINDURST] =
        {
            ['Pygmalion'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 1 then
                        return quest:progressEvent(241)
                    end
                end,
            },

            onEventFinish =
            {
                [241] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DROPPED_ITEM)
                        player:setCharVar('DiscerningEyeWindurstClears', player:getCharVar('DiscerningEyeWindurstClears') + 1)
                        updateTitle(player)
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Pygmalion'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                        return quest:progressEvent(240)
                    end
                end,
            },

            onEventFinish =
            {
                [240] = function(player, csid, option, npc)
                    if option == 1 then
                        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.A_DISCERNING_EYE)
                        npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM)
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },
}

return quest
