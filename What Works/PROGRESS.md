# Audit Progress Tracker

> **Reconciled 2026-06-09** via multi-agent audit of 369 claims across all tracking docs.
> Found 76 items marked incomplete that were actually done. The strikethrough/FIXED
> annotations below in **Blockers Found** and **In-Game Verification Queue** reflect
> reality; the **Completed** section above them preserves historical entries from the
> original audit (do not edit those — they record what was *known at the time*).

## How to Use
- Pick the next item from the **Queue** section
- Move it to **In Progress** while working
- Move to **Completed** when the research MD file is written
- Add any new blockers/discoveries to the **Blockers Found** section
- If you discover something broken, note it in the research file AND here

## Agent Onboarding
New agent? Read these files in order:
1. `what works/AUDIT_PLAN.md` — methodology, status key, file format
2. This file — what's done, what's next
3. `CLAUDE.md` and memory files — project context, CI rules, preferences

---

## Completed
- [x] 00_core/combat.md — All 15 subsystems WORKS. 208 WS, 342 abilities, 588 effects (2026-03-27)
- [x] 00_core/transport.md — All 16 transport methods WORKS. No blockers (2026-03-27)
- [x] 00_core/trusts.md — 120 scripts, only 49 have AI gambits. 71 auto-attack only (2026-03-27)
- [x] 00_core/mog_house.md — Mog Garden STUB, Mog Sack 0 slots, 9/12 systems work (2026-03-27) — RECONCILED 2026-06-09: 11/12 systems work (Mog Sack fixed via migration 050, Festive Moogle in 3 zones); only Mog Garden remains stub
- [x] 00_core/jobs/base_jobs.md — All 6 base jobs WORKS, SP1/SP2 complete (2026-03-27)
- [x] 00_core/jobs/advanced_jobs.md — All 9 unlock quests work, PLD SP2 (Guardian) MISSING (2026-03-27)
- [x] 00_core/jobs/expansion_jobs.md — 7 jobs, RUN/GEO PARTIAL (Adoulin access needs retest, GEO missing 4 abilities) (2026-03-27)
- [x] 01_base_game/sandoria/missions_rank1-3.md — All 9 WORKS, BCNMs functional (2026-03-27)
- [x] 01_base_game/bastok/missions_rank1-3.md — All 9 WORKS, 5 Emissary sub-scripts (2026-03-27)
- [x] 01_base_game/windurst/missions_rank1-3.md — All 9 WORKS, fossil rock RNG, timed kills (2026-03-27)
- [x] 01_base_game/windurst/missions_rank4-6.md — All 5 missions WORKS, 3 BCNMs functional, no blockers (2026-03-27)
- [x] 01_base_game/sandoria/missions_rank4-6.md — All 5 WORKS, Shadow Lord 2-phase (2026-03-27)
- [x] 01_base_game/bastok/missions_rank4-6.md — All 5 WORKS (2026-03-27)
- [x] 01_base_game/sandoria/missions_rank7-10.md — All 6 WORKS, 9-2 two-phase BCNM with ally (2026-03-27)
- [x] 01_base_game/bastok/missions_rank7-10.md — 5 WORKS, 9-2 PARTIAL (trusts now fixed) (2026-03-27)
- [x] 01_base_game/windurst/missions_rank4-6.md — All 5 WORKS (2026-03-27)
- [x] 01_base_game/windurst/missions_rank7-10.md — All 6 WORKS, minor cosmetic TODOs (2026-03-27)

- [x] 02_zilart/missions_zm1-8.md — All 8 WORKS, headstones + BCNMs (2026-03-27)
- [x] 02_zilart/missions_zm9-16.md — All 9 WORKS, Ark Angels + Divine Might + Eald'narche (2026-03-27)
- [x] 03_cop/missions_ch1-3.md — All 13 WORKS, Promyvion + Diabolos + Ouryu (2026-03-27)
- [x] 03_cop/missions_ch4-8.md — All 18 WORKS, Sea zones + Omega/Ultima/Promathia (2026-03-27)
- [x] 04_toau/missions_and_content.md — 48/48 missions, Nyzul/Einherjar WORKS, Assault 9/50, Besieged MISSING (2026-03-27)
- [x] 05_wotg/missions_and_content.md — 54 scripts, ~40 WORKS, Campaign battles/ops MISSING (2026-03-27)
- [x] 06_abyssea/access_and_content.md — 172 NMs (28 w/AI), 149 atma (69 empty), Fabricant STUB (2026-03-27)
- [x] 07_soa/missions_and_content.md — 105 missions, reives WORKS, coalitions/skirmish/delve MISSING (2026-03-27)
- [x] 08_rov/missions_all.md — 93 scripts, 5 boss stubs, Rhapsody KIs WORKS, Escha no Lua scripts (2026-03-27)
- [x] 09_endgame/all_systems.md — Dynamis/Limbus/JP WORKS, 6 systems MISSING (Odyssey/Omen/DI/Geas/ML/Vagary) (2026-03-27)
- [x] phase2/progression/new_player_lv1-10.md — All WORKS, Curio Vendor gated behind ROV KI (2026-03-28)
- [x] phase2/progression/leveling_10-30.md — All WORKS, Snipper droplist 3913 missing (2026-03-28)
- [x] phase2/progression/leveling_30-50.md — All WORKS, LB1 + AF + job unlocks verified (2026-03-28)
- [x] phase2/progression/leveling_50-75.md — LB2-5 all WORKS, coffers/Dynamis/FoV verified (2026-03-28)
- [x] phase2/progression/leveling_75-99.md — LB6-10 all WORKS, Maiden of Dusk battlefield MISSING (2026-03-28)

