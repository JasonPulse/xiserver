-----------------------------------
-- Aqua Puraga
-----------------------------------
-- Log ID: 8, Quest ID: 36
-- High_Bear   : Abyssea - Vunkerl (I-9), entity 17666740
-- Watergrass  : Abyssea - Vunkerl, entities 17666742 / 17666743 / 17666744
-- !addquest 8 36
-----------------------------------
-- Retail (bg-wiki "Aqua Puraga").
-- |Start=High Bear (A) (I-9), Abyssea - Vunkerl  |Fame=avun |FLevel=1
-- |Previous=Aqua Pura  |Repeatable=Yes
-- |Reward=First time: 400 Cruor. Subsequent: 200 Cruor. Chance at an Empyrean +1
--         FEET seal (Goetia/Iga/Lancer's/Navarch's).
--   "You must wait until the next Vana'dielian day after completing Aqua Pura in
--    order to start this quest."
--   1. Speak to High Bear at (I-9), near Conflux #00.
--   2. "Examine one of the Watergrass targetable locations and note your
--      observations." Each pond yields one of its own three lines.
--   3. "After you examine one location, return to High Bear and you will then have a
--      dialogue box to select one of three possible observations. If you did not
--      choose the correct pond and you are only receiving observations for a
--      different pond, choose 'Nothing of note'. You then need to visit the pond that
--      has observations that he is mentioning to you."
--   4. "Wait until the Vana'dielian day changes over (00:00) for your reward. Zoning
--      is not required to complete the quest."
--
-- CSIDS DECODED, NOT GUESSED. High Bear is 17666740 -> zone 217, and his block holds
-- BOTH quests: 1023-1026 are Aqua Pura (already implemented in Aqua_Pura.lua) and
-- 1029-1033 are this one. Per-csid attribution from his entry table's byte ranges:
--   1029 -> 8178-8188  THE OFFER. 8180 "the concentration and composition of the
--          contaminants exhibited a wide range of variance even among samples taken
--          fr[om the same pond]", 8188 "Take note of anything -- anything at all --
--          that seems amiss with the flora, and report back to me."
--   1030 -> 8188       the reminder, that instruction on its own.
--   1031 -> 8198-8218  THE REPORT. 8199 is a TEN-line menu, and its order is the
--          whole quest: Raindrops / Gunpowder / A curious ooze / Malodorous soil /
--          Rotted fruit / Ash-coated leaves / Beastly footprints / Slimy leaves /
--          Yellowish powder / Nothing of note. 8200-8214 are his reactions, one pair
--          per observation, and 8215 is the empty-handed branch ("But there must be
--          something! Anything!").
--   1032 -> 8220       the meagre-findings line.
--   1033 -> 8221-8225  THE RESULTS, read the following day: 8222 "The water quality
--          in the area has ${choice: 0}[plummeted to ne...]" and 8225 "why don't you
--          have this?"
--   Watergrass 1035 (17666742), 1037 (17666743), 1039 (17666744) -> 8189-8197, the
--          nine observation lines. One csid per pond, and the line shown is a param.
--
-- WHICH OBSERVATIONS BELONG TO WHICH POND comes straight from bg-wiki, cross-checked
-- against the menu order above:
--   (E-5)  Conflux #01: Yellowish powder, Beastly footprints, Slimy leaves -> 8, 6, 7
--   (G-10) Conflux #05: Raindrops, Gunpowder, A curious ooze                -> 0, 1, 2
--   (F-13) Conflux #06: Ash-coated leaves, Rotted fruit, Malodorous soil    -> 5, 4, 3
-- Entity order is npc_list order, the same order Aqua_Pura.lua already documents:
-- 17666742 is (E-5), 17666743 is (G-10), 17666744 is (F-13).
--
-- HIS TARGET POND IS FIXED FOR THE RUN, which is what bg-wiki's "His dialogue choices
-- will not change" means: he is only interested in one pond, and reporting anything
-- from the other two is the "Nothing of note" case. So the pond is rolled once on
-- accept and the report only lands if the option matches what was actually seen there.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AQUA_PURAGA)

-- Watergrass entity -> { csid, the three menu indices that pond can yield }.
local ponds =
{
    [17666742] = { 1035, { 8, 6, 7 } },
    [17666743] = { 1037, { 0, 1, 2 } },
    [17666744] = { 1039, { 5, 4, 3 } },
}

