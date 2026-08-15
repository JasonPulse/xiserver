# Adventuring Fellow quest chain — blocked on core C++ bindings

The 14 jeuno Adventuring Fellow quests cannot be built to retail today. This is a
**core limitation, not a research gap** — the CSIDs are all decoded (below).

## The blocker

Exactly one Fellow function is exposed to Lua:

```
src/map/lua/lua_baseentity.h:130      bool isFellow() const;
src/map/lua/lua_baseentity.cpp:19684  SOL_REGISTER("isFellow", CLuaBaseEntity::isFellow);
```

A grep across all of `src/` returns **zero** hits for `getFellowValue`,
`setFellowValue`, `spawnFellow`, `despawnFellow`, `fellowAttack`, `getFellow`,
`isFellowSpawned`, `setFellowPos` and `fellowDisengage`. The C++ entity exists
(`src/map/entities/fellowentity.{h,cpp}`) and is type-bound
(`sol_bindings.cpp:54`), but nothing beyond the type test reaches Lua.

**Can be enforced now:** quest order, player level, key items, trades, fame,
titles, NM kills.

**Cannot be enforced or delivered:** familiarity gates (45/55/65/70/80/85/100),
Fellow level gates (51/56/61/66), familiarity-cap raises (50/70/90/120), Fellow
level-cap raises (60/65/70/75/80/85/90/99), Fellow spawn/positioning, and the
Fellow's presence in the seven required battles — Namorodo, Carrion Dragon,
Metallic Slime, Ingaevon, Illusory Pot, Vassago, and the Clash duel.

The chain is also broken at step 1 independently:
`scripts/quests/jeuno/Unlisted_Qualities.lua:238-246` has its completion path
commented out with `-- TODO: Quest completion disabled until core changes made to
save Fellows`.

## Recovered API spec

Five `.todo` files at `scripts/quests/` root — `Blessed_Radiance.lua.todo`,
`Blighted_Gloom.lua.todo`, `Mixed_Signals.lua.todo`, `Regaining_Trust.lua.todo`,
`Unlocking_a_Myth.lua.todo` — are full retail implementations written against the
intended API, and **every CSID in them matches the DAT**. They are the best
starting point and imply:

```
player:getFellowValue('bond'|'level'|'lvlcap'|'personality'|'fellowid')
player:setFellowValue('bondcap'|'lvlcap', n)
player:getFellow() ; player:isFellowSpawned()
player:spawnFellow(id) ; player:despawnFellow()
player:fellowAttack(mob)
getFellowParam(player)   -- global; packs fellow state into event param [7]
```

## Decoded CSIDs (zone 244 Upper Jeuno unless noted)

Luto Mewrilah is entity **17776780** (`npc_list.sql:31003`;
`(17776780-16777216)//4096 = 244` rem 140). Most real programs live on unnamed
`'blank'` / `'csnpc'` holders while Luto carries a 1-byte `0x00` stub — normal,
and *not* evidence of a wrong id (see the ownership note in
`STUB_REMOVAL_MANIFEST.md`).

| Quest | Start | Completion | Notes |
|---|---|---|---|
| Girl in the Looking Glass | **10039** | 10043 | Bheem CS 10040; idle 10042 |
| **Mirror, Mirror** (missing file) | **10044** | **10046** | 10046 grants the Fellow |
| Past Reflections | **10063** | z246 **309** | mid 10064; completes at Khumo Daramasteh, Port Jeuno |
| Blighted Gloom | **10065** | 10066 | |
| Blessed Radiance | **10072** | 10073 | Neptune's Spire door z245 10049/10050 |
| Mirror Images | **10074** | 10075 | |
| Regaining Trust | **10058** | **10207** | Monberaux 10059/10062; 10060/10204/10205/10206 |
| Mixed Signals | Ratoto **10078** | **10081** | Luto 10079/10080 |
| Chameleon Capers | **10055** | — | Muhoho z243 **10070**; post-dust 10057 |
| Clash of the Comrades | **10175** | — | lead-in 10174 |
| A Trial in Tandem | **10192** | **10198** | |
| …Redux | **10193** | **10199** | |
| Yet Another… | **10194** | **10200** | |
| …Quaternary | **10195** | **10201** | |
| …Revisited | **10196** | **10202** | reminder 10216 |