---

- [x] phase2/progression/leveling_99-119.md — ALL iLvl 119 paths BROKEN (Monisette/Oboro/Ambuscade/Unity/Escha) (2026-03-28)
- [x] phase2/base_game/quests/sandoria_quests.md — 77/82 (93.9%), 5 missing optional (2026-03-28)
- [x] phase2/base_game/quests/bastok_quests.md — 78/94 (83%), 16 missing, 1 PUP LB blocker (2026-03-28)
- [x] phase2/base_game/quests/windurst_quests.md — 85/92 (92.4%), Nothing Matters prereq gap (2026-03-28)
- [x] phase2/base_game/quests/jeuno_quests.md — 100/140 (71.4%), all critical present (2026-03-28)
- [x] phase2/zilart/missions_detailed.md — All 17 ZM verified step-by-step, clean (2026-03-28)
- [x] phase2/base_game/quests/af_armor_all_jobs.md — 11 WORKS, 8 PARTIAL, 3 MISSING (PUP/RUN/GEO) (2026-03-28) — RECONCILED 2026-06-09: 21 WORKS, 1 PARTIAL (SCH Mortarboard stub), 0 MISSING; PUP/RUN/GEO completed in trust+AF overhaul (2026-04-02 / 2026-04-20)
- [x] phase2/cop/missions_detailed.md — All 33 COP verified step-by-step, clean (2026-03-28)
- [x] phase2/toau/missions_detailed.md — All 48 ToAU verified, fully completable (2026-03-28)
- [x] phase2/wotg/missions_detailed.md — 41 WORKS, 6 stub instances, 3 missing battlefields (2026-03-28)
- [x] phase2/soa/missions_detailed.md — 105 scripts, imprimaturGate BLOCKS at 1-6, 7/8 instances missing (2026-03-28)
- [x] phase2/rov/missions_detailed.md — 54 WORKS, 10 PARTIAL, 30 STUB, Scintillating KI not awarded (2026-03-28)
- [x] phase2/base_game/quests/other_areas_quests.md — 204/482 (42.3%), all job unlocks work (2026-03-28)
- [x] phase2/base_game/zones/zone_accessibility.md — All 300 zones reachable, no broken links (2026-03-28)
- [x] phase2/base_game/npcs/vendors_and_currency.md — Sparks/Conquest/Cruor WORKS, Ambuscade STUB, DI vendor works but no battles (2026-03-28)
- [x] phase2/base_game/crafting/crafting_system.md — All 8 crafts WORKS, 4389 recipes, fishing disabled by default (2026-03-28)
- [x] phase2/base_game/nms/nm_systems.md — NMs/drops WORKS, pre-RMT drops not enabled, VEmperor droplist bug FIXED (2026-04-20) (2026-03-28)
- [x] phase2/base_game/npcs/misc_systems.md — Signet/Sanction/Fame/LS WORKS, Ionis WORKS (Quiri-Aliri vendor in EA wired 2026-05-03), AH empty (2026-03-28)

---

- [x] phase2/base_game/zones/zone_paths_detailed.md — All base game zones reachable, Garlaige solo-modified (2026-03-28)
- [x] phase2/base_game/zones/expansion_zone_paths.md — Most reachable, Reisenjima needs !pos, Salvage permit FIXED (2026-03-28)
- [x] phase2/base_game/zones/battlefield_access.md — 146 battlefields work, Limbus BROKEN, Einherjar FIXED (2026-03-28)
- [x] phase2/base_game/crafting/crafting_system.md — All 8 crafts WORKS, 4389 recipes (2026-03-28)
- [x] phase2/base_game/nms/nm_systems.md — NMs/drops WORKS, pre-RMT module FIXED (2026-03-28)
- [x] phase2/base_game/npcs/misc_systems.md — Signet/Sanction/Fame/LS WORKS, Ionis WORKS (Quiri-Aliri vendor in EA wired 2026-05-03), AH empty (2026-03-28)

