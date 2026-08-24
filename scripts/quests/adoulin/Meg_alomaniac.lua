-----------------------------------
-- Meg-alomaniac
-----------------------------------
-- Log ID: 9, Quest ID: 89
-- Sharuru  : Eastern Adoulin (F-8), entity 17830011
-- Waypoints: Western Adoulin, entities 17825973 .. 17825981 and 17826107
-- !addquest 9 89
-----------------------------------
-- Retail (bg-wiki "Meg-alomaniac").
-- |Start=Sharuru, Eastern Adoulin (F-8)  |Fame=Adoulin |FLevel=3  |Repeatable=No
-- |Previous=Fertile Ground
--   1. "Talk to Sharuru to get a Waypoint scanner kit."
--   2. "Examine each Waypoint in Western Adoulin." bg-wiki lists nine: Platea
--      Triumphus, Pioneers' Coalition, Mummers' Coalition, Inventors' Coalition, the
--      Auction house, your Rent-a-Room, Big Bridge, the Airship docks and the
--      Adoulin Waterfront.
--   3. "Talk to Sharuru again for your reward."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Eastern Adoulin:
--   3015 -> "Ms. pioneer, ma'am! I need your helpy-welp! Meg...Meg is sick." through
--           "could you use this waypoint scanner kit and take a looky-wook at her for
--           me?"                                                       THE OFFER
--   3016 -> "Use the waypoint scanner kit to scrutinize-wutinize them for me."
--                                                                      the reminder
--   3017 -> "Yes, yes, you checked Meg out, but there are other waypointarus who also
--           need your help!"                             the partial-progress line
--   3018 -> "Wow, you actually did it? Hmph. First adventurer in a while who's worth
--           her saltaru." and the reward                                the turn-in
--
-- TEN WAYPOINTS ARE PLACED, NINE ARE LISTED. npc_list has ten Waypoint entities in
-- Western Adoulin, 17825973 through 17825981 plus 17826107, while bg-wiki names nine
-- locations. Rather than guess which of the ten is not one of the nine, the quest
-- counts DISTINCT waypoints scanned and completes at nine, so any nine satisfy it.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.MEGALOMANIAC)

local waypoints =
{
    17825973,
    17825974,
    17825975,
    17825976,
    17825977,
    17825978,
    17825979,
    17825980,
    17825981,
    17826107,
}

local scansNeeded = 9

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

local function scanned(player)
    local mask  = quest:getVar(player, 'Scanned')
    local count = 0

    for index = 0, #waypoints - 1 do
        if bit.band(mask, bit.lshift(1, index)) ~= 0 then
            count = count + 1
        end
    end

    return count
end

local waypointActions =
{
    onTrigger = function(player, npc)
        if not player:hasKeyItem(xi.ki.WAYPOINT_SCANNER_KIT) then
            return
        end

        for index, id in ipairs(waypoints) do
            if id == npc:getID() then
                quest:setVar(player, 'Scanned',
                    bit.bor(quest:getVar(player, 'Scanned'), bit.lshift(1, index - 1)))

                return
            end
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Sharuru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(3015)
                end,
            },

            onEventFinish =
            {
                [3015] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Scanned', 0)
                    npcUtil.giveKeyItem(player, xi.ki.WAYPOINT_SCANNER_KIT)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Waypoint'] = waypointActions,
        },

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Sharuru'] =
            {
                onTrigger = function(player, npc)
                    local done = scanned(player)

                    if done == 0 then
                        return quest:event(3016)
                    elseif done < scansNeeded then
                        return quest:event(3017)
                    end

                    return quest:progressEvent(3018)
                end,
            },

            onEventFinish =
            {
                [3018] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.WAYPOINT_SCANNER_KIT)
                        quest:setVar(player, 'Scanned', 0)
                    end
                end,
            },
        },
    },
}

return quest
