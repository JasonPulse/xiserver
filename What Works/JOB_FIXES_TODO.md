# Job Fixes Implementation Tracker

## Completed
- [x] GEO Collimated Fervor — ability routing script created
- [x] PLD Guardian — already implemented (audit was wrong)
- [x] GEO Concentric Pulse, Mending Halation, Radial Arcana — already implemented
- [x] RUN Runeist Bandeau +1 (27787) — mods added (16 stats)
- [x] RUN Runeist Mitons +1 (28067) — mods added (16 stats)
- [x] RUN AF Quests 2-5 (2026-04-02) — all 4 quests + Octavien commission NPC
- [x] GEO AF Quests 2-5 (2026-04-02) — all 4 quests + Wescolina commission NPC
- [x] PUP AF3: Puppetmaster Blues — quest, battlefield, Valkeng mob, Iruki-Waraki/Sajhra NPCs all implemented
- [x] PUP Commission NPC (Dhima Polevhia) — Aht Urhgan Whitegate, crystal trade + Imperial Standing for body/hands/legs/feet (2026-04-20)

## In Progress

### SCH AF3: Seeing Blood-red
- **Research**: Complete (see Research/phase2/base_game/quests/sch_af3_research.md)
- **Quest ID**: crystalWar quest 34
- **Reward**: Scholar's Mortarboard (16140) — item + mods exist
- **xidat findings (2026-06-09)**:
  - **AF3 dialog block confirmed** in zone 175 (Eldieme Necropolis [S]) at msg IDs **7866–7890** ("Ulbrecht", "Ruhotz Silvermines", "banishing stones", "silver/fountainheads", formula→Grauberg→Ruhotz progression). Story-recap menu at msg 7604 includes all 4 "Seeing Blood-red(pt.1-4)" branches.
  - **Erlene entity**: 17494732 (zone 175). Full CSID inventory:
    - 1-byte sentinels (real program lives in event#.dat, like AF1's 18 and AF2's 23): 10, 12, 14, 18, 20, 23, 25, 27, **29, 31, 32, 34**
    - Inline byte-code CSIDs: 11 (65b), 13 (129b), 15 (81b), 19 (89b — AF1 mid), 21 (30b), 22 (38b), 24 (38b — AF2 mid), 26 (46b — AF2 mid), 28 (81b), 30 (126b), 33, 35, 36 (30b), 37, 38 (190b), 39 (54b)
  - **Pattern from AF1/AF2**: offer + complete CSIDs are **sentinels** (AF1: 18 offer, 20 complete; AF2: 23 offer, 25 mid, 27 complete). Mid-quest dialog branches use inline byte-code CSIDs (AF1: 19; AF2: 24, 26).
  - **AF3 candidates (in sentinel order, following AF1/AF2 cadence)**:
    - **29** → offer (most likely — next sequential sentinel after AF2's 27)
    - **31** or **32** → mid-quest (Ulbrecht trail / Ruhotz formula)
    - **34** → complete (Mortarboard reward)
  - **Inline-code candidates for mid-quest dialogs** (in case the offer is a byte-code event, not a sentinel): 28 (81b), 30 (126b), 38 (190b — biggest, likely the formula-examination/Ruhotz reveal that prints msg 7866–7890).
- **Files to create**:
  - [x] scripts/quests/crystalWar/SCH_AF3_Seeing_Blood_Red.lua (stub — auto-completes; awaiting CSID for real progression flow)
  - [ ] scripts/zones/Ruhotz_Silvermines/instances/seeing_blood_red.lua
  - [ ] scripts/zones/Ruhotz_Silvermines/mobs/Ulbrecht.lua
- **Files to modify**:
  - [x] Erlene NPC stub handlers exist in SCH_AF3_Seeing_Blood_Red.lua; still need verified CSID + real reward branch
  - [ ] Indescript_Markings in Pashhow_Marshlands_[S] (add letter pickup)
  - [ ] Ruhotz_Silvermines/IDs.lua (add Ulbrecht mob reference)
- **Blockers**: In-game `!cs 29`, `!cs 31`, `!cs 32`, `!cs 34` at Erlene to pin offer/mid/complete. Cross-reference fired messages against the 7866–7890 block above to identify branch boundaries.
- **Mob data**: Ulbrecht pool 4078, group 4659, zone 93, Lv67, ~12k HP, Tabula Rasa at 50%
