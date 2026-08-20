# Quest backlog — live ledger

Single source of truth for quest work. Supersedes `QUEST_COVERAGE.md`,
`STUB_REMOVAL_MANIFEST.md`, `CSID_PROBE_WORKSHEET.md` and `FELLOW_CHAIN_TODO.md`
(all deleted; recoverable from git history if ever needed).

## Status

**The bg-wiki audit is complete: 1069 / 1069.**

The quest list is derived from **147 bg-wiki categories**, not from
`scripts/globals/quests.lua`. That matters: 133 bg-wiki titles (12%) have no
matching enum name at all — Scaredy-Cats, F.A.I.L.ure Is Not an Option,
Not-So-Clean Bill, The Arciela Directive, Rune Fencer Relic Armor and others. An
enum-anchored audit is structurally blind to those. Master list:
`tools/coverage/data/retail_quests_master.json`.

| Verdict | Approx. | Meaning |
|---|---:|---|
| CORRECT | 490 | matches the bg-wiki walkthrough |
| FLOW-WRONG | 135 | has code, diverges from retail |
| STUB | 60 | fabricated — invented dialog, or csids the NPC does not own |
| MISSING | 380 | **no code anywhere** |

Roughly 60 quests have been repaired so far, plus 9 double-reward sites, 5 live
exploits, and two complete endgame boss fights (Hades, Shinryu).

## Outstanding, by tractability

### 1. FLOW-WRONG — best return per unit effort (~95 open)

Small, well-evidenced, mostly one-liners. Recurring shapes:

- Fame-level gates off by one, or pointed at the wrong `fameArea`.
- Titles bg-wiki lists that are never granted (the enum exists; nothing awards it).
- Non-retail gates someone added — extra fame/level requirements bg-wiki omits.
- Timer windows: Community Service (18–23 vs 18:03–21:00), Scattered Into Shadow
  (900s vs 3 min), To Catch a Falling Star (0:00–3:59 vs 0:00–3:00).
- Dead handlers — `onEventFinish` entries nothing ever starts.
- Reward-fidelity gaps: Dormant Powers Dislodged (10 of 14 items), An Explorer's
  Footsteps (no 15-tablet bonus), Peddlestox (flat 4,000 gil / 4 items vs
  4,000–5,000 / 3–5), Hurr the Betrayer (50/50 roll vs always gold).
- Missing chain prerequisites and game-day / re-zone gates.

Named and still open: A Furious Finale (no trade/teleport, no 25% HP yield),
Mysteries of Beadeaux I (no option check), Save the Clock Tower (prereq mismatch),
Save My Sister (dead handler 172), Loussaire (no game-day gate, requires SCH every
piece), Orlando's Antiques + Way of the Cook (non-retail fame gates), Tango with a
Tracker + In the Name of Science (wrong mission prereq), Inside the Belly (fishing
re-checked after flagging), Fisherman's Heart (csid 193 fired with no params),
It's Raining Mannequins (60s timer where retail requires zoning), Beneath the Mask
and Her Memories: Of Malign Maladies (missing zone/day gates), Evil at the Inlet
(Bronze vs Brass ribbon, extra level 30), Message on the Wind (Windtalker granted
unconditionally instead of by option), Seeing Blood-red (invented `fame = 40`
SANDORIA).

### 2. Fabricated csids that are decodable now (~15)

Same method that fixed Mithran Delicacies, Son and Father and The Young and the
Threadless: `xi-dat csid <zone> <n>` to find the real owner, `xi-dat dialog` to
confirm by text. **Never ship an id without doing this.**

- A Generous General (720), An Affable Adamantking (710), An Understanding
  Overlord (700) — none owned by Faulpie.
- The Search for Goldmane — Rabao 400/401.
- The Big One — 300/301 belong to Liphatte, not Travonce.
- Survival of the Wisest — csid 200 absent from zone 90.
- Fei'Yin Strange Apparatus — csids 25/27 absent from the dump.
- The nine Crystal War accept-and-complete stubs (1010/1040/1080/1090/1130/1140/
  1150/1200/1330) — none exist in their target zones.

Decoded reference: `DECODED_CSIDS.md`.

### 3. MISSING — subsystem builds, not repair (~380)

The NPCs exist and render; the *quests* were never written. Do not report these as
"NPC missing" — LSB's NPC data has been complete every single time it was checked.

