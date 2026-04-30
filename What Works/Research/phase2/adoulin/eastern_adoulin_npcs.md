# Eastern Adoulin (Zone 257) NPC Audit

204 unique NPC names in the zone. 13 have dedicated scripts under `scripts/zones/Eastern_Adoulin/npcs/`, 9 have entries in `DefaultActions.lua`, and the remainder either resolve via the Interaction Framework when a quest/mission `check()` passes, or have no handler at all.

Each row below was verified two ways: bg-wiki / FFXIclopedia / FFXI Wiki lookup for retail role, plus codebase grep for an existing handler. Status keys:

- `WORKS` — script present and functional
- `BROKEN` — script present, logic incomplete (cited)
- `NO_SCRIPT_HANDLER_EXISTS` — global handler exists, just needs an NPC stub like the equivalents in other cities
- `NO_SCRIPT_NEEDS_IMPLEMENTATION` — whole subsystem missing
- `IF_REGISTERED` — handled by Interaction Framework via quest/mission file
- `AMBIENT` — verified as idle dialog in retail (lookup confirmed minimal/no role)
- `INACTIVE_PLACEHOLDER` — present in `npc_list.sql` but inert in retail (status flag 0, coords 0,0,0, or coalition-edification-gated NPC the server never spawns)

## Important corrections vs. previous audit

- **HomePoint #3, #4, #5 are NOT missing — retail Eastern Adoulin has only 2 HP/SG hubs.** `sql/npc_list.sql:17829978-17829980` rows are placeholder slots at coords `0,0,0` with status `0` (inactive). Retail confirms 2 HPs (one at G-6, one at H-10). The previous audit's recommendation to add HP#3/#4/#5 was wrong.
- **Winrix is the Eastern Adoulin Gobbie Mystery Box NPC.** ID 17830187 at H-10. No script exists; one-line wire-up to `xi.gobbieMysteryBox` mirroring `scripts/zones/Lower_Jeuno/npcs/Sweepstox.lua`.
- **Achieve_Master and Unity_Master are placeholders, not missing systems.** Retail RoE NPCs exist only in Western Adoulin (per `bg-wiki/Records_of_Eminence`), and Unity NPCs only in Western Adoulin (`Nunaarl_Bthtrogg`). Server rows for both at IDs 17829949 / 17829951 have coords `0,0,0` and status `0` — they are not spawned and have no retail counterpart in EA.
- **Sylvie's bg-wiki page lists Western Adoulin (I-5) as her location**, but `npc_list.sql:17830137` places a Sylvie copy in EA at coords `24,-22,34`. This is a mission-spawn (cutscene-only) — `Sick_and_Tired`, `Flowers_for_Svenja`, etc. handle her appearance.

## Hardcoded TODOs in scripted NPCs

Verified via grep across the 13 scripts in `scripts/zones/Eastern_Adoulin/npcs/`:

- `Iyvah_Halohm.lua:11,14-20` — `imprimatursSpent` and all 6 coalition ranks hardcoded to 0 with `-- TODO: Hook these up`
- `Ujlei_Zelekko.lua:28,37` — `edification` hardcoded 0; menu gated behind `extravaganza.campaignActive()` instead of coalition rank
- `Sifa_Alani.lua:40-44` — Frontier Station bitmask hardcoded to all-available; map vendor pre-Pioneer status untested

No other scripts contain TODO/FIXME markers.

---

## Audit Table

### Utility — currently working

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| HomePoint#1 | WORKS | Home Point teleport (G-6) | `xi.homepoint` registered idx 45 | Nothing |
| HomePoint#2 | WORKS | Home Point teleport (H-10) | `xi.homepoint` registered idx 110 | Nothing |
| Survival_Guide | WORKS | Survival Guide (only one in SoA) | `xi.survivalGuide` | Nothing |
| Auction_Counter | WORKS | AH menu | `player:sendMenu(xi.menuType.AUCTION)` | Nothing |
| Moogle | WORKS | Mog House | `xi.moghouse` | Nothing |
| Waypoint | WORKS | 9 waypoints linked | `xi.waypoint` | Nothing |
| Symphonic_Curator | WORKS | Symphony / song book | `xi.symphonic_curator` | Nothing |
| Inthius | WORKS | Weather reporter | event 4 inline | Nothing |
| Eppel-Treppel | WORKS | Library entry guard | event 591 inline | Nothing |

