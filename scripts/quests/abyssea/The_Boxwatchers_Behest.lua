-----------------------------------
-- The Boxwatcher's Behest
-----------------------------------
-- Log ID: 8, Quest ID: 31
-- Deraquien : Abyssea - Vunkerl (F-4), entity 17666762
-- Elmemague : Abyssea - Vunkerl (I-9), entity 17666763
-- !addquest 8 31
-----------------------------------
-- Retail (bg-wiki "The Boxwatcher's Behest").
-- |Start=Deraquien (A) (F-4), Abyssea - Vunkerl  |Fame=avun |FLevel=1
-- |Reward=First time: 300~1,500 Cruor, 10~70 Resistance Credits.
--         Subsequent: 225~1,125 Cruor, 10~70 Resistance Credits.
--         Chance at an Empyrean +1 FEET seal
--         (Ravager's/Caller's/Charis/Savant's).  |Repeatable=Yes
--   1. "Speak to Deraquien at (F-4), base camp (Conflux #01)."
--   2. "You will be given a choice between three backpack key items:
--        KI Pocket supply pack   -24% movement speed
--        KI Standard supply pack -48% movement speed
--        KI Hefty supply pack    -72% movement speed
--      The heavier the pack, the more reduction but the greater the Cruor reward."
--   3. "Travel to Elmemague at (I-9) near Veridical Conflux #00. Using a Veridical
--      Conflux will change your supply pack into a KI Pack of molten slag, and you
--      will fail. You will receive a KI Letter of receipt and Flee status."
--   4. "Return to Deraquien to complete the quest and receive reward."
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Deraquien 1046 -> 8374-8397 plus 8360  THE FIRST-TIME SCENE. It is the captain
--          dressing Deraquien down (8379-8387) and then recruiting the player
--          directly: 8388 "You there, stranger! You strike me as the capable sort",
--          8390 "What say you?", and 8360 is the two-way menu ("Anything to aid the
--          cause!" / "Sorry, I have better things to do."). 7942 is the standing
--          warning, "Changing areas, logging out, or becoming disconnected will
--          cause all data pertinent to this quest to be reset."
--   Deraquien 1047 -> 8398-8407  THE PACK SELECTION, and it is where every number in
--          bg-wiki's reward range is actually stated. 8401 is a FOUR-line menu,
--          "${keyitem-article: 0[2]}." / "1[2]." / "2[2]." / "Nothing at the
--          moment.", so the three pack ids are params 0, 1 and 2. 8402/8403/8404 then
--          quote "${number: 3} cruor" for the light, weighty and near-impossible
--          loads respectively, and 8405 is the "Transport this one? Yes. No."
--          confirmation. 8406 names Elmemague as the destination.
--   Deraquien 1049 -> 8409-8412  the abandon menu, "Abandon the transport mission?
--          Yes, I give up. / No, I will press on!"
--   Deraquien 1050 -> 8420  THE PAYOUT, "Oh, you're back. Seems milord captain was
--          right...you're capable of more than I could ever hope to be."
--   Deraquien 1051 -> 8409/8413  the ruined-pack branch, "Broken, you say? Tsk
--          tsk...I warned you against trying to take any shortcuts, did I not?"
--   Elmemague 1080 -> 8416/8417  his introduction to the outpost.
--   Elmemague 1081 -> 8414-8417  THE DELIVERY, "Right on time! You can just set that
--          down right here" / "You can go back and claim your reward from
--          what's-his-name at the central base."
--   Elmemague 1082 -> 8414/8418/8419  the failed delivery, "Your mission was to
--          deliver our supplies, not a load of rubbish. You didn't think you could
--          get away with taking a shortcut through [a conflux]."
--
-- NEEDS CONFIRMATION: 8402, 8403 and 8404 all render the Cruor figure from the SAME
-- param index (${number: 3}) while quoting three different sums, so the event must
-- re-read it as the selection moves. The update protocol is not decoded here, so
-- 1047 is fired with the three key item ids and the top-tier figure. What the text
-- quotes may therefore read high for the two lighter packs; what is actually PAID is
-- the per-pack table below, which is authoritative and matches bg-wiki.
--
-- THE CONFLUX FAILURE IS NOT WIRED. Turning the pack into a Pack of molten slag on
-- conflux use would mean reaching into the shared conflux script from here. The
-- branch is implemented and reachable -- 1051 and 1082 both fire off the slag key
-- item -- so when the conflux hook is added, nothing in this file changes.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_BOXWATCHERS_BEHEST)

-- bg-wiki's three loads, in the order 8401's menu lists them. Cruor spans its stated
-- 300~1,500 first-time band and the 225~1,125 repeat band, and credits its 10~70.
local supplyPacks =
{
    [0] = { ki = xi.ki.POCKET_SUPPLY_PACK,   first = 300,  again = 225,  credits = 10, slow = 24 },
    [1] = { ki = xi.ki.STANDARD_SUPPLY_PACK, first = 750,  again = 565,  credits = 40, slow = 48 },
    [2] = { ki = xi.ki.HEFTY_SUPPLY_PACK,    first = 1500, again = 1125, credits = 70, slow = 72 },
}

local feetSeals =
{
    xi.item.RAVAGERS_SEAL_FEET,
    xi.item.CALLERS_SEAL_FEET,
    xi.item.CHARIS_SEAL_FEET,
    xi.item.SAVANTS_SEAL_FEET,
}

-- 8401's fourth line, "Nothing at the moment."
local optionNoPack = 3

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

--- The pack entry the player is currently carrying, or nil.
local carriedPack = function(player)
    for _, entry in pairs(supplyPacks) do
        if player:hasKeyItem(entry.ki) then
            return entry
        end
    end

    return nil
end

local clearRun = function(player)
    for _, entry in pairs(supplyPacks) do
        player:delKeyItem(entry.ki)
    end

    player:delKeyItem(xi.ki.PACK_OF_MOLTEN_SLAG)
    player:delKeyItem(xi.ki.LETTER_OF_RECEIPT)
    quest:setVar(player, 'Pack', 0)
    player:delStatusEffect(xi.effect.WEIGHT)
end

--- Hand over the chosen load and apply its handicap.
local takePack = function(player, option)
    local entry = supplyPacks[option]

    if entry == nil then
        return
    end

    npcUtil.giveKeyItem(player, entry.ki)
    -- Stored 1-based so 0 can mean "carrying nothing".
    quest:setVar(player, 'Pack', option + 1)
    player:addStatusEffect(xi.effect.WEIGHT, entry.slow, 0, 0)
end

local payOut = function(player, firstTime)
    local option = quest:getVar(player, 'Pack') - 1
    local entry  = supplyPacks[option]

    clearRun(player)

    if entry == nil then
        return
    end

    player:addCurrency('resistance_credit', entry.credits)
    xi.abyssea.questReward(player, firstTime and entry.first or entry.again, feetSeals)
end

--- Deraquien behaves the same once the quest exists; only the payout tier differs.
local deraquienTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.LETTER_OF_RECEIPT) then
        return quest:progressEvent(1050)
    elseif player:hasKeyItem(xi.ki.PACK_OF_MOLTEN_SLAG) then
        return quest:progressEvent(1051)
    elseif carriedPack(player) ~= nil then
        return quest:progressEvent(1049)
    end

    return quest:progressEvent(1047,
        supplyPacks[0].ki, supplyPacks[1].ki, supplyPacks[2].ki, supplyPacks[2].first)
