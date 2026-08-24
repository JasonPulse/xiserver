-----------------------------------
-- Look Out Below
-----------------------------------
-- Log ID: 8, Quest ID: 68
-- Baldric       : Abyssea - Uleguerand (J-5), entity 17814094
-- Fresh Snowfall: Abyssea - Uleguerand, entities 17814095, 17814096, 17814097
-- !addquest 8 68
-----------------------------------
-- Retail (bg-wiki "Look Out Below").
-- |Start=Baldric (A), Abyssea - Uleguerand  |Fame=aule |FLevel=1  |Repeatable=Yes
-- |Reward=200-400 Cruor first time, 100-200 subsequently, by payload accuracy.
--         Chance at an Empyrean +1 BODY seal.
--   1. "He asks you to find Fresh Snowfall locations, and load them with the KI
--      Subniveal mines and Firesand." "Note that actual Firesand is not needed."
--   2. "Examining one of these locations will give you four options: Nothing, Load
--      Firesand, Remove Firesand, Place Mine."
--   3. bg-wiki's payload table, which is the whole puzzle:
--        thin layer of snow      -> filled to the brim  (4)
--        fair quantity of snow   -> filled halfway      (3)
--        large deposits of snow  -> only a pinch        (1)
--   4. "Return to Baldric (A) for your reward after filling all three spots."
--   "Zoning is required to repeat this quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Uleguerand:
--   266 -> "Avalanches have been occurring with disturbing frequency..." through
--          "Would you be willing to perform the task in my stead?"     THE OFFER,
--          and it ends on menu 7896 "Help out? [Certainly. / Certainly not.]"
--   267 -> "Through careful research, I have pinpointed three locations due east of
--          Bearclaw Pinnacle..."                              the instructions
--   270 -> "Your work's complete, is it? Wonderful! Well then, here goes nothing.
--          Look out beloooooow!" plus Furan-Furin's verdict         the turn-in
--   271 -> "Thanks to you, we've gathered valuable data. But our research is far from
--          complete."                                    the post-completion line
--   275 -> "Our lookout says we've got significant snow accumulation east of the
--          pinnacle."                                            the repeat offer
--
-- THE SNOWFALL MENU IS CSID 268 and it is fully decoded, message 7905:
--     0 Nothing.   1 Load firesand.   2 Remove firesand.   3 Set the <mine>.
-- Its companions, with the parameter that selects each variant:
--     7904 param 0 the snow depth   [thinnest layer / fair quantity / large deposits]
--     7908 param 2 the payload      [pinch / small lump / halfway / to the brim /
--                                    overflowing]
--     7906 param 3 the action       [adds / removes]
--     7907 "carefully sets the <mine> in the snowbank"
--     7909 "A <mine> has already been set here."
-- And Baldric's 270 grades on param 0: 0 too weak, 1 right on the mark, 2 overdone,
-- which is where the cruor spread comes from.
--
-- ONE THING I COULD NOT VERIFY: whether the client drives 268's load and remove
-- options as event UPDATES or as separate finishes. Menu text never reaches the chat
-- log, so the bridge cannot see it, and the Mac was locked. Both paths are wired
-- below, so the loop works either way rather than depending on the guess.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOOK_OUT_BELOW)

local snowfallSpots =
{
    17814095,
    17814096,
    17814097,
}

-- bg-wiki's table, indexed by the snow depth param 0 renders. Values are the payload
-- index that 7908 uses, so 3 is "filled to the brim" and 0 is "only a pinch".
local correctPayload =
{
    [0] = 3, -- thinnest layer of snow
    [1] = 2, -- a fair quantity of snow
    [2] = 0, -- large deposits, ready to give way
}

local maxPayload = 4

local bodySeals =
{
    xi.item.ORISON_SEAL_BODY,
    xi.item.RAIDERS_SEAL_BODY,
    xi.item.MAVI_SEAL_BODY,
    xi.item.FERINE_SEAL_BODY,
    xi.item.SYLVAN_SEAL_BODY,
}

-- 270's param 0: 0 too weak, 1 on the mark, 2 overdone. bg-wiki gives the band ends
-- only, so the middle grade takes the top of the band and the two misses the bottom.
local cruorFirst  = { [0] = 200, [1] = 400, [2] = 200 }
local cruorRepeat = { [0] = 100, [1] = 200, [2] = 100 }

local acceptOption = 0

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

local spotIndex = function(npc)
    for index, id in ipairs(snowfallSpots) do
        if id == npc:getID() then
            return index
        end
    end

    return nil
end

local function snowVar(index)
    return string.format('Snow%d', index)
end

local function payloadVar(index)
    return string.format('Load%d', index)
end