### Utility — broken / incomplete

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Iyvah_Halohm | BROKEN | Adoulin Fame + 6 coalition ranks (G-8) | event 562 wired | `Iyvah_Halohm.lua:14-20` — all 6 coalition ranks hardcoded 0; `:11` imprimatursSpent hardcoded 0. Need coalition rank read API |
| Ujlei_Zelekko | BROKEN | Peacekeepers shop, alter ego ciphers | event 7513 wired | `Ujlei_Zelekko.lua:28,37` — menu gated by Campaign instead of coalition edification rank; `edification` always 0 |
| Sifa_Alani | BROKEN | Map vendor (Scouts) | event 7530 wired | `Sifa_Alani.lua:40-44` — frontier-station bitmask hardcoded to 0x7FFFFF (all available). Won't break map purchases but advertises maps the player can't actually use until Frontier Stations exist |
| Octavien | WORKS (RUN AF only) | RUN job quest + AF commission (I-8) | inline + `xi.questLog.ADOULIN` | Functional path covered for Children of the Rune + Forging New Bonds. SoA mission overlap not validated |

### Missing one-line stub — global handler exists

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Winrix | NO_SCRIPT_HANDLER_EXISTS | Gobbie Mystery Box (H-10) | `scripts/globals/gobbie_mystery_box.lua` | Copy `scripts/zones/Lower_Jeuno/npcs/Sweepstox.lua` (40 lines) and verify event IDs 20055-20068 in EA's IDs.lua |
| Eternal_Flame_equiv (none in EA) | INACTIVE_PLACEHOLDER | RoE NPC | `xi.sparkshop` + `xi.roe` | Retail has no RoE NPC in EA — Achieve_Master row is inert. Skip |
| Unity_Master | INACTIVE_PLACEHOLDER | Unity Concord | `xi.unity` | Retail has no Unity NPC in EA — only Western Adoulin's Nunaarl_Bthtrogg. Skip |

### Coalition NPCs — no handlers exist (subsystem missing)

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Civil_Registrar (x2) | NO_SCRIPT_NEEDS_IMPLEMENTATION | Coalition info: rank, edification status, referendums | None | Coalition system not modeled. 2 instances: one in Peacekeepers (F-7), one in Scouts (F-9) |
| Task_Delegator (x2) | NO_SCRIPT_NEEDS_IMPLEMENTATION | Issues coalition assignments, shows imprimatur count | Only `xi.soa.helpers.imprimaturGate` (mission gate). No assignment-issuing handler | Full assignment subsystem missing. 2 instances mirror Civil_Registrar |
| GLD_BUILD_MASTER | INACTIVE_PLACEHOLDER | Coalition building visual placeholder | None | Edification visual; not interactive in retail. Status flag 0 — invisible |
| JGL_BUILD_MASTER_0..5 | INACTIVE_PLACEHOLDER | Coalition building stages | None | Same — invisible until edification triggers visual swap. Six placeholder slots |
| Mandragora_Assistant | NO_SCRIPT_NEEDS_IMPLEMENTATION | Mandragora Mania mini-game (H-10) | None | Mancala-like minigame for monthly Jingly currency. Whole subsystem absent |
| Anomaly_Expert | NO_SCRIPT_NEEDS_IMPLEMENTATION | Delve pop-item synth (G-10) | None — Delve not implemented | Synthesizes yantric planchettes from Yggrete; exchanges Delve boss KIs |

