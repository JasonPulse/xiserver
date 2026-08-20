-----------------------------------
-- An Affable Adamantking?
-----------------------------------
-- Log ID: 4, Quest ID: 107
-- Raptorlegs Gedwad : Qulun Dome (zone-in from Beadeaux, H-7)
-- Peshi Yohnts      : Windurst Woods (H-13)
-----------------------------------
-- bg-wiki "An Affable Adamantking?": |Start=Raptorlegs Gedwad, Qulun Dome
-- |Item Reqs=Quadav Barbut |Reward=Da'Vhu's Barbut |Title=Bronze Quadav
-- |Repeatable=Yes
-- Materials: Bugard Leather, Turtle Shell, 10,000 gil -> Quadav Parts.
--
-- The craftsman here is PESHI YOHNTS in Windurst Woods, not Faulpie -- the old
-- stub bound Faulpie for all three. Peshi is entity 17764402; his block is
-- 710-715, identified by csid 714's bytecode referencing item 1866
-- (set_of_quadav_barbut_parts) and 710/711 referencing 1637 (bugard leather) and
-- 885 (turtle_shell). Full derivation in scripts/globals/beastman_headgear.lua.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.AN_AFFABLE_ADAMANTKING)

quest.reward =
{
    item  = xi.item.DAVHUS_BARBUT,
    title = xi.title.BRONZE_QUADAV,
}

quest.sections = xi.beastmanHeadgear.sections(quest,
{
    questId       = xi.quest.id.otherAreas.AN_AFFABLE_ADAMANTKING,
    startZone     = xi.zone.QULUN_DOME,
    startCsid     = 60,
    craftsmanZone = xi.zone.WINDURST_WOODS,
    craftsmanName = 'Peshi_Yohnts',
    baseCsid      = 710,
    materials     = { xi.item.SQUARE_OF_BUGARD_LEATHER, xi.item.TURTLE_SHELL },
    cutting       = xi.item.SET_OF_QUADAV_BARBUT_PARTS,
    headgear      = xi.item.QUADAV_BARBUT,
    reward        = xi.item.DAVHUS_BARBUT,
    tallyVar      = 'AffableAdamantkingTally',
})

return quest
