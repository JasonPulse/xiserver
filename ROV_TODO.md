# ROV Mission TODO

## Known Bugs

### ROV 2-17 Sacrifice — Walk of Echoes Entry
- **Status**: Partially fixed (comment corrected)
- **Issue**: Players cannot reach Walk of Echoes (zone 182) to trigger the Ornate Door (`_521`)
- **Root Cause**: No functional entry point from Xarcabard [S] to Walk of Echoes is implemented
- **Script Fix Applied**: Comment corrected from `!pos -700 -20.25 -303.398 89` to `!pos -700 -20.25 -305.398 182` (zone 89=Grauberg_S was wrong, Z coord put player inside door)
- **Same fix applied to**: `scripts/missions/wotg/51_Maiden_of_the_Dusk.lua`
- **GM Workaround**: `!pos -700 -20.25 -305.398 182`
- **TODO**: Implement Walk of Echoes zone entry from Xarcabard [S]

---

## Stubbed Boss Battles

Three of 5 ROV boss missions now have real `onMobDeath` handlers (Balamor / Sempurne / Metus, all 2026-06-16). Disjoined One still SQL-blocked (mob_groups.poolId = 0); Cloud of Darkness is the ROV final boss with a more complex multi-phase requirement.

### ROV 2-36 — Pretender to the Throne (Balamor)
- **Status**: WIRED 2026-06-16
- **File**: `scripts/missions/rov/2_36_Pretender_to_the_Throne.lua`
- **Zone**: Escha - Ru'Aun (zone 289)
- **Boss**: Balamor — entity 17961637 (group 95, pool 5631)
- **Mission flow**: Replaced auto-complete-on-zone-in with `onMobDeath = mission:complete(player)`. Mob spawning is still GM-required (no QM trigger yet), but mission progression now requires the actual fight.
- **Event Data**: Escha Ru'Aun events 6 (Selh'teus/Balamor pre-fight) and 7 (post-fight) — not wired into the script; players still need GM to fire them for the full cinematic.
- **Difficulty**: Medium

### ROV 2-39 — Both Paths Taken (Disjoined One)
- **Status**: WIRED 2026-06-16 (SQL fix + onMobDeath)
- **File**: `scripts/missions/rov/2_39_Both_Paths_Taken.lua`
- **Zone**: Empyreal Paradox (zone 36)
- **Boss**: Disjoined One — entity 16924685 (group 5, pool **7501 — added in this fix**)
- **Battlefield**: Listed in Empyreal Paradox event 32000 as "Both Paths Taken"
- **SQL fix**:
  - `sql/mob_pools.sql` — added pool 7501 'Disjoined_One' (family 475, Sempurne-equivalent humanoid template)
  - `sql/mob_groups.sql` — updated row for (groupid=5, zoneid=36, 'Disjoined_One') from `poolid=0, HP=0` → `poolid=7501, HP=20000`
  - `tools/migrations/052_disjoined_one_mob_pool.py` — idempotent migration that ports the SQL changes to existing live DBs (INSERT... ON DUPLICATE + UPDATE).
- **Mission flow**: Replaced auto-complete-on-zone-in with `onMobDeath = mission:complete(player)`. Mob now spawns with proper stats; mission progression requires the actual fight.
- **Difficulty**: Medium-Hard

### ROV 3-17 — No Time Like the Future (Sempurne)
- **Status**: WIRED 2026-06-16
- **File**: `scripts/missions/rov/3_17_No_Time_Like_the_Future.lua`
- **Zone**: Desuetia - Empyreal Paradox (zone 290) — NOT regular Empyreal Paradox
- **Boss**: Sempurne — entity 17965057 (group 1, pool 4914, lv125 / 20000 HP)
- **Mission flow**: Replaced auto-complete-on-zone-in with `onMobDeath = mission:complete(player)`. Earlier stub fired in zone 36 (wrong zone); fixed to fire in zone 290.
- **Battlefield**: Event 32000 in Desuetia-Empyreal Paradox
- **Event Data**: Event 2 (Sempurne dialogue), Cait Sith events 1-8 (cutscene support) — not wired into the script.
- **Difficulty**: Medium

