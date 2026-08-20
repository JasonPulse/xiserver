-----------------------------------
-- An Understanding Overlord?
-----------------------------------
-- Log ID: 4, Quest ID: 106
-- Loo Kohor : Monastic Cavern (zone-in from Davoi, G-7)
-- Faulpie   : Tanners' Guild, Southern San d'Oria (E-8)
-----------------------------------
-- bg-wiki "An Understanding Overlord?": |Start=Loo Kohor, Monastic Cavern
-- |Item Reqs=Orc Helm |Reward=Gadzradd's Helm |Title=Orcish Serjeant |Repeatable=Yes
-- Materials: Buffalo Hide, Ram Leather, 10,000 gil -> Orc Cutting.
--
-- Faulpie's block for THIS quest is 760-765, identified by csid 764's bytecode
-- referencing item 1865 (orc_helm_cutting) and 760/761 referencing item 851
-- (square_of_ram_leather) -- matching bg-wiki's Ram Leather. His other block,
-- 770-775, is A Generous General?. Full derivation in
-- scripts/globals/beastman_headgear.lua.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.AN_UNDERSTANDING_OVERLORD)

quest.reward =
{
    item  = xi.item.GADZRADDS_HELM,
    title = xi.title.ORCISH_SERJEANT,
}

quest.sections = xi.beastmanHeadgear.sections(quest,
{
    questId       = xi.quest.id.otherAreas.AN_UNDERSTANDING_OVERLORD,
    startZone     = xi.zone.MONASTIC_CAVERN,
    startCsid     = 5,
    craftsmanZone = xi.zone.SOUTHERN_SAN_DORIA,
    craftsmanName = 'Faulpie',
    baseCsid      = 760,
    materials     = { xi.item.BUFFALO_HIDE, xi.item.SQUARE_OF_RAM_LEATHER },
    cutting       = xi.item.ORC_HELM_CUTTING,
    headgear      = xi.item.ORC_HELM,
    reward        = xi.item.GADZRADDS_HELM,
    tallyVar      = 'UnderstandingOverlordTally',
})

return quest
