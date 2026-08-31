-----------------------------------
-- Eye of the Beholder
-----------------------------------
-- Log ID: 9, Quest ID: 137
-- Behsa_Alehgo     : Eastern Adoulin (J-8), entity 17830132
-- Suspicious_Place : Yorcia J-8 / I-8 / H-9, 17855040 / 17855042 / 17855041
-- !addquest 9 137
-----------------------------------
-- Retail (bg-wiki "Eye of the Beholder").
-- |Start=Behsa Alehgo, Eastern Adoulin (J-8)  |Fame=Seekers of Adoulin  |FLevel=3
-- |Previous=The Secret to Success  |Next=In the Land of the Blind
-- |Item Reqs=12x Holy Water  |Reward=500 EXP, 1,000 Bayld
--   1. Speak to Behsa Alehgo in Eastern Adoulin (J-8).
--   2. Check the Suspicious Place at the SW corner of (J-8) in Yorcia Weald.
--   3. Trade 12 Holy Waters to the Suspicious Place on the south side of (I-8).
--   4. Check the Suspicious Place at the SW corner of (H-9) for the reward.
--
-- Unblocked by the same npc_list repair as The_Secret_to_Success.lua: the H-9 marker
-- 17855041 was "-- NC: NOT_CAPTURED" here and was restored from upstream/base.
--
-- Csids; Eastern Adoulin from dialog-table-257.xml, Yorcia from -263.xml:
--   5122 -> 10274-10287  offer and nudge in one event; accept prompt 10281
--   116  -> 8049-8089    the J-8 scene; 8083 is Erfimia counting her twelve
--   117  -> 8088, 8090   the short waiting-at-I-8 beat, used as the reminder
--   118  -> 8091-8105    the trade scene; 8104 has Robertioux fleeing
--   120  -> 8107-8153    the H-9 finale
--
-- The trade fires 118, not 117: bg-wiki gives step 3 one cutscene and 118 is the one
-- with a scene in it. 117's two lines are both Erisa saying where to be.
--
-- Holy Water is item_basic flask_of_holy_water, 4154.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.EYE_OF_THE_BEHOLDER)

local behsaAlehgo = 17830132
local markerJ8    = 17855040
local markerI8    = 17855042
local markerH9    = 17855041

local holyWaterNeeded = 12

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
    exp      = 500,
}

quest.sections =
{
    -- Section: Erfimia wants to see where Robertioux did it.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3 and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_SECRET_TO_SUCCESS)
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= behsaAlehgo then
                        return
                    end

                    return quest:progressEvent(5122)
                end,
            },

            onEventFinish =
            {
                [5122] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: three markers, twelve flasks, and one very bad eye.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= behsaAlehgo then
                        return
                    end

                    return quest:event(5122)
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['Suspicious_Place'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npc:getID() ~= markerI8 or
                        quest:getVar(player, 'Prog') ~= 1 or
                        not npcUtil.tradeHasExactly(trade, { { xi.item.FLASK_OF_HOLY_WATER, holyWaterNeeded } })
                    then
                        return
                    end

                    return quest:progressEvent(118)
                end,

                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')
                    local id   = npc:getID()

                    if
                        id == markerJ8 and
                        prog == 0
                    then
                        return quest:progressEvent(116)
                    elseif
                        id == markerI8 and
                        prog == 1
                    then
                        -- 8088/8090, Erfimia waiting on the flasks.
                        return quest:event(117)
                    elseif
                        id == markerH9 and
                        prog == 2
                    then
                        return quest:progressEvent(120)
                    end
                end,
            },

            onEventFinish =
            {
                [116] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [118] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 2)
                end,

                [120] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },
}

return quest
