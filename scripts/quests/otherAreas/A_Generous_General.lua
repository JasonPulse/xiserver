-----------------------------------
-- A Generous General?
-----------------------------------
-- Log ID: 4, Quest ID: 109
-- Gu'Zho Thunderblade : Oldton Movalpolos (zone-in from North Gustaberg, K-6)
-- Faulpie             : Tanners' Guild, Southern San d'Oria (E-8)
-----------------------------------
-- bg-wiki "A Generous General?": |Start=Gu'Zho Thunderblade, Oldton Movalpolos
-- |Item Reqs=Goblin Coif |Reward=Choplix's Coif |Title=Moblin Kinsman
-- |Repeatable=Yes, Once per Conquest Tally
-- Materials: Buffalo Hide, Sheep Leather, 10,000 gil -> Goblin Coif Cutting.
--
-- Faulpie's block for THIS quest is 770-775, identified by csid 774's bytecode
-- referencing item 1868 (goblin_coif_cutting) and 770/771 referencing item 850
-- (square_of_sheep_leather) -- matching bg-wiki's Sheep Leather. His other block,
-- 760-765, is An Understanding Overlord?. Full derivation and the shared flow are
-- in scripts/globals/beastman_headgear.lua.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_GENEROUS_GENERAL)

quest.reward =
{
    item  = xi.item.CHOPLIXS_COIF,
    title = xi.title.MOBLIN_KINSMAN,
}

quest.sections = xi.beastmanHeadgear.sections(quest,
{
    questId       = xi.quest.id.otherAreas.A_GENEROUS_GENERAL,
    startZone     = xi.zone.OLDTON_MOVALPOLOS,
    startCsid     = 60,
    craftsmanZone = xi.zone.SOUTHERN_SAN_DORIA,
    craftsmanName = 'Faulpie',
    baseCsid      = 770,
    materials     = { xi.item.BUFFALO_HIDE, xi.item.SQUARE_OF_SHEEP_LEATHER },
    cutting       = xi.item.GOBLIN_COIF_CUTTING,
    headgear      = xi.item.GOBLIN_COIF,
    reward        = xi.item.CHOPLIXS_COIF,
    tallyVar      = 'GenerousGeneralTally',
})

return quest
