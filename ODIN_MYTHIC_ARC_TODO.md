# Odin Arc & Mythic Arc — inert stubs, requirements to build properly

Six `scripts/quests/ahtUrhgan/` quests were deleted rather than left as
"accept + instantly complete" stubs. Each stub bound a real NPC with
`quest:progressEvent(...)` (Action.Priority.Progress = 1000), which outranks
`mission:event` (Priority.Event = 100) and hijacks that NPC for any player whose
`check` passes. The event IDs they fired (300, 310, 320, 210, 220, 230) were
hand-picked, not decoded.

A missing quest is safer than a wrong stub. This file records what each one
actually needs so it can be rebuilt to retail.

## STATUS CORRECTION (supersedes the table below)

These quests are **no longer deleted**. They were restored during the 61-file
rollback of the wrongly-deleted batch, which brought the stubs back too. As of the
2026-08-10 pass all six files EXIST and have been rewritten to be **deliberately
inert**: each sets a local `questAvailable = false` and its only section returns
that, so no section ever matches, no NPC is claimed at Action.Priority.Progress,
and no `onEventFinish` is registered. Verified: all six have zero `xi.zone.*`
references outside comments.

`The Rider Cometh` is the exception — it has been **properly rebuilt**, along with
the Odin Prime battlefield (`scripts/battlefields/Hazhalm_Testing_Grounds/rider_cometh.lua`),
so blocker #1 in the section further down is now resolved.

Two consequences worth knowing:

* Because The Rider Cometh now works, **Unwavering Resolve and A Stygian Pact became
  genuinely reachable**. That is precisely why their fabricated-csid stubs could no
  longer be left in place.
* **An Imperial Heist has been made inert too**, and it was not previously on any
  stub list. Its `onTrigger` on Naja Salaheem printed a line and then ran
  `quest:begin` immediately followed by `quest:complete`, so a single click
  completed it with no event and no prompt. It was dormant only while
  {KI} Captain Wildcat badge was unobtainable — and rebuilding `Promotion_Captain.lua`
  made that badge obtainable, activating it. (It did not block Naja: returning no
  action lets the framework fall through to her own script, so Assault registration
  still worked. The fault was the silent auto-completion.)

One of the six was an active cross-fire, not merely a dead id:

* **Forging a New Myth handled `onEventFinish[220]` in Whitegate.** csid 220 there
  has three owners and the real 95-byte program belongs to **Zarfhid (16982033)** —
  its bytecode references work vars `746C6B32` = "tlk2" and `idl0` — with 1-byte
  stubs on `_1ec` 'Door_1ea' (16982062) and 16982036.
  `scripts/zones/Aht_Urhgan_Whitegate/npcs/Zarfhid.lua:9` fires it unconditionally
  on trigger. Since onEventFinish dispatches zone-wide on csid alone, **talking to
  Zarfhid began and instantly completed Mythic chain quest #3** for anyone who had
  finished Duties, Tasks, and Deeds.

The other four stub csids are pure fabrications and render nothing:
`xi-dat csid 50 310`, `csid 50 320`, `csid 53 210` and `csid 53 230` all report
"not found in zone". Note also that every zone-50 `Nashmeira` row (16982184,
16982219, 16982220) has **status 6** — cutscene-only, not clickable — so binding her
as a trigger NPC in Whitegate was wrong independently of the csid.

## Deleted (HISTORICAL — see the correction above; none of these are deleted now)

| Quest | ID | Stub NPC | Invented csid |
|---|---|---|---|
| The Rider Cometh | 76 | Nashmeira (Whitegate) | 300 |
| Unwavering Resolve | 77 | Nashmeira (Whitegate) | 310 |
| A Stygian Pact | 78 | Nashmeira (Whitegate) | 320 |
| Duties, Tasks, and Deeds | 71 | Paparoon (Nashmau) | 210 |
| Forging a New Myth | 72 | Nashmeira (Whitegate) | 220 |
| Coming Full Circle | 73 | Paparoon (Nashmau) | 230 |

