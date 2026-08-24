-----------------------------------
-- Scattered Shells, Scattered Mind
-----------------------------------
-- Log ID: 8, Quest ID: 38
-- Aladoverre : Abyssea - Vunkerl (E-7), entity 17666755
-- qm         : Abyssea - Vunkerl, entities 17666756 .. 17666760
-- !addquest 8 38
-----------------------------------
-- Retail (bg-wiki "Scattered Shells, Scattered Mind").
-- |Start=Aladoverre (A) (E-7), Abyssea - Vunkerl  |Fame=avun |FLevel=3
-- |Reward=Aug Black Earring / Darkness Earring. First time: 1,200 Cruor.
--         Subsequent: 600 Cruor. Chance at an Empyrean +1 FEET seal
--         (Cirque/Estoqueur's/Sylvan/Bale).
--   1. Speak to Aladoverre at (E-7).
--   2. "Your objective is to obtain a KI Chipped linkshell, KI Cracked linkshell,
--      AND KI Grimy linkshell from various ??? targetable locations throughout the
--      zone. There are 5 areas where a ??? can spawn... It is important to note
--      that only ONE KI linkshell can be obtained from each ???."
--   3. Return to Aladoverre once all 3 are obtained.
--
-- CSIDS DECODED, NOT GUESSED. Aladoverre's own blocks are ONE BYTE each, i.e.
-- stubs; the real programs are on the unnamed HOLDER entity 17666745. Per-csid
-- attribution from that holder's byte ranges:
--   1072 -> 8323/8324  his idle counting ("One, two...two...what comes after
--          two!?"), used before the quest is available to him.
--   1073 -> 8325-8339  THE OFFER. 8332 is the two-way menu ("Danger is my middle
--          name." / "I'm not sure about this..."), 8334 "if you perchance come upon
--          a linkshell, that you deliver it back here to me", 8339 "Three should
--          do...or thereabouts?"
--   1074 -> 8340/8341  the reminder ("Nevertheless, I'll be needing about three").
--   1075 -> 8342       "An object on the ground glistens in the dim light..." --
--          a ??? that still has a linkshell. 8343 "You obtain
--          ${keyitem-article: 0[2]}" is the grant, so the KI id is a param.
--   1076 -> 6405       "There is nothing out of the ordinary here." -- a ??? with
--          nothing left for you.
--   1077 -> 8344-8348  THE TURN-IN. 8345 "One...two...tea... No, that's not right!
--          One...two...three! Yes, perfect!"
--   1078 -> 8347-8349  his post-completion lines.
--   1079 -> 8332/8334/8350-8354  the repeat offer.
--
-- WHICH SHELL A ??? GIVES. bg-wiki does not tie a specific linkshell to a specific
-- spot, and it cannot: three of the five spots are fixed but "the 4th and 5th spots
-- jump throughout various spots in the zone". What it does state is the invariant
-- that matters -- one shell per ???, and you need all three. So each ??? hands over
-- the first shell the player is still missing, in the enum's own order. That
-- reproduces the observable rule without inventing a mapping the wiki does not give.
--
-- These five qm entities share the name 'qm' with the three belonging to Bad
-- Communication, so the handler returns nil for any id that is not one of ours.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCATTERED_SHELLS_SCATTERED_MIND)

-- The five ??? spots. Value is the bit recording that this spot has been emptied on
-- the current run, so a single ??? cannot be farmed for all three shells.
local shellSpots =
{
    [17666756] = 0,
    [17666757] = 1,
    [17666758] = 2,
    [17666759] = 3,
    [17666760] = 4,
}

-- 1638 / 1640 / 1639. All three are required; order here is only the order they are
-- handed out in.
local linkshells =
{
    xi.ki.CHIPPED_LINKSHELL,
    xi.ki.CRACKED_LINKSHELL,
    xi.ki.GRIMY_LINKSHELL,
}

-- bg-wiki lists FEET seals for this quest: 3207/3194/3200/3197.
local feetSeals =
{
    xi.item.CIRQUE_SEAL_FEET,
    xi.item.ESTOQUEURS_SEAL_FEET,
    xi.item.SYLVAN_SEAL_FEET,
    xi.item.BALE_SEAL_FEET,
}

local firstCruor  = 1200
local repeatCruor = 600

-- bg-wiki: "Aug Black Earring / Darkness Earring", one or the other.
local earrings = { xi.item.BLACK_EARRING, xi.item.DARKNESS_EARRING }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

local hasAllShells = function(player)
    for _, ki in ipairs(linkshells) do
        if not player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

--- The first linkshell the player still lacks, or nil when they hold all three.
local nextShell = function(player)
    for _, ki in ipairs(linkshells) do
        if not player:hasKeyItem(ki) then
            return ki
        end
    end

    return nil
end

local clearRun = function(player)
    quest:setVar(player, 'Spots', 0)

    for _, ki in ipairs(linkshells) do
        player:delKeyItem(ki)
    end
end

--- Shared by the first run and the repeat.
local spotActions =
{
    onTrigger = function(player, npc)
        local bit1 = shellSpots[npc:getID()]

        if bit1 == nil then
            return
        end

        local mask = quest:getVar(player, 'Spots')
        local ki   = nextShell(player)

        -- Already emptied this spot, or nothing left to collect.
        if bit.band(mask, bit.lshift(1, bit1)) ~= 0 or ki == nil then
            return quest:event(1076)
        end

        quest:setVar(player, 'Spots', bit.bor(mask, bit.lshift(1, bit1)))

        -- 8343 renders the key item from a param, so the id is passed rather than
        -- granted separately.
        npcUtil.giveKeyItem(player, ki)

        return quest:event(1075, ki)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_VUNKERL) >= 3
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Aladoverre'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1073)
                end,
            },

            onEventFinish =
            {
                [1073] = function(player, csid, option, npc)
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
            ['qm'] = spotActions,

            ['Aladoverre'] =
            {
                onTrigger = function(player, npc)
                    if hasAllShells(player) then
                        return quest:progressEvent(1077)
                    end

                    return quest:event(1074)
                end,
            },

            onEventFinish =
            {
                [1077] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        npcUtil.giveItem(player, earrings[math.random(1, #earrings)])
                        xi.abyssea.questReward(player, firstCruor, feetSeals)
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

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['qm'] = spotActions,

            ['Aladoverre'] =
            {
                onTrigger = function(player, npc)
                    if hasAllShells(player) then
                        return quest:progressEvent(1077)
                    elseif quest:getVar(player, 'Spots') ~= 0 then
                        return quest:event(1074)
                    elseif quest:getMustZone(player) then
                        return quest:event(1078)
                    end

                    return quest:progressEvent(1079)
                end,
            },

            onEventFinish =
            {
                [1077] = function(player, csid, option, npc)
                    clearRun(player)
                    npcUtil.giveItem(player, earrings[math.random(1, #earrings)])
                    xi.abyssea.questReward(player, repeatCruor, feetSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SCATTERED_SHELLS_SCATTERED_MIND)
                end,

                [1079] = function(player, csid, option, npc)
                    clearRun(player)
                end,
            },
        },
    },
}

return quest
