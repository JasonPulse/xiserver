-----------------------------------
-- Abyssea Sturdy Pyxis - Key item
-----------------------------------
xi = xi or {}
xi.pyxis = xi.pyxis or {}

xi.pyxis.ki = {}

-----------------------------------
-- drop id's for keyitems
-- use zone id as the key
-----------------------------------
local drops =
{
    [xi.zone.ABYSSEA_KONSCHTAT]  =
    {
        xi.ki.FRAGRANT_TREANT_PETAL,
        xi.ki.FETID_RAFFLESIA_STALK,
        xi.ki.DECAYING_MORBOL_TOOTH,
        xi.ki.TURBID_SLIME_OIL,
        xi.ki.VENOMOUS_PEISTE_CLAW,
        xi.ki.TATTERED_HIPPOGRYPH_WING,
        xi.ki.CRACKED_WIVRE_HORN,
        xi.ki.MUCID_AHRIMAN_EYEBALL,
    },

    [xi.zone.ABYSSEA_TAHRONGI] =
    {
        xi.ki.OVERGROWN_MANDRAGORA_FLOWER,
        xi.ki.MOSSY_ADAMANTOISE_SHELL,
        xi.ki.CHIPPED_SANDWORM_TOOTH,
        xi.ki.GORY_SCORPION_CLAW,
        xi.ki.FAT_LINED_COCKATRICE_SKIN,
        xi.ki.SODDEN_SANDWORM_HUSK,
        xi.ki.LUXURIANT_MANTICORE_MANE,
        xi.ki.STICKY_GNAT_WING,
        xi.ki.TORN_BAT_WING,
        xi.ki.VEINOUS_HECTEYES_EYELID,
    },

    [xi.zone.ABYSSEA_LA_THEINE] =
    {
        xi.ki.MARBLED_MUTTON_CHOP,
        xi.ki.BLOODIED_SABER_TOOTH,
        xi.ki.BLOOD_SMEARED_GIGAS_HELM,
        xi.ki.PELLUCID_FLY_EYE,
        xi.ki.SHIMMERING_PIXIE_PINION,
        xi.ki.WARPED_GIGAS_ARMBAND,
        xi.ki.SEVERED_GIGAS_COLLAR,
        xi.ki.DENTED_GIGAS_SHIELD,
        xi.ki.GLITTERING_PIXIE_CHOKER,
    },

    [xi.zone.ABYSSEA_ATTOHWA] =
    {
        xi.ki.BULBOUS_CRAWLER_COCOON,
        xi.ki.DISTENDED_CHIGOE_ABDOMEN,
        xi.ki.VENOMOUS_WAMOURA_FEELER,
        xi.ki.MUCID_WORM_SEGMENT,
        xi.ki.SHRIVELED_HECTEYES_STALK,
        xi.ki.CRACKED_SKELETON_CLAVICLE,
    },

    [xi.zone.ABYSSEA_MISAREAUX] =
    {
        xi.ki.CLIPPED_BIRD_WING,
        xi.ki.GLISTENING_OROBON_LIVER,
        xi.ki.GNARLED_LIZARD_NAIL,
        xi.ki.JAGGED_APKALLU_BEAK,
        xi.ki.DOFFED_POROGGO_HAT,
        xi.ki.MOLTED_PEISTE_SKIN,
    },

    [xi.zone.ABYSSEA_VUNKERL] =
    {
        xi.ki.OSSIFIED_GARGOUILLE_HAND,
        xi.ki.INGROWN_TAURUS_NAIL,
        xi.ki.IMBRUED_VAMPYR_FANG,
        xi.ki.PULSATING_SOULFLAYER_BEARD,
        xi.ki.GLOSSY_SEA_MONK_SUCKER,
    },

    -- These three were { 0, 0, 0 } placeholders. setKeyItems below picks a random
    -- entry and hands it to giveKeyItem, so a pyxis in Altepa, Uleguerand or
    -- Grauberg always tried to grant key item 0 and reported KEYITEM_DISAPPEARED --
    -- the pop-item economy for all three of the Vol.3 zones was dead.
    --
    -- The real pools were recoverable without guesswork. key_item.lua carries three
    -- CONTIGUOUS blocks of exactly five, in the same order these three zones are
    -- declared in: Altepa 1518-1522, Uleguerand 1523-1527, Grauberg 1528-1532.
    -- Altepa's and Grauberg's are independently confirmed by the zones' own NM
    -- poppers (scripts/zones/Abyssea-Altepa/npcs/qm*.lua and
    -- Abyssea-Grauberg/npcs/qm*.lua reference exactly these five each).
    --
    -- Uleguerand has no qm* scripts at all, so its five are confirmed against the
    -- zone's NM roster in mob_groups (zone 253, spawntype 128) instead: it contains
    -- Ironclad_Triturator, Impervious_Chariot, Dhorme_Khimaira and Isgebind, which
    -- match WARPED_IRON_GIANT_NAIL, DENTED_CHARIOT_SHIELD, TORN_KHIMAIRA_WING and
    -- BEGRIMED_DRAGON_HIDE respectively. The fifth, DECAYING_DIREMITE_FANG, rests
    -- on the block position alone -- no diremite NM appears in that roster -- so it
    -- is the one entry here that is inferred rather than corroborated twice.
    [xi.zone.ABYSSEA_ALTEPA] =
    {
        xi.ki.BROKEN_IRON_GIANT_SPIKE,
        xi.ki.RUSTED_CHARIOT_GEAR,
        xi.ki.STEAMING_CERBERUS_TONGUE,
        xi.ki.BLOODIED_DRAGON_EAR,
        xi.ki.RESPLENDENT_ROC_QUILL,
    },

    [xi.zone.ABYSSEA_ULEGUERAND] =
    {
        xi.ki.WARPED_IRON_GIANT_NAIL,
        xi.ki.DENTED_CHARIOT_SHIELD,
        xi.ki.TORN_KHIMAIRA_WING,
        xi.ki.BEGRIMED_DRAGON_HIDE,
        xi.ki.DECAYING_DIREMITE_FANG,
    },

    [xi.zone.ABYSSEA_GRAUBERG] =
    {
        xi.ki.SHATTERED_IRON_GIANT_CHAIN,
        xi.ki.WARPED_CHARIOT_PLATE,
        xi.ki.VENOMOUS_HYDRA_FANG,
        xi.ki.VACANT_BUGARD_EYE,
        xi.ki.VARIEGATED_URAGNITE_SHELL,
    },
}

xi.pyxis.ki.setKeyItems = function(npc)
    local zoneId = npc:getZoneID()
    local ki = drops[zoneId][math.random(1, #drops[zoneId])]

    npc:setLocalVar('KI', ki)
end

xi.pyxis.ki.updateEvent = function(player, npc)
    player:updateEvent(npc:getLocalVar('KI'), 0, 0, 0, 0, 0, 0, 0)
end

xi.pyxis.ki.giveKeyItem = function(player, npc)
    local keyItem = npc:getLocalVar('KI')
    local zoneId = player:getZoneID()

    if keyItem == 0 then
        player:messageSpecial(zones[zoneId].text.KEYITEM_DISAPPEARED)
        return
    elseif player:hasKeyItem(keyItem) then
        player:messageSpecial(zones[zoneId].text.ALREADY_POSSESS_KEY_ITEM)
        return
    else
        player:addKeyItem(keyItem)
        xi.pyxis.messageChest(player, zones[zoneId].text.OBTAINS_KEYITEM, keyItem, 0, 0, 0)
        npc:setLocalVar('KI', 0)
    end

    if npc:getLocalVar('KI') == 0 then
        xi.pyxis.removeChest(player, npc, 0, 3)
    end
end