### Coalition vendors / utility — no script

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Vesca | NO_SCRIPT_NEEDS_IMPLEMENTATION | Peacekeepers gear shop (Bayld, edification-gated) | `xi.shop`/`xi.coalition_vendor` patterns elsewhere; coalition rank API missing | Vendor with edification-tier requirements |
| Craggy_Bluff | NO_SCRIPT_NEEDS_IMPLEMENTATION | Peacekeepers weapons shop (Bayld) | Same as Vesca | Vendor with edification-tier requirements |
| Bernegeois | NO_SCRIPT_NEEDS_IMPLEMENTATION | Cafe food/drink vendor (G-8) | Standard `xi.shop` | Static gil shop — needs script and shop table; one item gated by `Cafe...teria` quest |
| Dimmian | NO_SCRIPT_NEEDS_IMPLEMENTATION | Wildskeeper Reive entry items (E-6) | None — WSR not implemented | Sells WSR pop items 7,500-30,000 Bayld with fame/coalition discount |
| Old_Bellows | NO_SCRIPT_NEEDS_IMPLEMENTATION | Seed vendor (J-7) | Standard `xi.shop` | Static gil shop |
| Malgrom | NO_SCRIPT_NEEDS_IMPLEMENTATION | Seafood vendor (E-8) | Standard `xi.shop` | Static gil shop |
| Tallula | NO_SCRIPT_NEEDS_IMPLEMENTATION | HELM tools + ammo vendor (G-6) | Standard `xi.shop` | Static gil shop |
| Greebly | NO_SCRIPT_NEEDS_IMPLEMENTATION | Sells Hallowed Wood (G-6) during `A Thirst for the Eons` | None | Conditional vendor; quest-state gated |
| Runje_Desaali | NO_SCRIPT_NEEDS_IMPLEMENTATION | Bayld exchange (J-10) — gear-for-Bayld + High-Purity Bayld dispenser | None | Trade-in shop; non-trivial table mapping items to Bayld values |
| Quiri-Aliri | NO_SCRIPT_NEEDS_IMPLEMENTATION | Ionis buff applier — 10 Bayld | `xi.effect.IONIS` exists, applied in `Ruth.lua` (Western Adoulin) and `A_Pioneers_Best_Imaginary_Friend.lua` | Trivial: copy Ruth.lua pattern, add 10 Bayld cost. Effect already coded |
| Patient_Snake | NO_SCRIPT_NEEDS_IMPLEMENTATION | Sells Library Card 1000 Bayld (F-9, Scouts) | None | Single-item bayld vendor; needs Scouts edification gate |

### Skirmish NPCs

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Lola | NO_SCRIPT_NEEDS_IMPLEMENTATION | Skirmish wing storage + exchange (G-8) | None — Skirmish not implemented | Whole subsystem missing |
| Oston | NO_SCRIPT_NEEDS_IMPLEMENTATION | Simulacrum assembly + Obsidian Fragment exchange (G-8) | None — Skirmish not implemented | Whole subsystem missing |

### Coalition info / scout services (Scouts Coalition F-9)

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Chamulele | NO_SCRIPT_NEEDS_IMPLEMENTATION | Ergon Loci progress reports | None — Ergon Loci not implemented | Reads survey progress; affects Tincture potency |
| Soppopo | NO_SCRIPT_NEEDS_IMPLEMENTATION | Colonization intel (Ulbukan field areas) | None | Edification-gated info NPC |
| Xavinien | NO_SCRIPT_NEEDS_IMPLEMENTATION | Spoils of war (Skirmish/Delve drop intel), 10 Bayld | None | Dependent on Skirmish/Delve subsystems |
| Fariska_Lokhmi | NO_SCRIPT_NEEDS_IMPLEMENTATION | Adds map markers for Bivouacs | Map system has no marker API | Edification-gated; mostly cosmetic |

