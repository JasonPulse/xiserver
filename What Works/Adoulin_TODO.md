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
- [x] **6 item enums** added (Trail Cookie / Campfire Chocolate / Cascade Candy / Frontier Soda / Ulbuconut Milk / Senroh Skewer)

## Investigated and dismissed

- **HomePoints #3/#4/#5** in EA *and* WA — `npc_list` rows are inert placeholders (coords 0,0,0, status 0). Retail has only 2 HP hubs per zone. Don't add scripts.
- **Achieve_Master** in EA — inactive placeholder. RoE NPC `Eternal_Flame` exists in WA and is fully functional. Use that.
- **Unity_Master** in EA — inactive placeholder. Unity NPC `Nunaarl_Bthtrogg` is in WA and works.

## Real bugs still open (single-file, no rank dependency)

- [ ] **`Iyvah_Halohm.lua:14-20`** — all 6 coalition ranks hardcoded to 0. **Deferred** — without coalition rank API, the display would still show 0/0/0/0/0/0 (which is accurate). Wait for coalition system.
- [x] **`Ujlei_Zelekko.lua`** — campaign gate removed. Shop now always opens.
- [ ] **`Sifa_Alani.lua:40-44`** — frontier-station bitmask hardcoded all-on. Cosmetic, low priority.
- [ ] **`DefaultActions.lua:9`** — `Nhili_Uvolep = event 545`. Possibly stale copy from Western Adoulin (where 545 = Clautaire). Verify next time someone triggers Nhili_Uvolep — if dialog is wrong, replace event ID.

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
5. Lamaron boat — option byte 0 → Yahse setPos
6. Patient_Snake Library Card purchase — option byte 1 → bayld deduction + KI grant

## Reminder: not Adoulin-specific but flagged

- **Waypoints "spam options to chat"** — likely SoA mission 1-2 "The Geomagnetron" not completed → no Geomagnetron KI → client can't render the teleport menu and falls back to text. Confirm by checking `player:hasKeyItem(xi.ki.GEOMAGNETRON)` before assuming the script is wrong.
