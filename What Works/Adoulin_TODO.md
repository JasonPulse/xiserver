# Adoulin Working / Not Working — quick TODO

Focus is **80% basic functionality**. Coalition rank, mission gates, and Bayld-tier shops are deprioritized — they're behind too far to be worth chasing piecemeal.

## Done this session

- [x] **Trust skill lists populated** — 10 trusts had empty/wrong mob_skill_lists, now fixed:
  - Gilgamesh, Iroha, Iroha_II — Tachi WS sets (Jinpu/Yukikaze/Kasha/Gekko/Fudo)
  - Zeid II — Spinning Slash/Ground Strike/Resolution + Weapon Bash JA fallback
  - August, Halver, Mnejing, Excenmille_S — PLD Sword sets (Burning/Red Lotus/Spirits Within/Atonement/Vorpal/Savage)
  - Cid — WAR Great Axe set (Shield Break/Sturmwind/Raging Rush/Steel Cyclone/Fell Cleave/Ukko's Fury)
  - Maximilian — THF Dagger set (Dancing Edge/Shark Bite/Evisceration/Aeolian Edge)
- [x] **Trust gambits** — Meikyo Shisui added to Gilgamesh; Soul Eater/Last Resort gated with NOT_STATUS on Zeid II.
- [x] **Gobbie Mystery Box** — Winrix (EA) + Rewardox (WA) wired with standard event 6000 base. *In-game verification needed: if dialog doesn't open or text is wrong, the event base needs adjusting.*
- [x] **EA gil shops** — Bernegeois (cafe), Old_Bellows (seeds), Malgrom (seafood), Tallula (HELM tools/ammo). Standard `xi.shop.general`, no rank gating.
- [x] **Ionis dispenser** — Quiri-Aliri (EA G-6) wired with event 1200, 10-bayld cost, 9000s duration. *Verify in-game: option byte `1` is a guess; Ionis menu may need refining if it's a multi-branch select.*
- [x] **Delivery boxes** — Malulu + Jaded_Hawk (EA) stubbed with their respective events (7584 / 7585). *Verify: the byte_code's `0x21 0x00` tail typically opens delivery box client-side, but if it doesn't, will need a different mechanism.*
- [x] **Lamaron Yahse boat** — EA G-5, event 590, ports to Yahse default coords (361,4,-211,136). *Verify option byte 0 is the "set sail" choice.*
- [x] **Patient_Snake Library Card** — F-9, sells Celennia Memorial Library Card KI for 1000 bayld (event 7535 / 7591). Rank gate intentionally skipped per user direction.
- [x] **Ujlei_Zelekko ungated** — removed `if active > 0` campaign gate. Peacekeepers shop now opens always; cipher count still respects campaign state.
- [x] **Iyvah_Halohm via CharVars** — coalition ranks read from `Coalition_Pioneers_Rank` etc. CharVars (default 0). Future coalition system writes to these without script changes; admins can `!setvar` for testing.
- [x] **Bayld vendors (5)** — Vesca (EA, Karieyh Morion 505), Craggy_Bluff (EA, Vineslash Cesti 500), Wortherton (WA, Craftkeeper's Ring 20000), Kithvalio (WA, Critical Chop KI 20000), Ceciliotte (WA, Arborscent Seed 270). All ungated. Real event IDs from client DAT YAMLs.
- [x] **Gobbie events corrected** — Winrix base 5135, Rewardox base 5129 (verified against client DAT YAMLs, not the 6000 guess from earlier).
- [x] **Ornery_Dhole skipped** — Skirmish stones aren't usable without Skirmish system, and Obsidian Fragments aren't an item/currency yet.
- [x] **6 item enums** added (Trail Cookie / Campfire Chocolate / Cascade Candy / Frontier Soda / Ulbuconut Milk / Senroh Skewer)

## Investigated and dismissed

- **HomePoints #3/#4/#5** in EA *and* WA — `npc_list` rows are inert placeholders (coords 0,0,0, status 0). Retail has only 2 HP hubs per zone. Don't add scripts.
- **Achieve_Master** in EA — inactive placeholder. RoE NPC `Eternal_Flame` exists in WA and is fully functional. Use that.
- **Unity_Master** in EA — inactive placeholder. Unity NPC `Nunaarl_Bthtrogg` is in WA and works.

## Real bugs still open (single-file, no rank dependency)

- [x] **`Iyvah_Halohm.lua`** — now reads via the new `xi.coalition` API instead of inline CharVar reads. Same data, but `!setvar Coalition_*_Rank N` (or `xi.coalition.setRank`) now propagates everywhere.
- [x] **`Ujlei_Zelekko.lua`** — campaign gate removed. Shop now always opens.
- [ ] **`Sifa_Alani.lua:40-44`** — frontier-station bitmask hardcoded all-on. Cosmetic, low priority.
- [ ] **`DefaultActions.lua:9`** — `Nhili_Uvolep = event 545`. Possibly stale copy from Western Adoulin (where 545 = Clautaire). Verify next time someone triggers Nhili_Uvolep — if dialog is wrong, replace event ID.

## Coalition rank API (built — see `project_coalition_api.md`)

- [x] **Lua enum** `scripts/enum/coalition.lua` — IDs + var-name table + `MAX_RANK = 15`.
- [x] **Lua API** `scripts/globals/coalition.lua` — `xi.coalition.{getRank, setRank, addRank, getAllRanks, getImprimatursBalance, addImprimatursBalance, getImprimatursSpent, addImprimatursSpent, spendImprimaturs}`.
- [x] **COLONIZATION packet wired** — `0x071_influence_colonization.cpp` reads CharVars and the client now sees the player's actual ranks instead of the hardcoded `1` placeholder.
- [x] **SOA mission gates active** — `xi.soa.helpers.imprimaturGate` now checks `Coalition_Imprimaturs_Spent` instead of always returning true. Affects missions 1-6 (10), 1-8 (20), 2-7-3 (30).
- [x] **`Iyvah_Halohm.lua` uses the API.**

### Still unbuilt (gameplay flow, not API)

- [ ] **Civil_Registrar** (WA, NPC for joining a coalition). Until built, ranks must be set directly via `!setvar Coalition_*_Rank N` or `xi.coalition.setRank` — there is no in-game flow to join a coalition.
- [ ] **Task_Delegator** (Coalition Assignments / Lights — the system that grants imprimaturs as currency on completion). Until built, imprimatur balance must be granted directly via `xi.coalition.addImprimatursBalance(player, N)` — players have no in-game way to earn them.
- [ ] **Edification NPCs** — the per-coalition rank-up NPCs that the player pays imprimaturs at to advance rank. Until built, ranks must be raised via `xi.coalition.addRank` or `!setvar`.
- [x] **Bayld-tier vendor gating** — Vesca, Craggy_Bluff (Peacekeepers) and Wortherton, Kithvalio, Ceciliotte (Inventors) now gated. Each script has a `REQUIRED_RANK = 1` local at top — bump it for tighter gating. Rank-fail uses `printToPlayer` with a clear coalition-name message. To set a player's rank: `!setvar Coalition_Peacekeepers_Rank 1` (or `Inventors`) — that's a normal CharVar write, which is where ranks live.

## Behind other subsystems (skip per user — too far behind)

- Ornery_Dhole (WA Skirmish Obsidian-Fragment vendor) — needs Skirmish system
- Mandragora_Assistant (Mancala minigame) — needs minigame
- Anomaly_Expert (Skirmish entry) — needs Skirmish
- Dimmian (Wildskeeper Reives entry items) — needs WKR
- Lola/Oston/Xavinien (Skirmish system) — needs Skirmish
- Chamulele (Ergon Loci) — needs Loci

## Subsystems entirely missing (large work)

- Skirmish system
- Delve system
- Wildskeeper Reives
- Ergon Loci
- Mandragora Mania minigame
- ~6+ Adoulin fame quest cycles (Roskin Thirst trilogy, Sharuru waypoint quests, Yocile Cafe…teria, Erisa Bloomers, Oscairn Order Up, Audibert Don't Ever Leaf Me, Zaffeld Lilies trilogy)

## Verification needed in-game

These were wired blind on best-guess data and may need iteration:

1. Winrix dialog flow (Gobbie Mystery Box, EA)
2. Rewardox dialog flow (Gobbie Mystery Box, WA)
3. Quiri-Aliri Ionis casting flow — option byte and event branches
4. Malulu / Jaded_Hawk delivery box menu opening
5. Lamaron boat — option byte 0 → Yahse setPos
6. Patient_Snake Library Card purchase — option byte 1 → bayld deduction + KI grant

## Reminder: not Adoulin-specific but flagged

- **Waypoints "spam options to chat"** — likely SoA mission 1-2 "The Geomagnetron" not completed → no Geomagnetron KI → client can't render the teleport menu and falls back to text. Confirm by checking `player:hasKeyItem(xi.ki.GEOMAGNETRON)` before assuming the script is wrong.
