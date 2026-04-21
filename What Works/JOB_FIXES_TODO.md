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
- **Erlene events**: Unused from AF1/AF2: 10, 11, 12, 13, 14, 29, 31, 32, 34
- **Likely AF3 events**: 29, 31, 32, 34 (need in-game verification with !cs)
- **Files to create**:
  - [ ] scripts/quests/crystalWar/SCH_AF3_Seeing_Blood_Red.lua
  - [ ] scripts/zones/Ruhotz_Silvermines/instances/seeing_blood_red.lua
  - [ ] scripts/zones/Ruhotz_Silvermines/mobs/Ulbrecht.lua
- **Files to modify**:
  - [ ] Erlene NPC in The_Eldieme_Necropolis_[S] (add AF3 handlers)
  - [ ] Indescript_Markings in Pashhow_Marshlands_[S] (add letter pickup)
  - [ ] Ruhotz_Silvermines/IDs.lua (add Ulbrecht mob reference)
- **Blockers**: Need to verify event CSIDs via !cs testing at Erlene
- **Mob data**: Ulbrecht pool 4078, group 4659, zone 93, Lv67, ~12k HP, Tabula Rasa at 50%
