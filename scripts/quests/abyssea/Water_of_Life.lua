-----------------------------------
-- Water of Life
-----------------------------------
-- Log ID: 8, Quest ID: 7
-- Miageau    : Abyssea - La Theine (L-11), entity 17318639
-- Murky_Pond : Abyssea - La Theine, entities 17318640 / 17318641 / 17318642 / 17318643
-- !addquest 8 7
-----------------------------------
-- Retail (bg-wiki "Water of Life").
-- |Start=Miageau (A) (L-11), Abyssea - La Theine  |Fame=alth |FLevel=4
-- |Reward=360 Cruor, Evolith with random stats  |Repeatable=Yes
--   1. Speak to Miageau at (L-11), Veridical Conflux #06.
--   2. "You will receive the following four key items: Vial of purification agent
--      (blk./brz./slv./gld.)"
--   3. "Examine the 4 Murky Pond targetable locations at (L-10), (K-11), and 2 at
--      (H-7). With each pond examined, your key items will be replaced with:
--      Black-/Bronze-/Silver-/Gold-labeled vial."
--   4. Return to Miageau.
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Miageau is 17318639 -> zone 132. Per-csid attribution
-- from his entry table's byte ranges:
--   204 -> 7998       his generic encampment greeting, no quest involvement.
--   207 -> 7999-8012  THE OFFER. 8002 is the two-way menu ("I surely will." /
--          "Potable water is overrated."), 8005 "I entrust to you these four vials
--          of chemicals. Take them and empty the contents of one into each of the
--          four ponds", 8006 "draw water samples using the selfsame vials". 8012
--          is the repeat line, "the ponds do not remain cleansed for long".
--   205 -> 8005/8006  the reminder, the instructions without the preamble.
--   206 -> 8007-8011  THE TURN-IN. 8007 "I shall take the water samples off your
--          hands", 8008 "water quality has improved noticeably".
--   208 -> 8009-8011  his post-completion lines.
--   Murky_Pond 209 (17318640), 210 (17318641), 211 (17318642), 212 (17318643) ->
--          8013 "The water appears murky and stagnated...", 8014 "Use the
--          ${keyitem-singular: 0[2]}? Yes. No.", 8015 "${name-player} empties
--          ${keyitem-article: 0[2]} into the pond."
--
-- ONE CSID PER POND, so the vial each pond wants is fixed by the client rather than
-- chosen here: npc_list order pairs 17318640..17318643 with blk/brz/slv/gld, the
-- same order bg-wiki lists the key items in. The vial id is passed as a param
-- because 8014 and 8015 both render it from one.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WATER_OF_LIFE)

-- Murky_Pond entity -> { csid, agent vial, labelled vial }.
local ponds =
{
    [17318640] = { 209, xi.ki.VIAL_OF_PURIFICATION_AGENT_BLK, xi.ki.BLACK_LABELED_VIAL  },
    [17318641] = { 210, xi.ki.VIAL_OF_PURIFICATION_AGENT_BRZ, xi.ki.BRONZE_LABELED_VIAL },
    [17318642] = { 211, xi.ki.VIAL_OF_PURIFICATION_AGENT_SLV, xi.ki.SILVER_LABELED_VIAL },
    [17318643] = { 212, xi.ki.VIAL_OF_PURIFICATION_AGENT_GLD, xi.ki.GOLD_LABELED_VIAL   },
}

local agentVials =
{
    xi.ki.VIAL_OF_PURIFICATION_AGENT_BLK,
    xi.ki.VIAL_OF_PURIFICATION_AGENT_BRZ,
    xi.ki.VIAL_OF_PURIFICATION_AGENT_SLV,
    xi.ki.VIAL_OF_PURIFICATION_AGENT_GLD,
}

local labelledVials =
{
    xi.ki.BLACK_LABELED_VIAL,
    xi.ki.BRONZE_LABELED_VIAL,
    xi.ki.SILVER_LABELED_VIAL,
    xi.ki.GOLD_LABELED_VIAL,
}

local cruorReward = 360

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

local giveVials = function(player)
    for i = 1, #agentVials do
        player:delKeyItem(labelledVials[i])
        npcUtil.giveKeyItem(player, agentVials[i])
    end
end

local clearVials = function(player)
    for i = 1, #agentVials do
        player:delKeyItem(agentVials[i])
        player:delKeyItem(labelledVials[i])
    end
end

local allSampled = function(player)
    for _, ki in ipairs(labelledVials) do
        if not player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

--- The ponds behave the same on the first run and on repeats.
local pondActions =
{
    onTrigger = function(player, npc)
        local entry = ponds[npc:getID()]

        if entry == nil then
            return
        end

        -- 8014's menu only makes sense while the agent vial is still unopened.
        if not player:hasKeyItem(entry[2]) then
            return
        end

        return quest:event(entry[1], entry[2])
    end,
}

--- Swap the agent vial for its labelled counterpart. Shared by both sections.
local pondFinish = function(player, csid, option, npc)
    for _, entry in pairs(ponds) do
        if entry[1] == csid then
            -- 8014 is a Yes/No prompt; anything other than the accepting option
            -- leaves the vial untouched.
            if option == 0 then
                return
            end

            player:delKeyItem(entry[2])
            npcUtil.giveKeyItem(player, entry[3])

            return
        end
    end
end


quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_LATHEINE) >= 4
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Miageau'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(207)
                end,
            },

            onEventFinish =
            {
                [207] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearVials(player)
                    giveVials(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Murky_Pond'] = pondActions,

            ['Miageau'] =
            {
                onTrigger = function(player, npc)
                    if allSampled(player) then
                        return quest:progressEvent(206)
                    end

                    return quest:event(205)
                end,
            },

            onEventFinish =
            {
                [209] = pondFinish,
                [210] = pondFinish,
                [211] = pondFinish,
                [212] = pondFinish,

                [206] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearVials(player)
                        npcUtil.giveItem(player, xi.item.EVOLITH)
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Murky_Pond'] = pondActions,

            ['Miageau'] =
            {
                onTrigger = function(player, npc)
                    if allSampled(player) then
                        return quest:progressEvent(206)
                    elseif player:hasKeyItem(xi.ki.VIAL_OF_PURIFICATION_AGENT_BLK) then
                        return quest:event(205)
                    elseif quest:getMustZone(player) then
                        return quest:event(208)
                    end

                    return quest:progressEvent(207)
                end,
            },

            onEventFinish =
            {
                [209] = pondFinish,
                [210] = pondFinish,
                [211] = pondFinish,
                [212] = pondFinish,

                [206] = function(player, csid, option, npc)
                    clearVials(player)
                    npcUtil.giveItem(player, xi.item.EVOLITH)
                    xi.abyssea.questReward(player, cruorReward, nil)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.WATER_OF_LIFE)
                end,

                [207] = function(player, csid, option, npc)
                    clearVials(player)
                    giveVials(player)
                end,
            },
        },
    },
}

return quest
