# Unauthorized "Simplified for 4-player server" stub removal — manifest

The prior agent rewrote 99 quests across every expansion as "accept + instantly
complete" stubs. The owner had approved a simplified implementation for
**Besieged only**. This file records the disposition of every one of them.

Besieged (`scripts/globals/besieged.lua` and its NPCs) was not touched.
Two grep hits outside `scripts/quests/` were false positives and were left alone:
`scripts/globals/abyssea.lua:1092` and `scripts/globals/domain_invasion.lua:22`
are unrelated prose, not quest stubs.

## Why the stubs are dangerous

`quest:progressEvent` runs at `Action.Priority.Progress = 1000`, while a
mission's `mission:event` runs at `Priority.Event = 100`. A stub whose `check`
is only `status == xi.questStatus.QUEST_AVAILABLE` therefore wins every
interaction with its NPC and suppresses the mission handler. If the hand-picked
event ID also collides with a zone cutscene, the player gets teleported — that
was the An Imperial Heist / Mhaura ferry bug.

## Verification method

CSIDs were checked against the decoded client DAT dumps, not guessed:

```
xi-dat events <zone>          # every entity -> csid in a zone
xi-dat npc <zone> <entity>    # csids owned by one NPC (entity_id == LSB npc id)
xi-dat csid <zone> <csid>     # event program + owning entity
xi-dat dialog <zone> <a-b>    # dialog table
xi-dat search <zone> <text>   # find dialog by text
```

The dump was validated against the repo three independent ways before being
trusted:

- Whitegate zone-global actor `0x7FFFFFF0` owns csids 200 and 203 — exactly the
  two ferry warps in `scripts/zones/Aht_Urhgan_Whitegate/Zone.lua` `onEventFinish`.
- Southern San d'Oria csid 944 resolves to owner `0x010E6053`, which is Faulpie
  (npc_list 17719379, zone 230 index 83) — matching `missions/asa/03`.
- The Whitegate promotion series 5000..5086 lines up one-to-one with the nine
  implemented `Promotion_*.lua` quests.

DAT coverage was complete: 0 of the referenced zones lacked an event table.

## Results

| Disposition | Count |
|---|---|
| RESTORED-UPSTREAM | 4 |
| REBUILT-RETAIL | 1 |
| DELETED-NEEDS-IMPL (Odin/Mythic arc) | 6 |
| **PENDING REBUILD** (stub still in tree, proven broken) | 88 |
| **Total** | **99** |

> ### Status: incomplete — 88 quests still need rebuilding
>
> An earlier pass deleted 61 of these (58 with nonexistent CSIDs + 3 Faulpie).
> **That was wrong and has been reverted.** Proving a stub's invented CSID does
> not exist proves the *stub* is broken; it does not prove the *quest* cannot be
> built. Disposition rule 2 (research retail and rebuild) was never attempted on
> any of those 61 — rule 3 (delete) was applied straight away.
>
> Counter-example that settles it: `Totoroons_Treasure_Hunt.lua` was deleted as
> "unbuildable", but Nashmau dialog **11248-11254** is plainly its offer, ending
> `[11253] Got your attention? ${selection-lines} Indeed you do. / Not
> interested.`, and Totoroon (`0x01035050`, npc 16994384) owns only **11** csids
> (246-252, 281, 303, 304) — a small candidate set with a confirming dialog
> anchor.
>
> All 61 are restored. The only quests still deleted are the 6 Odin/Mythic ones,
> which have a genuine hard blocker (no Odin Prime battlefield exists at all).
>
> **Superseded numbers:** the CSID validity check in this file is *zone-level*.
> `CSID_PROBE_WORKSHEET.md` redoes it at *entity* level, which is the correct
> granularity — an id can exist in a zone but belong to a different NPC. At entity
> level **103 of 117** stub NPC-bindings fire an event the bound NPC does not own,
> and 8 NPCs own exactly one csid so their correct id is already determined.
>
> **These 88 stubs are live and dangerous in the meantime** — bare-check stubs
> win their NPC at priority 1000. See the two tables below.

---

## RESTORED-UPSTREAM (4)

Restored verbatim with `git checkout upstream/base -- <path>`. Every symbol they
reference was confirmed to resolve on our older base (merge-base 2026-02-03):
`xi.wotg.helpers.checkMemoryFragments` (`scripts/missions/wotg/helpers.lua:110`),
`xi.battlefield.id.MOMENT_OF_TRUTH` (`scripts/globals/battlefield.lua:335`),
`xi.ki.LARGE_MEMORY_FRAGMENT4`, `xi.ki.RED_OIL`, and all quest/mission ids in
`scripts/globals/quests.lua` / `missions.lua`. `lua_stylecheck.py` is clean on all
four and `lua_binding_usage.py` exits 0. **No adaptation was needed.**

- `scripts/quests/ahtUrhgan/Moment_of_Truth.lua`
- `scripts/quests/crystalWar/Her_Memories_Azure_Footfalls.lua`
- `scripts/quests/jeuno/Unlisted_Qualities.lua`
- `scripts/quests/otherAreas/Behind_the_Smile.lua`

> Flag: `Moment_of_Truth.lua` gates on the battlefield win
> `xi.battlefield.id.MOMENT_OF_TRUTH` (1155). `bcnm_records` has row
> `(1155, 67, 'moment_of_truth')` but there is **no battlefield script** for it,
> so the quest will correctly stall at the BCNM step rather than complete. That
> is retail-faithful-but-unfinishable, and strictly better than self-completing.

## REBUILT-RETAIL (1)

### `scripts/quests/ahtUrhgan/Promotion_Captain.lua` — CSID 5086

The only source of `xi.ki.CAPTAIN_WILDCAT_BADGE`, which gates An Imperial Heist
and the whole Mythic path.

Retail (bg-wiki "Promotion: Captain"): all 50 Assaults + Aht Urhgan Mission 48
(Eternal Mercenary) + Promotion: First Lieutenant. Talk to Abquhbah, choose
`<Knead>` 30x. Reward: Captain Wildcat badge + Captain title.

**CSID decoded by elimination over a closed series, then confirmed by dialog:**

