-----------------------------------
-- The Good, the Bad, the Clement
-----------------------------------
-- Log ID: 9, Quest ID: 125
-- Zaffeld              : Eastern Adoulin (J-8), entity 17830131
-- Occultist_Footprints : Yorcia Weald (J-6),    entity 17855033
-- Hostage_Tent         : Marjami Ravine (G-10), entity 17867231
-- Seat_of_Gramk-Droog  : Marjami Ravine (I-10), entity 17867232
-- Velkk_Sentinel       : Marjami Ravine,        mob    17867055
-- !addquest 9 125
-----------------------------------
-- Retail (bg-wiki "The Good, the Bad, the Clement").
-- |Start=Zaffeld, Eastern Adoulin (J-8)  |Fame=Seekers of Adoulin
-- |Previous=Velkkovert Operations  |Next=The Weatherspoon Inquisition
-- |Reward=500 EXP, 1,000 Bayld
--   1. Speak to Zaffeld in Eastern Adoulin (J-8).
--   2. Check the Occultist Footprints at the I-6/J-6 border in Yorcia Weald.
--   3. Check the Hostage Tent at (G-10) in Marjami Ravine.
--   4. Check it again to spawn a Velkk Sentinel, kill it, check a third time.
--   5. Check the Seat of Gramk-Droog at (I-10) for the reward.
--
-- Zone 257's yml dialog is shifted and zone 266's is short (8209 against 8299);
-- ids below come from the XML dumps. See Thorn_in_the_Side.lua.
--
-- Eastern Adoulin, holder 17830076:
--   5054 -> 10195-10209  offer; 10204 is the catalyst, accept prompt 10208
--   5055 -> 10211-10214  re-ask and nudge
-- Yorcia Weald, on the footprints:
--   107 -> 7954-7987  Nashu returns the catalyst; closes on "make for G-10 in
--          Marjami Ravine", which is what identifies it among the 18 csids there
-- Marjami Ravine:
--   54 -> 7907-7912, on the tent   arrival, four guards
--   55 -> 7913-7948, on the tent   after the kill, "To I-10 or bust"
--   57 -> 7949-7986, on the throne finale and payout
--
-- One Velkk_Sentinel row exists in mob_spawn_points, matching bg-wiki's singular.
-- It spawns on the second click, not the cutscene, because bg-wiki puts a
-- deliberate "buff up" step between them.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_GOOD_THE_BAD_THE_CLEMENT)

local occultistFootprints = 17855033
local hostageTent         = 17867231
local seatOfGramkDroog    = 17867232
local velkkSentinel       = 17867055

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
    exp      = 500,
}

quest.sections =
{
    -- Section: Nashu wants to give the catalyst back and talk the coven round.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.VELKKOVERT_OPERATIONS)
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Declined') == 1 then
                        return quest:progressEvent(5055)
                    end

                    return quest:progressEvent(5054)
                end,
            },

            onEventFinish =
            {
                [5054] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    else
                        quest:setVar(player, 'Declined', 1)
                    end
                end,

                [5055] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:setVar(player, 'Declined', 0)
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: the weald, the tent, the sentinel, and the throne room.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(5055)
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['Occultist_Footprints'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= occultistFootprints or
                        quest:getVar(player, 'Prog') ~= 0
                    then
                        return
                    end

                    return quest:progressEvent(107)
                end,
            },

            onEventFinish =
            {
                [107] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Hostage_Tent'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= hostageTent then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')

                    if prog == 1 then
                        return quest:progressEvent(54)
                    elseif prog == 3 then
                        return quest:progressEvent(55)
                    elseif prog ~= 2 then
                        return
                    end

                    -- The buff-up step. Second check puts the sentinel on the field
                    -- and hands it straight to the player who woke it.
                    local mob = GetMobByID(velkkSentinel)

                    if mob ~= nil and not mob:isSpawned() then
                        mob:spawn()
                        mob:updateClaim(player)
                    end

                    return quest:noAction()
                end,
            },

            ['Velkk_Sentinel'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if quest:getVar(player, 'Prog') == 2 then
                        quest:setVar(player, 'Prog', 3)
                    end
                end,
            },

            ['Seat_of_Gramk-Droog'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= seatOfGramkDroog or
                        quest:getVar(player, 'Prog') ~= 4
                    then
                        return
                    end

                    return quest:progressEvent(57)
                end,
            },

            onEventFinish =
            {
                [54] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,

                [55] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,

                [57] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },
}

return quest
