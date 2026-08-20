-----------------------------------
-- Area: Qufim Island (126)
--  NPC: Transcendental Radiance
-- !pos -259.433 -21.581 220.498 126
-----------------------------------
-- Entry to Abyssea - Empyreal Paradox for the quest chain
-- Beneath a Blood-red Sky -> The Wyrm God.
--
-- bg-wiki "The Wyrm God": "Enter Abyssea - Empyreal Paradox through the
-- Transcendental Radiance in Qufim Island at (F-7) for a key item: Crimson
-- traverser stone."
-- bg-wiki "Shinryu", The Wyrm God section: "Battlefield entry requires 10,000
-- cruor and a Crimson traverser stone {KI}." / "May be fought multiple times
-- after reaching the quest The Wyrm God."
--
-- THE NPC ALWAYS EXISTED -- entity 17293816 (npc_list.sql, zone 126 idx 504) at
-- exactly the -259.433/-21.581/220.498 the quest files' !pos comments cite, with
-- status 0 so it renders. It simply had no script, which is why both quests
-- dead-ended: Beneath_a_Blood_Red_Sky.lua only implements the ARRIVAL cutscene in
-- zone 255 and nothing could get the player there.
--
-- CSID 46, decoded not guessed. `xi-dat events 126` gives this entity exactly two
-- events, 47 (a 1-byte stub; the real 958-byte program is on the neighbour
-- 0x0107E1F9) and 46, a 981-byte program on the entity itself. Its dialog:
--   11517 "Your ${keyitem-singular: 0[2]} resonates with the eerie light before
--          you."
--   11519 "${choice: 0}[Enter the portal/Warp to Abyssea - Empyreal Paradox]?
--          ${selection-lines} Proceed. (${number: 3} cruor) / Not yet."
--   11520 "Cruor will not be expended for those possessing
--          ${keyitem-article: 0[2]}."
--   11521 "You do not have enough energy in cruor to warp to your destination."
-- So the cruor price is param 3, and 11519's ${choice: 0} selects between the
-- Sea/Al'Taieu wording and the Abyssea wording -- index 1 is the Abyssea one.
-- 11520 is what drives the "already holds the stone -> no charge" branch below.
--
-- NEEDS AN IN-GAME PROBE, stated rather than hidden: 11517 and 11520 read a key
-- item out of param 0 while 11519 reads a CHOICE out of param 0, so the exact
-- packing of that first parameter is not something the dialog alone settles. The
-- choice index is passed there because that is what selects the correct question
-- text; if it is wrong the prompt shows the Al'Taieu wording instead of the
-- Abyssea wording. It cannot mispay -- the cruor charge and the key item grant
-- below are driven by server-side checks, not by the event's parameters. Confirm
-- with `!cs 46` on this NPC.
-----------------------------------
local ID = zones[xi.zone.QUFIM_ISLAND]
-----------------------------------

local warpCost = 10000

---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local blooodRedSky = player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BENEATH_A_BLOOD_RED_SKY)
    local wyrmGod      = player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_WYRM_GOD)

    -- Usable while Beneath a Blood-red Sky is live, and afterwards for repeat
    -- Shinryu attempts once The Wyrm God has been reached.
    if
        blooodRedSky ~= xi.questStatus.QUEST_ACCEPTED and
        wyrmGod == xi.questStatus.QUEST_AVAILABLE
    then
        return
    end

    return player:startEvent(46, xi.ki.CRIMSON_TRAVERSER_STONE, 0, 0, warpCost)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid ~= 46 or option ~= 1 then
        return
    end

    local hasStone = player:hasKeyItem(xi.ki.CRIMSON_TRAVERSER_STONE)

    -- 11520: "Cruor will not be expended for those possessing [the stone]."
    if not hasStone then
        if player:getCurrency('cruor') < warpCost then
            -- 11521: "You do not have enough energy in cruor to warp..."
            player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)

            return
        end

        player:delCurrency('cruor', warpCost)
        npcUtil.giveKeyItem(player, xi.ki.CRIMSON_TRAVERSER_STONE)
    end

    -- Abyssea - Empyreal Paradox is not a Cavernous Maw, so it has no entry in
    -- abyssea.lua's teleportData. These are the coordinates the zone's own
    -- Zone.lua onZoneIn falls back to, which sit beside TR_Entrance and Prishe.
    player:setPos(540, -500, -565, 64, xi.zone.ABYSSEA_EMPYREAL_PARADOX)
end

return entity
