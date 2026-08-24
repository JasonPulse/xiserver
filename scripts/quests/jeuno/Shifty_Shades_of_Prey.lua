-----------------------------------
-- Shifty Shades of Prey
-----------------------------------
-- Log ID: 3, Quest ID: 177
-- Nantoto : Lower Jeuno (H-8), entity 17780982
-- !addquest 3 177
-----------------------------------
-- Retail (bg-wiki "Shifty Shades of Prey").
-- |Start=Nantoto, Lower Jeuno (H-8)  |Fame=Jeuno
-- |Previous=Teleports by Twilight
-- |Quest Reqs=Must have 100 unique RoE objectives completed.
-- |Reward=1500 Sparks, 2500 Experience Points, 5 Copper A.M.A.N. Vouchers
--   1. "Talk to Nantoto at H-8 in Lower Jeuno after you have completed 100 unique
--      Records of Eminence quests."
--   2. "She asks you to kill shadows in The Eldieme Necropolis."
--   3. "Kill 10 Fomor family monsters in The Eldieme Necropolis."
--
-- Quest id derived by the anchor method; see Teleports_by_Twilight.lua's header for
-- the working. This one is DMSG 155, which lands on 177.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Lower Jeuno:
--   20040 -> "How does it feel to be the grim reaper-weaper of shadows in the Eldieme
--            Necropolis?"                                              THE BRIEF
--   20050 -> "Take this and leave me to wallow in my self-pity-wity already!"
--                                                                       the payout
-- 20050 is taken by position: it is one of only two bare reward handovers in her
-- program, and the other, 20049, follows the Teleports by Twilight brief.
--
-- KNOWN DATA GAP, and the reason this cannot currently be finished in game. Zone 195
-- THE_ELDIEME_NECROPOLIS has NO Fomor placed in sql/mob_spawn_points; its spawn list
-- is Cwn Cyrff, Hellbound Warlock and similar. Fomor exist in Lufaise Meadows,
-- Misareaux Coast, Phomiuna Aqueducts, Sacrarium and others, just not here. The kill
-- counter below is registered against zone 195 because that is what bg-wiki
-- specifies, so the step starts working the moment those spawns are added rather than
-- needing this file changed.
-----------------------------------
require('scripts/globals/nantoto_records')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.SHIFTY_SHADES_OF_PREY)

local requiredRecords = 100
local requiredKills   = 10

local sparksReward  = 1500
local expReward     = 2500
local voucherReward = 5

local fomorNames =
{
    'Fomor_Bard',
    'Fomor_Beastmaster',
    'Fomor_Black_Mage',
    'Fomor_Dark_Knight',
    'Fomor_Dragoon',
    'Fomor_Monk',
    'Fomor_Ninja',
    'Fomor_Paladin',
    'Fomor_Pioneer',
    'Fomor_Ranger',
    'Fomor_Red_Mage',
    'Fomor_Samurai',
    'Fomor_Summoner',
    'Fomor_Thief',
    'Fomor_Warrior',
    'Fomor_Windwalker',
}

local fomorKill =
{
    onMobDeath = function(mob, player, optParams)
        local killed = quest:getVar(player, 'Fomor')

        if killed < requiredKills then
            quest:setVar(player, 'Fomor', killed + 1)
        end
    end,
}

local function eldiemeZone()
    local zone = {}

    for _, name in ipairs(fomorNames) do
        zone[name] = fomorKill
    end

    return zone
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.TELEPORTS_BY_TWILIGHT) == xi.questStatus.QUEST_COMPLETED and
                player:getNumEminenceCompleted() >= requiredRecords
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Nantoto'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(20040)
                end,
            },

            onEventFinish =
            {
                [20040] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Fomor', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.THE_ELDIEME_NECROPOLIS] = eldiemeZone(),

        [xi.zone.LOWER_JEUNO] =
        {
            ['Nantoto'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Fomor') < requiredKills then
                        return quest:event(20040)
                    end

                    return quest:progressEvent(20050)
                end,
            },

            onEventFinish =
            {
                [20050] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.nantoto.payReward(player, sparksReward, expReward, voucherReward)
                    end
                end,
            },
        },
    },
}

return quest