local function setVar(index)
    return string.format('Set%d', index)
end

--- Roll fresh snow depths and clear every mine. bg-wiki says the three spots carry
--- "three varying amounts of snowfall", so the depth is a property of the run.
local function beginRun(player)
    for index = 1, #snowfallSpots do
        quest:setVar(player, snowVar(index), math.random(0, 2))
        quest:setVar(player, payloadVar(index), 0)
        quest:setVar(player, setVar(index), 0)
    end
end

local function allMinesSet(player)
    for index = 1, #snowfallSpots do
        if quest:getVar(player, setVar(index)) == 0 then
            return false
        end
    end

    return true
end

--- 0 too weak, 1 on the mark, 2 overdone, matching 270's parameter. A single spot
--- being wrong is enough to spoil the run, which is what bg-wiki describes.
local function payloadGrade(player)
    local grade = 1

    for index = 1, #snowfallSpots do
        local wanted = correctPayload[quest:getVar(player, snowVar(index))] or 0
        local loaded = quest:getVar(player, payloadVar(index))

        if loaded < wanted then
            grade = 0
        elseif loaded > wanted then
            return 2
        end
    end

    return grade
end

--- Params for 268: p0 the snow depth, p2 the payload, p3 the last action.
local function snowfallParams(player, index, action)
    return quest:getVar(player, snowVar(index)),
        0,
        quest:getVar(player, payloadVar(index)),
        action
end

local function adjustPayload(player, index, delta)
    local loaded = utils.clamp(quest:getVar(player, payloadVar(index)) + delta, 0, maxPayload)

    quest:setVar(player, payloadVar(index), loaded)
end

local snowfallActions =
{
    onTrigger = function(player, npc)
        local index = spotIndex(npc)

        if index == nil then
            return
        end

        return quest:progressEvent(268, snowfallParams(player, index, 0))
    end,
}

local function handleSnowfallOption(player, option, npc)
    local index = spotIndex(npc)

    if index == nil or quest:getVar(player, setVar(index)) == 1 then
        return
    end

    if option == 1 then
        adjustPayload(player, index, 1)
    elseif option == 2 then
        adjustPayload(player, index, -1)
    elseif option == 3 then
        quest:setVar(player, setVar(index), 1)
    end
end

local function payOut(player, cruorByGrade)
    xi.abyssea.questReward(player, cruorByGrade[payloadGrade(player)] or 0, bodySeals)
    beginRun(player)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOOK_OUT_BELOW)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 1
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Baldric'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(266)
                end,
            },

            onEventFinish =
            {
                [266] = function(player, csid, option, npc)
                    -- 7896 is "Help out? [Certainly. / Certainly not.]", so a decline
                    -- has to leave the quest unstarted.
                    if option ~= acceptOption then
                        return
                    end

                    quest:begin(player)
                    beginRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.SUBNIVEAL_MINES)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Fresh_Snowfall'] = snowfallActions,

            ['Baldric'] =
            {
                onTrigger = function(player, npc)
                    if not allMinesSet(player) then
                        return quest:event(267)
                    end

                    return quest:progressEvent(270, payloadGrade(player))
                end,
            },

            onEventUpdate =
            {
                [268] = function(player, csid, option, npc)
                    handleSnowfallOption(player, option, npc)

                    local index = spotIndex(npc)

                    if index ~= nil then
                        player:updateEvent(snowfallParams(player, index, option == 2 and 1 or 0))
                    end
                end,
            },

            onEventFinish =
            {
                [268] = function(player, csid, option, npc)
                    handleSnowfallOption(player, option, npc)
                end,

                [270] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, cruorFirst)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Fresh_Snowfall'] = snowfallActions,

            ['Baldric'] =
            {
                onTrigger = function(player, npc)
                    if allMinesSet(player) then
                        return quest:progressEvent(270, payloadGrade(player))
                    elseif quest:getMustZone(player) then
                        return quest:event(271)
                    end

                    return quest:progressEvent(275)
                end,
            },

            onEventUpdate =
            {
                [268] = function(player, csid, option, npc)
                    handleSnowfallOption(player, option, npc)

                    local index = spotIndex(npc)

                    if index ~= nil then
                        player:updateEvent(snowfallParams(player, index, option == 2 and 1 or 0))
                    end
                end,
            },

            onEventFinish =
            {
                [268] = function(player, csid, option, npc)
                    handleSnowfallOption(player, option, npc)
                end,

                [270] = function(player, csid, option, npc)
                    payOut(player, cruorRepeat)
                end,

                [275] = function(player, csid, option, npc)
                    beginRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.SUBNIVEAL_MINES)
                end,
            },
        },
    },
}

return quest
