-----------------------------------
-- Wayward Wares
-----------------------------------
-- Log ID: 8, Quest ID: 39
-- Chapi_Galepilai : Abyssea - Attohwa (G-10), entity 17658592
-- Morlepiche      : Abyssea - Attohwa, entity 17658593
-- Supply_Point    : Abyssea - Attohwa, entities 17658594 / 17658595 / 17658596
-- !addquest 8 39
-----------------------------------
-- Retail (bg-wiki "Wayward Wares").
-- |Start=Chapi Galepilai (A) (G-10), Abyssea - Attohwa  |Fame=aatt |FLevel=1
-- |Reward=Based on how many KI returned: 100~400 Cruor, 25~100 Resistance Credits
--   1. Speak to Chapi Galepilai (A) (G-10).
--   2. "You will be asked to retrieve missing supply packs. There are three total."
--   3. "Examine at least one of the three Supply Points located around the Crevice
--      Amoeban / Treacle Slugs:
--        KI Pulse martello repair pack (G-8)
--        KI Clone ward reinforcement pack (F-9)
--        KI Pack of outpost repair tools (F-9)"
--   4. "Once you have found at least one of the packs, speak to Morlepiche (A) at
--      Veridical Conflux #00 to complete the quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Chapi_Galepilai 305 -> 8018-8039  THE OFFER. 8035 "a rrregiment charged with
--          delivering a shipment of essential supplies to the outpost was ambushed",
--          8036 "the supplies were scattered across the chasm", 8037 "You don't need
--          to track down all of them. Let's see... Yes, I believe ${number: 0} or so
--          would be sufficient" -- the count is a param, hence the three passed
--          below. 8038 "You can deliver them to Morlepiche."
--   Chapi_Galepilai 306 -> 8035-8039  the reminder, the request without the preamble.
--   Chapi_Galepilai 307 -> 8050/8051  her flavour lines about airship survivors.
--   Morlepiche 308 -> 8040  "...Five, six. Curses! Is this all that remains!?" --
--          he is still counting, i.e. nothing handed in yet.
--   Morlepiche 309 -> 8041/8042 plus msg 201, the activity-points marker every
--          rewarding event in these zones ends on. THE TURN-IN.
--   Morlepiche 310 -> 8043/8048/8049  his post-completion lines.
--
-- THE SUPPLY POINTS HAVE NO EVENT PROGRAMS AT ALL. csidmsg.load returns nothing for
-- 17658594/17658595/17658596, so picking a pack up is a plain key-item grant with
-- the standard KEYITEM_OBTAINED message rather than a cutscene. Each point carries
-- one fixed pack, in npc_list order, matching the order bg-wiki lists them.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WAYWARD_WARES)

-- Supply_Point entity -> the pack it holds. npc_list order.
local supplyPoints =
{
    [17658594] = xi.ki.PULSE_MARTELLO_REPAIR_PACK,
    [17658595] = xi.ki.CLONE_WARD_REINFORCEMENT_PACK,
    [17658596] = xi.ki.PACK_OF_OUTPOST_REPAIR_TOOLS,
}

local allPacks =
{
    xi.ki.PULSE_MARTELLO_REPAIR_PACK,
    xi.ki.CLONE_WARD_REINFORCEMENT_PACK,
    xi.ki.PACK_OF_OUTPOST_REPAIR_TOOLS,
}

-- "Varying amount of Cruor: 100~400" and "Resistance Credits: 25~100", both keyed to
-- how many of the three packs came back.
local cruorForPacks   = { 100, 250, 400 }
local creditsForPacks = { 25,  60,  100 }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

local packsHeld = function(player)
    local held = 0

    for _, ki in ipairs(allPacks) do
        if player:hasKeyItem(ki) then
            held = held + 1
        end
    end

    return held
end

local clearPacks = function(player)
    for _, ki in ipairs(allPacks) do
        player:delKeyItem(ki)
    end
end

--- Picking up a pack. Shared by the first run and the repeat.
local supplyActions =
{
    onTrigger = function(player, npc)
        local ki = supplyPoints[npc:getID()]

        if ki == nil or player:hasKeyItem(ki) then
            return
        end

        npcUtil.giveKeyItem(player, ki)

        return true
    end,
}

local payOut = function(player)
    local held = packsHeld(player)

    if held < 1 then
        return
    end

    clearPacks(player)
    player:addCurrency('resistance_credit', creditsForPacks[held])
    xi.abyssea.questReward(player, cruorForPacks[held], nil)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Chapi_Galepilai'] =
            {
                onTrigger = function(player, npc)
                    -- 8037's ${number: 0} is the "or so would be sufficient" count.
                    return quest:progressEvent(305, #allPacks)
                end,
            },

            onEventFinish =
            {
                [305] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearPacks(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Supply_Point'] = supplyActions,

            ['Chapi_Galepilai'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(306, #allPacks)
                end,
            },

            ['Morlepiche'] =
            {
                onTrigger = function(player, npc)
                    if packsHeld(player) > 0 then
                        return quest:progressEvent(309)
                    end

                    return quest:event(308)
                end,
            },

            onEventFinish =
            {
                [309] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Supply_Point'] = supplyActions,

            ['Chapi_Galepilai'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(307)
                end,
            },

            ['Morlepiche'] =
            {
                onTrigger = function(player, npc)
                    if packsHeld(player) > 0 then
                        return quest:progressEvent(309)
                    end

                    return quest:event(310)
                end,
            },

            onEventFinish =
            {
                [309] = function(player, csid, option, npc)
                    payOut(player)
                end,
            },
        },
    },
}

return quest
