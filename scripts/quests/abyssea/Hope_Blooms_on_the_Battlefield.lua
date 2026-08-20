-----------------------------------
-- Hope Blooms on the Battlefield
-----------------------------------
-- Log ID: 8, Quest ID: 10
-- Ayame        : Abyssea - Konschtat (I-13), entity 16839219
-- Raibaht      : Abyssea - Konschtat (I-13), entity 16839220
-- Repair_Trunk : Abyssea - Konschtat (I-13), entities 16839229-16839235
-- !addquest 8 10
-----------------------------------
-- Retail (bg-wiki "Hope Blooms on the Battlefield").
-- |Start=Ayame (A), Abyssea - Konschtat  |Reward=None  |Previous= none
--   1. Speak to Ayame (A) at (I-13).
--   2. Speak to Raibaht (A) at (I-13) near the magical barrier to the north.
--   3. Examine the Repair Trunks around (I-13) to get: Rainbow pearl,
--      Chipped wind cluster, Piece of dried ebony lumber.
--   4. Deliver them to Raibaht, then report back to Ayame.
--
-- CSIDS DECODED, NOT GUESSED, with csidscan.py against `xi-dat dialog 15`:
--   Ayame 214 -> 7842-7847  THE OFFER. 7845 "the searing ward protecting our
--          encampment is on its last leg[s]", 7846 "Raibaht is in charge of
--          maintenance, but we need someone to deliver to him the necessary
--          materials", 7847 "The supplies may be found scattered throughout
--          this encampment."
--   Ayame 215 -> 7848       the reminder: "You must collect the materials needed
--          to repair the ward and deliver them to Raibaht with all speed!"
--   Ayame 216 -> 7849       once the materials are in hand: "Yes, those are the
--          materials Raibaht needs. Deliver them to him... and report back."
--   Ayame 217 -> 7852-7858  THE COMPLETION. "Thank you, friend. You've served us
--          well."
--   Raibaht 225 -> 7850     THE DELIVERY: "You've brought those for me? Much
--          obliged, friend... tell Captain Ayame that the ward'll hold steady."
--   Raibaht 226 -> 7851     "Have you not reported back to Captain Ayame?"
-- Raibaht's 227-230 block (7860-7874) opens on 7862 "You're familiar with our
-- martellos, are you not?" -- that is the martello questline, not this quest,
-- and is left alone.
--
-- THE THREE MATERIALS are key items, all already defined: RAINBOW_PEARL (1572),
-- CHIPPED_WIND_CLUSTER (1573) and PIECE_OF_DRIED_EBONY_LUMBER (1574) -- three
-- consecutive ids, which is corroboration that they are one set. Seven
-- Repair_Trunk entities (16839229-16839235) stand around (I-13) and own no
-- csids, so examining one is handled server-side: it yields whichever of the
-- three the player still lacks, which is what makes "examine the Repair Trunks"
-- terminate rather than loop on duplicates.
--
-- REWARD: bg-wiki says None. quest.reward is therefore left unset rather than
-- inventing fame or gil to make it look finished.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HOPE_BLOOMS_ON_THE_BATTLEFIELD)

local materials =
{
    xi.ki.RAINBOW_PEARL,
    xi.ki.CHIPPED_WIND_CLUSTER,
    xi.ki.PIECE_OF_DRIED_EBONY_LUMBER,
}

local hasAllMaterials = function(player)
    for _, ki in ipairs(materials) do
        if not player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(214)
                end,
            },

            onEventFinish =
            {
                [214] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: gather the three materials, hand them to Raibaht.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Delivered == 0
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Repair_Trunk'] =
            {
                onTrigger = function(player, npc)
                    for _, ki in ipairs(materials) do
                        if not player:hasKeyItem(ki) then
                            npcUtil.giveKeyItem(player, ki)
                            return
                        end
                    end
                end,
            },

            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    if hasAllMaterials(player) then
                        return quest:progressEvent(225)
                    end
                end,
            },

            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    if hasAllMaterials(player) then
                        return quest:event(216)
                    end

                    return quest:event(215)
                end,
            },

            onEventFinish =
            {
                [225] = function(player, csid, option, npc)
                    for _, ki in ipairs(materials) do
                        player:delKeyItem(ki)
                    end

                    quest:setVar(player, 'Delivered', 1)
                end,
            },
        },
    },

    -- Delivered: report back to Ayame.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Delivered == 1
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(217)
                end,
            },

            ['Raibaht'] = quest:event(226),

            onEventFinish =
            {
                [217] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Delivered', 0)
                    end
                end,
            },
        },
    },
}

return quest