-- Same three ponds in npc_list order, so the rolled target can be stored as 1..3.
local pondOrder = { 17666742, 17666743, 17666744 }

-- 8199's tenth line.
local optionNothing = 9

-- bg-wiki files these under "Hands seal" but every name it lists is a FEET piece, so
-- these are the feet ids those names resolve to.
local feetSeals =
{
    xi.item.GOETIA_SEAL_FEET,
    xi.item.IGA_SEAL_FEET,
    xi.item.LANCERS_SEAL_FEET,
    xi.item.NAVARCHS_SEAL_FEET,
}

local firstCruor  = 400
local repeatCruor = 200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

local clearRun = function(player)
    quest:setVar(player, 'Pond', 0)
    quest:setVar(player, 'Seen', 0)
    quest:setVar(player, 'ReportDay', 0)
end

--- Roll the pond he cares about for this run.
local startRun = function(player)
    clearRun(player)
    quest:setVar(player, 'Pond', math.random(1, #pondOrder))
end

--- Examining a pond. Shared by the first run and the repeat.
local pondActions =
{
    onTrigger = function(player, npc)
        local entry = ponds[npc:getID()]

        if entry == nil then
            return
        end

        local observations = entry[2]
        local shown        = observations[math.random(1, #observations)]

        -- Only the pond he is actually studying counts toward the report; the other
        -- two still show their own lines, which is exactly the dead end bg-wiki
        -- describes.
        if pondOrder[quest:getVar(player, 'Pond')] == npc:getID() then
            -- Stored +1 so 0 can mean "nothing seen yet".
            quest:setVar(player, 'Seen', shown + 1)
        end

        return quest:event(entry[1], shown)
    end,
}

--- True once the Vana'diel day has rolled over since the report.
local resultsAreReady = function(player)
    local reported = quest:getVar(player, 'ReportDay')

    return reported ~= 0 and VanadielUniqueDay() > reported
end

local handleReport = function(player, option)
    local seen = quest:getVar(player, 'Seen') - 1

    -- "Nothing of note", or an observation from a pond he is not studying.
    if option == optionNothing or seen < 0 or option ~= seen then
        return false
    end

    quest:setVar(player, 'ReportDay', VanadielUniqueDay())

    return true
end

quest.sections =
{
    -- bg-wiki: Aqua Pura first, and not until the following Vana'diel day.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AQUA_PURA)
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['High_Bear'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1029)
                end,
            },

            onEventFinish =
            {
                [1029] = function(player, csid, option, npc)
                    quest:begin(player)
                    startRun(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Watergrass'] = pondActions,

            ['High_Bear'] =
            {
                onTrigger = function(player, npc)
                    if resultsAreReady(player) then
                        return quest:progressEvent(1033)
                    elseif quest:getVar(player, 'ReportDay') ~= 0 then
                        return quest:event(1032)
                    elseif quest:getVar(player, 'Seen') ~= 0 then
                        return quest:progressEvent(1031)
                    end

                    return quest:event(1030)
                end,
            },

            onEventFinish =
            {
                [1031] = function(player, csid, option, npc)
                    handleReport(player, option)
                end,

                [1033] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        xi.abyssea.questReward(player, firstCruor, feetSeals)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is not required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Watergrass'] = pondActions,

            ['High_Bear'] =
            {
                onTrigger = function(player, npc)
                    if resultsAreReady(player) then
                        return quest:progressEvent(1033)
                    elseif quest:getVar(player, 'ReportDay') ~= 0 then
                        return quest:event(1032)
                    elseif quest:getVar(player, 'Seen') ~= 0 then
                        return quest:progressEvent(1031)
                    elseif quest:getVar(player, 'Pond') ~= 0 then
                        return quest:event(1030)
                    end

                    return quest:progressEvent(1029)
                end,
            },

            onEventFinish =
            {
                [1029] = function(player, csid, option, npc)
                    startRun(player)
                end,

                [1031] = function(player, csid, option, npc)
                    handleReport(player, option)
                end,

                [1033] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.abyssea.questReward(player, repeatCruor, feetSeals)
                end,
            },
        },
    },
}

return quest
