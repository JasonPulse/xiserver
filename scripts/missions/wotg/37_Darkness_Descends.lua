-----------------------------------
-- Darkness Descends
-- Wings of the Goddess Mission 37
-----------------------------------
-- !addmission 5 36
-----------------------------------

local mission = Mission:new(xi.mission.log_id.WOTG, xi.mission.id.wotg.DARKNESS_DESCENDS)

mission.reward =
{
    nextMission = { xi.mission.log_id.WOTG, xi.mission.id.wotg.ADIEU_LILISETTE },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.THRONE_ROOM_S] =
        {
            onZoneIn = function(player, prevZone)
                local missionStatus = mission:getVar(player, 'Status')

                if missionStatus == 0 then
                    return 8
                elseif missionStatus == 2 then
                    return 10
                end
            end,

            onEventUpdate =
            {
                [8] = function(player, csid, option, npc)
                    if option == 5 then
                        -- TODO: Check this update with Bastok or Windurst as allegiance to verify
                        -- the first parameter.

                        player:updateEvent(1, 23, 1756, 470, 470, 848, 0, 0)
                    end
                end,

                [10] = function(player, csid, option, npc)
                    if option == 5 then
                        player:updateEvent(156, 10, 305, 183, 320, 847, 450, 0)
                    end
                end,
            },

            onEventFinish =
            {
                [8] = function(player, csid, option, npc)
                    mission:setVar(player, 'Status', 1)
                end,

                [10] = function(player, csid, option, npc)
                    mission:complete(player)
                end,

                [32001] = function(player, csid, option, npc)
                    -- battlefieldWin is set by the battlefield framework on win
                    -- (scripts/battlefields/Throne_Room_[S]/darkness_descends.lua).

                    if
                        player:getLocalVar('battlefieldWin') == xi.battlefield.id.DARKNESS_DESCENDS and
                        mission:getVar(player, 'Status') == 1
                    then
                        mission:setVar(player, 'Status', 2)
                        player:setPos(-90.854, -5.75, -0.009, 129, xi.zone.THRONE_ROOM_S)
                    end
                end,
            },
        },
    },
}

return mission