`xi.quest.id.ahtUrhgan.*` entries in `scripts/globals/quests.lua` were left in
place — they are just log IDs and are harmless without a handler.
`scrapeSubdir("scripts/quests")` (`src/map/lua/luautils.cpp:585`) loads quests by
directory scan, so deleting the file fully unregisters the handler.

## The Rider Cometh — retail flow (bg-wiki)

Prereq: Aht Urhgan Mission 48 (Eternal Mercenary).
Reward: Imperial Gold Piece + choice of Pact with Odin / Aesir Torque / Aesir
Mantle / Aesir Ear Pendant / 10,000 gil; unlocks Stygian Pact phantom gem.

1. Enter Walahra Temple, Aht Urhgan Whitegate (J/K-8) — cutscene.
   Walahra Temple is **not** a separate zone; it is cuboid trigger area **4** in
   `scripts/zones/Aht_Urhgan_Whitegate/Zone.lua:11`.
2. Speak to **Yoyoroon** in Nashmau (G-6, upper stalls) — grants
   {KI} Message from Yoyoroon. Not Yuyuroon (lower level, directly in front).
   Blocked while the player is Blue Mage.
3. Obtain a Timeworn Talisman from Ephramadian Shades (Arrapago Reef /
   Caedarva Mire).
4. Trade the Talisman + Sutlac and/or Irmik Helvasi to Yoyoroon. Appraisal can
   fail; trading both foods gives the best odds. `+1` foods are rejected.
5. On success, zone out and back, speak to Yoyoroon again —
   {KI} Talisman of the rebel gods.
6. Enter Walahra Temple again for a cutscene — {KI} Talisman key. If no
   cutscene fires, inspect **Imperial Whitegate** (L-8/9) instead.
7. Examine the Entry Gate in Hazhalm Testing Grounds — cutscene, then examine
   again to enter the BCNM vs **Odin Prime** (spawns up to 3 Odin Images, casts
   Dispelga, uses Zantetsuken at low HP; Trust magic is disabled).
8. Reward-choice cutscene after the win.
9. Examine Imperial Whitegate to complete. If the Trust: Nashmeira cutscene
   fires instead, finish it and re-examine.

### What the repo already has

- Key items all exist: `TALISMAN_OF_THE_REBEL_GODS` (1249),
  `MESSAGE_FROM_YOYOROON` (1250), `TALISMAN_KEY` (1263),
  `STYGIAN_PACT_PHANTOM_GEM` (3185) — `scripts/enum/key_item.lua`.
- `Odin_Prime` mob pool 6961, `mob_groups` (87, zone 78), spawn point
  17097298, and `mob_resistances` 'Avatar-Odin_Prime' all exist.
- `bcnm_records` row `(1184, 78, 'rider_cometh', ...)` exists.
- `scripts/zones/Nashmau/npcs/Yoyoroon.lua` exists but is **shop-only**
  (`xi.shop.general`); it has no quest handler.

### What is missing — the two hard blockers

1. **No Odin Prime battlefield.** There is no
   `scripts/battlefields/Hazhalm_Testing_Grounds/` directory at all, no
   `xi.battlefield.id` entry for the fight, and no Odin Image mob. The
   `bcnm_records` row is only a fastest-clear record; it does not define a
   battlefield. `scripts/zones/Hazhalm_Testing_Grounds/npcs/_260.lua` carries an
   explicit `-- TODO: Entry point for The Rider Cometh`, and
   `Zone.lua` has `-- TODO: Will likely conflict with The Rider Cometh` on the
   Einherjar eject path. Upstream LSB (~3000 commits ahead of us) has not
   implemented this either.
