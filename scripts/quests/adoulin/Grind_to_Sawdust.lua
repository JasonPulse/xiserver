-----------------------------------
-- Grind to Sawdust
-----------------------------------
-- Log ID: 9, Quest ID: 53
-- Elmric : Ceizak Battlegrounds (K-7), entity 17846812
-- !addquest 9 53
-----------------------------------
-- Retail (bg-wiki "Grind to Sawdust").
-- |Start=Elmric, Ceizak Battlegrounds (K-7)  |Fame=Adoulin |FLevel=1
--   "Participate in at least one colonization Reive battle, then return to Elmric to
--    complete the quest."
--   "The battle does not need to be participated in through completion as long as you
--    participated and received an evaluation."
--   "This can be completed before speaking with Elmric which will both start and end
--    the quest with the same dialogue."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Ceizak Battlegrounds:
--   2560 -> "You there! This forest is no place for the likes of you!"    the gate
--   2562 -> "<Grunt> Another pioneer come to 'brighten up my day'?" through
--           "'Logging' is necessary to even have a prayer of proceeding further into
--           the jungle."                                                THE OFFER
--   2563 -> "Think of Colonization Reives as training to learn about 'Logging'"
--                                                                      the reminder
--   2564 -> "Well now, this does come as a surprise. You actually learned a bit about
--           colonizing." through "you've now learned the basics of 'Logging'."
--                                                                       the turn-in
--   2565 -> the offer again, for a player who has not yet taken part
--   2566 -> "Keep on fighting and discovering more about the land"
--                                                          the post-completion line
--
-- HOW PARTICIPATION IS DETECTED. The reives module tracks obstacles and objective
-- status but records nothing per player, so there is no "you were evaluated" flag to
-- read. The observable act is felling a reive obstacle, and in this zone that is
-- Knotted_Root, which colonization_reive_data.lua uses as REIVE_MOB_OFFSET. Killing
-- one is therefore what counts as having taken part, which matches bg-wiki's point
-- that the battle need not be seen through to completion.
--
-- bg-wiki's "can be completed before speaking with Elmric" is honoured: the kill is
-- recorded whether or not the quest has been accepted, so a player who already felled
-- a root gets the offer and the turn-in back to back.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.GRIND_TO_SAWDUST)

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

local reiveParticipation =
{
    onMobDeath = function(mob, player, optParams)
        player:setCharVar('ColonizationReive_Joined', 1)
    end,
}

local function hasJoined(player)
    return player:getCharVar('ColonizationReive_Joined') == 1
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Knotted_Root'] = reiveParticipation,

            ['Elmric'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2562)
                end,
            },

            onEventFinish =
            {
                [2562] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Knotted_Root'] = reiveParticipation,

            ['Elmric'] =
            {
                onTrigger = function(player, npc)
                    if not hasJoined(player) then
                        return quest:event(2563)
                    end

                    return quest:progressEvent(2564)
                end,
            },

            onEventFinish =
            {
                [2564] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Elmric'] = quest:event(2566):replaceDefault(),
        },
    },
}

return quest
