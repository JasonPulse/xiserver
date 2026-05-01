-----------------------------------
-- A Discerning Eye (Kazham)
-----------------------------------
-- Log ID: 5, Quest ID: 14
-- Swift : Kazham (H-7)
-----------------------------------
-- Retail airship RNG; simplified for 4-player server: accept → zone into
-- Kazham-Jeuno airship → return to Swift for 500 gil. Same pattern as
-- the 3 nation variants — clears count toward retail titles.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.A_DISCERNING_EYE)

quest.reward =
{
    fame     = 5,
    fameArea = xi.fameArea.WINDURST,
    gil      = 500,
}

local function updateTitle(player)
    local clears = player:getCharVar('DiscerningEyeKazhamClears')
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

        [xi.zone.KAZHAM] =
        {
            ['Swift'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(200)
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
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

        [xi.zone.KAZHAM_JEUNO_AIRSHIP] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Delivered') == 0 then
                    quest:setVar(player, 'Delivered', 1)
                end

                return -1
            end,
        },

        [xi.zone.KAZHAM] =
        {
            ['Swift'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 1 then
                        return quest:progressEvent(201)
                    end
                end,
            },

            onEventFinish =
            {
                [201] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DROPPED_ITEM)
                        player:setCharVar('DiscerningEyeKazhamClears', player:getCharVar('DiscerningEyeKazhamClears') + 1)
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

        [xi.zone.KAZHAM] =
        {
            ['Swift'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                        return quest:progressEvent(200)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    if option == 1 then
                        player:addQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.A_DISCERNING_EYE)
                        npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM)
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },
}

return quest
