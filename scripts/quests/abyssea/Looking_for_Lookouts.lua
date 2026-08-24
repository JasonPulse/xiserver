-----------------------------------
-- Looking for Lookouts
-----------------------------------
-- Log ID: 8, Quest ID: 40
-- Colti              : Abyssea - Attohwa (H-8), entity 17658597
-- Resistance_Fighter : Abyssea - Attohwa, entities 17658598 .. 17658602
-- !addquest 8 40
-----------------------------------
-- Retail (bg-wiki "Looking for Lookouts").
-- |Start=Colti (A) (H-8), Abyssea - Attohwa  |Fame=aatt |FLevel=2
-- |Reward=400 Cruor. Chance at an Empyrean +1 HEAD seal
--         (Ravager/Caller's/Charis/Savant's).  |Repeatable=Yes
--   1. Speak to Colti at (H-8), Veridical Conflux #08.
--   2. "You will receive x5 KI Parradamo supply pack."
--   3. "You must speak to 5 Resistance Fighter NPCs scattered around the Parradamo
--      Tor" -- a Hume Female at (J-9), a Tarutaru at (J-9), a Mithra at (J-8), an
--      Elvaan male at (K-8) and a Galka at (K-9).
--   4. Speak to Colti for your reward.
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Colti 311 -> 8052/8053  her idle line, "She appears to be communicating with
--          someone..."
--   Colti 312 -> 8054-8067  THE OFFER. 8066 "My suspicion is that they've become
--          separated from each other", 8067 "At any rate, we're counting on you!"
--   Colti 313 -> 8066/8067  the reminder.
--   Colti 314 -> 8068-8070 plus msg 201, the activity-points marker. THE TURN-IN:
--          "Thanks to your efforts, we've restored contact with the entire scouting
--          regiment."
--   Colti 315 -> 8069       her post-completion line.
--   Colti 316 -> 8071/8072  the repeat offer, "my hapless scouts have once more gone
--          astray."
--   Each Resistance_Fighter owns THREE csids in npc_list order, and 17658598's
--   decode names the roles: 317 is the idle greeting ("Don't get many travelers out
--   this way"), 318 is the delivery ("What's that y' have with ye? Rations, and a
--   linkpearl to boot!?" ... "When I lost contact with the camp, I thought I was done
--   for"), and 319 is the after-line ("Ye take care of yerself, now"). The other four
--   repeat that triple: 320/321/322, 323/324/325, 326/327/328, 329/330/331.
--
-- FIVE DISTINCT KEY ITEMS, not one stack: the enum carries PARRADAMO_SUPPLY_PACK1
-- through 5 (1617-1621), one per fighter, which is why each fighter consumes its own.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOOKING_FOR_LOOKOUTS)

-- Resistance_Fighter entity -> { idle csid, delivery csid, done csid, its pack }.
local fighters =
{
    [17658598] = { 317, 318, 319, xi.ki.PARRADAMO_SUPPLY_PACK1 },
    [17658599] = { 320, 321, 322, xi.ki.PARRADAMO_SUPPLY_PACK2 },
    [17658600] = { 323, 324, 325, xi.ki.PARRADAMO_SUPPLY_PACK3 },
    [17658601] = { 326, 327, 328, xi.ki.PARRADAMO_SUPPLY_PACK4 },
    [17658602] = { 329, 330, 331, xi.ki.PARRADAMO_SUPPLY_PACK5 },
}

local packs =
{
    xi.ki.PARRADAMO_SUPPLY_PACK1,
    xi.ki.PARRADAMO_SUPPLY_PACK2,
    xi.ki.PARRADAMO_SUPPLY_PACK3,
    xi.ki.PARRADAMO_SUPPLY_PACK4,
    xi.ki.PARRADAMO_SUPPLY_PACK5,
}

-- bg-wiki lists HEAD seals for this quest: 3110/3124/3128/3129.
local headSeals =
{
    xi.item.RAVAGERS_SEAL_HEAD,
    xi.item.CALLERS_SEAL_HEAD,
    xi.item.CHARIS_SEAL_HEAD,
    xi.item.SAVANTS_SEAL_HEAD,
}

local cruorReward = 400

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

local givePacks = function(player)
    for _, ki in ipairs(packs) do
        npcUtil.giveKeyItem(player, ki)
    end
end

local clearPacks = function(player)
    for _, ki in ipairs(packs) do
        player:delKeyItem(ki)
    end
end

--- Every pack delivered means every fighter has been found.
local allDelivered = function(player)
    for _, ki in ipairs(packs) do
        if player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

--- Shared by the first run and the repeat.
local fighterActions =
{
    onTrigger = function(player, npc)
        local entry = fighters[npc:getID()]

        if entry == nil then
            return
        end

        if not player:hasKeyItem(entry[4]) then
            return quest:event(entry[3])
        end

        player:delKeyItem(entry[4])

        return quest:event(entry[2])
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 2
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Colti'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(312)
                end,
            },

            onEventFinish =
            {
                [312] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearPacks(player)
                    givePacks(player)
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
            ['Resistance_Fighter'] = fighterActions,

            ['Colti'] =
            {
                onTrigger = function(player, npc)
                    if allDelivered(player) then
                        return quest:progressEvent(314)
                    end

                    return quest:event(313)
                end,
            },

            onEventFinish =
            {
                [314] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearPacks(player)
                        xi.abyssea.questReward(player, cruorReward, headSeals)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required in order to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Resistance_Fighter'] = fighterActions,

            ['Colti'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.PARRADAMO_SUPPLY_PACK1) then
                        return quest:event(313)
                    elseif not allDelivered(player) then
                        return quest:event(313)
                    elseif quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(314)
                    elseif quest:getMustZone(player) then
                        return quest:event(315)
                    end

                    return quest:progressEvent(316)
                end,
            },

            onEventFinish =
            {
                [314] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 0)
                    clearPacks(player)
                    xi.abyssea.questReward(player, cruorReward, headSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOOKING_FOR_LOOKOUTS)
                end,

                [316] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                    clearPacks(player)
                    givePacks(player)
                end,
            },
        },
    },
}

return quest