- `xi-dat events 50` — the Whitegate promotion range is a closed run
  **5000..5086**. The nine sibling `Promotion_*.lua` quests already consume every
  id through 5085, and Captain was the only unimplemented promotion, leaving
  5086 as the sole unclaimed id.
- `xi-dat search 50 "Knead"` — `[14202] <Knead>...<knead>...`, plus
  `[14212]/[14213]/[14214] How do you proceed? ${selection-lines}` with Knead at
  option 0/1/2 (the prompt order is shuffled per attempt).
- `xi-dat search 50 "massage"` — `[14205] (Your task now is to go into the
  president's office and give her poor, tired muscles the same kind of massage!)`
- 5086 is referenced nowhere else in `scripts/`.

What the repo was missing: nothing. `xi.ki.CAPTAIN_WILDCAT_BADGE` (909),
`xi.title.CAPTAIN` (520), and the `player:hasCompletedAssault(id)` binding
(`src/map/lua/lua_baseentity.h:444`) all already exist. The stub had gated on
`PUPPET_IN_PERIL` and fired invented csid 400; it now gates on assaults 1..50
(51/52 are the Nyzul operations and are correctly excluded), Eternal Mercenary,
and First Lieutenant.

> **Needs in-game verification:** the massage minigame shuffles which option
> index is `<Knead>`. The handler treats reaching `onEventFinish` as success,
> since the client drives retries in-event (dialog 14218/14219). If the event
> instead reports failure via `option`, that branch needs adding after one live
> `!cs 5086` probe.

> **Interaction the owner must decide on:** `An_Imperial_Heist.lua` is still an
> accept-and-complete handler gated on `CAPTAIN_WILDCAT_BADGE`. That badge was
> previously unobtainable, so it was dormant. Rebuilding Promotion: Captain makes
> it reachable. It is outside the 99-file scope (it no longer carries the marker)
> so it was left untouched, but it should be rebuilt or removed before anyone
> reaches Captain rank.

## DELETED — Odin / Mythic arc (6)

See `ODIN_MYTHIC_ARC_TODO.md` for the full retail requirements and the two hard
blockers (no Odin Prime battlefield exists; the six required CSIDs cannot be
resolved statically).

`The_Rider_Cometh` (300), `Unwavering_Resolve` (310), `A_Stygian_Pact` (320),
`Duties_Tasks_and_Deeds` (210), `Forging_a_New_Myth` (220),
`Coming_Full_Circle` (230) — all in `scripts/quests/ahtUrhgan/`.

All three Whitegate ones hijacked **Nashmeira**, who is shared with the rest of
the arc. None of the six event IDs were decoded.

## PENDING REBUILD — Faulpie NPC hijack (3) — RESTORED, still broken

`scripts/quests/otherAreas/A_Generous_General.lua` (720),
`An_Affable_Adamantking.lua` (710), `An_Understanding_Overlord.lua` (700).

All three were bare-check and all three bound **Faulpie** in Southern San d'Oria,
who is required by `missions/asa/03_That_Which_Curdles_Blood.lua`
(`mission:progressEvent(944, ...)`). Both sides run at priority 1000, so the
resolution was ambiguous and a bare-check quest could preempt the mission.

Proof the stubs were broken regardless:

- Faulpie (`0x010E6053`) really owns csids 648, 649, 760-765, 770-775, 914, 944,
  3558-3592 (`xi-dat npc 230 17719379`).
- **710 and 720 do not exist anywhere in zone 230.**
- 700 exists but belongs to `0x010E60F0/F3/F6` — not Faulpie.

Restored pending rebuild; the hijack is therefore still live. They are also wrong about the quest itself: per bg-wiki, "A Generous General?"
starts at **Gu'Zho Thunderblade in Oldton Movalpolos**, not Faulpie. Faulpie is a
middle step (trade Buffalo Hide + Sheep Leather + 10,000 gil, wait a game day,
then a Leathercraft-75 synth), and the quest is once per Conquest Tally.
Rebuilding needs live CSID decoding.

Priority when rebuilding: high. Faulpie is shared with `missions/asa/03`.

# Stub removal manifest

## PENDING REBUILD — every CSID the file fired is absent from the target zone's DAT event table (58)

All restored. Each is a live accept-and-complete stub firing a nonexistent event,
so the NPC currently does nothing when triggered. Each needs BG-wiki retail
requirements plus a real CSID (narrow offline against the owning entity's csid
list + a dialog-text anchor, then confirm with a live `!cs` probe).