end

local elmemagueTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.PACK_OF_MOLTEN_SLAG) then
        return quest:progressEvent(1082)
    elseif carriedPack(player) ~= nil then
        return quest:progressEvent(1081)
    end

    return quest:event(1080)
end

--- Elmemague taking the delivery, shared by both sections.
local deliver = function(player, csid, option, npc)
    local entry = carriedPack(player)

    if entry == nil then
        return
    end

    player:delKeyItem(entry.ki)
    player:delStatusEffect(xi.effect.WEIGHT)
    npcUtil.giveKeyItem(player, xi.ki.LETTER_OF_RECEIPT)
    -- bg-wiki: "You will receive a KI Letter of receipt and Flee status."
    player:addStatusEffect(xi.effect.FLEE, 25, 0, 60)
end

--- The abandon menu, shared by both sections.
local abandon = function(player, csid, option, npc)
    -- 8410: "Yes, I give up." is the first line.
    if option ~= 0 then
        return
    end

    clearRun(player)
end

--- The ruined-pack branch, shared by both sections.
local scrapSlag = function(player, csid, option, npc)
    clearRun(player)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Deraquien'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1046)
                end,
            },

            onEventFinish =
            {
                [1046] = function(player, csid, option, npc)
                    -- 8360's second line declines.
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    clearRun(player)
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
            ['Deraquien'] = { onTrigger = deraquienTrigger },
            ['Elmemague'] = { onTrigger = elmemagueTrigger },

            onEventFinish =
            {
                [1047] = function(player, csid, option, npc)
                    if option == optionNoPack then
                        return
                    end

                    takePack(player, option)
                end,

                [1049] = abandon,
                [1051] = scrapSlag,
                [1081] = deliver,
                [1082] = scrapSlag,

                [1050] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, true)
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
            ['Deraquien'] = { onTrigger = deraquienTrigger },
            ['Elmemague'] = { onTrigger = elmemagueTrigger },

            onEventFinish =
            {
                [1047] = function(player, csid, option, npc)
                    if option == optionNoPack then
                        return
                    end

                    takePack(player, option)
                end,

                [1049] = abandon,
                [1051] = scrapSlag,
                [1081] = deliver,
                [1082] = scrapSlag,

                [1050] = function(player, csid, option, npc)
                    payOut(player, false)
                end,
            },
        },
    },
}

return quest
