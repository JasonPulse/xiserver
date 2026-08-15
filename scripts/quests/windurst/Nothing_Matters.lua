-----------------------------------
-- Nothing Matters
-----------------------------------
-- Log ID: 2, Quest ID: 79
-- Koru-Moru : Windurst Walls (E-7)
-- Prereq: Blast from the Past (enforced via xi.quest.setMustZone in that quest)
-----------------------------------
-- Retail (bg-wiki "Nothing Matters"): Windurst fame 8, after Blast from the Past.
-- Koru-Moru -> Fuepepe (Windurst Waters North L-6) -> the Acolyte Hostel (K-6),
-- where you interact with each of the six ground-floor doors to play Quiz de
-- Vana'diel and need 4-6 correct answers.
--
-- STILL SIMPLIFIED: the Fuepepe step and the six-door quiz are not implemented.
--
-- FABRICATED REWARD REMOVED: bg-wiki's Reward field is "10,000 Gil" and the Title
-- is Seeker of Truth -- there is no Vile Elixir. This file was handing one out
-- unconditionally with no quiz at all.
-----------------------------------
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.NOTHING_MATTERS)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.WINDURST,
    gil      = 10000,
    title    = xi.title.SEEKER_OF_TRUTH,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 8 and
                player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.BLAST_FROM_THE_PAST) and
                not xi.quest.getMustZone(player, xi.questLog.WINDURST, xi.quest.id.windurst.NOTHING_MATTERS)
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Koru-Moru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(350)
                end,
            },

            onEventFinish =
            {
                [350] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Koru-Moru'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npcUtil.tradeHasExactly(trade, { xi.item.COLD_BONE, xi.item.WARM_EGG })
                    then
                        return quest:progressEvent(351)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(352)
                end,
            },

            onEventFinish =
            {
                [351] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
