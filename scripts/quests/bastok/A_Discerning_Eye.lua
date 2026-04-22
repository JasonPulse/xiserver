-----------------------------------
-- A Discerning Eye (Bastok)
-----------------------------------
-- Log ID: 1, Quest ID: 71
-- Grin : Port Bastok (G-7)
-----------------------------------
-- Retail airship random-NPC RNG; simplified for 4-player server:
-- accept → zone into Bastok-Jeuno airship → return to Grin for 500 gil.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.A_DISCERNING_EYE)

quest.reward =
{
    fame     = 5,
    fameArea = xi.fameArea.BASTOK,
    gil      = 500,
}

local function updateTitle(player)
    local clears = player:getCharVar('DiscerningEyeBastokClears')
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

        [xi.zone.PORT_BASTOK] =
        {
            ['Grin'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(140)
                end,
            },

            onEventFinish =
            {
                [140] = function(player, csid, option, npc)
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

        [xi.zone.BASTOK_JEUNO_AIRSHIP] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Delivered') == 0 then
                    quest:setVar(player, 'Delivered', 1)
                end
                return -1
            end,
        },

        [xi.zone.PORT_BASTOK] =
        {
            ['Grin'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 1 then
                        return quest:progressEvent(141)
                    end
                end,
            },

            onEventFinish =
            {
                [141] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DROPPED_ITEM)
                        player:setCharVar('DiscerningEyeBastokClears', player:getCharVar('DiscerningEyeBastokClears') + 1)
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

        [xi.zone.PORT_BASTOK] =
        {
            ['Grin'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                        return quest:progressEvent(140)
                    end
                end,
            },

            onEventFinish =
            {
                [140] = function(player, csid, option, npc)
                    if option == 1 then
                        player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.A_DISCERNING_EYE)
                        npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM)
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },
}

return quest
