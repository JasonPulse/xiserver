# Server Implementation Audit — Executive Summary

Phase 1 completed 2026-03-27 (22 files). Phase 2 completed 2026-03-28 (25 files). Total: 47 research files.

> **Reconciled 2026-06-09** against actual codebase via multi-agent audit
> (369 claims verified, 76 closed as actually-done that this doc still flagged
> as incomplete). The "What Partially Works", "What's Missing", and "Quick Wins"
> sections below have been updated. The quest-coverage table reflects an
> older snapshot — see `scripts/globals/quests.lua` for current state.

## Overall Status

| Content Area | Status | Details |
|-------------|--------|---------|
| **Core Combat** | WORKS | All 15 subsystems, 208 WS, 342 abilities, 588 effects |
| **Core Transport** | WORKS | All 16 methods functional |
| **Core Jobs (22)** | WORKS | All unlock quests work. PLD SP2 (Intervene) + all 16 GEO abilities implemented |
| **Trusts** | WORKS | All 120 have AI gambits. Tank trusts have 1.5x ATT boost. No iLvl scaling |
| **Mog House** | PARTIAL | Mog Garden STUB (storage/capacity all default 30) |
| **San d'Oria Missions** | WORKS | All ranks 1-10, all BCNMs |
| **Bastok Missions** | WORKS | All ranks 1-10 (9-2 trusts fixed) |
| **Windurst Missions** | WORKS | All ranks 1-10 |
| **Zilart Missions** | WORKS | All 17 missions, Ark Angels, Divine Might, Celestial Nexus |
| **COP Missions** | WORKS | All 31 missions, 9 battlefields, Sea zones |
| **ToAU Missions** | WORKS | All 48 missions including Alexander |
| **ToAU Content** | PARTIAL | Nyzul/Einherjar WORKS. Assault 11/50 (all modern framework). Besieged MISSING |
| **WotG Missions** | PARTIAL | 54 scripts, ~8 battlefields incomplete |
| **WotG Content** | MISSING | Campaign battles AND ops not implemented |
| **Abyssea** | PARTIAL | 172 NMs (28 w/AI), 69/149 atma empty, Fabricant stub |
| **SoA Missions** | WORKS | 105 scripts across all chapters |
| **SoA Content** | PARTIAL | Coalitions WORK via xi.coalition API + Civil_Registrar/Task_Delegator. Skirmish/Delve missing |
| **ROV Missions** | PARTIAL | 93 scripts, 5 boss battles stubbed |
| **Endgame (Classic)** | WORKS | Dynamis, Limbus, Job Points |
| **Endgame (Modern)** | PARTIAL | Master Levels IMPLEMENTED (2026-06-09); Odyssey/Omen/Domain Invasion/Geas Fete still missing |

---

## What Works Great (no action needed)

- All nation missions rank 1-10 (27 missions x 3 nations)
- Zilart missions 1-17 with full boss fights
- COP missions 1-8 with all battlefields and Sea access
- ToAU missions 1-48
- All transport systems
- Core combat (melee, magic, skillchains, pets, enmity)
- All 22 job unlocks accessible
- Nyzul Isle Investigation
- Einherjar
- Dynamis (original 10 zones)
- Limbus
- Job Points system
- Rhapsody KI bonuses
- Home points, survival guides, unity warps, waypoints

## What Partially Works (usable but gaps)

- ~~**Trusts** — 49/120 have AI, rest auto-attack only~~ FIXED: All 120 have AI
- **Abyssea** — NMs spawn but most lack custom AI. Atma: only 1 truly unimplemented (Hateful Stream — needs reflect/drain C++ proc). Ace Angler + Shattering Star apply via runtime HP<25% gate.
- **ROV** — completable but 5 boss fights auto-complete
- **WotG missions** — ~8 need battlefield wiring
- **Assault** — 11 of 50 scenarios (all on modern framework); 38 missing assaults need mob_spawn_points placement before scripts can be written
- **SoA zones** — mobs exist via DB but minimal Lua scripts
- **Ambuscade** — framework exists, monthly rotation table now defined (`xi.ambuscade.rotation` / `getCurrentRotation`), simplified CharVar-pin shop on Gorpa-Masorpa (16 starter items: Abdhaljs materials + Ambuscade Vouchers). Per-family mob spawning + difficulty event flow still unwired.
- **Unity** — warps/shops work; Wanted NM weekly menu still stubbed but **endgame NM kills now grant Unity Accolades** (Geas Fete 25, WKR 50, Domain Invasion 10) via `xi.unity.grantWantedAccolades`. CAP_CURRENCY_ACCOLADES (99999) honored.

