-----------------------------------
-- To Catch a Predator
-----------------------------------
-- Log ID: 9, Quest ID: 1
-- Lucretia         : Ceizak Battlegrounds (H-9), entity 17846806
-- Claw Mark        : Ceizak Battlegrounds (H-8), entity 17846807
-- Truculent Mantis : Ceizak Battlegrounds, mob 17846603
-- !addquest 9 1
-----------------------------------
-- Retail (bg-wiki "To Catch a Predator").
-- |Start=Lucretia, Ceizak Battlegrounds (H-9)  |Fame=Adoulin
--   1. "Talk to Lucretia the guard at Bivouac #1 in Ceizak Battlegrounds and begin
--      the quest."
--   2. "Kill Fernfelling Chapulis until you obtain the Mantid bait key item."
--   3. "Use it to spawn Truculent Mantis at the Claw Mark, directly to the north."
--   4. "Defeating this NM will reward Flayed mantid corpse."
--   5. "Return to Lucretia and exchange the Flayed mantid corpse for your reward."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Ceizak Battlegrounds:
--   2510 -> "There's a mantid here that's a particular blight on the land." through
--           "Could you teach them that we pioneers mean business?"      THE OFFER
--   2511 -> "Those foul vermin devour chapuli the way you or I would devour steak, so
--           if you use one as bait..."                                the reminder
--   2513 -> "Some part of me thought you would fail, but I'm glad you proved me
--           wrong!" and "For now, though, I promised you a reward."     the turn-in
--   2515 -> "I can't shake the feeling that there's something out there, waiting for
--           us to make a misstep."                        the post-completion line
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.TO_CATCH_A_PREDATOR)

local clawMark       = 17846807
local truculentMantis = 17846603

-- bg-wiki does not publish the bait drop rate, so this is our tuning.
local baitChance = 25

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

--- Chapuli drop the bait. Every Fernfelling Chapuli in the zone shares one handler.
local chapuliKill =
{
    onMobDeath = function(mob, player, optParams)
        if
            not player:hasKeyItem(xi.ki.MANTID_BAIT) and
            not player:hasKeyItem(xi.ki.FLAYED_MANTID_CORPSE) and
            math.random(1, 100) <= baitChance
        then
            npcUtil.giveKeyItem(player, xi.ki.MANTID_BAIT)
        end
    end,
}

local mantisKill =
{
    onMobDeath = function(mob, player, optParams)
        npcUtil.giveKeyItem(player, xi.ki.FLAYED_MANTID_CORPSE)
    end,
}

local clawMarkActions =
{
    onTrigger = function(player, npc)
        if
            npc:getID() ~= clawMark or
            not player:hasKeyItem(xi.ki.MANTID_BAIT)
        then
            return
        end

        local mantis = GetMobByID(truculentMantis)

        if mantis == nil or mantis:isSpawned() then
            return
        end

        player:delKeyItem(xi.ki.MANTID_BAIT)
        SpawnMob(truculentMantis):updateClaim(player)

        return true
    end,
}

local ceizak =
{
    ['Claw_Mark']           = clawMarkActions,
    ['Fernfelling_Chapuli'] = chapuliKill,
    ['Truculent_Mantis']    = mantisKill,

    ['Lucretia'] =
    {
        onTrigger = function(player, npc)
            if not player:hasKeyItem(xi.ki.FLAYED_MANTID_CORPSE) then
                return quest:event(2511)
            end

            return quest:progressEvent(2513)
        end,
    },

    onEventFinish =
    {
        [2513] = function(player, csid, option, npc)
            if quest:complete(player) then
                player:delKeyItem(xi.ki.FLAYED_MANTID_CORPSE)
            end
        end,
    },
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Lucretia'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2510)
                end,
            },

            onEventFinish =
            {
                [2510] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] = ceizak,
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Lucretia'] = quest:event(2515):replaceDefault(),
        },
    },
}

return quest
