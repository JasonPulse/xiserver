-----------------------------------
-- Rune Fencing the Night Away
-----------------------------------
-- Log ID: 9, Quest ID: 135
-- Gaddiux : Western Adoulin (J-10), entity 17826113
-- !addquest 9 135
-----------------------------------
-- Retail (bg-wiki "Rune Fencing the Night Away").
-- |Start=Gaddiux (Inventors' Coalition, Western Adoulin)  |Fame=Adoulin
-- |Level=99 Rune Fencer  |Item Reqs=Trial Blade  |Previous=Children of the Rune
-- |Reward=300 Bayld, ability to use Dimidiation
--   1. Talk to Gaddiux at (J-10) as a level 99 Rune Fencer.
--   2. Accumulate 300 Weapon Skill Points on the Trial Blade.
--   3. Trade the unlocked weapon back to Gaddiux.
--
-- The core counts the points, not this file: item_weapon.unlock_points is 300 for
-- Trial Blade 20749 and CLuaItem exposes the running total. The trade reads it and
-- never writes it.
--
-- Zone 256's yml dialog is EMPTY (0 entries); dialog-table-256.xml has 13233.
--
-- Csids, all on Gaddiux's own block:
--   5119 -> 11629-11641  offer; accept prompt 11632, declined 11633, re-ask 11634
--   5121 -> 11642-11646  the gauge reading
--   5120 -> 11647-11656  turn-in. 11647-11653 also hold the lost-blade and
--           abandon branches, which the client reaches through 11646's own menu.
--
-- Accept is option 1; Adoulin selection dialogs are 1-based.
-- Dimidiation is unlock id 49 (weaponskillid 61). addLearnedWeaponskill takes the
-- unlock id. The Geomancer twin cannot be built: Exudation has no weapon_skills row.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.RUNE_FENCING_THE_NIGHT_AWAY)

local dimidiationUnlockId = 49

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 300,
}

quest.sections =
{
    -- Section: a greatsword with a gauge welded into it, and nobody to swing it.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.RUN and
                player:getMainLvl() >= 99 and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.CHILDREN_OF_THE_RUNE)
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Gaddiux'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5119)
                end,
            },

            onEventFinish =
            {
                [5119] = function(player, csid, option, npc)
                    if option ~= 1 then
                        return
                    end

                    if npcUtil.giveItem(player, xi.item.TRIAL_BLADE) then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: swing it three hundred points' worth, then hand it back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Gaddiux'] =
            {
                onTrade = function(player, npc, trade)
                    if not npcUtil.tradeHasExactly(trade, xi.item.TRIAL_BLADE) then
                        return
                    end

                    local blade = trade:getItem()

                    -- The core owns the counter. Refuse a blade that has not
                    -- finished rather than second-guessing the threshold here.
                    if
                        blade == nil or
                        blade:getWeaponskillPoints() < blade:getWeaponskillPointsNeeded()
                    then
                        return quest:event(5121)
                    end

                    return quest:progressEvent(5120)
                end,

                onTrigger = function(player, npc)
                    return quest:event(5121)
                end,
            },

            onEventFinish =
            {
                [5120] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:addLearnedWeaponskill(dimidiationUnlockId)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
