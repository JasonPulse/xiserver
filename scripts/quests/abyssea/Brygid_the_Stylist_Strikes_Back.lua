-----------------------------------
-- Brygid the Stylist Strikes Back
-----------------------------------
-- Log ID: 8, Quest ID: 86
-- Brygid : Abyssea - Altepa (D-11), entity 17670755
-- !addquest 8 86
-----------------------------------
-- Retail (bg-wiki and FFXIclopedia "Brygid the Stylist Strikes Back").
-- |Start=Brygid (A) (D-11), Abyssea - Altepa  |Fame=aalt |FLevel=2  |Repeatable=Yes
-- |Quest Reqs=Empyrean Armor equipped
-- |Reward=Stearc Subligar with random Augments. Chance at an Empyrean +1 BODY seal
--         (Orison / Bale / Ferine / Aoidos' / Navarch's).
--   1. "Speak to Brygid (A) at (D-11), near Conflux #8, while wearing at least 1 piece
--      of Empyrean Armor." "You cannot use upgraded iLvl 119 Empyrean Gear it must be
--      original Empyrean Armor."
--   2. "Brygid (A) requests you wear certain body and leg equipment depending on the
--      job you approach her as. Speak to her again while having both pieces equipped
--      for your reward."
--   3. "If you are already wearing some of the possible gear ... she will never select
--      that gear, and will always suggest something else."
--   4. "Brygid (A) will accept both standard and HQ (+1) versions of gear."
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Altepa:
--   326 -> "Yes? I'm a very busy girl. So, off with you now! Don't call me, I'll call
--          you! Ta-ta!"                                                  the gate
--   327 -> "Wait a minute. You're not <pc>, are you?" through "That face, those
--          proportions... <body> and <legs> would totally be you."     THE OFFER,
--          and it renders BOTH requested items as parameters
--   328 -> the same request again, plus "If you're not ready to be a trendsetter,
--          don't sweat it. Keep wearing those scruffy rags."          the reminder
--   329 -> "Turn around for me if you will, hm? Oh, there's no doubt about it. Night
--          and day. A whole new you!" then "Here, take this"          the turn-in
--   330 -> "How can I worry about fashion these days? Shows what you know, hon."
--                                                          the post-completion line
--
-- WHERE THE GEAR POOL COMES FROM. bg-wiki's page describes the mechanic but lists no
-- items; FFXIclopedia's page for the same quest carries the actual Body and Legs
-- tables, and they are reproduced below. The cross-check that they are the right
-- tables: bg-wiki's walkthrough uses Scorpion Harness as its worked example, and
-- Scorpion Harness is in FFXIclopedia's Body list.
--
-- EMPYREAN ARMOR IS A CONTIGUOUS ID RANGE. The twenty Empyrean sets are exactly the
-- twenty that have +1 seals, and their original head/body/hands/legs/feet pieces
-- occupy 12008 to 12107 with no gaps, twenty sets times five slots. That is derived
-- from item_basic plus item_equipment slots rather than typed out, and it is what
-- lets the "wearing Empyrean Armor" gate be a range test. The reforged ilvl 109/119
-- pieces live far away in the 16000s and 19000s, so they are excluded automatically,
-- which is exactly what bg-wiki demands.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRYGID_THE_STYLIST_STRIKES_BACK)

-- Original Empyrean Armor, head through feet. See the header for the derivation.
local empyreanFirst = 12008
local empyreanLast  = 12107

local empyreanSlots =
{
    xi.slot.HEAD,
    xi.slot.BODY,
    xi.slot.HANDS,
    xi.slot.LEGS,
    xi.slot.FEET,
}

-- FFXIclopedia's Body table. Each entry is { standard, HQ } because "Brygid (A) will
-- accept both standard and HQ (+1) versions"; a false HQ means the piece has none.
local bodyRequests =
{
    { xi.item.AKETON,               xi.item.AKETON_P1               },
    { xi.item.BLACK_COTEHARDIE,     false                           },
    { xi.item.DARKSTEEL_HARNESS,    xi.item.DARKSTEEL_HARNESS_P1    },
    { xi.item.ERRANT_HOUPPELANDE,   false                           },
    { xi.item.JUSTAUCORPS,          xi.item.JUSTAUCORPS_P1          },
    { xi.item.SCORPION_BREASTPLATE, xi.item.SCORPION_BREASTPLATE_P1 },
    { xi.item.SCORPION_HARNESS,     xi.item.SCORPION_HARNESS_P1     },
    { xi.item.SILK_CLOAK,           xi.item.SILK_CLOAK_P1           },
    { xi.item.TIGER_JERKIN,         false                           },
    { xi.item.VERMILLION_CLOAK,     false                           },
    { xi.item.VIVACITY_COAT,        xi.item.VIVACITY_COAT_P1        },
    { xi.item.HAUBERGEON,           xi.item.HAUBERGEON_P1           },
    { xi.item.BLUE_COTEHARDIE,      xi.item.BLUE_COTEHARDIE_P1      },
    { xi.item.WAR_AKETON,           xi.item.WAR_AKETON_P1           },
    { xi.item.CORAL_SCALE_MAIL,     xi.item.CORAL_SCALE_MAIL_P1     },
    { xi.item.HAUBERK,              xi.item.HAUBERK_P1              },
    { xi.item.MASTERS_GI,           xi.item.MASTERS_GI_P1           },
    { xi.item.GAVIAL_MAIL,          xi.item.GAVIAL_MAIL_P1          },
}

