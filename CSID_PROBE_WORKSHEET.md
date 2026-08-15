# CSID probe worksheet — 88 stub quests

> **SUPERSEDED — offline decode now works.** This file was written when I
> wrongly believed `csid -> dialog` could not be resolved offline. It can.
> `UpdateExtractor/xidat/csidmsg.py` does it:
> `python3 csidmsg.py <zone> <entity>` lists every csid an NPC owns and the
> dialog ids it emits. Read those with `xi-dat dialog <zone> <range>` and match
> against bg-wiki. Most entries below need **no probe at all** — the candidate
> lists here are still the right starting set, but you can now resolve them by
> reading rather than guessing.
>
> Worked example: `Fishermans_Heart.lua`, rebuilt from decoded csids 190-194.
> A live `!cs` is now only needed for large shared-program entities (see the
> known gap in `csidmsg.py`'s header) and for event param/option semantics.

This worksheet removes the guesswork from that: for each stub it lists the
**real csids owned by that exact NPC entity** in the DAT dump. The correct event
is in that list. Anything outside it is wrong by construction.

`FIRED` is the invented id the stub currently uses. Where FIRED is not in
CANDIDATES, the stub is provably firing a nonexistent or foreign event.

## How to use

Stand next to the NPC and run `!cs <id>` for each candidate, comparing what
renders against `xi-dat dialog <zone> <range>`. Per the puppet pacing rule:
one probe per round, wait for an explicit go, and listen 20-30s for the whole
cutscene before concluding what an id does.

Before using any confirmed id, run the two ship checks from the manifest:
zone `onEventFinish` collision, and NPC hijack (`grep -rn "\['<Npc>'\]" scripts/`).

## Determined without probing (8 NPCs)

These NPC entities own **exactly one** csid in the DAT, so that id is the
answer by construction — no probe needed. Every one of them shows the stub was
firing an event the NPC does not own.

| NPC | Zone | Stub fired | Real csid | Quest |
|---|---|---|---|---|
| `Olavia` | CRAWLERS_NEST | [52] | **6** | Escort_for_Hire |
| `Wanzo-Unzozo` | GARLAIGE_CITADEL | [61] | **60** | Escort_for_Hire |
| `Swift` | KAZHAM | [200, 201] | **10018** | A_Discerning_Eye |
| `Indescript_Markings` | PASHHOW_MARSHLANDS_S | [200] | **2** | Survival_of_the_Wisest |
| `Grin` | PORT_BASTOK | [140, 141] | **295** | A_Discerning_Eye |
| `Pygmalion` | PORT_WINDURST | [240, 241] | **10019** | A_Discerning_Eye |
| `Fortilace` | ROLANBERRY_FIELDS_S | [1010] | **200** | The_Swarm |
| `Cannau` | THE_ELDIEME_NECROPOLIS | [52] | **51** | Escort_for_Hire |

> Caveat: knowing *which* event is not the same as knowing its option/param
> semantics. Three of these quests (`A_Discerning_Eye` x3) drive both the offer
> and the turn-in through a single csid, so the branch must be selected by an
> event param. That still needs one live probe each before the flow can be
> written correctly — but the *cutscene id itself* is now settled.

## Scale of the problem

| | Count |
|---|---|
| Stub NPC-bindings analysed (quest x NPC x zone) | 117 |
| Fire at least one id the NPC actually owns | 14 |
| **Fire only ids the NPC does NOT own** | **103** |

> This supersedes the coarser zone-level figure in `STUB_REMOVAL_MANIFEST.md`.
> An id can exist in a zone yet belong to a different entity — e.g. `Grin` in
> Port Bastok fires 140/141, which exist in the zone but not on Grin (who owns
> only 295). Entity-level is the correct granularity; zone-level under-counts.

## 52 NPCs to probe, narrowest candidate set first

### Olavia — CRAWLERS_NEST (zone 197)
- entity `0x010C515F` (17584479)
- quests: Escort_for_Hire
- stub fires: [52]  <- **none of these exist on this NPC**
- **1 candidates:** [6]
- probe: `!cs 6`

### Wanzo-Unzozo — GARLAIGE_CITADEL (zone 200)
- entity `0x010C81A3` (17596835)
- quests: Escort_for_Hire
- stub fires: [61]  <- **none of these exist on this NPC**
- **1 candidates:** [60]
- probe: `!cs 60`

### Swift — KAZHAM (zone 250)
- entity `0x010FA07C` (17801340)
- quests: A_Discerning_Eye  **BARE CHECK**
- stub fires: [200, 201]  <- **none of these exist on this NPC**
- **1 candidates:** [10018]
- probe: `!cs 10018`

### Indescript_Markings — PASHHOW_MARSHLANDS_S (zone 90)
- entity `0x0105A303` (17146627)
- quests: Survival_of_the_Wisest
- stub fires: [200]  <- **none of these exist on this NPC**
- **1 candidates:** [2]
- probe: `!cs 2`

### Grin — PORT_BASTOK (zone 236)
- entity `0x010EC097` (17744023)
- quests: A_Discerning_Eye  **BARE CHECK**
- stub fires: [140, 141]  <- **none of these exist on this NPC**
- **1 candidates:** [295]
- probe: `!cs 295`

### Pygmalion — PORT_WINDURST (zone 240)
- entity `0x010F00BA` (17760442)
- quests: A_Discerning_Eye  **BARE CHECK**
- stub fires: [240, 241]  <- **none of these exist on this NPC**
- **1 candidates:** [10019]
- probe: `!cs 10019`

### Fortilace — ROLANBERRY_FIELDS_S (zone 91)
- entity `0x0105B31A` (17150746)
- quests: The_Swarm  **BARE CHECK**
- stub fires: [1010]  <- **none of these exist on this NPC**
- **1 candidates:** [200]
- probe: `!cs 200`

### Cannau — THE_ELDIEME_NECROPOLIS (zone 195)
- entity `0x010C31D6` (17576406)
- quests: Escort_for_Hire
- stub fires: [52]  <- **none of these exist on this NPC**
- **1 candidates:** [51]
- probe: `!cs 51`

### Callisto — GRAUBERG_S (zone 89)
- entity `0x0105935A` (17142618)
- quests: Succor_to_the_Sidhe  **BARE CHECK**
- stub fires: [1150]  <- **none of these exist on this NPC**
- **2 candidates:** [4000, 4001]
- probe: `!cs 4000` `!cs 4001`

### Laila — UPPER_JEUNO (zone 244)
- entity `0x010F40BA` (17776826)
- quests: A_Furious_Finale
- stub fires: [10123, 10124]  <- **none of these exist on this NPC**
- **2 candidates:** [10172, 10221]
- probe: `!cs 10172` `!cs 10221`

### Titus — BASTOK_MINES (zone 234)
- entity `0x010EA020` (17735712)
- quests: Fully_Mental_Alchemist
- stub fires: [900, 901]  <- **none of these exist on this NPC**
- **4 candidates:** [123, 587, 588, 589]
- probe: `!cs 123` `!cs 587` `!cs 588` `!cs 589`

### Halshaob — NASHMAU (zone 53)
- entity `0x0103507B` (16994427)
- quests: Royal_Painter_Escort, Scouting_the_Ashu_Talif, Targeting_the_Captain  **BARE CHECK**
- stub fires: [500, 510, 520]  <- **none of these exist on this NPC**
- **4 candidates:** [299, 300, 301, 302]
- probe: `!cs 299` `!cs 300` `!cs 301` `!cs 302`

### Magian_Moogle — RULUDE_GARDENS (zone 243)
- entity `0x010F30DC` (17772764)
- quests: A_Trial_in_Tandem
- stub fires: [10045]  <- **none of these exist on this NPC**
- **4 candidates:** [10135, 10136, 10137, 10161]
- probe: `!cs 10135` `!cs 10136` `!cs 10137` `!cs 10161`

### Rondipur — NORTHERN_SAN_DORIA (zone 231)
- entity `0x010E70EA` (17723626)
- quests: Escort_for_Hire
- stub fires: [722, 723]
- **5 candidates:** [721, 722, 723, 724, 725]
- probe: `!cs 721` `!cs 722` `!cs 723` `!cs 724` `!cs 725`

### Dehn_Harzhapan — PORT_WINDURST (zone 240)
- entity `0x010F00B9` (17760441)
- quests: Escort_for_Hire
- stub fires: [10019, 10020]  <- **none of these exist on this NPC**
- **5 candidates:** [10014, 10015, 10016, 10017, 10018]
- probe: `!cs 10014` `!cs 10015` `!cs 10016` `!cs 10017` `!cs 10018`

### Migliorozz — UPPER_JEUNO (zone 244)
- entity `0x010F4085` (17776773)
- quests: A_Reputation_in_Ruins
- stub fires: [10027, 10028]  <- **none of these exist on this NPC**
- **5 candidates:** [10019, 10020, 10021, 10022, 10026]
- probe: `!cs 10019` `!cs 10020` `!cs 10021` `!cs 10022` `!cs 10026`

### Selliste — BASTOK_MINES (zone 234)
- entity `0x010EA0B5` (17735861)
- quests: The_Wondrous_Whatchamacallit
- stub fires: [800, 801]  <- **none of these exist on this NPC**
- **6 candidates:** [591, 592, 593, 594, 595, 596]
- probe: `!cs 591` `!cs 592` `!cs 593` `!cs 594` `!cs 595` `!cs 596`

### Travonce — TAVNAZIAN_SAFEHOLD (zone 26)
- entity `0x0101A03A` (16883770)
- quests: The_Big_One  **BARE CHECK**
- stub fires: [300, 301]  <- **none of these exist on this NPC**
- **6 candidates:** [210, 211, 212, 213, 214, 215]
- probe: `!cs 210` `!cs 211` `!cs 212` `!cs 213` `!cs 214` `!cs 215`

### Khoto_Rokkorah — WINDURST_WATERS (zone 238)
- entity `0x010EE119` (17752345)
- quests: Babban_Ny_Mheillea  **BARE CHECK**
- stub fires: [989, 990]
- **6 candidates:** [988, 989, 990, 991, 992, 1016]
- probe: `!cs 988` `!cs 989` `!cs 990` `!cs 991` `!cs 992` `!cs 1016`

### Soun_Abralah — KAZHAM (zone 250)
- entity `0x010FA02A` (17801258)
- quests: The_Fireblom_Tree
- stub fires: [100, 101]
- **7 candidates:** [101, 102, 103, 104, 105, 106, 186]
- probe: `!cs 101` `!cs 102` `!cs 103` `!cs 104` `!cs 105` `!cs 106` `!cs 186`

### Rakuru-Rakoru — LOWER_JEUNO (zone 245)
- entity `0x010F50C0` (17780928)
- quests: The_Miraculous_Dale
- stub fires: [10079]
- **7 candidates:** [10078, 10079, 10080, 10081, 10082, 10083, 10094]
- probe: `!cs 10078` `!cs 10079` `!cs 10080` `!cs 10081` `!cs 10082` `!cs 10083` `!cs 10094`

### Trilok — PORT_BASTOK (zone 236)
- entity `0x010EC011` (17743889)
- quests: Escort_for_Hire
- stub fires: [45, 46]  <- **none of these exist on this NPC**
- **7 candidates:** [1, 44, 291, 292, 293, 294, 465]
- probe: `!cs 1` `!cs 44` `!cs 291` `!cs 292` `!cs 293` `!cs 294` `!cs 465`

### Katsunaga — MHAURA (zone 249)
- entity `0x010F9025` (17797157)
- quests: Fishermans_Heart  **BARE CHECK**
- stub fires: [100]  <- **none of these exist on this NPC**
- **8 candidates:** [190, 191, 192, 193, 194, 195, 196, 197]
- probe: `!cs 190` `!cs 191` `!cs 192` `!cs 193` `!cs 194` `!cs 195` `!cs 196` `!cs 197`

### Ponono — WINDURST_WATERS_S (zone 94)
- entity `0x0105E1C2` (17162690)
- quests: The_Young_and_the_Threadless  **BARE CHECK**
- stub fires: [1160]  <- **none of these exist on this NPC**
- **8 candidates:** [191, 192, 193, 194, 195, 196, 197, 198]
- probe: `!cs 191` `!cs 192` `!cs 193` `!cs 194` `!cs 195` `!cs 196` `!cs 197` `!cs 198`

### Salim — METALWORKS (zone 237)
- entity `0x010ED01F` (17747999)
- quests: Bait_and_Switch
- stub fires: [401, 402]  <- **none of these exist on this NPC**
- **9 candidates:** [400, 899, 900, 901, 908, 909, 910, 920, 930]
- probe: `!cs 400` `!cs 899` `!cs 900` `!cs 901` `!cs 908` `!cs 909` `!cs 910` `!cs 920` `!cs 930`

### Zoriboh — RABAO (zone 247)
- entity `0x010F7043` (17788995)
- quests: The_Search_for_Goldmane  **BARE CHECK**
- stub fires: [400, 401]  <- **none of these exist on this NPC**
- **9 candidates:** [119, 120, 121, 122, 123, 124, 127, 128, 129]
- probe: `!cs 119` `!cs 120` `!cs 121` `!cs 122` `!cs 123` `!cs 124` `!cs 127` `!cs 128` `!cs 129`

### Exoroche — SOUTHERN_SAN_DORIA_S (zone 80)
- entity `0x010501AA` (17105322)
- quests: Son_and_Father  **BARE CHECK**
- stub fires: [1170]  <- **none of these exist on this NPC**
- **9 candidates:** [156, 157, 158, 159, 160, 161, 162, 163, 164]
- probe: `!cs 156` `!cs 157` `!cs 158` `!cs 159` `!cs 160` `!cs 161` `!cs 162` `!cs 163` `!cs 164`

### Ropunono — WINDURST_WATERS (zone 238)
- entity `0x010EE01A` (17752090)
- quests: Heaven_Cent  **BARE CHECK**
- stub fires: [284, 285]
- **9 candidates:** [283, 284, 285, 288, 289, 292, 293, 296, 297]
- probe: `!cs 283` `!cs 284` `!cs 285` `!cs 288` `!cs 289` `!cs 292` `!cs 293` `!cs 296` `!cs 297`

### Adelbrecht — BASTOK_MARKETS_S (zone 87)
- entity `0x010571CF` (17134031)
- quests: A_Forbidden_Reunion, Champion_of_the_Dawn, Her_Memories_Verdure_Footfalls, The_Dawn_Also_Rises
- stub fires: [1310, 1320, 1330, 1340]  <- **none of these exist on this NPC**
- **10 candidates:** [63, 139, 140, 141, 142, 143, 162, 359, 360, 361]
- probe: `!cs 63` `!cs 139` `!cs 140` `!cs 141` `!cs 142` `!cs 143` `!cs 162` `!cs 359` `!cs 360` `!cs 361`

### Wahid — BASTOK_MARKETS_S (zone 87)
- entity `0x0105724A` (17134154)
- quests: A_Jewelers_Lament  **BARE CHECK**
- stub fires: [1100]  <- **none of these exist on this NPC**
- **10 candidates:** [335, 336, 337, 338, 339, 340, 341, 342, 343, 344]
- probe: `!cs 335` `!cs 336` `!cs 337` `!cs 338` `!cs 339` `!cs 340` `!cs 341` `!cs 342` `!cs 343` `!cs 344`

### Totoroon — NASHMAU (zone 53)
- entity `0x01035050` (16994384)
- quests: Totoroons_Treasure_Hunt  **BARE CHECK**
- stub fires: [130]  <- **none of these exist on this NPC**
- **10 candidates:** [246, 247, 248, 249, 250, 251, 252, 281, 303, 304]
- probe: `!cs 246` `!cs 247` `!cs 248` `!cs 249` `!cs 250` `!cs 251` `!cs 252` `!cs 281` `!cs 303` `!cs 304`

### Clarion_Star — PORT_BASTOK (zone 236)
- entity `0x010EC13C` (17744188)
- quests: Picture_Perfect  **BARE CHECK**
- stub fires: [443]
- **10 candidates:** [434, 435, 436, 437, 438, 442, 443, 457, 458, 464]
- probe: `!cs 434` `!cs 435` `!cs 436` `!cs 437` `!cs 438` `!cs 442` `!cs 443` `!cs 457` `!cs 458` `!cs 464`

### Marin — BASTOK_MARKETS (zone 235)
- entity `0x010EB074` (17739892)
- quests: All_by_Myself
- stub fires: [362, 363]
- **11 candidates:** [24, 361, 362, 363, 364, 365, 366, 432, 586, 587, 595]
- probe: `!cs 24` `!cs 361` `!cs 362` `!cs 363` `!cs 364` `!cs 365` `!cs 366` `!cs 432` `!cs 586` `!cs 587` `!cs 595`

### Rotih_Moalghett — FORT_KARUGO_NARUGO_S (zone 96)
- entity `0x010602CE` (17171150)
- quests: A_Manifest_Problem  **BARE CHECK**
- stub fires: [1230]  <- **none of these exist on this NPC**
- **11 candidates:** [101, 104, 105, 106, 107, 108, 109, 112, 113, 114, 232]
- probe: `!cs 101` `!cs 104` `!cs 105` `!cs 106` `!cs 107` `!cs 108` `!cs 109` `!cs 112` `!cs 113` `!cs 114` `!cs 232`

### Hishahma — AHT_URHGAN_WHITEGATE (zone 50)
- entity `0x01032142` (16982338)
- quests: Finding_Faults, The_Art_of_War  **BARE CHECK**
- stub fires: [110, 120]  <- **none of these exist on this NPC**
- **12 candidates:** [566, 567, 568, 569, 570, 571, 572, 577, 578, 799, 868, 878]
- probe: `!cs 566` `!cs 567` `!cs 568` `!cs 569` `!cs 570` `!cs 571` `!cs 572` `!cs 577` `!cs 578` `!cs 799` `!cs 868` `!cs 878`

### Offa — BASTOK_MARKETS_S (zone 87)
- entity `0x010571D2` (17134034)
- quests: A_Proper_Burial  **BARE CHECK**
- stub fires: [126, 128]
- **12 candidates:** [110, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138]
- probe: `!cs 110` `!cs 128` `!cs 129` `!cs 130` `!cs 131` `!cs 132` `!cs 133` `!cs 134` `!cs 135` `!cs 136` `!cs 137` `!cs 138`

### Robel-Akbel — WINDURST_WATERS_S (zone 94)
- entity `0x0105E218` (17162776)
- quests: A_Feast_for_Gnats, Howl_from_the_Heavens, The_Long_March_North  **BARE CHECK**
- stub fires: [1050, 1080, 1140]  <- **none of these exist on this NPC**
- **14 candidates:** [23, 24, 25, 134, 151, 153, 165, 168, 178, 179, 182, 186, 231, 233]
- probe: `!cs 23` `!cs 24` `!cs 25` `!cs 134` `!cs 151` `!cs 153` `!cs 165` `!cs 168` `!cs 178` `!cs 179` `!cs 182` `!cs 186` ...

### Offa — BASTOK_MARKETS (zone 235)
- entity `0x010EB02A` (17739818)
- quests: A_Proper_Burial  **BARE CHECK**
- stub fires: [125, 129, 130, 131]  <- **none of these exist on this NPC**
- **15 candidates:** [0, 124, 222, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486]
- probe: `!cs 0` `!cs 124` `!cs 222` `!cs 475` `!cs 476` `!cs 477` `!cs 478` `!cs 479` `!cs 480` `!cs 481` `!cs 482` `!cs 483` ...

### Nichais — SOUTHERN_SAN_DORIA_S (zone 80)
- entity `0x010502C7` (17105607)
- quests: Beast_from_the_East  **BARE CHECK**
- stub fires: [1240]  <- **none of these exist on this NPC**
- **15 candidates:** [71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 83, 178, 179, 180, 182]
- probe: `!cs 71` `!cs 72` `!cs 73` `!cs 74` `!cs 75` `!cs 76` `!cs 77` `!cs 78` `!cs 79` `!cs 80` `!cs 83` `!cs 178` ...

### Klara — BASTOK_MARKETS_S (zone 87)
- entity `0x010571F2` (17134066)
- quests: Bonds_of_Mythril, Fire_in_the_Hole, Quelling_the_Storm, Storm_on_the_Horizon  **BARE CHECK**
- stub fires: [1020, 1030, 1060, 1190]  <- **none of these exist on this NPC**
- **16 candidates:** [16, 27, 30, 34, 57, 60, 63, 65, 66, 71, 77, 78, 160, 184, 216, 608]
- probe: `!cs 16` `!cs 27` `!cs 30` `!cs 34` `!cs 57` `!cs 60` `!cs 63` `!cs 65` `!cs 66` `!cs 71` `!cs 77` `!cs 78` ...

### Magriffon — KAZHAM (zone 250)
- entity `0x010FA02E` (17801262)
- quests: Return_of_the_Depths
- stub fires: [400]  <- **none of these exist on this NPC**
- **16 candidates:** [143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 277, 299, 300, 301, 302]
- probe: `!cs 143` `!cs 144` `!cs 145` `!cs 146` `!cs 147` `!cs 148` `!cs 149` `!cs 150` `!cs 151` `!cs 152` `!cs 153` `!cs 277` ...

### Muckvix — LOWER_JEUNO (zone 245)
- entity `0x010F5019` (17780761)
- quests: Return_of_the_Depths
- stub fires: [300, 302]  <- **none of these exist on this NPC**
- **16 candidates:** [15, 46, 47, 48, 79, 80, 81, 99, 100, 184, 10094, 20087, 20088, 20091, 20092, 20093]
- probe: `!cs 15` `!cs 46` `!cs 47` `!cs 48` `!cs 79` `!cs 80` `!cs 81` `!cs 99` `!cs 100` `!cs 184` `!cs 10094` `!cs 20087` ...

### Tarnotik — OLDTON_MOVALPOLOS (zone 11)
- entity `0x0100B0D9` (16822489)
- quests: Return_of_the_Depths
- stub fires: [200]  <- **none of these exist on this NPC**
- **18 candidates:** [30, 31, 32, 33, 34, 42, 43, 44, 45, 54, 57, 67, 68, 69, 70, 71, 72, 73]
- probe: `!cs 30` `!cs 31` `!cs 32` `!cs 33` `!cs 34` `!cs 42` `!cs 43` `!cs 44` `!cs 45` `!cs 54` `!cs 57` `!cs 67` ...

### Lehko_Habhoka — WINDURST_WATERS_S (zone 94)
- entity `0x0105E236` (17162806)
- quests: A_Cait_Calls, A_Farewell_to_Felines, A_New_Menace, A_World_in_Flux, Ad_Infinitum, At_Journeys_End, Battle_on_a_New_Front, Between_a_Rock_and_Rift, Brace_for_the_Unknown, Crystal_Guardian, Drafted_by_the_Duchy, Endings_and_Beginnings, Glimmer_of_Hope, Guardian_of_the_Void, Healing_Herbs, No_Rest_for_the_Weary, Provenance, Redrafted_by_the_Duchy, Sins_of_the_Mothers, The_Forbidden_Path, The_Truth_Is_Out_There, Third_Tour_of_Duchy, Voidwalker_Op_126  **BARE CHECK**
- stub fires: [1000, 1090, 1130, 1210, 1400, 1410, 1420, 1430, 1440, 1450, 1460, 1470, 1480, 1490, 1500, 1510, 1520, 1530, 1540, 1550, 1560, 1570, 1580]  <- **none of these exist on this NPC**
- **18 candidates:** [21, 22, 23, 25, 158, 165, 168, 178, 179, 182, 184, 185, 186, 187, 232, 233, 234, 235]
- probe: `!cs 21` `!cs 22` `!cs 23` `!cs 25` `!cs 158` `!cs 165` `!cs 168` `!cs 178` `!cs 179` `!cs 182` `!cs 184` `!cs 185` ...

### Balakaf — AHT_URHGAN_WHITEGATE (zone 50)
- entity `0x01032141` (16982337)
- quests: Five_Seconds_of_Fame, Get_the_Picture  **BARE CHECK**
- stub fires: [100, 150]  <- **none of these exist on this NPC**
- **19 candidates:** [515, 545, 546, 553, 554, 555, 556, 557, 558, 559, 560, 561, 586, 856, 857, 872, 873, 880, 881]
- probe: `!cs 515` `!cs 545` `!cs 546` `!cs 553` `!cs 554` `!cs 555` `!cs 556` `!cs 557` `!cs 558` `!cs 559` `!cs 560` `!cs 561` ...

### Ayame — METALWORKS (zone 237)
- entity `0x010ED02F` (17748015)
- quests: Return_of_the_Depths
- stub fires: [502]  <- **none of these exist on this NPC**
- **33 candidates:** [701, 712, 715, 718, 720, 744, 748, 749, 761, 762, 782, 802, 803, 804, 805, 813, 845, 859, 860, 875, 876, 879, 880, 881, 882, 896, 935, 936, 943, 944, 985, 1050, 1054]
- probe: `!cs 701` `!cs 712` `!cs 715` `!cs 718` `!cs 720` `!cs 744` `!cs 748` `!cs 749` `!cs 761` `!cs 762` `!cs 782` `!cs 802` ...

### Dhea_Prandoleh — WINDURST_WATERS_S (zone 94)
- entity `0x0105E1FF` (17162751)
- quests: Manifest_Destiny, When_One_Man_Is_Not_Enough  **BARE CHECK**
- stub fires: [1040, 1200]  <- **none of these exist on this NPC**
- **33 candidates:** [20, 26, 31, 32, 34, 35, 36, 37, 42, 43, 103, 106, 128, 129, 131, 132, 133, 134, 135, 136, 139, 151, 158, 159, 160, 164, 166, 167, 168, 231, 232, 236, 530]
- probe: `!cs 20` `!cs 26` `!cs 31` `!cs 32` `!cs 34` `!cs 35` `!cs 36` `!cs 37` `!cs 42` `!cs 43` `!cs 103` `!cs 106` ...

### Raibaht — METALWORKS (zone 237)
- entity `0x010ED02C` (17748012)
- quests: Hyper_Active, The_Naming_Game
- stub fires: [502, 503, 504]
- **36 candidates:** [501, 503, 509, 510, 751, 755, 760, 764, 798, 849, 852, 853, 854, 855, 857, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 897, 898, 933, 979, 987, 990, 991, 992, 1035, 1036]
- probe: `!cs 501` `!cs 503` `!cs 509` `!cs 510` `!cs 751` `!cs 755` `!cs 760` `!cs 764` `!cs 798` `!cs 849` `!cs 852` `!cs 853` ...

### Faulpie — SOUTHERN_SAN_DORIA (zone 230)
- entity `0x010E6053` (17719379)
- quests: A_Generous_General, An_Affable_Adamantking, An_Understanding_Overlord  **BARE CHECK**
- stub fires: [700, 710, 720]  <- **none of these exist on this NPC**
- **39 candidates:** [648, 649, 760, 761, 762, 763, 764, 765, 770, 771, 772, 773, 774, 775, 914, 944, 3558, 3559, 3560, 3561, 3562, 3563, 3564, 3565, 3567, 3568, 3571, 3572, 3576, 3577, 3580, 3581, 3582, 3583, 3587, 3588, 3589, 3591, 3592]
- probe: `!cs 648` `!cs 649` `!cs 760` `!cs 761` `!cs 762` `!cs 763` `!cs 764` `!cs 765` `!cs 770` `!cs 771` `!cs 772` `!cs 773` ...

### Gentle_Tiger — BASTOK_MARKETS_S (zone 87)
- entity `0x010571D7` (17134039)
- quests: Beneath_the_Mask, Burden_of_Suspicion, Honor_Under_Fire, The_Truth_Lies_Hid, What_Price_Loyalty  **BARE CHECK**
- stub fires: [1070, 1110, 1120, 1180, 1220]  <- **none of these exist on this NPC**
- **47 candidates:** [16, 17, 27, 28, 30, 31, 34, 35, 46, 47, 57, 58, 59, 61, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 109, 160, 161, 176, 184, 186, 187, 190, 191, 212, 213, 214, 216, 351, 352, 353, 354, 355, 356, 357, 606, 607, 608]
- probe: `!cs 16` `!cs 17` `!cs 27` `!cs 28` `!cs 30` `!cs 31` `!cs 34` `!cs 35` `!cs 46` `!cs 47` `!cs 57` `!cs 58` ...

### Koru-Moru — WINDURST_WALLS (zone 239)
- entity `0x010EF021` (17756193)
- quests: Nothing_Matters
- stub fires: [350, 351]  <- **none of these exist on this NPC**
- **49 candidates:** [193, 194, 197, 198, 199, 211, 212, 213, 214, 215, 216, 224, 225, 226, 227, 228, 237, 238, 239, 241, 242, 244, 285, 286, 287, 345, 346, 348, 349, 394, 404, 405, 407, 408, 410, 411, 412, 414, 416, 417, 418, 419, 420, 442, 443, 510, 511, 548, 573]
- probe: `!cs 193` `!cs 194` `!cs 197` `!cs 198` `!cs 199` `!cs 211` `!cs 212` `!cs 213` `!cs 214` `!cs 215` `!cs 216` `!cs 224` ...

### Luto_Mewrilah — UPPER_JEUNO (zone 244)
- entity `0x010F408C` (17776780)
- quests: A_Trial_in_Tandem, Chameleon_Capers, Girl_in_the_Looking_Glass  **BARE CHECK**
- stub fires: [10035, 10037, 10044]
- **64 candidates:** [10031, 10032, 10033, 10034, 10039, 10041, 10042, 10043, 10044, 10045, 10046, 10047, 10048, 10049, 10050, 10051, 10052, 10053, 10055, 10056, 10057, 10058, 10059, 10060, 10061, 10062, 10063, 10064, 10065, 10066, 10067, 10068, 10069, 10070, 10071, 10072, 10073, 10074, 10075, 10076, 10077, 10078, 10079, 10080, 10081, 10082, 10085, 10174, 10175, 10192, 10193, 10194, 10195, 10196, 10197, 10198, 10199, 10200, 10201, 10202, 10203, 10205, 10207, 10216]
- probe: `!cs 10031` `!cs 10032` `!cs 10033` `!cs 10034` `!cs 10039` `!cs 10041` `!cs 10042` `!cs 10043` `!cs 10044` `!cs 10045` `!cs 10046` `!cs 10047` ...