- [x] phase2/base_game/quests/expansion_quests.md — ToAU 61.3%, WotG 30.6%, Adoulin 14.6% (2026-03-28)
- [x] phase2/base_game/nms/treasure_chests.md — Chests/coffers/caskets/pyxis all WORKS (2026-03-28)
- [x] phase2/base_game/gear/upgrade_paths.md — Monisette/Oboro MISSING, Magian/Sagheera/Switchstix WORKS (2026-03-28)
- [x] phase2/base_game/gear/quest_reward_items.md — Key rewards have stats, 71 AF+3 have zero mods, 1105 iLvl119 items missing (2026-03-28)

---

- [x] phase2/base_game/quests/af_partial_jobs_detailed.md — 7/8 actually WORKS, only SCH head missing (2026-03-28)
- [x] phase2/base_game/quests/sandoria_quests_deep.md — 49/56 clean, keyitem typo bug found (2026-03-28)
- [x] phase2/base_game/quests/bastok_quests_deep.md — All 78 verified, no blockers (2026-03-28)
- [x] phase2/base_game/quests/windurst_jeuno_quests_deep.md — All 146 verified, no broken quests (2026-03-28)
- [x] phase2/base_game/nms/nm_droplists_deep.md — 17/20 WORKS, VEmperor rate off, all abjurations obtainable (2026-03-28)
- [x] phase2/base_game/nms/mob_spawns_key_zones.md — All zones populated, Escha/Reisenjima no scripts (2026-03-28)
- [x] phase2/base_game/quests/seasonal_events.md — Egg Hunt/Starlight WORKS, 4 events MISSING (2026-03-28)
- [x] phase2/base_game/gear/common_gear_stats.md — Most correct, 8 Eminent latents wrong, 3 relic proc rates wrong (2026-03-28)

- [x] phase2/base_game/quests/toau_quests_deep.md — 46 scripts, Saga of Skyserpent dead code bug (2026-03-28) — bug FIXED in commit 2f056e99b9
- [x] phase2/base_game/nms/dynamis_content.md — All 10 zones fully implemented, relic drops + currency (2026-03-28)
- [x] phase2/base_game/nms/abyssea_nms_deep.md — Pop system WORKS, ~10 NMs HP=0, ~12 droplist=0, Bastion missing (2026-03-28)
- [x] phase2/base_game/crafting/recipes_deep.md — 31/33 correct, Dragon Leather missing, Bewitched no mods (2026-03-28)
- [x] phase2/base_game/quests/other_areas_quests_deep.md — 41 scripts, Behind_the_Smile blocks Forbidden Doors (2026-03-28) — Forbidden Doors FIXED in commit 2f056e99b9
- [x] phase2/toau/assault_detailed.md — 10/50 scripted (4 modern), Golden Salvage bug, 40 missing (2026-03-28)
- [x] phase2/base_game/quests/crystal_war_quests_deep.md — Only Sandy path works, Bastok/Windy broken, SCH AF 2/5 (2026-03-28)

- [x] phase2/base_game/quests/adoulin_quests_deep.md — 14/103, HELM blocks Stone's Throw, 0/77 coalitions (2026-03-28)
- [x] phase2/base_game/quests/outlands_quests_deep.md — 24 scripts, The_Missing_Piece softlock bug (2026-03-28) — softlock FIXED in commit 2f056e99b9
- [x] phase2/base_game/quests/abyssea_quests_deep.md — 5/9 maw quests can't complete, Conflux CSID bug (2026-03-28) — RECONCILED 2026-06-09: all 9 maw quests now have scripts (commit 7dd032fc23); Conflux CSID bug FIXED 2026-06-09 (#08 was 2138, now 2139)
- [x] phase2/base_game/gear/expansion_mission_rewards.md — 27/40 correct, Balrahn's Ring -Enmity missing, 6 SoA backs no mods (2026-03-28)

- [x] phase2/base_game/quests/quest_flag_dependencies.md — All 7 chains clean, no broken flags (2026-03-28)
- [x] phase2/base_game/gear/zero_mod_equipment.md — 3,692/14,874 (24.8%) have zero mods, 713 at iLvl119 (2026-03-28)
- [x] phase2/base_game/quests/all_job_quest_chains.md — All 22 unlock, 7 full AF, 10 partial, 5 none (2026-03-28)

- [x] phase2/base_game/gear/zero_mod_equipment.md — 3,692 items, 1,714 at lv99 (mostly hexed/jug/crafted) (2026-03-28) — RESCOPED 2026-04-21: inflated count, weapon stats live in item_weapon.sql not item_mods, many are legit cursed flavor items. Fix on-demand when a player flags a specific broken item.
- [x] phase2/base_game/quests/all_job_quest_chains.md — 8 full AF, 3 at 4/5, 4 at 3/5, 3 at 2/5, 1 at 1/5, 3 at 0/5 (2026-03-28) — RECONCILED 2026-06-09: 21/22 jobs have complete AF chains (RUN/GEO Adoulin quests 2026-04-02; PUP AF3 2026-04-20). Only **SCH AF3 (Seeing Blood-red)** stub remains, blocked on CSID verification.
- [x] phase2/base_game/nms/wrong_drops_audit.md — DB clean, no cross-family errors (Diremite was only one, fixed) (2026-03-28)
- [x] phase2/base_game/nms/drop_consistency_audit.md — 0 errors across 7 checks, 5 dungeon spot-checks clean (2026-03-28)