| Quest | CSIDs fired (none exist) |
|---|---|
| `scripts/quests/ahtUrhgan/Five_Seconds_of_Fame.lua` | [150] |
| `scripts/quests/ahtUrhgan/Royal_Painter_Escort.lua` | [510] |
| `scripts/quests/ahtUrhgan/Scouting_the_Ashu_Talif.lua` | [500] |
| `scripts/quests/ahtUrhgan/Targeting_the_Captain.lua` | [520] |
| `scripts/quests/ahtUrhgan/Totoroons_Treasure_Hunt.lua` | [130] |
| `scripts/quests/bastok/Fully_Mental_Alchemist.lua` | [900, 901] |
| `scripts/quests/bastok/The_Wondrous_Whatchamacallit.lua` | [800, 801] |
| `scripts/quests/crystalWar/A_Cait_Calls.lua` | [1440] |
| `scripts/quests/crystalWar/A_Farewell_to_Felines.lua` | [1510] |
| `scripts/quests/crystalWar/A_Feast_for_Gnats.lua` | [1050] |
| `scripts/quests/crystalWar/A_Forbidden_Reunion.lua` | [1340] |
| `scripts/quests/crystalWar/A_Jewelers_Lament.lua` | [1100] |
| `scripts/quests/crystalWar/A_Manifest_Problem.lua` | [1230] |
| `scripts/quests/crystalWar/A_New_Menace.lua` | [1470] |
| `scripts/quests/crystalWar/A_World_in_Flux.lua` | [1490] |
| `scripts/quests/crystalWar/Ad_Infinitum.lua` | [1580] |
| `scripts/quests/crystalWar/At_Journeys_End.lua` | [1210] |
| `scripts/quests/crystalWar/Battle_on_a_New_Front.lua` | [1420] |
| `scripts/quests/crystalWar/Beast_from_the_East.lua` | [1240] |
| `scripts/quests/crystalWar/Beneath_the_Mask.lua` | [1110] |
| `scripts/quests/crystalWar/Bonds_of_Mythril.lua` | [1190] |
| `scripts/quests/crystalWar/Brace_for_the_Unknown.lua` | [1540] |
| `scripts/quests/crystalWar/Burden_of_Suspicion.lua` | [1220] |
| `scripts/quests/crystalWar/Champion_of_the_Dawn.lua` | [1320] |
| `scripts/quests/crystalWar/Crystal_Guardian.lua` | [1560] |
| `scripts/quests/crystalWar/Drafted_by_the_Duchy.lua` | [1410] |
| `scripts/quests/crystalWar/Endings_and_Beginnings.lua` | [1570] |
| `scripts/quests/crystalWar/Fire_in_the_Hole.lua` | [1030] |
| `scripts/quests/crystalWar/Glimmer_of_Hope.lua` | [1530] |
| `scripts/quests/crystalWar/Guardian_of_the_Void.lua` | [1400] |
| `scripts/quests/crystalWar/Healing_Herbs.lua` | [1000] |
| `scripts/quests/crystalWar/Her_Memories_Verdure_Footfalls.lua` | [1310] |
| `scripts/quests/crystalWar/Honor_Under_Fire.lua` | [1070] |
| `scripts/quests/crystalWar/Howl_from_the_Heavens.lua` | [1140] |
| `scripts/quests/crystalWar/Manifest_Destiny.lua` | [1200] |
| `scripts/quests/crystalWar/No_Rest_for_the_Weary.lua` | [1480] |
| `scripts/quests/crystalWar/Provenance.lua` | [1550] |
| `scripts/quests/crystalWar/Quelling_the_Storm.lua` | [1060] |
| `scripts/quests/crystalWar/Redrafted_by_the_Duchy.lua` | [1460] |
| `scripts/quests/crystalWar/Sins_of_the_Mothers.lua` | [1130] |
| `scripts/quests/crystalWar/Son_and_Father.lua` | [1170] |
| `scripts/quests/crystalWar/Storm_on_the_Horizon.lua` | [1020] |
| `scripts/quests/crystalWar/Succor_to_the_Sidhe.lua` | [1150] |
| `scripts/quests/crystalWar/The_Dawn_Also_Rises.lua` | [1330] |
| `scripts/quests/crystalWar/The_Forbidden_Path.lua` | [1090] |
| `scripts/quests/crystalWar/The_Long_March_North.lua` | [1080] |
| `scripts/quests/crystalWar/The_Swarm.lua` | [1010] |
| `scripts/quests/crystalWar/The_Truth_Is_Out_There.lua` | [1450] |
| `scripts/quests/crystalWar/The_Truth_Lies_Hid.lua` | [1180] |
| `scripts/quests/crystalWar/The_Young_and_the_Threadless.lua` | [1160] |
| `scripts/quests/crystalWar/Third_Tour_of_Duchy.lua` | [1520] |
| `scripts/quests/crystalWar/Voidwalker_Op_126.lua` | [1430] |
| `scripts/quests/crystalWar/What_Price_Loyalty.lua` | [1120] |
| `scripts/quests/crystalWar/When_One_Man_Is_Not_Enough.lua` | [1040] |
| `scripts/quests/jeuno/Chameleon_Capers.lua` | [10035] |
| `scripts/quests/otherAreas/Survival_of_the_Wisest.lua` | [200] |
| `scripts/quests/outlands/The_Search_for_Goldmane.lua` | [400, 401] |
| `scripts/quests/windurst/A_Discerning_Eye.lua` | [240, 241] |

## KEPT — needs owner review (27)

These fire CSIDs that **do exist** in the target zone, so deleting them blind
would risk removing a quest whose event IDs are actually correct. But they are
still accept-and-complete stubs, and an existing-but-wrong CSID is the more
dangerous failure mode (it plays a real cutscene). Each needs a live `!cs` probe
to confirm the CSID renders the right scene, then a rebuild of the retail flow.

`BARE` = `check` is only `status == QUEST_AVAILABLE`, so it wins every
interaction with that NPC. Those should be triaged first.

