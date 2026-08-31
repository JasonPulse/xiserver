-----------------------------------
-- The Secret to Success
-----------------------------------
-- Log ID: 9, Quest ID: 127
-- Behsa_Alehgo     : Eastern Adoulin (J-8),      entity 17830132
-- Wegellion        : Eastern Adoulin (F-9),      entity 17830087
-- Emjook-Renook    : Yorcia Weald frontier stn,  entity 17855088
-- Suspicious_Place : Yorcia J-8 / I-8 / H-9,     17855040 / 17855042 / 17855041
-- !addquest 9 127
-----------------------------------
-- Retail (bg-wiki "The Secret to Success").
-- |Start=Behsa Alehgo, Eastern Adoulin (J-8)  |Fame=Adoulin  |FLevel=3
-- |Next=Eye of the Beholder  |Reward=1,000 Bayld
--   1. Talk to Behsa Alehgo at the priory.
--   2. Talk to Wegellion at the Scouts' Coalition (F-9).
--   3. Talk to Emjook-Renook at the Yorcia Weald frontier station.
--   4. Check the Suspicious Places at (J-8), (H-9) and (I-8). Only one has it.
--   5. Return to Emjook-Renook, then to Behsa Alehgo.
--
-- WAS BLOCKED ON A MISSING npc_list ROW. Retail has three Suspicious Places in
-- Yorcia; this fork's capture produced two, with 17855041 left commented out as
-- "-- NC:" named NOT_CAPTURED at a zeroed position. Restored verbatim from
-- upstream/base:sql/npc_list.sql, position -66.905 / 2.803 / -106.818. By position
-- 17855040 is J-8, 17855042 is I-8, 17855041 is H-9.
--
-- The badge spot is rolled when the errand starts, per bg-wiki's "only one of them
-- will have the item".
--
-- Csids; ids from the XML dumps, zone 257's yml is shifted:
--   5057 -> 10220-10237  offer, holder 17830076; accept prompt 10232
--   5059 -> 10242-10255  Wegellion and Reepi-Molpi, plus the nudge
--   5061 -> 10258-10271  turn-in, and 10271 is also the post line
--   109  -> 7990-8005    Emjook's errand; 8004 names the three quadrants
--   110  -> 8006-8007    the find, on Emjook-Renook; lookup is zone-global
--   111  -> 8008-8024    the return
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_SECRET_TO_SUCCESS)

local behsaAlehgo  = 17830132
local wegellion    = 17830087
local emjookRenook = 17855088

-- Rolled at step 3 and read at step 4. Order is bg-wiki's own: J-8, H-9, I-8.
local badgeSpots =
{
    [1] = 17855040,
    [2] = 17855041,
    [3] = 17855042,
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
}

quest.sections =
{
    -- Section: Erfimia cannot believe Robertioux managed it without a secret.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= behsaAlehgo then
                        return
                    end

                    return quest:progressEvent(5057)
                end,
            },

            onEventFinish =
            {
                [5057] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: the coalition, the frontier station, and three places to dig.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Wegellion'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= wegellion or
                        quest:getVar(player, 'Prog') ~= 0
                    then
                        return
                    end

                    return quest:progressEvent(5059)
                end,
            },

            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= behsaAlehgo or
                        quest:getVar(player, 'Prog') ~= 4
                    then
                        return
                    end

                    return quest:progressEvent(5061)
                end,
            },

            onEventFinish =
            {
                [5059] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [5061] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.UNBLEMISHED_PIONEERS_BADGE)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                        quest:setVar(player, 'Spot', 0)
                    end
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['Emjook-Renook'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= emjookRenook then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')

                    if prog == 1 then
                        return quest:progressEvent(109)
                    elseif prog == 3 then
                        return quest:progressEvent(111)
                    end
                end,
            },

            ['Suspicious_Place'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') ~= 2 then
                        return
                    end

                    local spot = quest:getVar(player, 'Spot')

                    if
                        badgeSpots[spot] == nil or
                        npc:getID() ~= badgeSpots[spot]
                    then
                        return
                    end

                    return quest:progressEvent(110)
                end,
            },

            onEventFinish =
            {
                [109] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                    quest:setVar(player, 'Spot', math.random(#badgeSpots))
                end,

                [110] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, xi.ki.UNBLEMISHED_PIONEERS_BADGE) then
                        quest:setVar(player, 'Prog', 3)
                    end
                end,

                [111] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },
    },

    -- Section: 10271, Erfimia rehearsing her exorcism lines.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] = quest:event(5061):replaceDefault(),
        },
    },
}

return quest
