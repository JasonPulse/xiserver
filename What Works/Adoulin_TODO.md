# Adoulin Working / Not Working — quick TODO

Focus is **80% basic functionality**. Coalition rank, mission gates, and Bayld-tier shops are deprioritized — they're behind too far to be worth chasing piecemeal.

## Done this session

- [x] **Trust AI** — Gilgamesh given 5 Tachi WSs (was empty), Zeid II gained Spinning Slash + Resolution + Weapon Bash JA fallback for stuns, Meikyo Shisui added to Gilgamesh gambit. Gilgamesh and Zeid II now actually weaponskill.
- [x] **Gobbie Mystery Box** — Winrix (EA) + Rewardox (WA) wired with standard event 6000 base. *In-game verification needed: if dialog doesn't open or text is wrong, the event base needs adjusting.*
- [x] **EA gil shops** — Bernegeois (cafe), Old_Bellows (seeds), Malgrom (seafood), Tallula (HELM tools/ammo). Standard `xi.shop.general`, no rank gating.
- [x] **Ionis dispenser** — Quiri-Aliri (EA G-6) wired with event 1200, 10-bayld cost, 9000s duration. *Verify in-game: option byte `1` is a guess; Ionis menu may need refining if it's a multi-branch select.*
- [x] **Delivery boxes** — Malulu + Jaded_Hawk (EA) stubbed with their respective events (7584 / 7585). *Verify: the byte_code's `0x21 0x00` tail typically opens delivery box client-side, but if it doesn't, will need a different mechanism.*
- [x] **6 item enums** added (Trail Cookie / Campfire Chocolate / Cascade Candy / Frontier Soda / Ulbuconut Milk / Senroh Skewer)

## Investigated and dismissed

- **HomePoints #3/#4/#5** in EA *and* WA — `npc_list` rows are inert placeholders (coords 0,0,0, status 0). Retail has only 2 HP hubs per zone. Don't add scripts.
- **Achieve_Master** in EA — inactive placeholder. RoE NPC `Eternal_Flame` exists in WA and is fully functional. Use that.
- **Unity_Master** in EA — inactive placeholder. Unity NPC `Nunaarl_Bthtrogg` is in WA and works.

## Real bugs still open (single-file, no rank dependency)

- [ ] **`Iyvah_Halohm.lua:14-20`** — all 6 coalition ranks hardcoded to 0. Fix needs the coalition rank read API to exist; without it, can't display real ranks. Could leave as-is or stub a "coalition system pending" message.
- [ ] **`Ujlei_Zelekko.lua:28,37`** — Peacekeepers shop gated behind Campaign extravaganza only. Either ungate entirely (always-open) or wait for coalition rank API.
- [ ] **`Sifa_Alani.lua:40-44`** — frontier-station bitmask hardcoded all-on. Cosmetic.
- [ ] **`DefaultActions.lua:9`** — `Nhili_Uvolep = event 545`. Possibly stale copy from Western Adoulin (where 545 = Clautaire). Verify.

## Behind the rank/coalition wall (skip per user — too far behind)

- Coalition rank/edification API (blocks Civil_Registrar, Task_Delegator, Vesca, Craggy_Bluff, Wortherton, Ceciliotte, etc.)
- Vesca + Craggy_Bluff (EA Peacekeepers Bayld weapon/gear shops)
- Ornery_Dhole (WA Skirmish Obsidian-Fragment vendor)
- Wortherton (WA Inventors Bayld vendor)
- Kithvalio (WA Inventors Bayld vendor)
- Ceciliotte (WA Mog Garden seed Bayld vendor)
- Mandragora_Assistant (Mancala minigame)
- Anomaly_Expert (Skirmish entry)
- Dimmian (Wildskeeper Reives entry items)
- Lola/Oston/Xavinien (Skirmish system)
- Chamulele (Ergon Loci)

## Subsystems entirely missing (large work)

- Coalition rank/edification storage + API
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

## Reminder: not Adoulin-specific but flagged

- **Waypoints "spam options to chat"** — likely SoA mission 1-2 "The Geomagnetron" not completed → no Geomagnetron KI → client can't render the teleport menu and falls back to text. Confirm by checking `player:hasKeyItem(xi.ki.GEOMAGNETRON)` before assuming the script is wrong.
