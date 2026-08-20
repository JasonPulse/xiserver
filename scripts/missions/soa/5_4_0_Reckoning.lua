-----------------------------------
-- Reckoning
-- Seekers of Adoulin M5-4
-----------------------------------
-- !addmission 12 121
-- Ominous Postern : !pos 118 37.5 20 277
-----------------------------------

local mission = Mission:new(xi.mission.log_id.SOA, xi.mission.id.soa.RECKONING)

mission.reward =
{
    keyItem     = xi.ki.AWAKENED_CRYSTALLIZED_PSYCHE,
    nextMission = { xi.mission.log_id.SOA, xi.mission.id.soa.ABOMINATION },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.RAKAZNAR_TURRIS] =
        {
            onZoneIn = function(player, prevZone)
                if mission:getVar(player, 'Status') == 1 then
                    return 3
                end
            end,

            onEventFinish =
            {
                [3] = function(player, csid, option, npc)
                    mission:complete(player)
                end,

                [32001] = function(player, csid, option, npc)
                    -- 32001 is the shared battlefield-win event, dispatched
                    -- zone-wide on csid alone, and this had no discriminator at
                    -- all -- the removed TODO asked for a battlefield-ID check.
                    -- Ra'Kaznar Turris has no battlefield defined yet (no
                    -- bcnm_records row for zone 277, no xi.battlefield.id entry,
                    -- no script), so there is no id to match on and inventing one
                    -- would be fabricating data.
                    -- What IS real and sourced is this mission's entry key item.
                    -- bg-wiki, Notes: "Should you lose the battle, re-zone into
                    -- Ra'Kaznar Inner Court for another {KI} Crystallized psyche."
                    -- Gating on it means the handler cannot be driven by some
                    -- future unrelated battlefield in this zone, and it stays
                    -- correct once the Hades fight is built.
                    if not player:hasKeyItem(xi.ki.CRYSTALLIZED_PSYCHE) then
                        return
                    end

                    mission:setVar(player, 'Status', 1)
                    player:setPos(132.2, 39.75, 20, 0, xi.zone.RAKAZNAR_TURRIS)
                end,
            },
        },

        [xi.zone.RAKAZNAR_INNER_COURT] =
        {
            afterZoneIn = function(player)
                if
                    not player:hasKeyItem(xi.ki.CRYSTALLIZED_PSYCHE) and
                    mission:getVar(player, 'Status') == 0
                then
                    -- TODO: This message needs verification, and need to determine if there
                    -- is a unique event or message.
                    npcUtil.giveKeyItem(player, xi.ki.CRYSTALLIZED_PSYCHE)
                end
            end,
        },
    },
}

return mission