| Quest | Zone | CSIDs (all real) | NPCs | Bare check |
|---|---|---|---|---|
| `Finding_Faults.lua` | AHT_URHGAN_WHITEGATE | 110 | Hishahma | **BARE** |
| `Get_the_Picture.lua` | AHT_URHGAN_WHITEGATE | 100 | Balakaf | **BARE** |
| `The_Art_of_War.lua` | AHT_URHGAN_WHITEGATE | 120 | Hishahma |  |
| `A_Discerning_Eye.lua` | PORT_BASTOK | 140 | Grin | **BARE** |
| `A_Discerning_Eye.lua` | PORT_BASTOK | 141 | Grin | **BARE** |
| `A_Discerning_Eye.lua` | PORT_BASTOK | 140 | Grin | **BARE** |
| `A_Proper_Burial.lua` | BASTOK_MARKETS | 125 | Offa | **BARE** |
| `A_Proper_Burial.lua` | BASTOK_MARKETS_S | 126, 128 | Offa | **BARE** |
| `A_Proper_Burial.lua` | BASTOK_MARKETS | 129, 130, 131 | Offa | **BARE** |
| `All_by_Myself.lua` | BASTOK_MARKETS | 362 | Marin |  |
| `All_by_Myself.lua` | BASTOK_MARKETS | 363 | Marin |  |
| `Bait_and_Switch.lua` | METALWORKS | 401, 402 | Salim |  |
| `Escort_for_Hire.lua` | PORT_BASTOK | 45 | Trilok |  |
| `Escort_for_Hire.lua` | CRAWLERS_NEST | 52 | Olavia |  |
| `Escort_for_Hire.lua` | PORT_BASTOK | 46 | Trilok |  |
| `Hyper_Active.lua` | METALWORKS | 502 | Raibaht |  |
| `Hyper_Active.lua` | METALWORKS | 503 | Raibaht |  |
| `Return_of_the_Depths.lua` | METALWORKS | 502 | Ayame |  |
| `Return_of_the_Depths.lua` | LOWER_JEUNO | 300, 302 | Muckvix |  |
| `Return_of_the_Depths.lua` | KAZHAM | 400 | Magriffon |  |
| `Return_of_the_Depths.lua` | OLDTON_MOVALPOLOS | 200 | Tarnotik |  |
| `The_Naming_Game.lua` | METALWORKS | 504 | Raibaht |  |
| `Between_a_Rock_and_Rift.lua` | WINDURST_WATERS_S | 1500 | Lehko_Habhoka |  |
| `A_Furious_Finale.lua` | UPPER_JEUNO | 10123, 10124 | Laila |  |
| `A_Reputation_in_Ruins.lua` | UPPER_JEUNO | 10027 | Migliorozz |  |
| `A_Reputation_in_Ruins.lua` | UPPER_JEUNO | 10028 | Migliorozz |  |
| `A_Trial_in_Tandem.lua` | UPPER_JEUNO | 10044 | Luto_Mewrilah |  |
| `A_Trial_in_Tandem.lua` | RULUDE_GARDENS | 10045 | Magian_Moogle |  |
| `Girl_in_the_Looking_Glass.lua` | UPPER_JEUNO | 10037 | Luto_Mewrilah |  |
| `The_Miraculous_Dale.lua` | LOWER_JEUNO | 10079 | Rakuru-Rakoru |  |
| `Fishermans_Heart.lua` | MHAURA | 100 | Katsunaga | **BARE** |
| `Picture_Perfect.lua` | PORT_BASTOK | 443 | Clarion_Star | **BARE** |
| `The_Big_One.lua` | TAVNAZIAN_SAFEHOLD | 300 | Travonce | **BARE** |
| `The_Big_One.lua` | TAVNAZIAN_SAFEHOLD | 301 | Travonce | **BARE** |
| `A_Discerning_Eye.lua` | KAZHAM | 200 | Swift | **BARE** |
| `A_Discerning_Eye.lua` | KAZHAM | 201 | Swift | **BARE** |
| `A_Discerning_Eye.lua` | KAZHAM | 200 | Swift | **BARE** |
| `The_Fireblom_Tree.lua` | KAZHAM | 100 | Soun_Abralah |  |
| `The_Fireblom_Tree.lua` | KAZHAM | 101 | Soun_Abralah |  |
| `Escort_for_Hire.lua` | NORTHERN_SAN_DORIA | 722 | Rondipur |  |
| `Escort_for_Hire.lua` | THE_ELDIEME_NECROPOLIS | 52 | Cannau |  |
| `Escort_for_Hire.lua` | NORTHERN_SAN_DORIA | 723 | Rondipur |  |
| `Babban_Ny_Mheillea.lua` | WINDURST_WATERS | 989 | Khoto_Rokkorah | **BARE** |
| `Babban_Ny_Mheillea.lua` | WINDURST_WATERS | 990 | Khoto_Rokkorah | **BARE** |
| `Escort_for_Hire.lua` | PORT_WINDURST | 10019 | Dehn_Harzhapan |  |
| `Escort_for_Hire.lua` | GARLAIGE_CITADEL | 61 | Wanzo-Unzozo |  |
| `Escort_for_Hire.lua` | PORT_WINDURST | 10020 | Dehn_Harzhapan |  |
| `Heaven_Cent.lua` | WINDURST_WATERS | 284 | Ropunono | **BARE** |
| `Heaven_Cent.lua` | WINDURST_WATERS | 285 | Ropunono | **BARE** |
| `Nothing_Matters.lua` | WINDURST_WALLS | 350 | Koru-Moru |  |
| `Nothing_Matters.lua` | WINDURST_WALLS | 351 | Koru-Moru |  |

---

## How to resume (method that worked)

`Promotion_Captain.lua` is the worked example. The technique, in order:

1. **BG-wiki wikitext** for the real retail flow (`/w/api.php` and `action=raw`
   are Cloudflare-blocked; this form works):
   `curl -sL "https://www.bg-wiki.com/api.php?action=parse&page=PAGE&prop=wikitext&format=json"`
2. **Find the NPC's entity id** in `sql/npc_list.sql`. `entity_id` is the LSB npc
   id: `id - 16777216`, then `// 4096` = zone, remainder = index.
3. **List that entity's real csids**: `xi-dat npc <zone> <entity_id>`. This is
   usually a small set (Totoroon: 11, Faulpie: ~40).
4. **Narrow by elimination** — check which of those csids are already consumed by
   implemented sibling quests/missions on the same NPC (`grep -rn "<csid>" scripts/`).
   For Captain this alone was decisive: the promotion range is a closed run
   5000..5086 and the nine siblings pinned every id but one.
5. **Anchor with dialog text**: `xi-dat search <zone> "<distinctive phrase>"` then
   `xi-dat dialog <zone> <a-b>` to read the block. Quest offers end in
   `${selection-lines}` with accept/decline options.
6. **Confirm live** with `!cs <csid>` on the puppet when steps 4-5 leave more than
   one candidate. One probe per round; wait for an explicit go.

### Two checks that must pass before shipping any rebuilt quest

- **CSID collision**: event ids are per-zone. Check
  `scripts/zones/<Zone>/Zone.lua` `onEventFinish`/`onEventUpdate` — if the zone
  acts on that id (especially `setPos`), the id is wrong. This is what caused the
  Mhaura ferry bug (csid 200 in Whitegate).
- **NPC hijack**: `grep -rn "\['<NpcName>'\]" scripts/` for every other handler on
  that NPC. `quest:progressEvent` is priority 1000 and beats `mission:event` (100).
  Never leave a `check` that is only `status == QUEST_AVAILABLE`.

### Suggested batch order

1. `ahtUrhgan` (5 remaining) and `otherAreas` Faulpie (3) — Faulpie contests
   `missions/asa/03`, highest hijack risk.
2. The bare-check entries in the review table below — they win their NPC
   unconditionally.
3. `crystalWar` (~44) — the largest block, all on a handful of shared NPCs
   (`Lehko_Habhoka` alone is bound by 22 quests).

---

## Voidwatch chain removed (19 quests) — 2026-08-07

