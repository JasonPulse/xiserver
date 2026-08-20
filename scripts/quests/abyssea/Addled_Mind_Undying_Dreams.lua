-----------------------------------
-- Addled Mind, Undying Dreams
-----------------------------------
-- Log ID: 8, Quest ID: 16
-- Silver_Owl : Abyssea - Konschtat (D-7), entity 16839223
-- !addquest 8 16
-----------------------------------
-- bg-wiki: |Start=Silver Owl (A) (D-7), Conflux #03
-- |Item Reqs=Pinch of moist Dangruf sulfur
-- |Reward=Azure abyssite of prosperity
--   He asks for the sulfur, which drops from any colour Pyxis in any Abyssea zone.
--
-- CSIDS (csidmsg.load on 16839223; NPC confirmed by resolve_npc.py -- KI 1600
-- sits at data[3] of his block):
--   260 -> 7970            his idle line.
--   256 -> 7971-7976       THE OFFER.
--   257 -> 7976/7977       the reminder.
--   258 -> 7978-7980       THE TURN-IN.
--   259 -> 7981            post-completion.
-- 208 spans the whole block and is the umbrella program, not a separate step.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.ADDLED_MIND_UNDYING_DREAMS)

quest.reward =
{
    keyItem = xi.ki.AZURE_ABYSSITE_OF_PROSPERITY,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Silver_Owl'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(256, { [0] = xi.ki.PINCH_OF_MOIST_DANGRUF_SULFUR })
                end,
            },

            onEventFinish =
            {
                [256] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Silver_Owl'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.PINCH_OF_MOIST_DANGRUF_SULFUR) then
                        return quest:progressEvent(258, { [0] = xi.ki.PINCH_OF_MOIST_DANGRUF_SULFUR })
                    end

                    return quest:event(257, { [0] = xi.ki.PINCH_OF_MOIST_DANGRUF_SULFUR })
                end,
            },

            onEventFinish =
            {
                [258] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.PINCH_OF_MOIST_DANGRUF_SULFUR)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Silver_Owl'] = quest:event(259):replaceDefault(),
        },
    },
}

return quest