## What's Missing (major gaps)

| System | Effort | Impact |
|--------|--------|--------|
| Campaign Battles | Massive | WotG main content loop, no Allied Notes earning |
| Campaign Ops | Large | 100+ ops, nation-specific |
| Besieged | Massive | ToAU city defense system |
| Bastion | Partial | Bastion_Prefect daily cruor stipend (5000 per zone per day) shipped 2026-06-11; wave-defense mechanic still missing |
| Skirmish | Large | SoA endgame content |
| Wildskeeper Reives | Partial | popBoss + 6 Naakual death handlers (Colkhab/Tchakka/Achuka/Yumcax/Hurkan/Kumhau) shipped 2026-06-09 |
| Delve | Large | SoA endgame content |
| Odyssey/Sheol | Massive | Modern endgame, no code exists |
| Omen | Large | Modern endgame, empty zone |
| Domain Invasion | Medium | Daily Escha content — vendor + currency wired; mob death handlers + GM-callable rotation spawn shipped 2026-06-09. Periodic auto-spawn (every N hours) still unwired. |
| Geas Fete | Partial | Escha NM system — popBoss helper + 60+ NM pop table + 58 mob death scripts across Escha-Zi'Tah/Ru'Aun/Reisenjima shipped 2026-06-09 |
| Voidwatch | Large | In progress (see VOIDWATCH_TODO.md) |
| Mog Garden | Massive | Tutorial/gathering/rearing all missing |
| Dynamis Divergence | Large | Empty zone shells only |
| Vagary | Medium | No code exists |

## Quick Wins (easy fixes found during audit)

| Fix | File | Status |
|-----|------|--------|
| Bastok 9-2 allow trusts | `battlefields/Throne_Room/where_two_paths_converge.lua` | FIXED |
| Phomiuna gate silent fail | `zones/Phomiuna_Aqueducts/npcs/_ir9.lua` | FIXED |
| Mog Sack 0 slots | `sql/char_storage.sql` + migration 050 | FIXED (DEFAULT 30, backfill applied) |
| Acuex mob family for Sylvie ROE | `scripts/globals/roe_records.lua` record 3690 | FIXED |
| ROV ROE records 1417-1425 | `scripts/globals/roe_records.lua` | ADDED |
| Vanadversary ROE (27 records) | `scripts/globals/roe_records.lua` | ADDED |
| 4 new ROE trigger types | `src/map/roe.h` + Lua + C++ hook points | ADDED |
| SoA imprimaturGate | `scripts/missions/soa/helpers.lua` | FIXED |
| Scintillating Rhapsody KI | `scripts/missions/rov/3_34_The_Orbs_Radiance.lua` | FIXED |
| RUN AF armor 78 mods | `sql/item_mods.sql` (Futhark set) | FIXED |
| Einherjar enabled | `settings/default/main.lua` | FIXED |
| toau pre-RMT drops | `modules/init.txt` | FIXED |
| Salvage Remnants Permit | `zones/Aht_Urhgan_Whitegate/npcs/Zasshal.lua` | FIXED |

## Phase 2 Findings (Step-by-Step Verification)

### Player Progression (verified lv1-119)
- Lv1-99: All limit breaks, FoV/GoV, sub-job, AF quests verified
- Lv99-119: Monisette (DONE 2026-04-02) + Oboro (DONE 2026-04-04) + Unity gear upgrades (DONE) all work. STILL BROKEN: Ambuscade (framework only, no monthly rotation/trade flows) + Escha NMs (no pop system)

