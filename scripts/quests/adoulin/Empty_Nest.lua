-----------------------------------
-- Empty Nest
-----------------------------------
-- Log ID: 9, Quest ID: 2
-- Bataron : Ceizak Battlegrounds (H-7), entity 17846808
-- !addquest 9 2
-----------------------------------
-- Retail (bg-wiki "Empty Nest").
-- |Start=Bataron, Ceizak Battlegrounds - (H-7)  |Fame=None
-- |Reward=2000 Experience Points
--   1. Speak to Bataron near Bivouac #2 to begin the quest.
--   2. Defeat eight Belaboring Wasps located in the area around Bataron (H-7).
--      "You do not have to be within EXP range to get credit."
--      "If you zone, your count will be reset."
--      "If you kill them with an AoE, you only get credit for the one(s) you
--      have claim on."
--   3. Return to Bataron to receive your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Bataron is 17846808 -> zone 261 idx 536 (0x01105218). `xi-dat events 261` gives
-- him 2520, 2521, 2523, 2524.
--
-- The dumped dialog file labelled zone N holds zone N-1's text for the Adoulin
-- field zones, so Ceizak's text is in the file labelled 262. That offset is
-- pinned by this repo's own known-correct ids, not by my reading:
-- Ceizak_Battlegrounds/IDs.lua has WAYPOINT_ATTUNED = 7599 and
-- Yahse_Hunting_Grounds/IDs.lua has 7619, and in the dumps 7599 is the
-- attunement line in file 262 while 7619 is the attunement line in file 261.
-- Read against file 262:
--   2520 -> 7525-7528  THE OFFER. 7525 "You look like you can handle yourself
--          with my little wasp hive problem", 7527 "That's why I'm looking for
--          someone to smash into the nests and take care of some of the
--          belaboring wasps inside", and 7528 "You really want a number to kill?
--          <Sigh> I want to say 'as many as you can,' but you've probably got
--          better things to do...so let's say ${number}". No ${selection-lines},
--          so speaking to him starts it.
--   2521 -> 7528       the reminder, the count on its own.
--   2523 -> 7529-7534  THE TURN-IN. "You actually went out and killed them for
--          me? What a pal!", through the Naakual foreshadowing, to 7534 "accept
--          your just reward for a task well done."
--   2524 -> 7533       his post-completion line.
--
-- THE COUNT OF EIGHT IS THE EVENT'S OWN. 7528 renders it as ${number}, which
-- looked like it needed a param. It does not -- csidmsg.load() shows the block
-- carries its own data[] and reads the figure out of it:
--     data = [5, 7525, 7526, 7527, 8, 7528, 7529, 7530, 7531, 7532, 7533, 7534,
--             201, 0]
-- data[4] = 8, which is exactly bg-wiki's "Defeat eight Belaboring Wasps". The
-- events are therefore fired bare, and the 8 below is the same number read from
-- the same place rather than a second, independent guess.
--
-- ZONING RESETS THE COUNT, per bg-wiki, which is why the tally lives in a local
-- var rather than a quest var -- local vars do not survive a zone change.
-- CLAIM: bg-wiki is explicit that AoE kills only count where you hold claim, so
-- the kill is credited through the isKiller/claim check rather than to everyone
-- present.
-----------------------------------
local ceizakID = zones[xi.zone.CEIZAK_BATTLEGROUNDS]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.EMPTY_NEST)

local waspsNeeded = 8 -- data[4] of Bataron's event block

quest.reward =
{
    exp = 2000,
}

quest.sections =
{
    -- bg-wiki lists |Fame=None and no |Previous=, so there is genuinely no
    -- prerequisite on this one.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Bataron'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2520)
                end,
            },

            onEventFinish =
            {
                [2520] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:setLocalVar('EmptyNestWasps', 0)
                end,
            },
        },
    },

    -- Accepted: cull the wasps, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Belaboring_Wasp'] =
            {
                onMobDeath = function(mob, player, optParams)
                    -- luautils only fills isKiller when a char is credited; on
                    -- the noKiller path player is nil, so both must be checked
                    -- before touching the player.
                    if player == nil or not optParams.isKiller then
                        return
                    end

                    local killed = player:getLocalVar('EmptyNestWasps')
                    if killed >= waspsNeeded then
                        return
                    end

                    killed = killed + 1
                    player:setLocalVar('EmptyNestWasps', killed)
                    player:messageName(ceizakID.text.BELABORING_WASPS_KILLED, player, killed, waspsNeeded, 0)
                end,
            },

            ['Bataron'] =
            {
                onTrigger = function(player, npc)
                    if player:getLocalVar('EmptyNestWasps') >= waspsNeeded then
                        return quest:progressEvent(2523)
                    end

                    return quest:event(2521)
                end,
            },

            onEventFinish =
            {
                [2523] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setLocalVar('EmptyNestWasps', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7533, his parting word about the Naakuals.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Bataron'] = quest:event(2524):replaceDefault(),
        },
    },
}

return quest
