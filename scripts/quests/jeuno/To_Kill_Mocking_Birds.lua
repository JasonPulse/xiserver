-----------------------------------
-- To Kill Mocking Birds
-----------------------------------
-- Log ID: 3, Quest ID: 178
-- Nantoto : Lower Jeuno (H-8), entity 17780982
-- Yagudo High Priest : Castle Oztroja, mobs 17396127 and 17396133
-- !addquest 3 178
-----------------------------------
-- Retail (bg-wiki "To Kill Mocking Birds").
-- |Start=Nantoto, Lower Jeuno  |Fame=Jeuno  |Repeatable=No
-- |Previous=Petals of Recollection
-- |Quest Reqs=Complete 150 separate objectives in Records of Eminence.
-- |Reward=500 Sparks, 2500 Experience Points, 12 Copper A.M.A.N. Vouchers
--   1. "Talk to Nantoto at H-8 in Lower Jeuno."
--   2. "Defeat one Yagudo High Priest in Castle Oztroja."
--      "The priest is through the trap door at the top of the castle."
--
-- Quest id derived by the anchor method; see Teleports_by_Twilight.lua. DMSG 156
-- lands on 178.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Lower Jeuno:
--   20052 -> "...and that's why it had to be those theocratic thugs. I was sick of
--            that sour-wour taste in my mouth."                        THE BRIEF,
--            the theocratic thugs being the Yagudo
--
-- ITS STATED PREREQUISITE CANNOT BE EXPRESSED. bg-wiki puts Petals of Recollection
-- immediately before this, but Petals is absent from the client's Jeuno quest table
-- in our dump, so it has no id to reference and is not built. The chain is therefore
-- anchored on Shifty Shades of Prey, the last link that does have an id, plus the RoE
-- count bg-wiki gives. Add the Petals check here the day that quest gets an id.
--
-- The turn-in reuses 20052 rather than inventing a payout csid. Her two bare reward
-- handovers, 20049 and 20050, are already spoken for by the two preceding quests, and
-- guessing a third would be exactly the kind of invented csid this repo bans.
-----------------------------------
require('scripts/globals/nantoto_records')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.TO_KILL_MOCKING_BIRDS)

local requiredRecords = 150

local sparksReward  = 500
local expReward     = 2500
local voucherReward = 12

local priestKill =
{
    onMobDeath = function(mob, player, optParams)
        quest:setVar(player, 'Priest', 1)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.SHIFTY_SHADES_OF_PREY) == xi.questStatus.QUEST_COMPLETED and
                player:getNumEminenceCompleted() >= requiredRecords
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Nantoto'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(20052)
                end,
            },

            onEventFinish =
            {
                [20052] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Priest', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CASTLE_OZTROJA] =
        {
            ['Yagudo_High_Priest'] = priestKill,
        },

        [xi.zone.LOWER_JEUNO] =
        {
            ['Nantoto'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Priest') == 0 then
                        return quest:event(20052)
                    end

                    return quest:progressEvent(20052)
                end,
            },

            onEventFinish =
            {
                [20052] = function(player, csid, option, npc)
                    if quest:getVar(player, 'Priest') == 0 then
                        return
                    end

                    if quest:complete(player) then
                        xi.nantoto.payReward(player, sparksReward, expReward, voucherReward)
                    end
                end,
            },
        },
    },
}

return quest