### ROV 3-26 — The Winds of Time (Metus)
- **Status**: WIRED 2026-06-16
- **File**: `scripts/missions/rov/3_26_The_Winds_of_Time.lua`
- **Zone**: Empyreal Paradox (zone 36)
- **Boss**: Metus — entity 16924721 (group 8, pool 4820, lv125 / 20000 HP)
- **Mission flow**: Replaced auto-complete-on-zone-in with `onMobDeath = mission:complete(player)`.
- **Battlefield**: Listed in Empyreal Paradox event 32000 as "The Winds of Time"
- **Event Data**: Empyreal Paradox events 9-17 surround this fight — not wired into the script.
- **Mob Resistances**: mob_resistances.sql line 529
- **Difficulty**: Medium (likely multi-phase)

### ROV 3-34 — The Orb's Radiance (Cloud of Darkness)
- **Status**: WIRED 2026-06-16
- **File**: `scripts/missions/rov/3_34_The_Orbs_Radiance.lua`
- **Zone**: Reisenjima Sanctorium (zone 293) — earlier stub fired in EMPYREAL_PARADOX (zone 36), same wrong-zone bug shape as Sempurne. Fixed.
- **Boss**: Cloud of Darkness — entity 17977400 (group 1, pool 4819, family 497, lv130 / 20000 HP)
- **Mission flow**: Replaced auto-complete-on-zone-in with `onMobDeath = mission:complete(player)` in the correct zone. Reward chain (Scintillating Rhapsody KI + Cipher: Iroha II + chain to A Rhapsody for the Ages) preserved.
- **Battlefield**: Event 32000 in Reisenjima Sanctorium — not wired into the script (cinematic still needs !cs verification).
- **Mob Resistances**: mob_resistances.sql line 512
- **Difficulty**: Hard (final boss, likely complex phases, ally NPCs) — multi-phase mechanics are AI-side.

---

## Stubbed Kill Missions

Kill counter logic is implemented but mobs may not be spawning in-game.

### ROV 3-2 — The Brewing Storm
- **File**: `scripts/missions/rov/3_02_The_Brewing_Storm.lua`
- **Zone**: Reisenjima (zone 291)
- **Objective**: Kill 3 Perfervid Naraka
- **Mob Data**: Pool ID 5378, Family 472, Level 121-126, HP 9999, 11 spawn points, 180s respawn
- **Status**: Kill counter implemented. Verify mobs spawn in-game.
- **TODO**: Confirm mob scripts exist or create them. Test in-game.

### ROV 3-22 — From West to East
- **File**: `scripts/missions/rov/3_22_From_West_to_East.lua`
- **Zone**: Reisenjima (zone 291)
- **Objective**: Kill 11 Obstreperous Panopt
- **Mob Data**: Pool ID 5367, Family 463, Level 121-126, HP 9999, 32 spawn points, 180s respawn
- **Status**: Kill counter implemented. Verify mobs spawn in-game.
- **TODO**: Confirm mob scripts exist or create them. Test in-game.

---

## Missing Event IDs

Event data extracted via xi-tinkerer from `FFXI_DATS_Decoded/raw_data/events/`. Probable CSIDs identified below — need in-game testing to confirm exact mappings.