| Block | Count | Blocker |
|---|---:|---|
| Abyssea zone quests | 96 | no quest-giver scripts in any `Abyssea-*/npcs/` |
| Adoulin | 38 | zone `npcs/` dirs hold only utility NPCs |
| Crystal War Voidwatch | 19 | see `VOIDWATCH_TODO.md` |
| Kupofried's Moogle Magic | 14 | empyrean WS unlocks; Kupofried 17339259 unscripted |
| Mog Garden | 11 | `mog_garden.lua` is a custom simplified system |
| Martello Refuel/Replenish | 10 | `martello.lua` states these are not implemented |
| Bastion Ward Warden | 6 | `bastion.lua` is a flat cruor stipend |
| RoE (Duberasson / Nantoto / Anastase) | 20 | see `ROE_CAPTURE.md` |
| Odin & Mythic arcs | 6 | see `ODIN_MYTHIC_ARC_TODO.md` |

### 4. Needs data we do not have

- **Dominion Ops**: the Empyrean +1 seal drop (bg-wiki gives no rate or item list)
  and the 600–4950 XP scaling, which depends on the sphere-of-influence formula
  `dominion.lua`'s own TODO admits is unresearched. Currently a flat 1000 XP.
- **The Wyrm God**: all 15 Shinryu mobskills are now implemented and the mob data
  is wired, but the fight still needs a `THE_WYRM_GOD` battlefield id, a
  `bcnm_records` row for zone 255, the battlefield script binding `TR_Entrance` /
  `Transcendental_Radiance`, Shinryu's HP (`mob_groups` says 0), and the Qufim
  entry that charges 10,000 cruor for the Crimson traverser stone.

## Method corrections from the structured-field sweep

Three machine-readable bg-wiki fields were swept across the corpus. Two of the
three turned out to be **unusable as bug signals**, which is worth recording so
the sweep is not repeated:

