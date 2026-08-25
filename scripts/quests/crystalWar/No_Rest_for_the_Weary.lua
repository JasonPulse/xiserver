-----------------------------------
-- No Rest for the Weary
-----------------------------------
-- Log ID: 7, Quest ID: 88
-- Bulwark_Gate : Sauromugue Champaign [S] (F-6), entity 17179329
-- !addquest 7 88
-----------------------------------
-- Retail (bg-wiki "No Rest for the Weary").
-- Step nine of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=A New Menace  |Next=A World in Flux
-- |Reward=KI White stratum abyssite VI, KI Starlight Voidwatcher's emblem
--   1. "Speak with any Voidwatch Officer in a Shadowreign area to receive a KI
--      Voidwatch alarum." The officer MUST be from the Shadowreign era.
--   2. "Proceed to the Bulwark Gate (F-6) in Sauromugue Champaign (S) for a cutscene.
--      At the end of the cutscene, the key items White stratum abyssite VI and
--      Starlight Voidwatcher's emblem will be received."
--
-- THE BULWARK GATE HAS NO CUTSCENE PROGRAM IN THE DUMPS. csidmsg.load returns nothing
-- for entity 17179329, and a scan of every event in Sauromugue Champaign [S] for
-- bulwark or Grand Duchy text finds only the Voidwatch Officer's own summons blocks
-- and the general Voidwatch tutorial (msgs 9920-9933). Rather than invent a csid, the
-- gate is driven as a plain interaction: the player still has to travel to it, which
-- is the part of the flow that matters, and the key items are granted there.
--
-- The alarum step is era-gated because bg-wiki is emphatic about it: the officer must
-- be Shadowreign, and the present-day ones will not serve. That list lives in
-- scripts/globals/voidwatch_wotg.lua.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.NO_REST_FOR_THE_WEARY)

local bulwarkGate = 17179329

local zones =
{
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S] =
    {
        ['Bulwark_Gate'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= bulwarkGate or
                    not player:hasKeyItem(xi.ki.VOIDWATCH_ALARUM)
                then
                    return
                end

                player:delKeyItem(xi.ki.VOIDWATCH_ALARUM)

                if quest:complete(player) then
                    npcUtil.giveKeyItem(player, xi.ki.WHITE_STRATUM_ABYSSITE_VI)
                    npcUtil.giveKeyItem(player, xi.ki.STARLIGHT_VOIDWATCHERS_EMBLEM)
                end

                return true
            end,
        },
    },
}

--- The Shadowreign officers hand over the alarum that opens the gate.
for zoneId, _ in pairs(xi.vwChain.officers) do
    local officerCsid = xi.vwChain.officerCsid(zoneId, 'again')

    if xi.vwChain.shadowreign[zoneId] and officerCsid ~= nil then
        zones[zoneId] = zones[zoneId] or {}

        zones[zoneId]['Voidwatch_Officer'] =
        {
            onTrigger = function(player, npc)
                if player:hasKeyItem(xi.ki.VOIDWATCH_ALARUM) then
                    return
                end

                return quest:progressEvent(officerCsid)
            end,
        }

        zones[zoneId].onEventFinish =
        {
            [officerCsid] = function(player, csid, option, npc)
                npcUtil.giveKeyItem(player, xi.ki.VOIDWATCH_ALARUM)
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

quest.sections = { acceptedSection }

return quest
