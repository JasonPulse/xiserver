-----------------------------------
-- Guardian of the Void
-----------------------------------
-- Log ID: 7, Quest ID: 80
-- Veridical_Conflux : Xarcabard [S], entity 17339257 (programs on holder 17339258)
-- Veridical_Conflux : Pashhow Marshlands [S] (J-9), entity 17146658
-- !addquest 7 80
-----------------------------------
-- Retail (bg-wiki "Guardian of the Void").
-- Step one of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=(none)  |Next=Drafted by the Duchy
-- |Reward=KI Voidwatch alarum
--   Prerequisite: "complete ANY 4 past National Quests (no mix and matching allowed)"
--   from one of the three Shadowreign chains. Each chain's terminator is checked
--   below, since completing the last of a chain implies the three before it:
--     San d'Oria (S): Knights of The Iron Ram -> Steamed Rams -> Gifts of the
--                     Griffon -> CLAWS OF THE GRIFFON
--     Bastok (S):     Republican Legion's Fourth Division -> The Fighting Fourth ->
--                     Better Part of Valor -> FIRES OF DISCONTENT
--     Windurst (S):   The Cobras -> Snake on the Plains -> The Tigress Stirs ->
--                     THE TIGRESS STRIKES
--   1. "Once a single Quest-line has been completed, touch any of the 3 Cavernous
--      Maws outside Jeuno in the past to get a cutscene for Cait Sith."
--   2. "Once in Xarcabard (S) find the Veridical Conflux located near the Home Point
--      for a cutscene and to acquire KI Kupofried's medallion."
--   3. "Now travel to Pashhow Marshlands (S) and click on the Veridical Conflux
--      located near the Pashhow Gate Crystal in (J-9) to start a cutscene."
--   4. "Speak with a Voidwatch Officer in one of the three starting-Nations (past or
--      present) to receive the KI Voidwatch alarum." bg-wiki is emphatic: this
--      "cannot be done at Jeuno or at any other external-cities Voidwatch Officer".
--
-- CSIDS DECODED, NOT GUESSED.
--   Xarcabard [S]: the Veridical Conflux (17339257) carries csids 36 and 37 as
--     ONE-BYTE stubs. The real programs are on the unnamed HOLDER entity 17339258,
--     where 36 is 3,498 bytes and 37 is 918. 36 decodes to Kupofried introducing
--     himself (msgs 8617-8626, "I am Kupofried, a simple moogle beckoned hither by
--     the enormous e[nergy]"), which is the cutscene that hands over his medallion.
--   Pashhow Marshlands [S]: conflux 17146658, csid 13 (744 bytes), the substantial
--     block. See A_Cait_Calls.lua, which uses the same conflux later in the chain.
--   The officer's alarum uses the `first` role, the 631-byte block, which is the one
--     block in the officer's set that is uniquely identifiable: msg 15507, "I've
--     received an urgent alarum calling our best men to arms, and guess whose name is
--     listed front and center?" Every other summons block says "once more" or "as
--     before". This is the FIRST alarum, so `first` is right by its own text.
--
-- THE CAIT SITH FLAG IS NOT MODELLED HERE. Touching a past Cavernous Maw to trigger
-- Cait Sith belongs to the Cavernous Maws mission content, not to this quest, and the
-- national-chain check above is the gate bg-wiki actually names as the requirement.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.GUARDIAN_OF_THE_VOID)

local xarcabardConflux = 17339257
local pashhowConflux   = 17146658

local medallionCsid = 36
local pashhowCsid   = 13

-- Only the three starting nations count, past or present. Jeuno and the field
-- officers are explicitly excluded by bg-wiki.
local nationOfficerZones =
{
    [xi.zone.SOUTHERN_SAN_DORIA_S] = true,
    [xi.zone.BASTOK_MARKETS_S]     = true,
    [xi.zone.WINDURST_WATERS_S]    = true,
    [xi.zone.SOUTHERN_SAN_DORIA]   = true,
    [xi.zone.BASTOK_MARKETS]       = true,
    [xi.zone.WINDURST_WATERS]      = true,
}

--- One completed Shadowreign national chain, checked at its terminator.
local hasNationalChain = function(player)
    return player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.CLAWS_OF_THE_GRIFFON) or
        player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.FIRES_OF_DISCONTENT) or
        player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_TIGRESS_STRIKES)
end

local zones =
{
    [xi.zone.XARCABARD_S] =
    {
        ['Veridical_Conflux'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= xarcabardConflux or
                    player:hasKeyItem(xi.ki.KUPOFRIEDS_MEDALLION)
                then
                    return
                end

                return quest:progressEvent(medallionCsid)
            end,
        },

        onEventFinish =
        {
            [medallionCsid] = function(player, csid, option, npc)
                npcUtil.giveKeyItem(player, xi.ki.KUPOFRIEDS_MEDALLION)
            end,
        },
    },

    [xi.zone.PASHHOW_MARSHLANDS_S] =
    {
        ['Veridical_Conflux'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= pashhowConflux or
                    not player:hasKeyItem(xi.ki.KUPOFRIEDS_MEDALLION) or
                    quest:getVar(player, 'Briefed') == 1
                then
                    return
                end

                return quest:progressEvent(pashhowCsid)
            end,
        },

        onEventFinish =
        {
            [pashhowCsid] = function(player, csid, option, npc)
                quest:setVar(player, 'Briefed', 1)
            end,
        },
    },
}

--- The nation officers close the quest out with the first alarum.
for zoneId, _ in pairs(nationOfficerZones) do
    -- nationOfficerZones is its own list, so a zone in it without an officer entry
    -- is possible; resolving here skips that zone instead of firing a nil csid.
    local officerCsid = xi.vwChain.officerCsid(zoneId, 'first')

    if officerCsid ~= nil then
        zones[zoneId] = zones[zoneId] or {}

        zones[zoneId]['Voidwatch_Officer'] =
        {
            onTrigger = function(player, npc)
                if quest:getVar(player, 'Briefed') ~= 1 then
                    return
                end

                return quest:progressEvent(officerCsid)
            end,
        }

        zones[zoneId].onEventFinish =
        {
            [officerCsid] = function(player, csid, option, npc)
                if quest:complete(player) then
                    quest:setVar(player, 'Briefed', 0)
                    npcUtil.giveKeyItem(player, xi.ki.VOIDWATCH_ALARUM)
                end
            end,
        }
    end
end

local acceptedSection =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,
}

for zoneId, handlers in pairs(zones) do
    acceptedSection[zoneId] = handlers
end

quest.sections =
{
    -- bg-wiki's requirement is one completed Shadowreign national chain.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                hasNationalChain(player)
        end,

        [xi.zone.XARCABARD_S] =
        {
            ['Veridical_Conflux'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= xarcabardConflux then
                        return
                    end

                    return quest:progressEvent(medallionCsid)
                end,
            },

            onEventFinish =
            {
                [medallionCsid] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.KUPOFRIEDS_MEDALLION)
                end,
            },
        },
    },

    acceptedSection,
}

return quest