-- FFXIclopedia's Legs table.
local legsRequests =
{
    { xi.item.BATTLE_HOSE,        xi.item.BATTLE_HOSE_P1        },
    { xi.item.CLOWNS_SUBLIGAR,    xi.item.CLOWNS_SUBLIGAR_P1    },
    { xi.item.DARKSTEEL_SUBLIGAR, xi.item.DARKSTEEL_SUBLIGAR_P1 },
    { xi.item.DUSK_TROUSERS,      xi.item.DUSK_TROUSERS_P1      },
    { xi.item.ERRANT_SLOPS,       false                         },
    { xi.item.JET_SERAWEELS,      false                         },
    { xi.item.SILK_SLACKS,        xi.item.SILK_SLACKS_P1        },
    { xi.item.SILKEN_SLOPS,       false                         },
    { xi.item.TABIN_HOSE,         xi.item.TABIN_HOSE_P1         },
    { xi.item.VENDORS_SLOPS,      false                         },
    { xi.item.CORAL_CUISSES,      xi.item.CORAL_CUISSES_P1      },
    { xi.item.BARONE_COSCIALES,   false                         },
    { xi.item.DARKSTEEL_BREECHES, xi.item.DARKSTEEL_BREECHES_P1 },
    { xi.item.IGQIRA_LAPPAS,      false                         },
    { xi.item.WAR_BRAIS,          xi.item.WAR_BRAIS_P1          },
    { xi.item.ARHATS_HAKAMA,      xi.item.ARHATS_HAKAMA_P1      },
}

local bodySeals =
{
    xi.item.ORISON_SEAL_BODY,
    xi.item.BALE_SEAL_BODY,
    xi.item.FERINE_SEAL_BODY,
    xi.item.AOIDOS_SEAL_BODY,
    xi.item.NAVARCHS_SEAL_BODY,
}

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
    item     = xi.item.STEARC_SUBLIGAR,
}

--- "while wearing at least 1 piece of Empyrean Armor", original only.
local function wearingEmpyrean(player)
    for _, slot in ipairs(empyreanSlots) do
        local equipped = player:getEquipID(slot)

        if equipped >= empyreanFirst and equipped <= empyreanLast then
            return true
        end
    end

    return false
end

--- Pick one piece the player could actually wear and is not already wearing. bg-wiki:
--- "she will never select that gear, and will always suggest something else."
local function pickRequest(player, pool, slot)
    local equipped = player:getEquipID(slot)
    local choices  = {}

    for _, pair in ipairs(pool) do
        local standard, hq = pair[1], pair[2]

        if
            equipped ~= standard and
            (not hq or equipped ~= hq) and
            player:canEquipItem(standard)
        then
            table.insert(choices, standard)
        end
    end

    if #choices == 0 then
        return 0
    end

    return choices[math.random(#choices)]
end

--- The HQ that goes with a requested standard piece, or false when it has none.
local function hqFor(pool, standard)
    for _, pair in ipairs(pool) do
        if pair[1] == standard then
            return pair[2]
        end
    end

    return false
end

local function wearingRequested(player, pool, slot, requested)
    if requested == 0 then
        return false
    end

    local equipped = player:getEquipID(slot)
    local hq       = hqFor(pool, requested)

    return equipped == requested or (hq and equipped == hq)
end

local function rollOutfit(player)
    quest:setVar(player, 'Body', pickRequest(player, bodyRequests, xi.slot.BODY))
    quest:setVar(player, 'Legs', pickRequest(player, legsRequests, xi.slot.LEGS))
end

local function outfitWorn(player)
    return wearingRequested(player, bodyRequests, xi.slot.BODY, quest:getVar(player, 'Body')) and
        wearingRequested(player, legsRequests, xi.slot.LEGS, quest:getVar(player, 'Legs'))
end

--- 327 and 328 both render the two requested pieces, so both take them as params.
local function requestParams(player)
    return quest:getVar(player, 'Body'), quest:getVar(player, 'Legs')
end

local function payOut(player)
    xi.abyssea.questReward(player, 0, bodySeals)
    quest:setVar(player, 'Body', 0)
    quest:setVar(player, 'Legs', 0)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRYGID_THE_STYLIST_STRIKES_BACK)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ALTEPA) >= 2
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Brygid'] =
            {
                onTrigger = function(player, npc)
                    -- Turn up in ordinary clothes and she is not interested.
                    if not wearingEmpyrean(player) then
                        return quest:event(326)
                    end

                    rollOutfit(player)

                    return quest:progressEvent(327, requestParams(player))
                end,
            },

            onEventFinish =
            {
                [327] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Brygid'] =
            {
                onTrigger = function(player, npc)
                    if outfitWorn(player) then
                        return quest:progressEvent(329)
                    end

                    return quest:event(328, requestParams(player))
                end,
            },

            onEventFinish =
            {
                [329] = function(player, csid, option, npc)
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

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Brygid'] =
            {
                onTrigger = function(player, npc)
                    if outfitWorn(player) and quest:getVar(player, 'Body') ~= 0 then
                        return quest:progressEvent(329)
                    elseif quest:getVar(player, 'Body') ~= 0 then
                        return quest:event(328, requestParams(player))
                    elseif quest:getMustZone(player) or not wearingEmpyrean(player) then
                        return quest:event(330)
                    end

                    rollOutfit(player)

                    return quest:progressEvent(327, requestParams(player))
                end,
            },

            onEventFinish =
            {
                [329] = function(player, csid, option, npc)
                    payOut(player)
                end,
            },
        },
    },
}

return quest