## Corrections already applied

- **`Girl_in_the_Looking_Glass`: 10037 -> 10039.** Fixed a live cross-fire.
  `zones/Upper_Jeuno/npcs/Bheem.lua:11` fires `startEvent(10037)` unconditionally,
  and `onEventFinish` is dispatched **zone-wide keyed only on csid, not on NPC**
  (`interaction_lookup.lua:10-12`). Talking to Bheem could silently begin *and
  complete* the quest.
- **`A_Trial_in_Tandem_Revisited`: 10053 -> 10202.** 10053 is the Fellow-**erase**
  confirmation (dialog 9249 "Returning the ${item} will errrase all that has
  happened between us", 9250 "Maybe not... / Positively."). Destructive.
- **`A_Trial_in_Tandem_Redux`: 10046 -> 10193.** 10046 is Mirror, Mirror's
  completion — the CS whose dialog 9175-9182 reads "You can now call on ${choice}
  as your adventuring fellow!"
- **`Chameleon_Capers` reward items.** Were `{ 5334, 5335, 5336 }` =
  blind/acid/holy **bolt quivers** (99-stack crossbow ammo). Now the three Fellow
  Tactics Manuals (1820 / 1839 / 1876), added to `scripts/enum/item.lua`.
- **`xidat/csidmsg.py`**: added `0x2B` to `TEXT`. The Fellow programs encode text
  as `0x2B <entity4> <u16 msgref> 0x23`, which the original opcode set missed
  entirely, under-reporting those programs to zero. Katsunaga's self-test is
  unchanged, so no regression.

## Also missing

- **`Mirror_Mirror.lua` does not exist.** Enums do:
  `quests.lua MIRROR_MIRROR = 79`, `battlefield.lua MIRROR_MIRROR = 37`, and
  `bcnm_info.sql:63` has `(37, 140, 'mirror_mirror', 'nobody', 0, 900)` — zone
  **140 = Ghelsba Outpost**, NOT Qu'Bia Arena. Retail: Portaure (Port San d'Oria
  H-9) gives the BC, entered via the Hut Door at Ghelsba Outpost (F/G-10), NM
  **Carrion Dragon**, level cap 40, 3 players, Trust disabled. Neither
  `battlefields/Ghelsba_Outpost/mirror_mirror.lua` nor a Hut Door NPC exists.
  `Past_Reflections` consequently gates on the wrong prior quest
  (`GIRL_IN_THE_LOOKING_GLASS` instead of `MIRROR_MIRROR`).
- `QuBia_Arena/` has no `mirror_images.lua` (battlefield 529, Vassago, Lv50 cap)
  and no `clash_of_the_comrades.lua` (battlefield 531).
- **Wrong Magian Moogle in all five Trial files.** They bind
  `['Magian_Moogle']` = 17772764. Retail is the one with the orange ball:
  `npc_list.sql:30807` **17772778 `'Magian_Moogle_Orange'`** (z243 idx 234),
  which owns Trial csids 10167/10168/10173/10174.
- Titles exist but are never granted: `DESTINED_FELLOW` (411),
  `WORTHY_OF_TRUST` (420), `A_FRIEND_INDEED` (423), `FELLOW_FORTIFIER` (596).
  `TEAM_PLAYER` (419) is referenced by a Selbina NPC and may not belong to this
  chain — verify before wiring.
- Mixed Signals' Homemade reward is **12** items, not random: retail keys it off
  `getFellowValue('personality')`. All 12 enums already exist.