Crystal War quest ids **80-98** are a single unbroken Voidwatch chain, confirmed via
bg-wiki Previous/Next links: Guardian of the Void -> Drafted by the Duchy -> Battle
on a New Front -> VW Op. 126 -> A Cait Calls -> The Truth Is Out There -> Redrafted
by the Duchy -> A New Menace -> No Rest for the Weary -> A World in Flux -> Between
a Rock and Rift -> A Farewell to Felines -> Third Tour of Duchy -> Glimmer of Hope
-> Brace for the Unknown -> Provenance -> Crystal Guardian -> Endings and
Beginnings -> Ad Infinitum.

They structurally require Voidwatch (stratum abyssite tiers, planar rifts, Atmacite
Refiners, cruor, the Provenance Watcher), which is **not implemented on this
server** — see `VOIDWATCH_TODO.md`. Every one was an accept-and-complete stub, and
each was wrong three ways over:

1. **Dead CSIDs.** All fired a fabricated id from an arithmetic sequence keyed to
   the quest id (1000, 1010, 1040, 1050 ... 1580). Zone-level disproof: 29 of them
   report "csid N not found in zone 94"; the rest likewise in zones 80/87/89/91/96.
   Only 1500 exists in zone 94 at all, and it resolves to an unrelated 1666-byte
   program on holder `0x0105E30A`.
2. **Wrong NPC and wrong zone.** All 19 bound `Lehko_Habhoka` in Windurst Waters
   [S]. Retail starts are Voidwatch Officers / the Veridical Conflux / the Bulwark
   Gate (Sauromugue Champaign [S], zone 98) / the Audience Chamber (Ru'Lude
   Gardens) / Walk of Echoes / Provenance.
3. **`Ad Infinitum` (98) can never be completed on retail** — bg-wiki states it
   "cannot be 'completed' and will always remain in Current Quests". A stub calling
   `quest:complete()` is wrong in principle, not just in detail.

The `xi.quest.id.crystalWar.*` enum entries are left in place; they are log ids and
are inert without a handler. Rebuild these only once Voidwatch exists.

### Crystal War zone dialog offset: ZERO
Unlike the Adoulin-era dumps, Crystal War zones (80, 87, 89, 91, 94, 96) are **not**
skewed. Controls: `xi-dat search 94 "Rhinostery"` -> `[10941] "This is the
Rhinostery, home to a myriad of research and study..."`; `xi-dat dialog 87 7625` ->
`"I am Wahid, a gem dealer of some repute"`.

---

## Batch: 13 Bastok / San d'Oria / Windurst stubs (nations batch)

All thirteen rebuilt on decoded csids. Method note that unlocked the batch: in these
old-world zones the real cutscene program almost never sits on the NPC. It sits on a
zone-wide holder -- `0x7FFFFFF0`, or a named-but-invisible holder such as `DIRECTOR`
(Metalworks `0x010ED0A3`, Lower Delkfutt's `0x010B8144`) or `blank` (Windurst Waters
`0x010EE116`, Metalworks `0x010ED0C3`/`0x010ED0C4`). The NPC carries a 1-byte `0x00`
stub of the same csid. Repeatedly: **big csid on the holder = the cutscene; the small
sibling csid directly on the NPC = the per-stage idle chat.**

That even/odd chat-vs-cutscene rule is corroborated in-repo, not just from the DATs:
`scripts/zones/Bastok_Markets/npcs/Lamepaue.lua:173-183` (upstream's Past Event
Watcher) maps *A Proper Burial (pt.1)-(pt.6)* to **475, 477, 479, 481, 483, 485** --
exactly the six odd-numbered holder programs derived independently.

### Four live exploits found and fixed