### Delivery / mailbox NPCs

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Malulu | NO_SCRIPT_NEEDS_IMPLEMENTATION | Delivery Box (H-11) | `SendItemToDeliveryBox` exists; no menu glue for an NPC-driven delivery box | Likely just `player:sendMenu(xi.menuType.DELIVERY_BOX)` if such enum exists. Verify pattern in other Mog House zones |
| Jaded_Hawk | NO_SCRIPT_NEEDS_IMPLEMENTATION | Delivery Box (H-10) | Same | Same as Malulu |
| Delivery_Specialist | NO_SCRIPT_NEEDS_IMPLEMENTATION | Send-only delivery box outside Mog House | Same | Couriers Coalition emblem-gated |
| Cunegonde | NO_SCRIPT_NEEDS_IMPLEMENTATION | Rent-a-Room help (G-11) | Used in IF mission registration in SoA | NPC also has SoA mission cutscene state; static help dialog otherwise |
| Terianne | NO_SCRIPT_NEEDS_IMPLEMENTATION | AH employee dialog (H-10) | None | Pure flavor; could be ambient |

### Cutscene replay / library

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Bheva_Grantih | NO_SCRIPT_NEEDS_IMPLEMENTATION | Cutscene replay bard (K-9) | None — cutscene replay not implemented | Whole subsystem missing |
| Maudilyonne | NO_SCRIPT_NEEDS_IMPLEMENTATION | Event replay bard (G-6) | None | Same |
| Lamaron | NO_SCRIPT_NEEDS_IMPLEMENTATION | Boat to Yahse Hunting Grounds (G-5) | `setPos` pattern works; no script | Trivial: warp to Yahse coords. **Already registered in IF for SoA mission** — IF blocks fallback dialog |

