-----------------------------------
-- Hyper Active
-----------------------------------
-- Log ID: 1, Quest ID: 80
-- Raibaht : Metalworks (G-8), default event 501
-- Cermet Door + Orna NM : Lower Delkfutt's Tower basement
-- Street Lamp : Lower Jeuno
-----------------------------------
-- Retail: kill Orna NM at Cermet Door, find Hyper Altimeter via
-- Street Lamp inspection in Lower Jeuno.
-- Simplified for 4-player server: accept from Raibaht → receive
-- Molybdenum Box → zone into Lower Delkfutt's Tower (sets flag) →
-- click Street Lamp in Lower Jeuno for Hyper Altimeter → return
-- to Raibaht. Skips the Orna NM kill — private server, no NM infra
-- for this pop yet.
-- Prerequisite: Teak Me to the Stars (checked), Delkfutt Key required
-- to reach basement on retail.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.HYPER_ACTIVE)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.BASTOK,
    gil      = 3000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 4 and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.TEAK_ME_TO_THE_STARS)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(502)
                end,
            },

            onEventFinish =
            {
                [502] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.MOLYBDENUM_BOX)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_DELKFUTTS_TOWER] =
        {
            onZoneIn = function(player, prevZone)
                if
                    player:hasKeyItem(xi.ki.MOLYBDENUM_BOX) and
                    quest:getVar(player, 'TowerVisited') == 0
                then
                    quest:setVar(player, 'TowerVisited', 1)
                end

                return -1
            end,
        },

        [xi.zone.LOWER_JEUNO] =
        {
            -- Streetlamps in Lower Jeuno are polymorphic entities _l00 through _l19.
            -- Retail quest script checked a specific lamp; on this server the first
            -- lamp (_l00) is the quest-giving one.
            ['_l00'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'TowerVisited') == 1 and
                        not player:hasKeyItem(xi.ki.HYPER_ALTIMETER)
                    then
                        return quest:keyItem(xi.ki.HYPER_ALTIMETER)
                    end
                end,
            },
        },

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.HYPER_ALTIMETER) then
                        return quest:progressEvent(503)
                    end
                end,
            },

            onEventFinish =
            {
                [503] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.HYPER_ALTIMETER)
                        player:delKeyItem(xi.ki.MOLYBDENUM_BOX)
                    end
                end,
            },
        },
    },
}

return quest
