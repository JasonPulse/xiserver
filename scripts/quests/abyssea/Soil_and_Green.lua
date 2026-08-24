-----------------------------------
-- Soil and Green
-----------------------------------
-- Log ID: 8, Quest ID: 54
-- Sieglinde     : Abyssea - Misareaux (K-7), entity 17662732
-- Logging_Point : Abyssea - Misareaux, entity 17662717
-- !addquest 8 54
-----------------------------------
-- Retail (bg-wiki "Soil and Green").
-- |Start=Sieglinde (A), Abyssea - Misareaux  |Fame=amis |FLevel=2
-- |Reward=400 Cruor. Chance at an Empyrean +1 LEGS seal
--         (Ravager's/Caller's/Charis/Savant's).  |Repeatable=Yes
--   1. "Speak to Sieglinde (A) at (K-7). She will give you the KI Mineral gauge for
--      dummies."
--   2. "Find a Logging Point and interact with it, the mineral gauge will respond
--      with a color."
--   3. "Return to Sieglinde. If the mineral gauge is red or yellow, Sieglinde will
--      give you the KI Tube of alchemical fertilizer. Interact with a Logging Point
--      again. If the mineral gauge is blue, or if you examined a logging point after
--      getting the fertilizer, speak to Sieglinde again to finish the quest."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Sieglinde's own blocks are ONE BYTE each, i.e. stubs;
-- the real programs live on the unnamed HOLDER entity 17662724 ('010d8300'), which
-- carries 186-199 for this quest and 210-214 for Cookbook of Hope Restoring.
-- Per-csid attribution from that holder's byte ranges:
--   186 -> 8304  the brush-off, "I've no time to waste on individuals of little
--          account" -- her fame gate.
--   187 -> 8305-8308  THE OFFER. "You would serve admirably as my assistant" / "You
--          are to take this ${keyitem-singular: 1[2]} and thrust it [into the earth]".
--   189 -> 8315-8317  the reminder, "Simply thrust it into the earth by the root of a
--          tree, and then observe what color of [light]".
--   190 -> 8318-8321  THE READING, and it carries all three outcomes: 8319 "an angry
--          red light", 8320 "a radiant blue light", 8321 "a homely yellow light". The
--          colour is therefore a param, which is why it is rolled and passed here.
--   191 -> 8322-8326  THE FIRST REPORT, also carrying every branch: 8323 the red
--          reply, 8324/8325 the blue reply ("The soil quality leaves nothing to be
--          desired"), 8326 "Take this as your reward".
--   192 -> 8335  the fertilizer reminder, "the active ingredients remain effective
--          for only a limited duration".
--   193 -> 8340-8342  THE INJECTION: "You inject the fertilizer into the soil" /
--          "The soil begins giving off a rich, earthy aroma" / "Nothing happened..."
--   195 -> 8346-8348  the successful completion, "Take this as a small token."
--   196 -> 8343-8345  the failed completion, "you were too late in administering the
--          fertilizer. Our painstaking effort was all for naught."
--   197 -> 8349  her post-completion line after a success.
--   198 -> 8345  her post-completion line after a failure.
--   199 -> 8307-8311  the repeat offer, which re-explains the colour code.
--
-- THE COLOUR IS ROLLED, not read from the world. 8309-8311 describe what each colour
-- means about the soil ("A blue light indicates nutrient-rich soil", "A yellow light
-- indicates ordinary soil that would benefit from a boost in mineral levels"), and
-- bg-wiki gives no per-Logging-Point mapping -- it says only "Find a Logging Point",
-- listing five interchangeable ones. So the reading is a property of the sample, and
-- blue short-circuits the quest exactly as bg-wiki describes.
--
-- bg-wiki files the seal list under "Hands" but every name in it is a LEGS piece
-- (Ravager's Seal: Legs and so on), so the ids below are the legs pieces the names
-- actually resolve to.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOIL_AND_GREEN)

local loggingPoint = 17662717

-- The param 190 and 191 both branch on: 0 red, 1 blue, 2 yellow, in the order 8319,
-- 8320 and 8321 appear. Only blue is named here because only blue changes the flow;
-- red and yellow both lead to the fertilizer leg.
local colourBlue = 1

local legsSeals =
{
    xi.item.RAVAGERS_SEAL_LEGS,
    xi.item.CALLERS_SEAL_LEGS,
    xi.item.CHARIS_SEAL_LEGS,
    xi.item.SAVANTS_SEAL_LEGS,
}

local cruorReward = 400

-- 8335: "the active ingredients remain effective for only a limited duration."
-- bg-wiki publishes no figure; this is the generous end of a walk between two
-- logging points.
local fertilizerLimit = 300

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_MISAREAUX,
}

local clearRun = function(player)
    quest:setVar(player, 'Colour', 0)
    quest:setVar(player, 'Read', 0)
    quest:setVar(player, 'Injected', 0)
    quest:setVar(player, 'FertTime', 0)
    player:delKeyItem(xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
    player:delKeyItem(xi.ki.TUBE_OF_ALCHEMICAL_FERTILIZER)
end

--- Reading the soil, then later injecting into it. Shared by both sections.
local loggingActions =
{
    onTrigger = function(player, npc)
        if npc:getID() ~= loggingPoint then
            return
        end

        -- Second visit: administer the fertilizer she handed over.
        if player:hasKeyItem(xi.ki.TUBE_OF_ALCHEMICAL_FERTILIZER) then
            local inTime = GetSystemTime() - quest:getVar(player, 'FertTime') <= fertilizerLimit

            quest:setVar(player, 'Injected', inTime and 1 or 2)
            player:delKeyItem(xi.ki.TUBE_OF_ALCHEMICAL_FERTILIZER)

            return quest:event(193)
        end

        if
            not player:hasKeyItem(xi.ki.MINERAL_GAUGE_FOR_DUMMIES) or
            quest:getVar(player, 'Read') == 1
        then
            return
        end

        -- Stored as 1..3 so 0 can mean "not yet sampled".
        local colour = math.random(0, 2)

        quest:setVar(player, 'Colour', colour + 1)
        quest:setVar(player, 'Read', 1)

        return quest:event(190, colour)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_MISAREAUX) >= 2
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Sieglinde'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(187)
                end,
            },

            onEventFinish =
            {
                [187] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Logging_Point'] = loggingActions,

            ['Sieglinde'] =
            {
                onTrigger = function(player, npc)
                    local injected = quest:getVar(player, 'Injected')

                    -- The fertilizer leg has run: 195 on time, 196 too late.
                    if injected == 1 then
                        return quest:progressEvent(195)
                    elseif injected == 2 then
                        return quest:progressEvent(196)
                    end

                    if quest:getVar(player, 'Read') ~= 1 then
                        return quest:event(189, xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
                    end

                    -- 191 carries every branch itself; the colour just selects one.
                    -- Blue closes the quest out, red and yellow start the fertilizer
                    -- leg, and that decision is made in its onEventFinish.
                    return quest:progressEvent(191, quest:getVar(player, 'Colour') - 1)
                end,
            },

            onEventFinish =
            {
                [191] = function(player, csid, option, npc)
                    local colour = quest:getVar(player, 'Colour') - 1

                    if colour == colourBlue then
                        if quest:complete(player) then
                            clearRun(player)
                            xi.abyssea.questReward(player, cruorReward, legsSeals)
                        end

                        return
                    end

                    -- Red or yellow: she hands over the fertilizer and the clock
                    -- 8335 warns about starts.
                    npcUtil.giveKeyItem(player, xi.ki.TUBE_OF_ALCHEMICAL_FERTILIZER)
                    quest:setVar(player, 'FertTime', GetSystemTime())
                end,

                [195] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        xi.abyssea.questReward(player, cruorReward, legsSeals)
                    end
                end,

                [196] = function(player, csid, option, npc)
                    -- "Our painstaking effort was all for naught": the run ends, but
                    -- the quest stays open so it can simply be redone.
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Logging_Point'] = loggingActions,

            ['Sieglinde'] =
            {
                onTrigger = function(player, npc)
                    local injected = quest:getVar(player, 'Injected')

                    if injected == 1 then
                        return quest:progressEvent(195)
                    elseif injected == 2 then
                        return quest:progressEvent(196)
                    elseif quest:getVar(player, 'Read') == 1 then
                        return quest:progressEvent(191, quest:getVar(player, 'Colour') - 1)
                    elseif player:hasKeyItem(xi.ki.MINERAL_GAUGE_FOR_DUMMIES) then
                        return quest:event(189, xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
                    elseif quest:getMustZone(player) then
                        return quest:event(197)
                    end

                    return quest:progressEvent(199)
                end,
            },

            onEventFinish =
            {
                [191] = function(player, csid, option, npc)
                    local colour = quest:getVar(player, 'Colour') - 1

                    if colour == colourBlue then
                        clearRun(player)
                        xi.abyssea.questReward(player, cruorReward, legsSeals)
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOIL_AND_GREEN)

                        return
                    end

                    npcUtil.giveKeyItem(player, xi.ki.TUBE_OF_ALCHEMICAL_FERTILIZER)
                    quest:setVar(player, 'FertTime', GetSystemTime())
                end,

                [195] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.abyssea.questReward(player, cruorReward, legsSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOIL_AND_GREEN)
                end,

                [196] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOIL_AND_GREEN)
                end,

                [199] = function(player, csid, option, npc)
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.MINERAL_GAUGE_FOR_DUMMIES)
                end,
            },
        },
    },
}

return quest