2. ~~**CSIDs cannot be decoded statically.**~~ **SOLVED — the Nashmau half is
   decoded.** `UpdateExtractor/xidat/csidmsg.py` resolves csid -> dialog offline.
   Yoyoroon's events live on proxy entity `0x01035062` (Nashmau, 17750B blob):

   | csid | messages | what it is |
   |---|---|---|
   | **318** | 11818-11840 | first Yoyoroon talk. 11839 'Along with the talisman, perhaps you could bring him a treat from his favorite teahouse'; 11840 'Thank you, friend. Be safe in your travels.' => grants {KI} Message from Yoyoroon |
   | **327** | 11847-11867 + 11868 | the talisman + food trade and appraisal. 11868 is the menu `Give a treat to Yoyoroon? / <item1> / <item2> / Both.` — matches bg-wiki's 'or even both'. 11860-11862 = appraisal success |
   | **324** | 11847-11854 + 11868 | shorter trade branch |
   | **320** | 11868-11873 | 'Ah, welcome back, friend. This is for you. One [keyitem], restored as closely as possible to its original glory.' => grants {KI} Talisman of the rebel gods |
   | **323** | 11869, 11873 | condensed handover |
   | **321** | 11874-11885 | later branch |
   | **326** | 11868 | trade menu alone |

   Still to decode the same way: the Walahra Temple cutscenes (Whitegate zone 50,
   cuboid trigger area 4) and the Hazhalm entry-gate event (zone 78).

   Old note kept for context — this was wrong: Six events are needed (Walahra
   Temple ×2, Yoyoroon ×3, Hazhalm entry gate, reward CS). `xidat/eventvm.py`
   desyncs on the Nashmau event table — 38 of 370 programs parse clean and only
   12 message sites resolve across the whole zone — so `csid -> message` cannot
   be resolved offline. `xidat/README.md` documents this as unimplemented.
   The confirmed Yoyoroon dialog block is Nashmau **11820-11846**
   (`xi-dat search 53 talisman` -> 11839; `xi-dat dialog 53 11820-11846`), and
   Yoyoroon's own entity `0x01035028` (16994344, Nashmau index 40) owns csids
   **3, 16, 18, 20, 277** (`xi-dat npc 53 16994344`) — but which of those
   renders 11820-11846 needs a live `!cs` probe on a puppet client.

Recommended path: decode the six csids live via the Windower bridge
(`!cs <csid>` and read back the rendered dialog against `xi-dat dialog`), then
build the Odin Prime battlefield, then write the quest.

## Unwavering Resolve / A Stygian Pact

Both gate on the prior Odin-arc quest, so they are unreachable until The Rider
Cometh exists. Rebuild them together with it.

## Mythic arc — Duties, Tasks, and Deeds / Forging a New Myth / Coming Full Circle

Chain order: An Imperial Heist -> Duties, Tasks, and Deeds -> Forging a New
Myth -> Coming Full Circle.

- **Duties, Tasks, and Deeds** (Paparoon, Nashmau G-7): 30,000 Alexandrite or
  Cat's Eye, 150,000 Nyzul tokens, and re-completion of all 50 Assaults.
- **Forging a New Myth** (Nashmeira): collect Tinnin's Fang, Sarameya's Hide and
  Tyger's Tail, then fight Zahak and Balrahn.
- **Coming Full Circle**: trade the statless Mythic plus a relief shard at the
  Caedarva Mire tombstone for the finished lv75 Mythic Weapon.

None of the boss fights or the Mythic reward pipeline exist. These need the same
live csid decoding plus substantial new content.

> **Interaction to be aware of:** `An_Imperial_Heist.lua` is still an
> accept-and-complete handler gated on `xi.ki.CAPTAIN_WILDCAT_BADGE`. That badge
> was previously unobtainable, so the handler was dormant. Rebuilding
> `Promotion_Captain.lua` makes the badge obtainable, which makes An Imperial
> Heist live. Decide whether to rebuild or remove it before players reach
> Captain rank.