### Quest Coverage (reconciled 2026-06-09 vs `scripts/globals/quests.lua` markers)
| Area | Scripts | Total | Rate |
|------|---------|-------|------|
| San d'Oria | 82 | 82 | 100% |
| Bastok | 93 | 93 | 100% |
| Windurst | 86 | 90 | 95.6% |
| Jeuno | 145 | 145 | 100% |
| Aht Urhgan | 72 | 72 | 100% (28 are simplified accept+complete for 4-player server) |
| Crystal War | 80 | 95 | 84.2% (49 are auto-complete QOL stubs skipping Campaign/Voidwatch mechanics) |
| Adoulin | 28 | 97 | 28.9% |
| Other Areas | 67 | 67 | 100% |
| Outlands | 48 | 56 | 85.7% |
| Abyssea | 68 | 192 | 35.4% |

### AF Armor by Job (CORRECTED 2026-04-21)
- 21/22 jobs fully complete. Deep audit (af_partial_jobs_detailed.md) found that BLM/PLD/RNG/DRG/BRD/SMN/COR already work end-to-end via NPC scripts (prior Phase 2 undercounted)
- PUP IMPLEMENTED (2026-04-20): Puppetmaster Blues AF3 + Dhima Polevhia commission NPC
- RUN/GEO IMPLEMENTED (2026-04-02): quests 2-5 + Octavien/Wescolina commissions
- Only gap: **SCH AF3 (Seeing Blood Red)** — blocked on in-game !cs verification of Erlene CSIDs, tracked in `JOB_FIXES_TODO.md`

### Zone Accessibility
- All base game zones reachable without GM commands
- All expansion zones reachable except Reisenjima (needs !pos)
- Garlaige banishing gates modified for solo play

### Gear/Upgrade Pipeline
- Sagheera, Switchstix, Magian Trials: WORKS
- Monisette (iLvl 109/119 armor): IMPLEMENTED (2026-04-02) — 421 mappings, all 22 jobs
- Oboro (REMA weapons to 119): IMPLEMENTED (2026-04-04) — 48 weapons across Relic/Mythic/Empyrean
- 71 AF/Relic/Empyrean +3 pieces: 79 now have full mods across multiple batches; ~38 still need work (66 SoA-era hands/legs/feet IDs 23554-23709 need item_equipment.sql first)
- 672 iLvl 119 items missing mods (down from 1,105 — 1,944 of 2,616 now wired; upstream gap)

### Key Broken Systems (Phase 1 corrections)
- ~~Limbus: BROKEN~~ — Re-investigated 2026-04-04: entry script EXISTS and is functional. Phase 1 finding was wrong, Phase 2 correction was also wrong. Limbus WORKS.

## Recommendations for a 4-Player Server

1. ~~**#1 Priority**: Implement Monisette~~ DONE (2026-04-02)
2. ~~**#1 Priority**: Implement Oboro~~ DONE (2026-04-04) — 48 weapons (14 Relic + 20 Mythic + 14 Empyrean)
3. ~~**High value**: Fill empty atma mods~~ DONE (2026-04-04) — 39/42 filled (3 conditional-only left empty)
4. ~~**Medium value**: Fix Limbus entry~~ NOT BROKEN (audit was wrong, entry script exists and works)
5. ~~**Medium value**: Fix AF+3 zero-mod pieces~~ DONE (2026-04-04) — 35 items got full stat blocks (670 mod entries)
6. ~~**Medium value**: Add PUP AF quests~~ DONE (2026-04-20). **Still open**: wire up WotG battlefields (Maiden of the Dusk, 51 Lilith)
5. **Continue**: Voidwatch (in progress), ROV boss battles
6. **Don't worry about**: Campaign, Besieged, Odyssey, Master Levels — designed for large populations
7. ~~**Consider**: `UNLOCK_OUTPOST_WARPS=1`~~ DONE (2026-06-08) — set to 2 (all warps incl. Tu'Lia/Tavnazia). ~~increase Mog Sack slots~~ DONE (migration 050). **Consider**: seed AH with common items
