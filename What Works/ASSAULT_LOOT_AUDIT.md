# Assault Lockbox Loot Audit

**Date:** 2026-04-20
**Source:** cross-reference of `scripts/globals/appraisal.lua` vs `scripts/enum/assault.lua`

Ancient Lockboxes drop **unappraised items** keyed by the current assault mission. Appraising the item produces the actual gear per `xi.appraisal.loot` tables. An assault with no loot-table entry will either drop generic/wrong items or nothing useful.

## Coverage summary

- **50 total assaults** + 2 Nyzul
- **20 have loot tables** (at least one unappraised item type mapped)
- **30 have no loot tables** — gear from these assaults is unreachable even if the assault gets implemented

## Assaults WITH loot tables (20)

Leujaoam Cleansing · Orichalcum Survey · Imperial Agent Rescue · Preemptive Strike · Sagelord Elimination · Breaking Morale · The Double Agent · Azure Experiments · Blitzkrieg · Red Versus Blue · Excavation Duty · Lebros Supplies · Troll Fugitives · Wamoura Farm Raid · Seagull Grounded · Requiem · Shooting Down the Baron · Golden Salvage · Lamia No. 13 · Extermination

## Assaults WITHOUT loot tables (30)

### Leujaoam Sanctum (Caedarva Mire - Azouph)
- Escort Professor Chanoix (3)
- Shanarha Grass Conservation (4)
- Counting Sheep (5)
- Supplies Recovery (6)
- Imperial Code (8)
- Bloody Rondo (10)

### Mamool Ja Training Grounds (Bhaflau Thickets)
- Imperial Treasure Retrieval (16)
- Marids in the Mist (18)
- Azure Ailments (19)
- The Susanoo Shuffle (20)

### Lebros Cavern (Mount Zhayolm)
- Evade and Escape (24)
- Siegemaster Assassination (25)
- Apkallu Breeding (26)
- Egg Conservation (28)
- Operation: Black Pearl (29)
- Better Than One (30)

### Periqia (Caedarva Mire - Dvucca)
- Saving Private Ryaaf (33)
- Building Bridges (35)
- Stop the Bloodshed (36)
- Defuse the Threat (37)
- Operation: Snake Eyes (38)
- Wake the Puppet (39)
- The Price is Right (40)

### Ilrusi Atoll (Arrapago Reef)
- Demolition Duty (44)
- Searat Salvation (45)
- Apkallu Seizure (46)
- Lost and Found (47)
- Deserter (48)
- Desperately Seeking Cephalopods (49)
- Bellerophon's Bliss (50)

## Prioritization

All 30 missing loot tables correspond to assaults that have **no instance script** (audit: `phase2/toau/assault_detailed.md`). The encounter itself must be built before the loot matters.

**Recommendation:** add each loot table AS each assault gets implemented, not ahead of time. The assault design (mob count, boss presence, party-size scaling) informs which tier/rank each item should drop at. Pre-filling from bg-wiki without implementation context risks drop rates that don't match the encounter difficulty.

## Structural note

The existing 20 loot tables use this schema in `appraisal.lua`:
```lua
[xi.item.UNAPPRAISED_<SLOT>] =
{
    [xi.assault.mission.<NAME>] =
    {
        items =
        {
            { <weight>, xi.item.<ITEM> },
            ...
        },
    },
    ...
}
```

Unappraised item types currently covered: body, legs, feet, hands, head, ring, earring, neckwear. When adding a new assault's drops, add entries under each relevant slot's table.

## Also verified

- All 20 existing loot tables reference items that exist in `scripts/enum/item.lua`
- No orphaned entries (no tables for non-existent assault IDs)