### Eastern Adoulin Missions (ROV events mixed into SoA event infrastructure)
Events 1547-1552 are large ensemble cutscenes (15-20+ NPCs including Arciela, Melvien, Ploh Trishbahk). Zone-in trigger entities: 17830025, 17830026.
- **3-5 Forward Thinking** — Eastern Adoulin zone-in — **CSID 1547 ✅ VERIFIED 2026-06-18** (Arciela offers Adoulinian tomato juice with Ploh Trishbahk)
- **3-7 What He Left Behind** — Eastern Adoulin zone-in — **CSID 1549 ✅ VERIFIED 2026-06-18** (Hildebert's apology to Arciela in the council chamber)
- **3-10 Solemnity** — Eastern Adoulin zone-in — **CSID 1551 ✅ VERIFIED 2026-06-18** (Fremilla's farcical "legendary sleuth" eulogy for Melvien)

### Walk of Echoes Missions
Zone-in trigger: 17523287. Cait Sith: 17523288. Lilisette: 17523300. Event 28 = ROV 3-14 (confirmed).
- **3-15 What Remains of Hope** — Walk of Echoes — **CSID 29 ✅ VERIFIED 2026-06-18** (Cait Sith chastises player; Lilisette rebukes him over the masked man's escape)
- **3-18 Sin** — Walk of Echoes — **CSID 5 ✅ VERIFIED 2026-06-18** (Lady Lilith confronts Lilisette+Cait Sith — "Spitewardens", "Father and Mother to their knees")
- **3-19 Penance** — Walk of Echoes (awards Rhapsody in Puce) — **CSID 9 ✅ VERIFIED 2026-06-18** (Lady Lilith's death + transfer of role to Lilisette)
- **3-27 Calm After the Storm** — Walk of Echoes — **CSID 31 ✅ VERIFIED 2026-06-18** (Lilith's brief farewell — "Do not neglect to say your farewells")

### Reisenjima Missions
Zone-in triggers: 17969923, 17969924. Iroha: 17969928. Known: event 2=3-1, 6=3-3, 7=3-20, 9=3-30.
- **3-21 The Lifestream of Reisenjima** — probable CSID: **3** — INCONCLUSIVE 2026-06-18 (CSID 3 fires "Iroha: Master! Wait!" then auto-closes after one line, both before and after a clean zone reset; need different candidate)
- **3-23 Good Things Come in Threes** — **CSID 8 ✅ VERIFIED 2026-06-18** (Iroha's finale monologue: gentle breeze, the Reckoning, "Never give up", winding the ancient clock)

### Chapter 2 Missions (various zones)
- **2-26 Where Divinities Collide** — Shattered Telepoint (3 Crags)
- **2-27 Visions of Dread** — Hall of Transference zone-in
- **2-29 Escha Ru'Aun** — Misareaux Coast Undulating Confluence
- **2-30 The Decisive Heroine** — Escha Ru'Aun zone-in (events 2/4 likely)
- **2-31 Fall from Grace** — Shattered Telepoint (3 Crags)
- **2-33 Over the Rainbow** — Windurst Walls (Shantotto)
- **2-34 Cacophonous Discord** — Misareaux Coast Undulating Confluence
- **2-35 Eddies of Despair II** — Escha Ru'Aun zone-in
- **2-38 Call of the Void** — Telepoint at Crags (Dimensional Portal)

### Nation Zone-In Missions (no zone-specific events found)
- **2-41 Uncertain Futures** — nation zone-in (10 zones)
- **3-29 An Unending Song** — nation zone-in (10 zones)

### Boss Battle Event Data (from decoded DATs)
- **Empyreal Paradox**: Event 32000 on Transcendental Radiance (16924740-43). Cutscenes: events 9-17 on entity 16924799+ (Iroha 16924801, Selh'teus 16924802, Volto Oscuro 16924803)
- **Desuetia-EP (Sempurne)**: Event 32000 = battlefield entry. Event 2 = Sempurne dialogue. Cait Sith (17965081) has events 1-8
- **Reisenjima Sanctorium (CoD)**: Event 32000 on Ramblix (17977507). Events 12-13 = pre-CoD (Iroha 17977517 + Selh'teus 17977518). Event 11 = major ensemble (all allies)
- **Escha-Ru'Aun (Balamor)**: Events 6/7 confirmed on Selh'teus (17961692) + Balamor (17961693). Event 4 = confrontation (Iroha, Volto Oscuro, Kagero, Tenzen, Siren)

---

## ~~Missing Cipher Items~~ FIXED (2026-04-20)

- **Cipher: Iroha** (10185) — added to enum, awarded via ROV 3-28 reward table
- **Cipher: Iroha II** (10186) — added to enum, awarded via ROV 3-34 reward table
- Items already existed in `item_basic.sql`; only enum + mission reward hooks needed

---

## Implementation Notes

### Battlefield Pattern Reference
See `scripts/battlefields/Empyreal_Paradox/dawn.lua` for a complete example of:
- `BattlefieldMission` class usage
- Multi-phase boss fights with ally NPCs
- Event 32001 victory detection → mission completion chain

### Event ID Sources
- **xi-tinkerer decoded DATs** — `FFXI_DATS_Decoded/raw_data/events/<Zone>.yml` (definitive, from client `30251101_1`)
- **KnowOne134/FFXI_Events** — Dialogue text organized by actor (predates Voidwatch)
- **KnowOne134/DSP-Shared_Collection/Event CSID Dump** — CSID-to-dialogue mappings with actor IDs
- **UpdateExtractor output** — `~/Code/Lua/Personal/UpdateExtractor/output/dialog-table-<zoneID>.xml` (verified text IDs)
