-----------------------------------
-- A Discerning Eye (San d'Oria)
-----------------------------------
-- Log ID: 0, Quest ID: 104
-- Eddy : Port San d'Oria (H-6) near airship terminal
-----------------------------------
-- Retail: Eddy shows a random passenger description. Player boards the
-- San d'Oria-Jeuno airship, finds the matching random-appearance NPC,
-- and returns the Dropped item. Only one of several lookalikes is correct.
--
-- On this 4-player private server, the airship passenger RNG isn't
-- implemented, so the flow is simplified: accept from Eddy → zone into
-- the San d'Oria-Jeuno airship (sets 'Delivered') → return to Eddy for
-- 500 gil. Clears track toward the three retail titles.
-- CSIDs are best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.A_DISCERNING_EYE)

quest.reward =
{
    fame     = 5,
    fameArea = xi.fameArea.SANDORIA,
    gil      = 500,
}

local function updateTitle(player)
    local clears = player:getCharVar('DiscerningEyeClears')
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

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Eddy'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(585)
                end,
            },

            onEventFinish =
            {
                [585] = function(player, csid, option, npc)
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

        [xi.zone.SAN_DORIA_JEUNO_AIRSHIP] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Delivered') == 0 then
                    quest:setVar(player, 'Delivered', 1)
                end

                return -1
            end,
        },

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Eddy'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 1 then
                        return quest:progressEvent(586)
                    else
                        return quest:event(584)
                    end
                end,
            },

            onEventFinish =
            {
                [586] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DROPPED_ITEM)
                        player:setCharVar('DiscerningEyeClears', player:getCharVar('DiscerningEyeClears') + 1)
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

        -- Repeatable — restart from Eddy
        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Eddy'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                        return quest:progressEvent(585)
                    end
                end,
            },

            onEventFinish =
            {
                [585] = function(player, csid, option, npc)
                    if option == 1 then
                        -- Reopen quest for another run
                        player:addQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.A_DISCERNING_EYE)
                        npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM)
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },
}

return quest