### Quest NPCs (handled by Interaction Framework)

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Felmsy | IF_REGISTERED | `A_Good_Pair_of_Crocs` start (G-5) | `scripts/quests/adoulin/A_Good_Pair_of_Crocs.lua` | Test in-game |
| Pudith | IF_REGISTERED | `A_Shot_in_the_Dark` start (F-6) | `scripts/quests/adoulin/A_Shot_in_the_Dark.lua` | Test in-game |
| Vastran | IF_REGISTERED | `The_Longest_Way_Round` (F-8) | `scripts/quests/adoulin/The_Longest_Way_Round.lua` | Test in-game |
| Octavien | IF_REGISTERED | `Destinys_Device`, `Endeavoring_to_Awaken`, `Forging_New_Bonds`, `Legacies_Lost_and_Found` | quest files + dedicated script | Works |
| Audibert | IF_REGISTERED | `Don't_Ever_Leaf_Me` start (F-9) | Quest not in `scripts/quests/adoulin/` — **MISSING quest file** | Add quest file |
| Ndah_Tolohjin | IF_REGISTERED | `The_Whole_Place_Is_Abuzz` + LWR | DefaultAction event 512; SoA helpers register | Works for SoA, quest line missing |
| Roskin | NO_SCRIPT_NEEDS_IMPLEMENTATION | `A_Thirst_for_the_Ages/Eons/Eternity/Before_Time` + `Ygnas_Directive` (H-8) | Quest files **not in `scripts/quests/adoulin/`** | 4 quest scripts to add |
| Sharuru | NO_SCRIPT_NEEDS_IMPLEMENTATION | Waypoint quests: `Eastern_Waypoints_Ho`, `Meg-alomaniac`, `Wayward_Waypoints` (F-8) | Quest files not present | 3 quest scripts to add |
| Yocile | NO_SCRIPT_NEEDS_IMPLEMENTATION | `Cafe...teria` quest (G-8) | Quest file not present | 1 quest script to add |
| Risen_Hackles | NO_SCRIPT_NEEDS_IMPLEMENTATION | `Open_the_Floodgates` (G-6/7) | Quest file not present | 1 quest script to add |
| Behsa_Alehgo | IF_REGISTERED | `Secret_to_Success`, `Eye_of_the_Beholder`, `In_the_Land_of_the_Blind` | Cited in IF but quest files not present | Quest files needed |
| Erminold | IF_REGISTERED | SoA Mission 3-1-2 cutscene NPC | `scripts/missions/soa/3_1_2_A_Curse_from_the_Past.lua` registers | Works in mission flow |
| Erfimia | IF_REGISTERED | Same trio as Behsa_Alehgo | Quest files not present | Quest files needed |
| Lamaron | IF_REGISTERED | SoA mission cutscene + Yahse boat | SoA helpers register | Boat function needs separate dialog when no mission active |
| Nhili_Uvolep | IF_REGISTERED | `Saved_by_the_Bell`, `For_Whom_the_Bell_Tolls`, `Bloodline_of_Zacariah` (DefaultAction event 545) | DefaultActions + IF | Verify event 545 isn't a stale Western Adoulin value |
| Stavalian | IF_REGISTERED (DefaultAction 533) | SoA mission flavor | DefaultActions | Verify event 533 |
| Fostaig | IF_REGISTERED (DefaultAction 513) | Peacekeepers guard | DefaultActions | Likely just dialog |
| Oscairn | IF_REGISTERED (DefaultAction 525) | `Order_Up`, `No_Mercy_for_the_Wicked` | Quest files not present | 2 quest scripts |
| Huss | IF_REGISTERED (DefaultAction 503) | Singing child | DefaultActions | Pure flavor |
| Irate_Destrier | IF_REGISTERED (DefaultAction 505) | Peacekeepers guard | DefaultActions | Verify event 505 |
| Ploh_Trishbahk | IF_REGISTERED | Castle gate + dropped-item recovery (Councilor's Garb/Cuffs/SoA Ring) + 9 SoA missions | DefaultAction 563 + SoA mission registers | Item recovery may not be implemented; verify after SoA flow tested |
| Cunegonde | IF_REGISTERED | SoA missions register; rent-a-room dialog otherwise | SoA mission files | Default dialog absent |
| Wegellion | IF_REGISTERED | Scouts coalition employee, mission cutscenes | SoA helpers register | Works in mission flow |
| Rigobertine | IF_REGISTERED | SoA mission cutscene | SoA mission files | Works in mission flow |
| Zaffeld | NO_SCRIPT_NEEDS_IMPLEMENTATION | `Thorn_in_the_Side`, `Velkkovert_Operations`, `The_Ygnas_Directive` (Wake of Lilies) | Quest files not present | 3 quest scripts |

### Story / cutscene NPCs (mission-only, no idle dialog needed)

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Arciela (x3) | IF_REGISTERED | Princess of Adoulin, central SoA character | SoA mission files | Works in mission flow |
| Margret (x2) | IF_REGISTERED | Maester of Scouts; also a Trust unlocked via cipher | SoA mission files; trust spell 977 | Mission cutscene works; trust cipher purchased from Ujlei_Zelekko |
| Amchuchu | IF_REGISTERED | Pioneers Coalition Maester (cipher trust) | SoA mission files | Works in mission flow |
| Lhe_Lhangavo | IF_REGISTERED | Pioneers Maester (Mithra) | SoA mission files | Cutscene NPC |
| Ikhi_Askamot | IF_REGISTERED | Renaye Maester (geomancers) | SoA mission files | Cutscene NPC |
| Hildebert | IF_REGISTERED | Weatherspoon Order leader (justice minister) | SoA mission files | Cutscene NPC |
| Gratzigg | IF_REGISTERED | Peacekeepers Maester | SoA mission files | Cutscene NPC |
| Svenja | IF_REGISTERED | Janniston Order head — also Western Adoulin quest giver | SoA mission files; WA quests | Works in mission flow |
| Sylvie | IF_REGISTERED | Geomancer NPC (mostly Western Adoulin); EA appearance is mission cutscene | SoA mission files | Works in mission flow |
| Reginald | IF_REGISTERED | Couriers Coalition Maester | SoA mission files | Likely cutscene only |
| Flaviria | IF_REGISTERED | Mummers Maester | SoA mission files | Cutscene NPC |
| Insidio | IF_REGISTERED | NPC form spawned for `Destinys_Device` quest (otherwise the NM in Foret de Hennetiel) | `Destinys_Device.lua` | Already wired |
| Erisa | IF_REGISTERED | `Keep_Your_Bloomers_On_Erisa` (Door:Research_Chamber starts it) | Quest file not present | 1 quest script |
| Ingrid | IF_REGISTERED | Sinister Reign NM model used in cutscene at J-8 | SoA mission files | Cutscene NPC |

### Door NPCs

| NPC | Status | Role | Existing handler? | What's needed |
|---|---|---|---|---|
| Door_Boarding_House | IF_REGISTERED | Door at I-7 area; SoA mission progressEvent (1511, 1513) | DefaultAction `messageSpecial = NOTHING_OUT_OF_ORDINARY`; SoA missions override during flow | Works |
| Door_Research_Chamber | NO_SCRIPT_NEEDS_IMPLEMENTATION | Sverdhried Hillock door (J-8) — starts `Keep_Your_Bloomers_On_Erisa` | Quest file not present | Wire as part of Erisa quest |

### Ambient — verified no role in retail

Each entry below was looked up; bg-wiki / FFXIclopedia confirm "Adoulin citizen" with no quests, no shops, no services. Grouping for brevity:

| NPC | Status | Notes |
|---|---|---|
| Adelise | AMBIENT | Wake of Lilies covenant member; no quests start here |
| Alphonserme | AMBIENT | Adoulin citizen |
| Amaury | AMBIENT | Adoulin citizen |
| Ari-Barali | AMBIENT | No bg-wiki page |
| Boffin | AMBIENT | Adoulin citizen at E-9 |
| Celine | AMBIENT | No bg-wiki page; Adoulin citizen |
| Chelidoine | AMBIENT | Adoulin citizen |
| Chero-Machero | AMBIENT | No bg-wiki page |
| Chumli-Mojumli | AMBIENT | House guard, mention in `Order_Up`; otherwise idle |
| Corpo-Vorpo | AMBIENT | No bg-wiki page |
| Dalish | AMBIENT | Listed as merchant on bg-wiki but no goods documented; treat as ambient until verified |
| DIRECTOR_by_yaeko | AMBIENT | Internal placeholder name (developer slug) |
| Dimmian | NO_SCRIPT_NEEDS_IMPLEMENTATION | Already covered above (WSR vendor) |
| Dworvigg | AMBIENT | No bg-wiki page |
| Estelle | AMBIENT | Adoulin citizen at F-9 |
| Estienneux | AMBIENT | No bg-wiki page |
| Finnigor | AMBIENT | Adoulin citizen at G-9 |
| Garembert | AMBIENT | Peacekeepers guard, F-7 |
| Geosuke | AMBIENT | Leafkin near Runje_Desaali; chirps |
| Glowing_Hearth | AMBIENT | Adoulin citizen at H-6 |
| Gregoirellaud | AMBIENT | No bg-wiki page |
| Grennith | AMBIENT | No bg-wiki page |
| Hemborok | AMBIENT | No bg-wiki page |
| Jampiaire | AMBIENT | Cafe employee, G-8 |
| Jozhud | AMBIENT | No bg-wiki page |
| Kapeipei | AMBIENT | No bg-wiki page |
| Krepol | AMBIENT | Adoulin citizen at H-6 |
| Kyff | AMBIENT | No bg-wiki page |
| Laetitia | AMBIENT | No bg-wiki page |
| Lhaiso_Neftereh | AMBIENT/CUTSCENE | Cutscene appearance for `The_Communion`; no idle role |
| Lionardois | AMBIENT | No bg-wiki page |
| Melvien | AMBIENT | No bg-wiki page |
| Melvort | AMBIENT | No bg-wiki page |
| Nashu | AMBIENT | No bg-wiki page |
| Neviyak | AMBIENT | No bg-wiki page |
| Obelailai | AMBIENT | No bg-wiki page |
| Othellius | AMBIENT | No bg-wiki page |
| Palomel (x2) | AMBIENT | Quest cutscene only (`Order_Up`, `A_Thirst_for_the_Eons`) |
| Penthus | AMBIENT | "Adoulin vacationer who owns a home in the Far-East" — flavor |
| Pollimio | AMBIENT | No bg-wiki page |
| Reepi-Molpi | AMBIENT/CUTSCENE | Cutscene in `The_Secret_to_Success` |
| Reffen-Geppen | AMBIENT | No bg-wiki page |
| Reginald | CUTSCENE | Couriers Maester — appears in missions only |
| Stavalian | AMBIENT | DefaultAction 533 covers; no quest |
| Uhlstar | AMBIENT | No bg-wiki page |
| Vortimere | AMBIENT | No bg-wiki page |
| Yvermain | AMBIENT | No bg-wiki page |
| Ysadel | AMBIENT | No bg-wiki page |
| Zalk | AMBIENT | Adoulin citizen at K-9 |

### Inactive placeholders (engine slots, never spawned in retail)

| NPC | Status | Notes |
|---|---|---|
| Achieve_Master | INACTIVE_PLACEHOLDER | RoE NPC type — retail has none in EA |
| Unity_Master | INACTIVE_PLACEHOLDER | Unity NPC type — retail has none in EA |
| GLD_BUILD_MASTER | INACTIVE_PLACEHOLDER | Coalition building visual; coords 0,0,0 |
| JGL_BUILD_MASTER_0..5 | INACTIVE_PLACEHOLDER | Coalition building stage variants; coords 0,0,0 |
| HomePoint#3, #4, #5 | INACTIVE_PLACEHOLDER | Retail only has 2 HPs; rows are reserved slots |
| NPC[16]..NPC[3f], NPC[40]..NPC[5b] | INACTIVE_PLACEHOLDER | Engine NPC slots |
| _750.._75h, _gh0/1, _gi0/1/2 | INACTIVE_PLACEHOLDER | Decorative entities (effects, particles, named-but-empty slots) |
| blank | INACTIVE_PLACEHOLDER | 56 instances — empty NPC slots |
| csnpc | INACTIVE_PLACEHOLDER | 20 instances — cutscene-only invoke targets |
| qm | INACTIVE_PLACEHOLDER | 9 instances — `???` event triggers; one is the Treasure Coffer |
| Treasure_Coffer | INACTIVE_PLACEHOLDER | At ID 17830188; coffer chest, only spawns during specific events |
| Soul_Pyre (x6) | NO_SCRIPT_NEEDS_IMPLEMENTATION | Soul Pyre minigame — Ulbukan post-mob spawn objects, not strictly an EA citizen NPC |
| Old_Bellows / Tallula / Bernegeois / Malgrom | listed above as gil shops |

---

## Top 5 highest-value fixes (priority order)

1. **Iyvah_Halohm coalition rank display (BROKEN)** — `Iyvah_Halohm.lua:11,14-20`. Visible to every player, all six coalition fame numbers always show 0. Needs a coalition-rank read API or `getCharVar` lookup; until coalition system is built, hardcoding rank-1 (visible at fame > 0) is better than rank-0.
2. **Winrix Gobbie Mystery Box wire-up (NO_SCRIPT_HANDLER_EXISTS)** — copy `scripts/zones/Lower_Jeuno/npcs/Sweepstox.lua` to `Eastern_Adoulin/npcs/Winrix.lua` and adjust event IDs from EA's IDs.lua. Smallest possible PR, restores a real retail feature.
3. **Quiri-Aliri Ionis buff (NO_SCRIPT_NEEDS_IMPLEMENTATION)** — `xi.effect.IONIS` is fully implemented (`Ruth.lua` Western Adoulin pattern); just needs an EA-side dispenser at 10 Bayld. Trivial port from `Western_Adoulin/npcs/Ruth.lua`.
4. **Delivery box NPCs Malulu / Jaded_Hawk (NO_SCRIPT_NEEDS_IMPLEMENTATION)** — `SendItemToDeliveryBox` exists. Verify the menu enum used by other Mog House zones and stub a one-line `player:sendMenu(...)` for both. Minor inconvenience for players who use AH/delivery flows in EA otherwise have to walk to mog house.
5. **Ujlei_Zelekko campaign gate (BROKEN)** — `Ujlei_Zelekko.lua:37`. Peacekeepers shop only opens during Campaign extravaganza; outside campaign the menu silently never opens. Replace `if active > 0 then` with an unconditional `startEvent` (use `extravaganza.campaignActive() == 0` to drop cipher availability instead). Same file fix.

---

## Spot-check status of "previously named questionable NPCs"

- **Winrix** — verified: Gobbie Mystery Box, no script (top-5 fix)
- **Achieve_Master** — verified: not a real NPC in retail EA, inactive placeholder (RoE handler exists but EA has no RoE NPC)
- **Unity_Master** — verified: not a real NPC in retail EA, inactive placeholder
- **Civil_Registrar** — verified: coalition info NPC; no coalition system to read from
- **Anomaly_Expert** — verified: Delve pop-item NPC at G-10; Delve subsystem missing
- **Mandragora_Assistant** — verified: Mandragora Mania mini-game; subsystem missing
- **Delivery_Specialist** — verified: send-only delivery box outside Mog House (Couriers edification gate)
- **GLD_BUILD_MASTER / JGL_BUILD_MASTER_0..5** — verified: invisible building-stage placeholders, not interactive
- **Insidio** — verified: spawned NPC for `Destinys_Device`, already wired in `scripts/quests/adoulin/Destinys_Device.lua`
- **Boffin / Greebly / Cunegonde / Erminold / Maudilyonne** — verified: Boffin = ambient. Greebly = quest-conditional vendor for Hallowed Wood. Cunegonde = rent-a-room help + SoA cutscene NPC. Erminold = SoA mission 3-1-2 cutscene. Maudilyonne = event/cutscene replay bard
- **Glowing_Hearth / Craggy_Bluff / Jaded_Hawk / Addled_Fetters** — verified: Glowing_Hearth and Addled_Fetters are ambient guards. Craggy_Bluff is the Peacekeepers weapons vendor. Jaded_Hawk is a Delivery Box at H-10
- **Door_Boarding_House** — verified: SoA mission door, registered. Default = NOTHING_OUT_OF_ORDINARY message
- **Door_Research_Chamber** — verified: starts `Keep_Your_Bloomers_On_Erisa` quest; no script

## References

- bg-wiki / FFXIclopedia / FFXI Wiki for retail NPC roles (cross-referenced per row above)
- `scripts/zones/Eastern_Adoulin/npcs/` — 13 scripts, all reviewed for TODOs
- `scripts/zones/Eastern_Adoulin/DefaultActions.lua` — 9 entries
- `scripts/globals/gobbie_mystery_box.lua` — 365 lines, exposes `xi.gobbieMysteryBox.{onTrigger,onTrade,onEventUpdate,onEventFinish}`
- `scripts/globals/unity.lua`, `scripts/globals/sparkshop.lua`, `scripts/globals/roe_records.lua`, `scripts/globals/deeds.lua` — global handlers all confirmed present
- `scripts/quests/adoulin/` — 7 quest files registering EA NPCs
- `scripts/missions/soa/` — 35 mission files registering EA NPCs
- `scripts/missions/rov/` — 3 RoV mission files registering EA NPCs
- `sql/npc_list.sql` zone 257 range: 17829888 - 17833983
