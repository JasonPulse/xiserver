-----------------------------------
-- Alluvion Skirmish — global module.
--
-- Skirmish drops Alluvion stones (3 elemental families × 4 tiers × 3 ranks).
-- Each Skirmish zone uses 2 of the 3 elemental families:
--   * Yorcia Weald [U] — Leaf + Dusk
--   * Rala Waterways [U] / Cirdas Caverns [U] — Leaf + Snow
--   * Outer Ra'Kaznar [U] — Snow + Dusk
-- (per bg-wiki Alluvion_Skirmish; uses our existing item DB IDs 8930-8963.)
--
-- Tiers (slit / tip / dim / orb) correspond to gear-slot the stone augments;
-- ranks (base / +1 / +2) correspond to drop rarity. The Mistmaw bosses in
-- each _U zone drop one random stone from the zone's family + tier pool on
-- death, scaled by the simplified-server reward setting.
--
-- All 5 Mistmaw entities in Rala_Waterways_U and 4 in Cirdas_Caverns_U
-- already exist in `mob_spawn_points.sql` ; this module handles their
-- death-handler reward distribution.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.skirmish = xi.skirmish or {}

-- Stone families (12 items in sequential order: snow / leaf / dusk × 4
-- tiers × 3 ranks).
xi.skirmish.stones =
{
    snow =
    {
        slit = { base = 8930, p1 = 8931, p2 = 8932 }, -- snowslit
        tip  = { base = 8939, p1 = 8940, p2 = 8941 }, -- snowtip
        dim  = { base = 8948, p1 = 8949, p2 = 8950 }, -- snowdim
        orb  = { base = 8957, p1 = 8958, p2 = 8959 }, -- snoworb
    },
    leaf =
    {
        slit = { base = 8933, p1 = 8934, p2 = 8935 }, -- leafslit
        tip  = { base = 8942, p1 = 8943, p2 = 8944 }, -- leaftip
        dim  = { base = 8951, p1 = 8952, p2 = 8953 }, -- leafdim
        orb  = { base = 8960, p1 = 8961, p2 = 8962 }, -- leaforb
    },
    dusk =
    {
        slit = { base = 8936, p1 = 8937, p2 = 8938 }, -- duskslit
        tip  = { base = 8945, p1 = 8946, p2 = 8947 }, -- dusktip
        dim  = { base = 8954, p1 = 8955, p2 = 8956 }, -- duskdim
        orb  = { base = 8963, p1 = 8964, p2 = 8965 }, -- duskorb
    },
}

-- Zone → families that drop here (per bg-wiki).
xi.skirmish.zoneFamilies =
{
    [xi.zone.YORCIA_WEALD_U]    = { 'leaf', 'dusk' },
    -- Rala/Cirdas don't have _U enum entries on this server; their main
    -- zones are 258/270 and the Augural Conveyor lives there. Mistmaw
    -- entities are still in zones 259/271 even without enum names.
}

local tiers = { 'slit', 'tip', 'dim', 'orb' }

-- Roll a random stone from the family pool. Rank weighting: 70% base,
-- 25% +1, 5% +2.
local function rollStone(family)
    local tier = tiers[math.random(#tiers)]
    local pool = xi.skirmish.stones[family][tier]
    local roll = math.random(100)
    if roll <= 5 then
        return pool.p2
    elseif roll <= 30 then
        return pool.p1
    else
        return pool.base
    end
end

-- Death-handler helper for Mistmaw bosses. Each Mistmaw drops one stone
-- from one of the two families that drop in its zone.
xi.skirmish.grantStoneDrop = function(mob, player, families)
    if not player or not families or #families == 0 then
        return
    end

    local family   = families[math.random(#families)]
    local stoneId  = rollStone(family)

    ---@diagnostic disable-next-line: param-type-mismatch
    npcUtil.giveItem(player, stoneId)
end

-----------------------------------
-- Augural Conveyor entry helper. The retail event CSID 5500 (verified
-- via xidat on all 4 Conveyor NPCs) handles instance creation + warp.
-- We fire it directly; engine handles state.
-----------------------------------
xi.skirmish.conveyorOnTrigger = function(player, npc, label)
    local bayld = player:getCurrency('bayld')

    printf('[Augural_Conveyor_%s] onTrigger: bayld=%d', label, bayld)

    player:startEvent(5500, bayld, 0, 0, 0, 0, 0, 0)
end

xi.skirmish.conveyorOnEventUpdate = function(player, csid, option, label)
    printf('[Augural_Conveyor_%s] onEventUpdate: csid=%d option=%d (0x%08X)', label, csid, option, option)
end

xi.skirmish.conveyorOnEventFinish = function(player, csid, option, label)
    printf('[Augural_Conveyor_%s] onEventFinish: csid=%d option=%d (0x%08X)', label, csid, option, option)
end
