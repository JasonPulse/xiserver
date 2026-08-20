-----------------------------------
-- Voices from Beyond
-----------------------------------
-- Log ID: 8, Quest ID: 57
-- Rukususu : Abyssea - Grauberg (F-10), entity 17818237
-- !addquest 8 57
-----------------------------------
-- bg-wiki: |Start=Rukususu (A) (F-10)  |Repeatable=No
-- |Item Reqs=Decaying Molar, Ominous Skull  |Reward=Indigo abyssite of lenity
--   Talk to Rukususu, investigate the ??? at (C-8) in Skyrend, return with
--   evidence that the mountain is haunted.
--
-- CSIDS (csidmsg.load on 17818237; NPC confirmed by resolve_npc.py -- item 3315
-- sits at data[27]):
--   255 -> 8085-8096  THE OFFER. 8093 "ghosts of zee dead 'aunt zee mountains",
--          8094 "I require zat vous go et determine zee authenticité".
--   256 -> 8098/8099  the reminder, "bring eet back to moi".
--   257 -> 8102-8112  THE TURN-IN.
--   258 -> 8111       post-completion.
-- Items are param 0/1: Decaying Molar (3269) and Ominous Skull (3315).
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.VOICES_FROM_BEYOND)

quest.reward =
{
    keyItem = xi.ki.INDIGO_ABYSSITE_OF_LENITY,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(255,
                        { [0] = xi.item.DECAYING_MOLAR, [1] = xi.item.OMINOUS_SKULL })
                end,
            },

            onEventFinish =
            {
                [255] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npcUtil.tradeHasExactly(trade, xi.item.OMINOUS_SKULL) or
                        npcUtil.tradeHasExactly(trade, xi.item.DECAYING_MOLAR)
                    then
                        return quest:progressEvent(257,
                            { [0] = xi.item.DECAYING_MOLAR, [1] = xi.item.OMINOUS_SKULL })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(256,
                        { [0] = xi.item.DECAYING_MOLAR, [1] = xi.item.OMINOUS_SKULL })
                end,
            },

            onEventFinish =
            {
                [257] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        -- Benevolence Lost: "You must zone after completing
                        -- Voices from Beyond before you can start this quest."
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.BENEVOLENCE_LOST)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Rukususu'] = quest:event(258):replaceDefault(),
        },
    },
}

return quest
