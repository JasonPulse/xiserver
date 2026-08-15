-----------------------------------
-- Martial Mastery
-----------------------------------
-- !addquest 3 167
-- Nomad Moogle : !pos 10.012 1.453 121.883 243
-----------------------------------
local ruLudeID = zones[xi.zone.RULUDE_GARDENS]
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.MARTIAL_MASTERY)

-- bg-wiki "Martial Mastery": |Level=96+ |Previous=[[Beyond Infinity]]
-- |Item Reqs=15 Merit Points |Reward={{KI}} [[Heart of the bushin]] |Title= (empty).
--
-- THE 357-SKILL GATE IS GONE, and this is explicit on the wiki rather than
-- inferred. Its Walkthrough reads: "{{math|ge}}357 Skill in a weapon is required
-- to use the Merit Weapon Skills, BUT NOT NECESSARY TO COMPLETE THIS QUEST."
-- Both the offer and the turn-in called a local hasRequiredCombatSkill() that
-- demanded 357 in one of fourteen skills, so a level 96+ character with 15 merits
-- -- everything retail actually asks for -- could be refused the quest outright.
-- The helper and its skill table were the only users of that check and are
-- removed with it.
--
-- The title is removed too: |Title= is empty here, and bg-wiki gives
-- "Bushin-Ryu Inheritor" to the PREVIOUS quest, Beyond Infinity. This file was
-- awarding it one quest too late; LB10_Beyond_Infinity.lua now grants it.
quest.reward =
{
    keyItem = xi.ki.HEART_OF_THE_BUSHIN,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 96 and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.BEYOND_INFINITY)
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Nomad_Moogle'] = quest:progressEvent(10196),

            onEventFinish =
            {
                [10196] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            -- TODO: Confirm that the player must be on a valid job to complete
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:getMainLvl() >= 96 and
                player:getMeritCount() >= 15
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Nomad_Moogle'] = quest:progressEvent(10198),

            onEventFinish =
            {
                [10198] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setMerits(player:getMeritCount() - 15)
                        player:messageSpecial(ruLudeID.text.LEARNED_SECRET_TECHNIQUE)
                    end
                end,
            },
        },
    },
}

return quest