## In Progress
(none — full audit complete; see Blockers Found and In-Game Verification Queue below for open work)

---

## Queue (historical)

Initial audit queue — fully consumed by the Completed list above. All batches (Core Systems, Core/Advanced/Expansion Jobs, all nation/expansion mission sets, quests, gear, NMs, crafting) now have research files in `Research/` and corresponding entries in Completed. New findings should go to **Blockers Found** (below) or the appropriate topic-specific TODO (`JOB_FIXES_TODO.md`, `ROV_TODO.md`, `VOIDWATCH_TODO.md`, `ROE_CAPTURE.md`).

---

## Blockers Found
Track cross-cutting issues here so they don't get lost:

- **Mog Garden is a stub** -- Zone loads, Green Thumb Moogle opens mog menu + seed shop, but no gathering NPCs, no tutorial quests, no monster rearing. Massive effort to implement. (from mog_house.md)
- ~~**Mog Sack defaults to 0 slots**~~ -- FIXED (2026-04-21): char_storage.sql defaults for locker/satchel/sack bumped from 0 to 30 each. New characters get base capacity automatically. For existing characters: `UPDATE char_storage SET locker=GREATEST(locker,30), satchel=GREATEST(satchel,30), sack=GREATEST(sack,30);`
- ~~**71/120 trusts have no AI**~~ -- FIXED (2026-04-02): All 120 trusts now have AI gambits. Tank trusts also have 1.5x ATT boost (2026-04-04).
- **No trust iLvl scaling** -- Trusts capped at player level stats, weak in endgame. (from trusts.md)
- ~~**Alter Ego Extravaganza disabled**~~ -- FIXED (2026-04-21): campaignActive() now returns BOTH unconditionally; bonus cipher drops + Shadow Era vendors always on
- ~~**PLD SP2 (Guardian) missing**~~ -- FALSE ALARM: already implemented (from JOB_FIXES_TODO.md completed list)
- ~~**GEO missing 4 abilities**~~ -- FIXED: Radial Arcana / Concentric Pulse / Mending Halation already present; Collimated Fervor routing added (from JOB_FIXES_TODO.md completed list)
- **RUN/GEO Adoulin access** -- Scripts exist but user reported needing GM teleport. Needs re-testing. (from expansion_jobs.md)
- **Bastok 9-2 BCNM no Trusts** -- FIXED: added `allowTrusts = true` to `where_two_paths_converge.lua` (from missions_rank7-10.md)
- **Campaign Battles MISSING** -- DB infrastructure tracks zone control but actual battle spawning/rewards don't exist. No way to earn Allied Notes. (from wotg)
- **Campaign Ops MISSING** -- Zero of 100+ ops implemented. (from wotg)
- **Besieged MISSING** -- NPC/currency/Sanction works but actual siege battles don't exist. (from toau)
- **Assault 11/50** -- 2026-04-20: 6 Tier 2 assaults upgraded to modern framework (now awarding points); 2026-04-21: Lebros Supplies (22) implemented from pre-existing mob data. 38 remaining missing assaults need mob_pools + mob_spawn_points SQL + in-game placement before scripts can be written.
- **~8 WotG missions PARTIAL** -- Battlefields exist but completion not fully wired. (from wotg)
- ~~**69 Abyssea Atma have empty mods**~~ -- CLARIFIED (2026-04-20): audit was wrong, only 3 atma had empty mods (Hateful Stream, Ace Angler, Shattering Star) because they're HP-conditional. Ace Angler + Shattering Star now implemented via xi.atma.conditionalAtmaMods with HP<25% runtime gate. Hateful Stream still unimplemented (requires reflect/drain mechanic).
- **144/172 Abyssea NMs lack custom AI** -- Use default behavior only. (from abyssea)
- ~~**Atma Fabricant STUB**~~ -- IMPLEMENTED (2026-06-09): simplified cruor + 7-lights purchase keyed to `Atma_Selection` CharVar (pin to atma KI 1279-1699). Unblocks Abyssea progression — atmas are otherwise unobtainable (NM scripts don't grant them, atma stones don't exist in DB).
- **NM atma drops** -- PARTIAL (2026-06-09): `xi.abyssea.grantAtmaDrop(mob, player, atmaKi)` helper added; 10 NMs wired to canonical bg-wiki atma drops (Kukulkan→Noxious Fang, Balaur→Stormbreath, Fistule→Vicissitude, Eccentric Eve→Voracious Violet, Hadal Satiator→Beyond, Turul→Stormbird, Briareus→Stout Arm, Iratham→Cosmos, Rani→Merciless Matriarch, Sippoy→Would-Be King). 4-player server policy: always grants on kill (no proc/chance gating). Remaining ~18 Abyssea NM scripts have no documented atma drop on bg-wiki — Fabricant covers acquisition.
- **Ambuscade shop** -- PARTIAL (2026-06-09): monthly rotation table (24 enemy families, cycles by Vana'diel month via `xi.ambuscade.getCurrentRotation()`); simplified CharVar-pin shop on Gorpa-Masorpa via `Ambuscade_Item_Selection` (16 starter items: Abdhaljs Thread/Dust/Sap/Dye/Resin/Nuggets/Gem/Anima/Matter + 7 Ambuscade Vouchers). Players can now spend hallmarks/gallantry. Per-family mob spawning in Maquette_Abdhaljs_Legion_B and the difficulty event flow (CSID 386 menu) still unwired — needs in-game capture.
- **Domain Invasion** -- PARTIAL (2026-06-09): `scripts/globals/domain_invasion.lua` with `grantPoints(mob, player)` (alliance-distribute, 50yalm range, daily cap 600 honored) and `spawnNext()` (rotation: Yumcax/Naga_Raja/Kyou/Suttung). Mob death scripts written for all 4 bosses. Zurim vendor + char_points.domain_points already worked — closing the loop. Auto-rotation cron still unwired (manual `!exec xi.domainInvasion.spawnNext()` only).
- **Wildskeeper Reives** -- PARTIAL (2026-06-09): `scripts/globals/wildskeeper_reives.lua` with popBoss/grantRewards. 6 Naakual death scripts (Colkhab/Tchakka/Achuka/Yumcax-shared-w/DI/Hurkan/Kumhau). Pop KIs map → boss SpawnMob via xi.zone.* lookup; KI consumed on success. 5000 bayld alliance reward (100yalm) + WKR_<Name>_Defeated CharVar. No further fight mechanics (engagement/leashing/rage/etc).
- **Geas Fete** -- PARTIAL (2026-06-09): `scripts/globals/geas_fete.lua` with popBoss/grantRewards. **Expanded same day**: pop table now 60+ NMs (5 Gods + 5 Ark Angels + 19 standard Escha-Ru'Aun + 25 Escha-Zi'Tah + 9 Reisenjima), with 58 mob death scripts wired (25 Zi'Tah + 24 Ru'Aun + 9 Reisenjima). 3000 bayld alliance reward. Remaining ~20 GF NMs across the same zones follow the same pattern — extend xi.geasFete.pops + add a 12-line mob death script.
- **Pop-trigger NPC** -- DONE (2026-06-09): `scripts/globals/pop_trigger.lua` unifies WKR + GF pop UX. Players set `Pop_Selection` CharVar to a pop KI id (or just hold any registered pop KI matching the current zone) and trigger an NPC wired to `xi.popTrigger.tryPop(player)`. Wired into 9 NPCs across 9 zones: Undulating_Confluence (Escha-Ru'Aun + Escha-Zi'Tah), qm_ethereal_droplet (Reisenjima), Waypoint (Ceizak_Battlegrounds + Foret_de_Hennetiel + Morimar_Basalt_Fields + Yorcia_Weald + Marjami_Ravine + Kamihr_Drifts). All Geas Fete + Wildskeeper Reive bosses are now poppable in-game without GM intervention.
- **Unity Wanted NM accolades** -- DONE (2026-06-09): `xi.unity.grantWantedAccolades(player, amount)` helper added to scripts/globals/unity.lua. Existing endgame reward helpers (Geas Fete +25, WKR +50, Domain Invasion +10) now award Unity Accolades alongside bayld/domain points. CAP_CURRENCY_ACCOLADES (99999) honored. RoE-objective + sparks-trade paths remain functional. Retail's weekly Wanted-NM menu rotation still stubbed (requires CSID work on the Concord NPC menu) — this gives accolades a non-RoE earning path until the menu is built.
- ~~**Silent fail QOL pattern**~~ -- AUDITED 2026-04-21: scanned all ~600 zone NPC files with Python regex for silent position-check returns; 0 found outside the original Phomiuna _ir9 fix. Door NPCs consistently messageSpecial on the wrong-side branch.
- ~~**Snipper droplist 3913 missing**~~ -- FALSE ALARM verified 2026-03-28; Snippers use 482/483/2281 which all exist
- ~~**Monisette has no script**~~ -- FIXED (2026-04-02): Monisette implemented with 421 reforge mappings, proper Rem's Tale + slot material requirements for all 22 jobs. (from gear audit)
- ~~**Oboro has no script**~~ -- FIXED (2026-04-04): Oboro implemented with 48 weapon reforges (14 Relic + 20 Mythic + 14 Empyrean), lv90 + 300 materials → iLvl 119. (from gear audit)
- ~~**Curio Vendor gated behind ROV KI**~~ -- Tuned by user to their preference; not touching. (2026-04-21)
- **Maiden of the Dusk (WotG 51) Lilith battlefield MISSING** -- No battlefield script, no Walk_of_Echoes battlefield dir. Blocks WotG story but not level caps. (from phase2 lv75-99)
- **SoA imprimaturGate BLOCKS at mission 1-6** -- FIXED: function now returns true. (from phase2 soa)
- ~~**Limbus entry BROKEN**~~ -- FALSE ALARM (2026-04-04): Re-investigated — AlTaieu/npcs/Swirling_Vortex.lua EXISTS and is functional, xi.limbus module EXISTS at scripts/globals/limbus.lua. Both Temenos and Apollyon instances work. Phase 1 "WORKS" was correct after all.
- **Einherjar disabled by default** -- FIXED: added EINHERJAR_ENABLED=true to settings/default/main.lua (from battlefield_access audit)
- **toau module enabled** -- FIXED: added to modules/init.txt for pre-RMT drops (from NM audit)
- **Salvage Remnants Permit commented out** -- FIXED: uncommented Zasshal trigger logic (from expansion zone paths)
- **Reisenjima has no entry NPC** -- Transcendental Radiance NPC missing in Escha Ru'Aun. Needs !pos. (from expansion zone paths)
- **SoA 7/8 battlefield instances missing** -- chapters 3-5 blocked (from phase2 soa)
- **ROV 30 missions auto-complete (no cutscenes)** -- mostly chapters 2-3 (from phase2 rov)
- **Scintillating Rhapsody KI never awarded** -- FIXED: added to 3-34 mission reward (from phase2 rov)
- **ROV 2-28 wrong event ID** -- reuses 2-19 Norg event, duplicate dialogue (from phase2 rov)
- **RUN base AF armor has zero mods** -- FIXED: added 78 mods for all 5 Futhark pieces (from AF audit)
- **RUN +1 AF armor has zero mods** -- FIXED (2026-04-02): added mods for all 5 Futhark +1 pieces + all 5 Erilaz pieces
- **SAM Omodaka set has zero mods** -- FIXED (2026-04-02): added mods for 4 Omodaka pieces
- **Valorous Mitts/Greaves zero mods** -- FIXED (2026-04-02): added mods
- **Lustratio Harness zero mods** -- FIXED (2026-04-02): added mods
- **Unity gear upgrade (Perle/Aurore/Teal +1)** -- FIXED (2026-04-02): trade handler in unity.lua, Harold's Ore added to shop
- ~~**8 jobs missing AF quest scripts**~~ -- RECLASSIFIED 2026-04-21: deep audit (af_partial_jobs_detailed.md) shows 7/8 jobs (BLM/PLD/RNG/DRG/BRD/SMN/COR) already fully functional. Only SCH AF3 (Seeing Blood Red) genuinely missing; tracked in JOB_FIXES_TODO.md as blocked on in-game CSID verification.
- ~~**RUN and GEO have NO AF quests**~~ -- FIXED (2026-04-02): RUN quests 2-5 + Octavien commissions, GEO quests 2-5 + Wescolina commissions. All 5 AF pieces obtainable for both jobs.
- ~~**PUP has NO AF quests**~~ -- FULLY FIXED 2026-04-20: AF3 Puppetmaster Blues + Dhima Polevhia commission NPC (crystal + Imperial Standing for body/hands/legs/feet) both live. All 5 AF pieces obtainable.
- **Adoulin quests 19.2% coverage** -- lowest of any area (from other areas)
- ~~**Adoulin Coalitions 0/77**~~ -- API SHIPPED 2026-05-03, gameplay loop SHIPPED 2026-05-03 to 2026-06-08: `xi.coalition.{getRank,setRank,addRank,spendImprimaturs,edify}` API + COLONIZATION packet wired; Civil_Registrar (registration), Task_Delegator (daily imprimaturs + edification rank-up), 5 Bayld vendors gated. 77 individual repeatable quest scripts still absent but the *coalition system* is no longer "stuck at 0".
- ~~**MapHTTPServer hangs xi_test**~~ -- FIXED (2026-06-09): MapHTTPServer construction now gated on `!isTestServer` in map_engine.cpp:363. Was causing CI test timeouts (6-hour kills) because httplib::listen() held a thread that blocked shutdown.
- ~~**Master Levels MISSING**~~ -- IMPLEMENTED (2026-06-09): `master_level` + `exemplar_points` columns in char_stats (migration 051); EP accrues from CP overflow when JP cap is hit; +5 HP, +5 MP, +1 to each base stat per ML in CalculateStats; `/check` packet's `mlvl`/`mflags` fields populated. Lua API: `player:{get,set}MasterLevel()`, `player:{get,add}ExemplarPoints()`. Settings: `MAX_MASTER_LEVEL` (default 50), `EXEMPLAR_RATE`, `EXEMPLAR_PER_LEVEL` (default 30000). UI display depends on client version — stat bonuses apply regardless.

---

## In-Game Verification Queue

Items below are **code-complete or research-complete** but need live-game testing with `!cs`, `!pos`, or manual playthrough to confirm behavior or capture data. Organized by command type so you can run them in batches.

### `!cs` — Event CSID verification

**SCH AF3: Seeing Blood-red** (tracked in `JOB_FIXES_TODO.md`)
- [ ] Erlene NPC in The_Eldieme_Necropolis_[S] — try `!cs 29`, `!cs 31`, `!cs 32`, `!cs 34` to find AF3 offer/progress/reward events. Unused CSIDs from AF1/AF2: 10, 11, 12, 13, 14, 29, 31, 32, 34.

**Voidwatch** (tracked in `VOIDWATCH_TODO.md` § testing checklist)
- [ ] Voidwatch Officer CSIDs per zone — run `!cs <id>` at each Officer to confirm menu mapping:
  - Southern San d'Oria 977,978,979,981-985,963,993
  - Bastok Markets 11,12,13,16-19,21,9,24
  - Windurst Waters 1035-1037,1039-1043,1024
  - Batallia Downs 10-17,8 · Rolanberry 9-16,7 · Sauromugue 10-17,8 · Qufim 52-59,50
- [ ] Voidwatch Purveyor CSIDs (13 locations)
- [ ] Atmacite Refiner CSIDs — Southern Sandy 962/993, Bastok Markets 8/24, Windurst Waters 1023
- [ ] Ardrick (Jugner Forest) CSIDs 61, 62

**ROV Missing Event IDs** (tracked in `ROV_TODO.md` § Missing Event IDs)
- [ ] Eastern Adoulin zone-in (3-5 Forward Thinking, 3-7 What He Left Behind, 3-10 Solemnity) — try CSIDs 1547, 1549, 1551
- [ ] Walk of Echoes: 3-15 What Remains of Hope (try 29 or 30), 3-18 Sin (try 5 or 8), 3-19 Penance (try 9), 3-27 Calm After the Storm (try 31)
- [ ] Reisenjima: 3-21 Lifestream (try 3), 3-23 Good Things Come in Threes (try 8)
- [ ] Chapter 2 batch: 2-26, 2-27, 2-29, 2-30, 2-31, 2-33, 2-34, 2-35, 2-38 — see ROV_TODO.md for zones/NPC IDs
- [ ] Nation zone-in missions: 2-41 Uncertain Futures, 3-29 An Unending Song (10 zones each)

### `!pos` — Position/zone entry verification

- [ ] **Reisenjima Transcendental Radiance NPC** — missing from Escha Ru'Aun; get the live NPC position to add it
- [ ] **Walk of Echoes entry from Xarcabard [S]** — tentative fix `!pos -700 -20.25 -305.398 182`; verify zoneline lands player at the Ornate Door for ROV 2-17 Sacrifice and WotG 51 Maiden of the Dusk
- [x] **Planar Rift spawn points** — pyxis entity IDs captured (RECONCILED 2026-06-09): West Saru 17248917-19, N. Gust 17212119-21, Ordelle's 17568202-04, Gusgen 17580414-16, Pashhow 17224374-76, Shakhrami 17588786-88, Meriph. 17265318-20. Pending VOIDWATCH_TODO.md § 3A update.
- [ ] **RUN/GEO Adoulin access** — user previously reported needing GM teleport to complete unlock. Retest normal zone path: Jeuno → Al Zahbi → Adoulin ferry chain.

### Manual gameplay verification (no GM command)

- [ ] **ROE records marked "(W)" in ROE_CAPTURE.md** — try to accept each, capture the `"The record #XXXX is not implemented at this time."` ID. Categories: 15th Vana'versary I-V, 17th Vana'versary (True Love, A Fond Farewell), plus any other failing ROE objectives.
- [ ] **ROV 3-2 The Brewing Storm** — confirm 3 Perfervid Naraka spawn in Reisenjima (pool 5378, **12** spawn points, 180s respawn) — count corrected 2026-06-09
- [x] **ROV 3-22 From West to East** — VERIFIED 2026-06-09: pool 5367 Obstreperous_Panopt has 32 spawn points in zone 291 (Reisenjima), 180s respawn, killCounter wired to 11 in `3_22_From_West_to_East.lua`
- [ ] **Unity Leader (Sylvie) objectives** — capture any failing ROE IDs in ROE_CAPTURE.md § Unity Leader
- [x] **Existing char Mog Sack fix** — handled by `tools/migrations/050_char_storage_default_to_30.py`; runs on next `dbtool update`. Also disables upstream migration 049 which was silently reverting our DEFAULT 30 on every dbtool run (so brand-new chars were being created with 0 capacity).

### Still-stubbed boss battles (need implementation + test)

All auto-complete on zone-in; tracked in `ROV_TODO.md`:
- [ ] ROV 2-36 Pretender to the Throne (Balamor) — Escha-Ru'Aun, events 6/7
- [ ] ROV 2-39 Both Paths Taken (Disjoined One) — Empyreal Paradox, **mob_pools/mob_spawn_points missing**
- [ ] ROV 3-17 No Time Like the Future (Sempurne) — Desuetia-Empyreal Paradox, pool 4914
- [ ] ROV 3-26 The Winds of Time (Metus) — Empyreal Paradox, pool 4820
- [ ] ROV 3-34 The Orb's Radiance (Cloud of Darkness) — Reisenjima Sanctorium, pool 4819 (final boss)
- [ ] WotG 51 Maiden of the Dusk (Lilith) — Walk_of_Echoes battlefield dir missing entirely

### Verification queue — new shipments this session (2026-06-09)

These were built without in-game verification — list of behaviors a play-test needs to confirm:
- [ ] **Master Levels `/check` packet** — `mlvl`/`mflags` populated, but pinned client may not render the ML number in the UI (stat bonuses still apply server-side regardless)
- [ ] **Master Levels EP gain** — when JP is capped on current job and an lv 100+ mob is killed, excess CP should redirect to Exemplar Points; verify EP accrues per kill and ML increments at 30k
- [ ] **Master Levels stat application** — confirm HP/MP/STR/DEX/VIT/AGI/INT/MND/CHR all gain bonuses on `setMasterLevel`
- [ ] **Atma Fabricant** — set `Atma_Selection` to a valid atma KI, ensure Visitant Status check passes, cruor deduction matches setting, lights deducted from `abysseaLights1`/`abysseaLights2`, atma KI granted
- [ ] **NM atma drops** — kill one of the 10 wired NMs (Kukulkan, Briareus, etc.), confirm KI grant to alliance members with Visitant Status who don't already have it
- [ ] **Ambuscade simplified shop** — set `Ambuscade_Item_Selection` to an item id from the shop table, trigger Gorpa-Masorpa, verify currency deduction and item grant
- [ ] **Domain Invasion** — manually `!exec xi.domainInvasion.spawnNext()`, kill the boss, confirm `domain_points` award (10 base + level diff) honors daily cap (600); verify rotation cursor advances on each subsequent spawn
- [ ] **Domain Invasion daily reset** — does `domain_points_daily` reset at Conquest tally? If not, players will hit the cap after one fight day. (May need a cron task or daily-reset hook.)
- [ ] **Wildskeeper Reives popBoss** — set `Reives_Selection` etc., trade or call `xi.wildskeeperReives.popBoss(player, kiId)`, verify pop KI is consumed and Naakual spawns at retail coords
- [ ] **Wildskeeper Reives reward distribution** — kill Colkhab/Tchakka/etc., confirm 5000 bayld awarded to all alliance in 100yalm range
- [ ] **Geas Fete popBoss** — trade or `xi.geasFete.popBoss(player, kiId)` for one of the 20 wired pops, verify KI consumption + boss spawn
- [ ] **Geas Fete reward distribution** — kill any of the 10 wired death-handler NMs (Byakko/Genbu/Seiryu/Suzaku/Kirin + 5 AAs), verify 3000 bayld alliance reward in 100yalm range
- [ ] **Pop-trigger NPC flow** — hold or pin a Geas Fete pop KI, trigger Undulating_Confluence (Escha-Zi'Tah) or qm_ethereal_droplet (Reisenjima), confirm boss spawns and KI is consumed; verify teleport/droplet menu still fires when no pop is in hand
- [ ] **WKR pop via Waypoint** — hold one of the 6 Naakual pop KIs, trigger the appropriate zone's Waypoint NPC; verify Naakual spawns at retail coords + KI consumed; confirm waypoint menu still fires when no WKR pop in hand
- [ ] **Unity Accolade endgame grants** — kill a Geas Fete / WKR / Domain Invasion boss, confirm +25/+50/+10 accolades respectively appear in the currency packet and respect the 99999 cap

---

## Known Issues (from prior work)
- ROV missions: many cutscenes auto-complete, boss battles stubbed (see ROV_TODO.md)
- Voidwatch: not implemented, in progress (see VOIDWATCH_TODO.md)
- Vanadversary ROE: partially implemented (see ROE_CAPTURE.md)
- RUN/GEO: jobs work but unlock quest zones may require GM teleport
- Mog Garden: zone exists but tutorial quests may be missing
- Client version staying pinned at server 30251227_0 — not tracking upstream client bumps (user decision 2026-04-20)
- DB performance: innodb_flush_log_at_trx_commit = 2 fix applied for Orange Pi Longhorn storage
