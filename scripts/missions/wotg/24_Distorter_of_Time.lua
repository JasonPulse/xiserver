-----------------------------------
-- Distorter of Time
-- Wings of the Goddess Mission 24
-----------------------------------
-- !addmission 5 23
-- Regal Pawprints (9) : !pos 54.437 -41.904 104.974 136
-----------------------------------

local mission = Mission:new(xi.mission.log_id.WOTG, xi.mission.id.wotg.DISTORTER_OF_TIME)

mission.reward =
{
    nextMission = { xi.mission.log_id.WOTG, xi.mission.id.wotg.THE_WILL_OF_THE_WORLD },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.BEAUCEDINE_GLACIER_S] =
        {
            ['Regal_Pawprints_1'] =
            {
                onTrigger = function(player, npc)
                    if
                        not player:hasKeyItem(xi.ki.UMBRA_BUG) and
                        mission:getVar(player, 'Timer') <= VanadielUniqueDay()
                    then
                        -- TODO: For future Instance implementation, on instance fail,
                        -- Timer var should be set to VanadielUniqueDay() + 1

                        return mission:progressEvent(26, 136, 23, 1756)
                    end
                end,
            },

            onZoneIn = function(player, prevZone)
                if mission:getVar(player, 'Status') == 1 then
                    return 19
                end
            end,

            onEventFinish =
            {
                [19] = function(player, csid, option, npc)
                    mission:complete(player)
                end,

                [26] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.UMBRA_BUG)
                end,
            },
        },

        [xi.zone.RUHOTZ_SILVERMINES] =
        {
            onEventFinish =
            {
                [10000] = function(player, csid, option, npc)
                    -- LIVE EXPLOIT FIXED. csid 10000 is the shared "instance
                    -- cleared" event for Ruhotz Silvermines, and this handler had
                    -- no guard beyond `currentMission == DISTORTER_OF_TIME`.
                    -- scripts/zones/Ruhotz_Silvermines/instances/light_in_the_darkness.lua
                    -- fires startEvent(10000) on clear, and onEventFinish is
                    -- dispatched zone-wide on csid alone -- so any player on this
                    -- mission who cleared Light in the Darkness had Status set to
                    -- 1 and was teleported to Beaucedine Glacier [S], where the
                    -- onZoneIn above then fires event 19 and completes the mission.
                    -- The entire Distorter of Time battlefield was skippable.
                    --
                    -- Scoped by instance NAME rather than by blacklisting ids:
                    -- an id blacklist missed doomvoid (9302), which also lives in
                    -- this zone and also fires 10000. Distorter of Time has no
                    -- instance_list row yet, so this is correctly inert until that
                    -- is built, and will start working the moment it is.
                    local instance = player:getInstance()

                    if not instance or instance:getName() ~= 'distorter_of_time' then
                        return
                    end

                    mission:setVar(player, 'Status', 1)
                    player:setPos(51.641, -41.230, 98.680, 0, xi.zone.BEAUCEDINE_GLACIER_S)
                end,
            },
        },
    },
}

return mission
