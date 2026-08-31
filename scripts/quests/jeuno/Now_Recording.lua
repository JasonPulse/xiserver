-----------------------------------
-- Now Recording...
-----------------------------------
-- Log ID: 3, Quest ID: 175
-- Darcia : Lower Jeuno (H-7), entity 17780959
-- !addquest 3 175
-----------------------------------
-- Retail (bg-wiki and ffxiclopedia "Now Recording...").
-- |Start=Darcia, Lower Jeuno (H-7)  |Previous=The Geomagnetron
-- |Repeatable=Yes, after Japanese Midnight
-- |Reward=300 gil, EXP depending on the fount examined
--   1. Speak to Darcia and take the request.
--   2. Attune the Temporary geomagnetron at ONE of the eighteen founts.
--   3. Return to Darcia.
--
-- bg-wiki lists eighteen founts but leaves EXP blank on eight. ffxiclopedia has a
-- value on every row and the ten they share agree, so fountExp is ffxiclopedia's
-- table. All eighteen zones were checked to hold a Geomagnetic_Fount in npc_list.
--
-- The prerequisite is SoA mission 1, not a quest.
--
-- Csid 10117 on Darcia does the whole interaction and is wired in both sections.
-- From dialog-table-245.xml: 10332-10336 the pitch, 10337 the accept prompt, 10338
-- the key item, 10339-10340 the payout, 10341-10344 the cancel branch. One event
-- holding three mutually exclusive menus has to branch on the quest log the server
-- already sent it, the same shape as Anastase's 10221 in Further_Founts.lua. The
-- conservative csidmsg pass attributes 10339 and 10344 to 10117 outright.
-- Ignore holder 17780979: its data[] has 4083 entries, so a wide scan matches
-- almost any id inside it.
--
-- The fount handlers return nothing so geomagnetic_fount.lua is not shadowed.
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.NOW_RECORDING)

-- Zone to EXP, transcribed from the ffxiclopedia table.
local fountExp =
{
    [xi.zone.YUGHOTT_GROTTO]         = 200,
    [xi.zone.PALBOROUGH_MINES]       = 200,
    [xi.zone.RANGUEMONT_PASS]        = 200,
    [xi.zone.KING_RANPERRES_TOMB]    = 300,
    [xi.zone.MONASTIC_CAVERN]        = 300,
    [xi.zone.DANGRUF_WADI]           = 300,
    [xi.zone.KORROLOKA_TUNNEL]       = 300,
    [xi.zone.MAZE_OF_SHAKHRAMI]      = 300,
    [xi.zone.OUTER_HORUTOTO_RUINS]   = 300,
    [xi.zone.THE_ELDIEME_NECROPOLIS] = 400,
    [xi.zone.GARLAIGE_CITADEL]       = 400,
    [xi.zone.CRAWLERS_NEST]          = 400,
    [xi.zone.INNER_HORUTOTO_RUINS]   = 400,
    [xi.zone.ORDELLES_CAVES]         = 500,
    [xi.zone.GUSGEN_MINES]           = 500,
    [xi.zone.GUSTAV_TUNNEL]          = 500,
    [xi.zone.LABYRINTH_OF_ONZOZO]    = 500,
    [xi.zone.TORAIMARAI_CANAL]       = 500,
}

local function startRequest(player)
    if npcUtil.giveKeyItem(player, xi.ki.TEMPORARY_GEOMAGNETRON) then
        quest:begin(player)
        quest:setVar(player, 'Fount', 0)
    end
end

local accepted =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,

    [xi.zone.LOWER_JEUNO] =
    {
        ['Darcia'] =
        {
            onTrigger = function(player, npc)
                return quest:progressEvent(10117)
            end,
        },

        onEventFinish =
        {
            [10117] = function(player, csid, option, npc)
                local recorded = quest:getVar(player, 'Fount')
                local reward   = fountExp[recorded]

                -- Still carrying an unused geomagnetron: the event played its
                -- cancel branch, so take the key item back and stand down.
                if reward == nil then
                    player:delKeyItem(xi.ki.TEMPORARY_GEOMAGNETRON)

                    return
                end

                player:addGil(300)
                player:addExp(reward)
                player:delKeyItem(xi.ki.TEMPORARY_GEOMAGNETRON)

                if quest:complete(player) then
                    quest:setVar(player, 'Fount', 0)
                    quest:setVar(player, 'Wait', NextJstDay())
                end
            end,
        },
    },
}

for zoneId, _ in pairs(fountExp) do
    accepted[zoneId] =
    {
        ['Geomagnetic_Fount'] =
        {
            onTrigger = function(player, npc)
                if
                    quest:getVar(player, 'Fount') == 0 and
                    player:hasKeyItem(xi.ki.TEMPORARY_GEOMAGNETRON)
                then
                    quest:setVar(player, 'Fount', zoneId)
                end
            end,
        },
    }
end

quest.sections =
{
    -- Section: the Association wants another locus recorded. Repeatable once a day,
    -- so a finished run reopens after the next JP midnight.
    {
        check = function(player, status, vars)
            return (
                status == xi.questStatus.QUEST_AVAILABLE or
                (status == xi.questStatus.QUEST_COMPLETED and vars.Wait <= GetSystemTime())
            ) and
                player:hasCompletedMission(xi.mission.log_id.SOA, xi.mission.id.soa.THE_GEOMAGNETRON)
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Darcia'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10117)
                end,
            },

            onEventFinish =
            {
                [10117] = function(player, csid, option, npc)
                    startRequest(player)
                end,
            },
        },
    },

    accepted,
}

return quest
