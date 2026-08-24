-----------------------------------
-- Of Malnourished Martellos
-----------------------------------
-- Log ID: 8, Quest ID: 65
-- Raibaht      : Abyssea - Konschtat (I-13), entity 16839220
-- KS-NN_Martello : Abyssea - Konschtat, entities 16839203 .. 16839210
-- !addquest 8 65
-----------------------------------
-- Retail (bg-wiki "Of Malnourished Martellos").
-- |Start=Raibaht (A) (I-13), Abyssea - Konschtat  |Fame=akon |FLevel=1
-- |Previous=Hope Blooms on the Battlefield
-- |Next=Refuel and Replenish (Konschtat), Rose on the Heath
-- |Repeatable= (blank, so once only)
--   1. "Speak to Raibaht (A) at (I-13). He will give you a KI Vat of martello fuel."
--      "If you zone out of Abyssea - Konschtat at any point during this quest, you
--       may have to restart it."
--   2. "Examine one of the Martellos in Abyssea - Konschtat. It does not matter what
--      health it is at. The nearest one is slightly to the north."
--   3. "Select the option to 'Prepare to replenish martello' in the menu."
--   4. "Move to the side of the Martello that is mentioned within the menu, and
--      replenish the Martello."
--      "Although not told to you, the KI Vat of martello fuel is replaced with an
--       KI Empty fuel vat."
--   5. "Return to Raibaht, he will request that you replenish a Martello via the
--      Refuel and Replenish (Konschtat) quest."
--
-- CSIDS DECODED, NOT GUESSED. Raibaht is 16839220 -> zone 15, and his block holds
-- several quests. 205/222-226/237 belong to the Ayame materials run and to Hope
-- Blooms on the Battlefield (7850 "You've brought those for me... tell Captain Ayame
-- that the ward'll hold", 8073 "I'm in need of ${keyitem-article: 0[2]},
-- ${keyitem-article: 1[2]}, and ${keyitem-article: 2[2]}"). Per-csid attribution for
-- THIS quest:
--   227 -> 7860-7864  THE OFFER. "Ah, the young ${choice-player-gender}[man/woman]
--          who brought me my materials" -- picking up from the previous quest -- then
--          7862 "You're familiar with our martellos, are you not?", 7863 the two-way
--          menu ("Sure do." / "Mar-what-os?") and 7864 "Good. Saves me the trouble of
--          a lengthy explanation." BOTH lines accept; the second just earns the long
--          version.
--   228 -> 7869  the reminder, and it is the whole instruction: "See the martello just
--          over yonder? Why don't you try your hand at replenishing its fuel stores."
--   229 -> 7870-7874  THE TURN-IN. "Now that wasn't so difficult, was it?" then the
--          handoff bg-wiki describes: 7872 "We've tasked a dedicated machine outfitter
--          with the supervision of all martello-related matters around camp", 7873
--          "Should you wish to assist further with replenishment and repair, I
--          encourage you to seek him out."
--   230 -> 7871-7874  the same handoff after completion, "I trust you're an old hand
--          with martellos by now?"
--
-- THE MARTELLO MENU IS CLIENT-SIDE MASKED, which is why this does not fire a cutscene
-- at the tower. The eight towers each own one 981-byte program (2140-2147 in this
-- zone) whose option mask is computed in a work var, so the "Prepare to replenish
-- martello" line and the side it names cannot be resolved from the dumps. The
-- established handling for that in this codebase is scripts/globals/abyssea/martello.lua,
-- which drives the towers with printToPlayer rather than the masked menu, so this
-- quest does the same and stays consistent with it.
--
-- WHAT IS ACTUALLY VERIFIABLE is bg-wiki's stated outcome: the Vat of martello fuel
-- becomes an Empty fuel vat at the tower, and Raibaht then closes the quest. Both
-- key items are real (1559 and 1561), and that is the whole of what this file does.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.OF_MALNOURISHED_MARTELLOS)

-- The eight towers are contiguous in npc_list.
local martelloFirst = 16839203
local martelloLast  = 16839210

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_KONSCHTAT,
}

local clearRun = function(player)
    player:delKeyItem(xi.ki.VAT_OF_MARTELLO_FUEL)
    player:delKeyItem(xi.ki.EMPTY_FUEL_VAT)
end

--- Emptying the fuel vat into a tower. Reported with printToPlayer for the same
--- reason martello.lua does: the tower's own menu is masked and cannot be driven.
local martelloActions =
{
    onTrigger = function(player, npc)
        local entityId = npc:getID()

        if
            entityId < martelloFirst or
            entityId > martelloLast or
            not player:hasKeyItem(xi.ki.VAT_OF_MARTELLO_FUEL)
        then
            return
        end

        player:delKeyItem(xi.ki.VAT_OF_MARTELLO_FUEL)
        npcUtil.giveKeyItem(player, xi.ki.EMPTY_FUEL_VAT)
        player:printToPlayer('You empty the vat into the martello fuel intake. The tower thrums as it drinks.', xi.msg.channel.NS_SAY)

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HOPE_BLOOMS_ON_THE_BATTLEFIELD)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(227)
                end,
            },

            onEventFinish =
            {
                [227] = function(player, csid, option, npc)
                    -- 7863's two lines both accept; the second only asks for the
                    -- long explanation.
                    quest:begin(player)
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.VAT_OF_MARTELLO_FUEL)
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
            -- All eight towers share one handler, so each entry is a reference
            -- rather than eight copies of the same closure.
            ['KS-01_Martello'] = martelloActions,
            ['KS-02_Martello'] = martelloActions,
            ['KS-03_Martello'] = martelloActions,
            ['KS-04_Martello'] = martelloActions,
            ['KS-05_Martello'] = martelloActions,
            ['KS-06_Martello'] = martelloActions,
            ['KS-07_Martello'] = martelloActions,
            ['KS-08_Martello'] = martelloActions,

            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.EMPTY_FUEL_VAT) then
                        return quest:progressEvent(229)
                    end

                    return quest:event(228)
                end,
            },

            onEventFinish =
            {
                [229] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
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
            ['Raibaht'] = quest:event(230):replaceDefault(),
        },
    },
}

return quest