| # | Quest | Mechanism | Impact |
|---|---|---|---|
| 1 | A Discerning Eye | `onEventFinish[141]` in a QUEST_ACCEPTED section. csid 141 is the **airship boarding fee** event, fired by `Port_Bastok/npcs/_6k8.lua:11` (`Door:Departures Exit`), `Rajesh.lua:11` and `Varden.lua:17` | Walking through the boarding door -- the quest's own next step -- completed the quest, paid 500 gil, deleted the KI and bumped the clear counter. Repeatable => unbounded gil + free 5/20/100 titles |
| 2 | Bait and Switch | `check` accepted QUEST_COMPLETED; `onEventFinish[401]` did addQuest -> addItem -> completeQuest in one Salim click | Unlimited Pots of Silent Oil, no minigame, no tally gate |
| 3 | Escort for Hire (San d'Oria) | `onEventFinish[52]`; csid 52 in zone 195 is owned solely by **Ramblix** (17576408) | Talking to Ramblix handed over the Completion certificate, skipping the whole escort |
| 4 | Escort for Hire (Bastok) | `onEventFinish[45]`; csid 45 is fired by `Port_Bastok/npcs/Bodaway.lua:32` | Talking to Bodaway at fame 6 silently started/restarted the quest |

Both Escort files additionally did `addFame(..., 10)` on **every repeat** on top of
`quest.reward.fame = 30`, with no Conquest Tally gate -- unbounded fame plus unbounded
Miratete's Memoirs. bg-wiki lists no fame for either, so none is granted now, and the
tally gate is enforced via the new `scripts/globals/escort.lua`.

### Collision neutralised rather than avoided
A Proper Burial legitimately needs csids 475-485, which Lamepaue replays. Every one of
its handlers is therefore gated on the triggering npc being Offa by entity id
(`isOffa(npc, offaPresent)`), so replaying a cutscene at the Past Event Watcher cannot
advance or complete the quest. A repo-wide scan confirms this is the only such
collision in the batch.

### Reward correction: The Naming Game
The previous file's own header asserted "FABRICATED GIL REMOVED ... Neither figure
appears on bg-wiki". **That premise was false.** bg-wiki's Reward field reads verbatim:
`* First time only: {{Icon|Gil|Medium}} 3,600 gil`. The 3,600 first-time-only payment
is retail and has been restored. The 500-per-repeat *was* fabricated and stays removed
(the quest is repeatable, so it was a faucet). Also restored: the ten-clear counter
that unlocks name segment 4.

Other reward fixes: A Proper Burial granted the **Rolanberry twice** (in both
`onEventFinish[129]` and `[128]`); retail grants exactly one and you hand it back.
A Discerning Eye's 500 gil now comes from the **Passenger on the airship**, which is
where retail pays it, not from Grin. `xi.item.WITHERED_ROLANBERRY` (5675) is confirmed
to be bg-wiki's "Withered Berry" -- `item_basic.sql:5454` gives it the sort name
`withered_berry` -- so that was not a fabrication.

### Data added (every id taken from sql/, none guessed)
Item enums: `SHELLING_PIECE` 545, `KEY_RING_BELT` 15880, `PORTAFURNACE` 13078,
`AMPOULE_OF_ASTRAL_MATTER` 2799, `FLAMESTONE` 2793, `FROSTSTONE` 2794, `GALESTONE`
2795, `STORMSTONE` 2797, `TIDESTONE` 2798, and the eight `ORB_OF_*_FEWELL` 2784-2791.
The stubs had hardcoded 545 / 13078 / 2784-2791 as bare locals -- correct numbers,
no enums.

Text ids, each read back out of the DATs first: Metalworks
`SWITCH_DEACTIVATED_OFFSET` 10632 (10632-10640 = "The first...ninth switch has been
deactivated") and `NOISE_FROM_TEMPLE` 10641 -- a block that stops at *ninth*, which
independently corroborates bg-wiki's 10-switch maximum; Lower Delkfutt's
`BLOODTHIRSTY_MONSTER_APPEARED` 7523; Grauberg [S] `GOLD_GRAINS_RETRIEVED` 7939 and
`LEAVE_AREA_LOSE_GOLD_DUST` 7940; Lower Jeuno / Rolanberry Fields [S] / North
Gustaberg [S] `NOTHING_OUT_OF_ORDINARY` 6405; Maze of Shakhrami
`COIN_CONSTELLATION_OFFSET` 7084.

**No NPCs needed adding.** All 44 name bindings across the 13 quests already exist in
`npc_list` with the exact internal names used, and every decoded entity id matches.

### Two corrections to the research report
* There are **three** NPCs named `Titus`, not two -- 17670750 decodes to zone 218
  (Abyssea). Within Bastok Mines the conclusion holds: wire to 17735712 (owns csids
  123/587/588/589), not 17735819 (owns none). Every Fully Mental Alchemist handler is
  gated on 17735712 so it coexists with the existing `Titus.lua` image support.
* Babban Ny Mheillea's three rootprints are **not** free-order. Each one's closing
  narration names the next zone (7992 -> Gustaberg, 7811 -> Meriphataud, 7852 -> "the
  next exciting chapter"), so they form a fixed chain. The stub's "any order" claim
  and its three independent zone-in flags were both wrong.

### API-misuse bug caught before shipping
All by Myself's level-10 restriction was first written with `setLevelCap(10)`.
`setLevelCap` is the **limit-break ceiling** -- every other caller is a LB03-LB10
quest raising it -- so that would have permanently capped the character at level 10.
Corrected to `player:levelRestriction(10)`, cleared with `levelRestriction(0)`, as
`scripts/effects/level_restriction.lua:34` does. (A_Furious_Finale's `setLevelCap(75)`
was checked and is correct -- it genuinely raises the limit break, guarded on
`getLevelCap() == 70`.)

### Wrong entity found: Hyper Active's Cermet Door
Zone 184 has seven Cermet Doors. The quest door is the **unnamed `_543`** (17531159,
at 500.870/19.343/91.976) -- 8.5 units from Orna's spawn (507.288/23.707/97.632), with
Chandraj (17531207) between them -- and it had no script. The **named** `Cermet_Door`
(17531158, at 520.437/13.333/20.025) is the up-warp to Upper Delkfutt's, already
scripted at `Cermet_Door.lua:11` with csid 20; left untouched. Orna (poolid 3055) and
both Fomorian Spears (poolid 1379) are healthy and pop-only.

### Genuinely event-free, not undecoded
Two steps have no csid at all, and this was established rather than assumed: `_543`
owns only the 65535 sentinel, so Orna's pop is a server-side spawn plus system message
7523; and `xi-dat search 245 "altimeter"` returns zero hits while Lower Jeuno's csids
120-131 belong entirely to the separate lamp-lighting quest, so the altimeter find is
a plain key-item grant.

### Still simplified, flagged in-file rather than passed off as retail
* Escort for Hire x2 -- Olavia/Cannau do not path; the three retail routes and the
  (H-8) door switch need waypoint data this repo lacks. The 30-minute limit, the
  cancel path, the one-active and one-per-tally rules and the shared first-clear
  bonus ARE enforced.
* Bait and Switch -- the clue NPCs and four alert NPCs are unwired; their programs are
  three ~20KB blobs on `blank` 0x010ED0C3 (csids 908/909/910) needing param-level
  work. So the switch order must currently be brute-forced. That is safe rather than
  exploitable because the tally gate caps it at one reward per tally either way, and
  the reward paid is the correct one for the item picked.
* All by Myself -- Ken does not path, so the eight position messages and the
  spotted/died failures are absent. csid 150 is one shared program used from three
  call sites whose param split is undecoded.
* Fully Mental Alchemist -- the scoop/wash sub-menu option that corresponds to "Wash
  carefully to extract gold" is undecoded. The 3-11 grain spread, 20-grain threshold
  and progress-loss-on-zoning are faithful; progress lives in a **localVar** so
  "leaving Grauberg [S] loses everything" falls out of the storage choice.
* The Wondrous Whatchamacallit -- the six ??? stone spots and the synergy recipe are
  separate systems and are not wired here.
* The Naming Game -- the four chosen segments are stored, but nothing renders them:
  the airship that carries the name only appears in CoP 5-1 and no entity reads a
  player-chosen name.
* Heaven Cent -- the Rusty Key comes from Wight drops on retail, which needs a
  `mob_droplist` row (a data change outside this file), so the key is not granted here.
* A Proper Burial -- the two-option branch is recorded and both outcomes shown, but
  both follow the same csid chain because only one exists in the dumps.

### Confidence, stated honestly
Pinned by quoted dialog: Grin 295; Trilok 291-294; Rondipur 721-725; Salim 899/900/907
and idle 400; Offa present 475-486 and past 110/128-138; Marin 361-366 and Ken 367-371;
Titus 587-589 and Riverbed 24; Raibaht 866/872/867 and Chandraj 26; Naming Game
869/873/874/870; Hildolf 973-978; Selliste 591-596; Khoto Rokkorah 988-992 and
rootprints 5/114/105; Ropunono 283-297.

Weaker, and marked as such in the files: Naming Game **868** (the offer by
elimination, not by a quoted line); Cannau **51** (proven by ownership, its bytecode
entity reference and a key-item opcode, but her text refs are computed so no line
could be quoted); the Iron Door **41-vs-42** split and the chest csid pairing; the
csid **5-vs-6** split for Olavia; the csid **150** param split.

Needs an in-game probe: csid 295's two-param signature (`fdi0`/`fdi1`) -- passing the
chosen passenger index as param 0 is inferred, so confirm the picture with `!cs 295`.
If it is wrong the quest merely fails to start; it cannot mispay, because the payout
lives on the airship and is gated on the stored target index.

### Note for whoever picks this up next
`scripts/quests/bastok/Synergistic_Pursuits.lua` is **still a stub**, and it is the
prerequisite both Synergistic Support and The Wondrous Whatchamacallit now gate on.
`scripts/quests/sandoria/A_Discerning_Eye.lua` is also still a stub, and zone 223
carries the identical 8-passenger airship layout (0x010DF005-0x010DF00C -> csids
101-108 / 111-118), so the Bastok rebuild ports across directly.

---

## Batch: A Discerning Eye family + Aht Urhgan inert pass

### A Discerning Eye x4 -- unified and rebuilt

The quest exists four times over, once per airship route, and the client data shows
all four are the same design. They are now one shared implementation in
`scripts/globals/discerning_eye.lua`, called by four thin quest files.

**The giver owns exactly ONE csid in every variant**, so there was nothing to
disambiguate -- one program covers offer, picture, re-show, failure and idle:

| Variant | Giver | Entity | Zone/idx | csid | Messages | Program |
|---|---|---|---|---|---|---|
| San d'Oria | Eddy | 17727617 | 232 / 129 | **723** | 8531-8546 | 753 B |
| Bastok | Grin | 17744023 | 236 / 151 | **295** | 8868-8883 | 752 B |
| Windurst | Pygmalion | 17760442 | 240 / 186 | **10019** | 12801-12816 | 753 B |
| Kazham | Swift | 17801340 | 250 / 124 | **10018** | 10677-10692 | 753 B |

Sixteen messages and the same program size in all four. All four givers even share
the npc_list look field `0x00004403...`, i.e. the same model -- an independent
confirmation that they are one NPC role.

**OPTION 0 ACCEPTS -- proven, not assumed.** The accept prompt is the fourth message
of each block and reads identically in all four, with "Gladly." as the FIRST
selection line: Eddy 8534, Pygmalion 12804, Swift 10680, Grin 8871. Every previous
version of these files tested `option == 1`, which is the DECLINE.

Airship side is identical in all four zones -- `xi-dat events <zone>` shows the eight
Passengers each owning exactly two csids, the Nth by ascending entity id owning
100+N (idle) and 110+N (offer and reward):
zone 223 `17690629-17690636`, zone 224 `17694724-17694731`,
zone 225 `17698820-17698827`, zone 226 `17702916-17702923`.
Kazham's csid 111 -> msgs 7076-7086 carries both outcomes twice over: 7078/7079 are
the two wrong-passenger lines, 7080/7081 the two correct ones, 7082 the 500 gil.

The Passengers really are distinguished as bg-wiki describes. Their look strings
differ only in head / hands / legs / feet -- hair-or-hat, gloves, legwear. Bastok and
Windurst share one look set with three head groups, so hands and legs separate them;
San d'Oria and Kazham give all eight a distinct head.

**CRITICAL BUG REMOVED (Kazham).** The outlands stub handled csids 200 and 201, which
in Kazham belong to *The Opo-opo and I*: 200 is fired by
`scripts/zones/Kazham/npcs/Roropp.lua` and 201 by `Popopp.lua`. Because
onEventFinish dispatches zone-wide on csid alone, **running that unrelated quest
drove this one** -- Roropp granted the Dropped item and Popopp completed the quest,
paying 500 gil and counting a title clear. Repeatable, so it was an unbounded gil and
title faucet triggered entirely by another quest.

Other fixes: the San d'Oria stub fired csid 585, which Eddy does not own; the
Windurst file auto-succeeded on merely zoning into the airship; all four invented
`fame = 5` when every bg-wiki Reward field is `*500 gil` and nothing else; and the
San d'Oria stub used the unprefixed charvar `DiscerningEyeClears`, which would have
shared its clear count with any other variant picking the same name. `FLevel` is
empty on the Kazham and San d'Oria pages, so only Bastok (whose page says FLevel 1)
carries a fame gate.

### Aht Urhgan: eight files made deliberately inert

These are NOT deletions. Each keeps its file and all of its research, but sets a
local `questAvailable = false` whose only section returns it, so no section ever
matches, no NPC is claimed at Action.Priority.Progress, and no `onEventFinish` is
registered. Verified: all eight have zero `xi.zone.*` references outside comments.
This satisfies the same rationale as deleting -- no hijack, no stray cutscene --
without discarding the decode work.

**Get the Picture / Five Seconds of Fame** (Balakaf, Whitegate I-5). Balakaf IS the
right giver, but the csids cannot be decoded from our dump and guessing is not
allowed:
* `Get the Picture` fired csid 100, which `xi-dat csid 50 100` shows is owned by the
  **zone-global actor 0x7FFFFFF0** -- a 21-byte program whose only string is
  `6D61696E` = "main", with no text opcode. A system event, not a cutscene. That same
  actor owns csids 200 and 203, the two ferry warps in Whitegate's Zone.lua, i.e. the
  family behind the original An Imperial Heist ferry bug.
* `Five Seconds of Fame` fired csid **150 = the IMPERIAL COIN EXCHANGE**, fired by
  `npcs/Ugrihd.lua:44` as `startEvent(150, rank, badge, points, ...)`. Exchanging
  imperial standing for coins could complete the quest -- and the quest's reward IS
  imperial pieces, so it paid out of the same currency being spent at. `xi-dat csid
  50 150` also reports it "not found", because the exchange is a client-side menu
  with no bytecode: so `progressEvent(150)` was opening the coin window from Balakaf.
* Text-anchor search is empty for every distinctive bg-wiki phrase --
  `search 50 "photopticator"` / `"image recorder"` / `"billowing"` / `"me own eyes"`
  / `"pickpocket"` all 0 hits, the last two quoted verbatim from the First Picture
  description. CONTROL: the same table decodes fine for other content (msg 14503 is
  the Odin briefing; the 5000..5086 promotion series maps 1:1 onto the nine
  implemented `Promotion_*.lua`), so this is missing text, not a broken dump.
* NOT blocked on data: `xi.ki.IMAGE_RECORDER` = 773 and `xi.ki.PHOTOPTICATOR` = 892
  both exist, and six of the scene NPCs are present in zone 50 -- Zyfhil 16982124,
  Talwahn 16982127, Ulamaal 16982274, Qutiba 16982273, Ratihb 16982264,
  Zubyahn 16982146. Unblock path is a live `!cs` probe on Balakaf.

**The Odin and Mythic chains** -- An Imperial Heist, Duties Tasks and Deeds, Forging
a New Myth, Coming Full Circle, Unwavering Resolve, A Stygian Pact. Details and the
corrected status are in `ODIN_MYTHIC_ARC_TODO.md`, whose header wrongly claimed all
six were deleted; they had come back with the 61-file rollback. Highlights:
* **Forging a New Myth was a live cross-fire.** csid 220 in zone 50 has three owners
  and the real 95-byte program is **Zarfhid's** (16982033, bytecode referencing work
  vars `"tlk2"` and `idl0`), with 1-byte stubs on `_1ec` 'Door_1ea' (16982062) and
  16982036. `npcs/Zarfhid.lua:9` fires it unconditionally, so **talking to Zarfhid
  began and instantly completed Mythic chain quest #3.**
* **An Imperial Heist was activated by our own earlier work.** Its onTrigger printed
  a line then ran `quest:begin` immediately followed by `quest:complete`, so one
  click on Naja Salaheem completed it with no event and no prompt. It was dormant
  only while {KI} Captain Wildcat badge was unobtainable -- and rebuilding
  `Promotion_Captain.lua` made the badge obtainable. It did not block Naja (returning
  no action falls through to her own script, so Assault registration still worked);
  the fault was the silent auto-completion.
* **Rebuilding The Rider Cometh made Unwavering Resolve and A Stygian Pact reachable**,
  which is exactly why their fabricated-csid stubs could no longer be left alone.
* The other four csids are fabrications: `csid 50 310`, `50 320`, `53 210` and
  `53 230` all report "not found in zone".
* Independent of the csids, every zone-50 `Nashmeira` row (16982184, 16982219,
  16982220) has **status 6** -- cutscene-only, not clickable -- so binding her as a
  trigger NPC in Whitegate was wrong anyway.

### Counting note
The stub inventory was being undercounted. The marker comment sometimes wraps across
lines (`Simplified\n-- for 4-player`), which a single-line `grep -l` misses -- that is
why `Coming_Full_Circle.lua` never appeared on any stub list. Count with a pattern
that flattens comment continuations first. Behavioural scans for
`quest:begin` -> `quest:complete` or for a bare `status == QUEST_AVAILABLE` check are
NOT reliable substitutes: many legitimate upstream quests have no prerequisite, and a
genuinely one-step quest legitimately begins and completes in one handler.

---

## Batch: crystalWar -- Beast from the East (30)

Rebuilt with csids resolved to **actual message ids**, not inferred from position.
The method that finally worked on these Crystal War NPCs: `csidmsg.py`'s CLI prints
nothing for zone 80, but importing it and calling `find_msg(blob, entry, data,
targets)` directly against an explicit target message range does resolve them.

Nichais is 17105607 -> zone 80 idx 711, 0x010502C7:

| csid | messages | role |
|---|---|---|
| 83 | 13563-13565 | pre-quest approach |
| **72** | 13566-13589 | **the offer** |
| **74** | 13606-13615 | return after the altar; sets the riddle |
| 75 | 13616-13617 | wrong item -- "I'm not sure I see the relevance" |
| 76 | 13618-13620 | wrong item -- "a bit too large" |
| 77 | 13621-13622 | wrong item -- a rare tome |
| **78** | 13623-13632 | **the Shell Bug, i.e. the correct trade** |
| 79 / 80 | 13632-13635 | closing scenes |

What pins csid 72 is message **13567**: "Does this talk interest you?
${selection-lines} Immensely, yes. Not in the least, no." -- word for word the
choice bg-wiki names, with "Immensely, yes" FIRST, so **option 0 accepts**.
csid 78 is pinned by 13627, "the shell bug is a parasite which thrives within the
shells of Quadav", answering the riddle in 13609.

**Holder pattern again, twice.** csid 78's program is not on Nichais at all -- it is
on the invisible `blank` holder 0x010502C5 (17105605), two indices before him. And
the Timeworn Altar (17142597, zone 89 idx 837) owns exactly two csids, 17 and 18,
matching the two altar visits, with both real programs on the `blank` holder
0x01059343 (17142595): 17 is 4023 bytes (first cutscene) and 18 is 16194 bytes (the
final cutscene and the award -- by far the larger, consistent with carrying the
reward).

The stub fired csid 1240 from the fabricated arithmetic sequence; `xi-dat csid 80
1240` reports it not found, so Nichais did nothing when triggered. Its
`fameArea = SANDORIA, fame = 30` was invented -- bg-wiki's Fame field is "Wings of
the Goddess" with no numeric value, so none is granted. Its header even carried a
mangled location, "SOUTHERN [S]AN DORIA [S]", from a bad string replace.

All fifteen reward jewels verified present in `scripts/enum/item.lua`, as are
`xi.title.WYRMSWORN_PROTECTOR` (602) and `xi.item.SHELL_BUG` (17397).

**Concurrency bug avoided:** the two random jewels are granted with
`npcUtil.giveItem` rather than by assigning to `quest.reward.item`. `quest` is a
single shared object per quest file, so writing a per-player roll into it would leak
one player's jewels to the next completer.

STILL SIMPLIFIED: csids 75, 76 and 77 are three DISTINCT wrong-item responses and
which item each answers is not decoded. Only the Shell Bug path and one generic
wrong-item reply (75) are wired; 76 and 77 are documented so the ids are not lost.
