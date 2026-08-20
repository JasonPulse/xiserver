-----------------------------------
-- Voidwatch Ops: Border Crossing
-----------------------------------
-- Log ID: 7, Quest ID: 100
-- Kieran : Norg (I-8), entity 17809529
-- !addquest 7 100
-----------------------------------
-- Retail (bg-wiki "Voidwatch Ops: Border Crossing").
-- |Start=Kieran, Norg  |Fame=None  |Quest Reqs=Adventurer Certificate
-- |Reward=Ashen stratum abyssite
--   1. Speak to Kieran in Norg (I-8) for a cutscene and the Ashen stratum abyssite.
--   2. Speak to the following NPCs to begin their respective subquests:
--      Hildegard in Kazham (F-9) begins VW Op. 054: Elshimo List.
--      Gushing Spring in Rabao (G-8) begins VW Op. 101: Detour to Zepwell.
--      "Make sure to speak to these NPCs and start both their respective subquests
--      prior to killing the Voidwatch NMs, otherwise the kills will not count."
--   3. Complete both subquests and return to Kieran to complete the quest.
--
-- THIS ONE HAS NO NM LIST OF ITS OWN, which is why it does not use
-- xi.voidwatch.opSections like its siblings: it is the umbrella over the two
-- subquests, and it finishes when both of them are complete. The abyssite it hands
-- over is what those subquests check for, so it must be granted on enrolment rather
-- than at the end.
--
-- Kieran's counter is csid 259 (4468 bytes, far and away his largest block --
-- 249/255 are 30-byte lines and 250/252/254/258/260 are 12-byte stubs). As with
-- Camille and Owain, option 2 on that menu is "Participate in Voidwatch Ops." and
-- option 3 is "Request debriefing." See scripts/globals/voidwatch_ops.lua.
--
-- bg-wiki's warning about starting the subquests BEFORE killing anything is already
-- how the subquests behave -- each only counts kills while it is ACCEPTED -- so no
-- extra guard is needed here.
-----------------------------------
require('scripts/globals/voidwatch_ops')
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING)

local subquestsDone = function(player)
    return player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_054_ELSHIMO_LIST) and
        player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_101_DETOUR_TO_ZEPWELL)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(259)
                end,
            },

            onEventFinish =
            {
                [259] = function(player, csid, option, npc)
                    -- Option 2: "Participate in Voidwatch Ops."
                    if option ~= 2 then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.ASHEN_STRATUM_ABYSSITE)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(259)
                end,
            },

            onEventFinish =
            {
                [259] = function(player, csid, option, npc)
                    -- Option 3: "Request debriefing." Only settles once Hildegard
                    -- and Gushing Spring have both signed their subquests off.
                    if option ~= 3 or not subquestsDone(player) then
                        return
                    end

                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] = quest:event(261):replaceDefault(),
        },
    },
}

return quest