1. **`|Previous=` is chain navigation, not a prerequisite.** Of 156 quests whose
   `|Previous=` maps to a known enum, 132 gate it (explicitly, or structurally
   because the predecessor's handler calls `addQuest` for the successor). Of the
   24 that did not, the walkthroughs say the gate should not exist: Let Sleeping
   Dogs Lie states outright *"Completion of Reap What You Sow is not required to
   activate this quest"*; A Furious Finale and The Real Gift likewise. Job-AF
   quests (Dark Legacy, On Sabbatical, The Puppet Master) have their `|Previous=`
   satisfied implicitly by `getMainJob()`, since the predecessor is the job
   unlock. The limit-break chain (LB02-LB05) is ordered by `getLevelCap()`,
   which each predecessor raises. **Always read the walkthrough, not the field.**
2. **`|Repeatable=Yes` vs the check** produced only false positives. The repo
   idiom is `status >= QUEST_ACCEPTED` / `status ~= QUEST_AVAILABLE` on the
   turn-in section, which already admits `QUEST_COMPLETED`.
3. **`|Fame=` IS usable, but is filled inconsistently by editors** — sometimes
   the area code (`s`/`b`/`w`/`k`/`r`/`alth`), sometimes the *expansion* name
   copied from `|Expansion=` (The Swarm → "Wings of the Goddess", Finding Faults
   → "Treasures of Aht Urhgan"). Of 153 quests whose `|Fame=` resolved to a
   mapped area, **0 had the wrong `fameArea`** — the repo is sound here.

### Genuinely fixed by this sweep

- Seven quests set `fame` with **no `fameArea`**, so `giveReward`
  (`npc_util.lua:589`) silently paid nothing: Prelude of Black and White,
  Advanced / Intermediate / Introduction to Teamwork, Messenger from Beyond,
  Tiger's Teeth. Spice Gals was **not** a bug — its 725 handler pays
  `addFame(SANDORIA, 40)` by hand on first clear only, which is correct for a
  repeatable.
- Cloak and Dagger paid `NORG`; it is a Kazham quest (`|Fame=k`), and Kazham
  fame is Windurst fame per `fame_area.lua` / `lua_baseentity.cpp:7541`. Every
  other Kazham quest in `outlands/` already used `WINDURST`.

### No Aht Urhgan fame area exists

`addFame` (`lua_baseentity.cpp:7533`) accepts 0-15 only, with no Aht Urhgan
slot, so the seven Whitegate quests that declare `fameArea = WINDURST` have no
correct alternative in this build. Left as-is rather than changed; adding a real
area is a C++ + profile change.

## Cait Sith is unobtainable — highest-value open item

Every other avatar has an `addSpell` somewhere: Ifrit/Garuda/Leviathan
(`outlands/Trial_by_*`), Titan (`bastok/Trial_by_Earth`), Diabolos
(`windurst/Waking_Dreams`), Carbuncle (`SMN_I_Can_Hear_a_Rainbow`), Alexander
(`Divine_Interference`, `Waking_the_Colossus`), Odin (`The_Rider_Cometh:108`).
**`xi.magic.spell.CAIT_SITH` (307) is granted by nothing.** The pet id
(`pet_id.lua:30`) and Favor logic (`avatars_favor.lua:78`) are already wired, so
the summon works — it simply cannot be learned.

Retail source is the WOTG pair whose `|Reward=` is "Choice of: Pact with Cait
Sith / Nesanica Torque / ...": **Champion of the Dawn** and **The Dawn Also
Rises**. Both are "Simplified for 4-player" stubs granting only fame + title,
and both are wrong beyond the missing reward:

- csid 1320 does not exist in Bastok Markets (S) — `xi-dat csid 87 1320` reports
  not found.
- Neither quest starts at Adelbrecht in Bastok Markets (S) at all. bg-wiki
  `|Start=` is **Walk of Echoes** for Champion of the Dawn (entering the zone
  flags it) and **Walk of Echoes (S)** for The Dawn Also Rises.

So unlocking Cait Sith means building the Walk of Echoes leg: zone-in flag, three
"remnant of latent energy" points (temporary KI Breath of dawn, at the Fork in
the Road dawndrop locations), the shared fight, and the choice reward. That is a
subsystem build, not a reward line.

## Reward/requirement sweeps — results

`|Reward=` gil and `|FLevel=` are both usable signals, unlike `|Previous=`.

**gil**: of 108 quests listing a gil reward, only **A Taste for Meat** was wrong
(paid 150, bg-wiki says 120). Everything else that looked wrong was the sweep's
fault: gil is commonly paid as `player:addGil(xi.settings.main.GIL_RATE * N)` in
a handler rather than `quest.reward.gil`. Notable non-bugs — Food for Thought
pays 120 + 440 + 440 across its three deliveries, which is exactly bg-wiki's
"1,000 gil" total; Reap What You Sow's wiki value is a *range* ("500 - 700 Gil")
and the file pays both.

**`|FLevel=`**: of 152 quests with a numeric FLevel > 1, **136 gate it exactly**
and 16 did not. All 16 are now fixed — six off-by-N corrections (Trial by Wind
5→6, A Timely Visit 4→3, His Name Is Valgeir 3→2, The Sand Charm 2→4, A Potter's
Preference 6→5, Unending Chase 3→2) and ten gates that were absent entirely
(The Fanged One, The Starving, Waking Dreams, Candle-making, Rubbish Day,
An Explorer's Footsteps, Sorcery of the North, The Vicasque's Sermon,
Fisherman's Heart, An Eye for Revenge). Trial by Wind was confirmed by its three
siblings, each of which already matched its own wiki FLevel (Fire 6, Water 4,
Earth 6). Note `getFameLevel` returns 1 at fame 0, so an `FLevel=1` gate is a
no-op and was excluded.

### Destructive bug found while doing it

`An_Eye_for_Revenge.lua` called `player:delKeyItem(VIAL_OF_LAMBENT_POTION)` in
`onTrigger` — before the cutscene resolved — while `quest:begin` ran only in
`onEventFinish[190]`. Cancelling the cutscene therefore consumed the key item and
left the quest permanently unstartable, and the potion was never checked for in
the first place. Both now happen in the event handler.

## METHOD RULE — BG-WIKI DRIVES EVERYTHING. `quests.lua` is never evidence.

The audit runs **outward-in from bg-wiki**, one bg-wiki quest at a time. Never
walk the repo and ask "what do we have" — that is inward-out and is structurally
blind to everything absent, which is the whole point of the exercise.

For each of bg-wiki's quests, in this order:

1. **bg-wiki gives the quest list.** 147 category pages, 1069 quests. This is the
   denominator, always. Not `quests.lua`, not `scripts/quests/`, not a file walk.
2. **bg-wiki gives the steps.** Fetch the page; the Walkthrough is the spec.
3. **Then** ask whether this bg-wiki quest has an implementation.
4. **Then** verify that implementation follows the bg-wiki steps.

`scripts/globals/quests.lua` is consulted for **one** thing only: looking up or
confirming a quest id when *adding* a quest at step 3/4. It is **never** evidence
that a quest exists, is implemented, or is correct. An id existing there means
nothing — 357 ids in it are referenced nowhere in `scripts/`.

A pass that counted "has an enum id" as covered produced badly wrong numbers
(421 -> 189 -> 90 outstanding). All three were junk, and the low ones were the
worst: they hid real missing work. The number below is the bg-wiki denominator
minus the bg-wiki quests that have an implementation.

At step 3, a bg-wiki quest counts as implemented only when a file implements it —
either a file declaring `Quest:new(... xi.quest.id.<area>.<SYMBOL>)`, or a legacy
zone NPC script that *acts* on it (`addQuest` / `completeQuest` / `delQuest`).
A file merely *referencing* a quest id (a prereq check) is not an implementation.

### Corrected count

| | Count |
|---|---:|
| bg-wiki quests | 1069 |
| implemented (a file declares or acts on it) | 731 |
| **no implementation at all** | **338** |

Minus the 14 Kupofried's Moogle Magic quests, which *are* implemented as an NPC
handler but are invisible to any quest-id signal because they have no quest-log
entry, the outstanding build list is **~324**.

Largest blocks: Abyssea 119, Adoulin 73, Jeuno 58 (+37 Lower, +17 Upper),
Voidwatch 27, Crystal War 21, Mog Garden 20, Fellowship 18 (dropped by owner
decision — trusts supersede them).

### "Has a file" is not "works"

This count answers *does an implementation exist*, nothing more. It is
orthogonal to the FLOW-WRONG / STUB axis: Healing Herbs, Champion of the Dawn and
19 others all count as implemented here while being confirmed-dead stubs whose
csids do not exist in their zone (see `DECODED_CSIDS.md`). Both lists must be
worked; neither substitutes for the other.

## Live-bug classes to check on every change

These each produced real exploits in this repo. Check for them by default.

1. **DOUBLE-REWARD.** `interaction_lookup.lua:412` runs **both** the Interaction
   Framework handler **and** the legacy zone-NPC fallback for `onEventFinish`
   (only `onSteal`/`onTrigger`/`onTrade` are excluded), and
   `npcUtil.completeQuest` has no already-completed guard. When a quest is
   converted, the legacy `scripts/zones/*/npcs/*.lua` must be deleted. Nine such
   sites were found and fixed, including two paying 20,000 gil.
2. **Shared-event cross-fire.** `onEventFinish` dispatches **zone-wide on csid
   alone**. Battlefield/instance clear events (`10000`, `32001`, `32000`) are
   shared by every content item in the zone — scope them with
   `instance:getName()` or `getLocalVar('battlefieldWin')`. Fourteen handlers
   needed this.
3. **Malformed sections.** A section keyed by NPC name instead of `[xi.zone.X]` is
   silently dropped at load (`interaction_lookup.lua:214` filters against a
   numeric zone table) — the quest looks fine and is dead.
4. **Silently dropped reward keys.** `giveReward` reads only `keyItem` — **not**
   `ki`, **not** `keyitem` — and grants fame **only** when `fameArea` is set.
5. **Wrap-midnight windows.** `hour >= 18 and hour < 5` is never true. Must be
   `or`. Four instances existed, one of which blocked the whole Abyssea storyline.
6. **Invented APIs.** Verify every method and enum against its definition before
   shipping. Fabricated in this session and caught only by checking:
   `target:knockback`, `xi.damageType.LIGHTNING`, `xi.battlefield.status.LOSE`,
   `xi.mobskills.physicalTpBonus.DMG_BONUS`, `npcUtil.tradeMatches`.
7. **Client-trust gaps.** `title_changer.lua` greyed unowned titles out in the UI
   but never re-checked server-side, and `setTitle` grants as well as displays.

## Tooling caveat

`tools/coverage/build_batches.py:47` globs only `scripts/quests/**`, so any quest
implemented entirely in `scripts/zones/**` gets an empty `repo_candidates` list and
is invisible to a pass that walks candidates. Worse, 11 Windurst rows point at
files that no longer exist or belong to unrelated quests (Hat in Hand →
`A_Feather_in_Ones_Cap.lua`, The Moonlit Path → `outlands/Mama_Mia.lua`). **Treat
`repo_candidates` as a hint, never as coverage.** Those 11 need re-auditing.

## Method

1. bg-wiki gives the quest list **and** the steps:
   `curl -sL "https://www.bg-wiki.com/api.php?action=parse&page=TITLE&prop=wikitext&format=json"`
   (`action=raw` and `/w/api.php` are Cloudflare-blocked; HTTP 429 looks exactly
   like an empty page — back off and retry; a ~43-char body is a `#REDIRECT` stub,
   follow it).
2. Find the implementation anywhere in `scripts/` — Interaction Framework file
   **or** legacy zone-NPC script. Both are valid.
3. Compare control flow to the walkthrough step by step. **Read the file**; grep
   locates, reading concludes.
4. Verify with `bash tools/ci/sanity_checks/lua.sh <files>` — plain `luacheck`
   under-reports, because `lua.sh` treats any luacheck output as failure.

## Related documents

- `DECODED_CSIDS.md` — decoded csid reference. Before shipping an id, run the two
  ship checks: zone `onEventFinish` collision, and NPC hijack.
- `VOIDWATCH_TODO.md`, `ROV_TODO.md`, `ROE_CAPTURE.md`,
  `ODIN_MYTHIC_ARC_TODO.md` — live per-domain TODOs.
- `What Works/` — separate implementation audit, its own workstream.
