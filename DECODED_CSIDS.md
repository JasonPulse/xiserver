# Decoded CSIDs for all 93 remaining stub quests

Produced offline with `UpdateExtractor/xidat/csidmsg.py` — no puppet needed.
For each stub: the NPC it binds, the csid it *currently fires*, and the csids that
NPC **actually owns**, with the dialog each one emits. Match the dialog against
bg-wiki and the correct event is unambiguous.

Before shipping any id, run the two ship checks from `STUB_REMOVAL_MANIFEST.md`:
zone `onEventFinish` collision and NPC hijack.

`WRONG` = the id the stub fires is not owned by that NPC. This is true for 103 of
117 bindings.
---

## 1. `scripts/quests/ahtUrhgan/A_Stygian_Pact.lua`

**Nashmeira** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x010320A8`  
stub fires `[320]`  ← **WRONG — NPC does not own it**

- csid **825** → msgs [891, 921, 968, 1076, 1542, 1592]  
  `[891] Please claim your item before maintenance for the February 2022 version update begins.`

## 2. `scripts/quests/ahtUrhgan/Coming_Full_Circle.lua`

**Paparoon** — NASHMAU (zone 53), entity `0x0103505E`  
stub fires `[230]`  ← **WRONG — NPC does not own it**

- csid **28** → msgs [11739]  
  `[11739] What will you ask about?  Alexandrite gems[./ (done).] Wyrmseeker of Areuhat[./ (done).] Assaul...`
- csid **29** → msgs [11814, 11815, 11816]  
  `[11814] If you trade the  to Paparoon, all  you have entrusted to him thus far will be lost.`
- csid **334** → msgs [11798, 11805, 11806]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **335** → msgs [11798, 11805, 11807]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **336** → msgs [11798, 11805, 11808]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **337** → msgs [11798, 11805, 11809]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **338** → msgs [11798, 11805, 11810]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`

## 3. `scripts/quests/ahtUrhgan/Duties_Tasks_and_Deeds.lua`

**Paparoon** — NASHMAU (zone 53), entity `0x0103505E`  
stub fires `[210]`  ← **WRONG — NPC does not own it**

- csid **28** → msgs [11739]  
  `[11739] What will you ask about?  Alexandrite gems[./ (done).] Wyrmseeker of Areuhat[./ (done).] Assaul...`
- csid **29** → msgs [11814, 11815, 11816]  
  `[11814] If you trade the  to Paparoon, all  you have entrusted to him thus far will be lost.`
- csid **334** → msgs [11798, 11805, 11806]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **335** → msgs [11798, 11805, 11807]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **336** → msgs [11798, 11805, 11808]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **337** → msgs [11798, 11805, 11809]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`
- csid **338** → msgs [11798, 11805, 11810]  
  `[11798] Trade the blank memoire to the Rune of Release which appears following successful completion of...`

## 4. `scripts/quests/ahtUrhgan/Finding_Faults.lua`

**Hishahma** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x01032142`  
stub fires `[110]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **567** → msgs [6799, 6801, 6803, 6806, 6905, 6912]…  
  `[6799] According to my research, there are a number of Lamiae by the viridescent bogs in the area.`
- csid **569** → msgs [6817]  
  `[6817] A special force is now being put together based on the information you have provided us. It is ...`
- csid **572** → msgs [6826, 6830, 6831, 6832, 6833, 6834]…  
  `[6826] We owe our success on the battlefield to you. Please accept this as a token of our appreciation...`
- csid **878** → msgs [7356, 7357, 7358]  
  `[7356] The other day, I was informed by one of our citizens that a member of my unit was breaking rank...`

## 5. `scripts/quests/ahtUrhgan/Five_Seconds_of_Fame.lua`

**Balakaf** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x01032141`  
stub fires `[150]`  ← **WRONG — NPC does not own it**

- csid **515** → msgs [4959, 4960]  
  `[4959] Ye be wantin' a scrap of paper with a letter on it? Why, I could write such a thing for ye mese...`
- csid **553** → msgs [5132, 5133]  
  `[5132] Why, I forgot to mention to ye a mighty important piece of information. Ye be needin'   t' take...`
- csid **554** → msgs [5193]  
  `[5193] Thanks for yer trouble. I may ask more of ye later.`
- csid **555** → msgs [5141]  
  `[5141] I'm all out of ! I'll have t' order more, now.`
- csid **556** → msgs [5140]  
  `[5140] Looking at the picture ye brought me has made me feel like a young man again...`
- csid **557** → msgs [5142, 5143]  
  `[5142] Why, this be a genuine !`
- csid **558** → msgs [5144, 5145]  
  `[5144] I had t' dismantle the  for the time being. It'll take a mite until it's up and working again, ...`
- csid **559** → msgs [5174, 5175]  
  `[5174] Someday ye'll enjoy reminiscing as much as I do, so be sure to visit as many places as ye can w...`
| _...5 more csids_ | | |

## 6. `scripts/quests/ahtUrhgan/Forging_a_New_Myth.lua`

**Nashmeira** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x010320A8`  
stub fires `[220]`  ← **WRONG — NPC does not own it**

- csid **825** → msgs [891, 921, 968, 1076, 1542, 1592]  
  `[891] Please claim your item before maintenance for the February 2022 version update begins.`

## 7. `scripts/quests/ahtUrhgan/Get_the_Picture.lua`

**Balakaf** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x01032141`  
stub fires `[100]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **515** → msgs [4959, 4960]  
  `[4959] Ye be wantin' a scrap of paper with a letter on it? Why, I could write such a thing for ye mese...`
- csid **553** → msgs [5132, 5133]  
  `[5132] Why, I forgot to mention to ye a mighty important piece of information. Ye be needin'   t' take...`
- csid **554** → msgs [5193]  
  `[5193] Thanks for yer trouble. I may ask more of ye later.`
- csid **555** → msgs [5141]  
  `[5141] I'm all out of ! I'll have t' order more, now.`
- csid **556** → msgs [5140]  
  `[5140] Looking at the picture ye brought me has made me feel like a young man again...`
- csid **557** → msgs [5142, 5143]  
  `[5142] Why, this be a genuine !`
- csid **558** → msgs [5144, 5145]  
  `[5144] I had t' dismantle the  for the time being. It'll take a mite until it's up and working again, ...`
- csid **559** → msgs [5174, 5175]  
  `[5174] Someday ye'll enjoy reminiscing as much as I do, so be sure to visit as many places as ye can w...`
| _...5 more csids_ | | |

## 8. `scripts/quests/ahtUrhgan/Royal_Painter_Escort.lua`

**Halshaob** — NASHMAU (zone 53), entity `0x0103507B`  
stub fires `[510]`  ← **WRONG — NPC does not own it**

- csid **299** → msgs [11234, 11235]  
  `[11234] <Sigh>. This assignment'll be the end o' me. Maybe I can grab a short nap over here...`
- csid **300** → msgs [11236, 11237, 11238, 11239, 11240, 11241]…  
  `[11236] This assignment'll be the end o' me. Maybe I can unload it onto some other unsuspectin'...`
- csid **301** → msgs [11268, 11269, 11270, 11271, 11272, 11273]…  
  `[11268] I knew you'd show up again. Let's get down to business.`
- csid **302** → msgs [11277, 11278, 11279]  
  `[11277] Right, so I'm takin' yer   in exchange fer lettin' you take on “.”`

## 9. `scripts/quests/ahtUrhgan/Scouting_the_Ashu_Talif.lua`

**Halshaob** — NASHMAU (zone 53), entity `0x0103507B`  
stub fires `[500]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **299** → msgs [11234, 11235]  
  `[11234] <Sigh>. This assignment'll be the end o' me. Maybe I can grab a short nap over here...`
- csid **300** → msgs [11236, 11237, 11238, 11239, 11240, 11241]…  
  `[11236] This assignment'll be the end o' me. Maybe I can unload it onto some other unsuspectin'...`
- csid **301** → msgs [11268, 11269, 11270, 11271, 11272, 11273]…  
  `[11268] I knew you'd show up again. Let's get down to business.`
- csid **302** → msgs [11277, 11278, 11279]  
  `[11277] Right, so I'm takin' yer   in exchange fer lettin' you take on “.”`

## 10. `scripts/quests/ahtUrhgan/Targeting_the_Captain.lua`

**Halshaob** — NASHMAU (zone 53), entity `0x0103507B`  
stub fires `[520]`  ← **WRONG — NPC does not own it**

- csid **299** → msgs [11234, 11235]  
  `[11234] <Sigh>. This assignment'll be the end o' me. Maybe I can grab a short nap over here...`
- csid **300** → msgs [11236, 11237, 11238, 11239, 11240, 11241]…  
  `[11236] This assignment'll be the end o' me. Maybe I can unload it onto some other unsuspectin'...`
- csid **301** → msgs [11268, 11269, 11270, 11271, 11272, 11273]…  
  `[11268] I knew you'd show up again. Let's get down to business.`
- csid **302** → msgs [11277, 11278, 11279]  
  `[11277] Right, so I'm takin' yer   in exchange fer lettin' you take on “.”`

## 11. `scripts/quests/ahtUrhgan/The_Art_of_War.lua`

**Hishahma** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x01032142`  
stub fires `[120]`  ← **WRONG — NPC does not own it**

- csid **567** → msgs [6799, 6801, 6803, 6806, 6905, 6912]…  
  `[6799] According to my research, there are a number of Lamiae by the viridescent bogs in the area.`
- csid **569** → msgs [6817]  
  `[6817] A special force is now being put together based on the information you have provided us. It is ...`
- csid **572** → msgs [6826, 6830, 6831, 6832, 6833, 6834]…  
  `[6826] We owe our success on the battlefield to you. Please accept this as a token of our appreciation...`
- csid **878** → msgs [7356, 7357, 7358]  
  `[7356] The other day, I was informed by one of our citizens that a member of my unit was breaking rank...`

## 12. `scripts/quests/ahtUrhgan/The_Rider_Cometh.lua`

**Nashmeira** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x010320A8`  
stub fires `[300]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **825** → msgs [891, 921, 968, 1076, 1542, 1592]  
  `[891] Please claim your item before maintenance for the February 2022 version update begins.`

## 13. `scripts/quests/ahtUrhgan/Totoroons_Treasure_Hunt.lua`

**Totoroon** — NASHMAU (zone 53), entity `0x01035050`  
stub fires `[130]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **248** → msgs [10676]  
  `[10676] Yooo forgot? Looook in [Jajooom Wooodlands/Bhaplooo Thickets/Cadaaada Mire/Mount Zhayooomie].`
- csid **250** → msgs [10679]  
  `[10679] Nooo nice sweets yet?`
- csid **251** → msgs [10680]  
  `[10680] Yooomy shooogar! Thank yooo! Give sweet, get hint!`
- csid **252** → msgs [10672]  
  `[10672] Totoroon let yooo know when yooo bring shooogary thing.`

## 14. `scripts/quests/ahtUrhgan/Unwavering_Resolve.lua`

**Nashmeira** — AHT_URHGAN_WHITEGATE (zone 50), entity `0x010320A8`  
stub fires `[310]`  ← **WRONG — NPC does not own it**

- csid **825** → msgs [891, 921, 968, 1076, 1542, 1592]  
  `[891] Please claim your item before maintenance for the February 2022 version update begins.`

## 15. `scripts/quests/bastok/A_Discerning_Eye.lua`

**Grin** — PORT_BASTOK (zone 236), entity `0x010EC097`  
stub fires `[140]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **295** → msgs [8868, 8869, 8870, 8871, 8872, 8873]…  
  `[8868] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Grin** — PORT_BASTOK (zone 236), entity `0x010EC097`  
stub fires `[141]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **295** → msgs [8868, 8869, 8870, 8871, 8872, 8873]…  
  `[8868] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Grin** — PORT_BASTOK (zone 236), entity `0x010EC097`  
stub fires `[140]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **295** → msgs [8868, 8869, 8870, 8871, 8872, 8873]…  
  `[8868] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

## 16. `scripts/quests/bastok/A_Proper_Burial.lua`

**Offa** — BASTOK_MARKETS (zone 235), entity `0x010EB02A`  
stub fires `[125]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **124** → msgs [7500, 7501, 7502, 7503, 7504]  
  `[7500] <Yawn> Guess I'll skip work today, too...`
- csid **222** → msgs [7505, 7506, 7507, 7508, 7509]  
  `[7505] Hungry Wolf told you about ? Yeah, he's a real gourmand, that one. Much like myself.`
- csid **476** → msgs [12403]  
  `[12403] I was devastated when I found our time capsule. Battered and empty... Those goblins are the sco...`
- csid **478** → msgs [12404]  
  `[12404] A while back I went to dig up our letters but realized I had totally forgotten where they were ...`
- csid **480** → msgs [12407]  
  `[12407] If only we had put   in the capsule as well. Maybe that would have diverted their attention awa...`
- csid **482** → msgs [12411]  
  `[12411] A false-bottom box... That would have worked. Why do I always think of these things after the f...`
- csid **484** → msgs [12420]  
  `[12420] Well, that's all going to change from now on! M-my not changing, that is...`
- csid **486** → msgs [12425, 12426]  
  `[12425] The time capsule? Oh, yes--I already made sure that everyone got their letter.`

**Offa** — BASTOK_MARKETS_S (zone 87), entity `0x010571D2`  
stub fires `[126, 128]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **110** → msgs [11271]  
  `[11271] I can't even sleep at night when I start thinking about the beastmen attacking the city... How ...`
- csid **129** → msgs [11269]  
  `[11269] Of course! I'll just have my father bury it here in the city. Why didn't I think of that?`
- csid **130** → msgs [11270]  
  `[11270] Of course! I'll just have my father cover up the burial spot with a rock! Why didn't I think of...`
- csid **132** → msgs [11274]  
  `[11274] I sure do feel a lot better, knowing our capsule's resting place is hidden under a rock. Thank ...`
- csid **134** → msgs [11278]  
  `[11278] I had totally forgotten how crazy goblins are for fish bones. Thanks again for the great advice...`
- csid **136** → msgs [11282]  
  `[11282] I really can't thank you enough for all your help!`
- csid **138** → msgs [11285]  
  `[11285] Don't worry! I'll make sure your  gets buried along with the letters.`

**Offa** — BASTOK_MARKETS (zone 235), entity `0x010EB02A`  
stub fires `[129, 130, 131]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **124** → msgs [7500, 7501, 7502, 7503, 7504]  
  `[7500] <Yawn> Guess I'll skip work today, too...`
- csid **222** → msgs [7505, 7506, 7507, 7508, 7509]  
  `[7505] Hungry Wolf told you about ? Yeah, he's a real gourmand, that one. Much like myself.`
- csid **476** → msgs [12403]  
  `[12403] I was devastated when I found our time capsule. Battered and empty... Those goblins are the sco...`
- csid **478** → msgs [12404]  
  `[12404] A while back I went to dig up our letters but realized I had totally forgotten where they were ...`
- csid **480** → msgs [12407]  
  `[12407] If only we had put   in the capsule as well. Maybe that would have diverted their attention awa...`
- csid **482** → msgs [12411]  
  `[12411] A false-bottom box... That would have worked. Why do I always think of these things after the f...`
- csid **484** → msgs [12420]  
  `[12420] Well, that's all going to change from now on! M-my not changing, that is...`
- csid **486** → msgs [12425, 12426]  
  `[12425] The time capsule? Oh, yes--I already made sure that everyone got their letter.`

## 17. `scripts/quests/bastok/All_by_Myself.lua`

**Marin** — BASTOK_MARKETS (zone 235), entity `0x010EB074`  
stub fires `[362]`

- csid **361** → msgs [8453, 8455, 8456, 8457, 8460, 8462]…  
  `[8453] Are you sure you'll be all right? I could always go for you.`
- csid **362** → msgs [8473, 8475, 8477, 8484, 8485, 8486]  
  `[8473] Oh, thank you thank you thank you thank you! Now I can rest easy knowing that a powerful advent...`
- csid **363** → msgs [8473, 8475, 8477, 8478, 8486]  
  `[8473] Oh, thank you thank you thank you thank you! Now I can rest easy knowing that a powerful advent...`
- csid **364** → msgs [8487, 8488]  
  `[8487] Thank you so much for watching over my brother. Now that the test is over, he seems to be in a ...`
- csid **365** → msgs [8475, 8479, 8480, 8481]  
  `[8475] The Wadi is an evil place crawling with ferocious beasts. Don't allow any of them to lay a fing...`
- csid **366** → msgs [8490]  
  `[8490] I do hope that you pass...`

**Marin** — BASTOK_MARKETS (zone 235), entity `0x010EB074`  
stub fires `[363]`

- csid **361** → msgs [8453, 8455, 8456, 8457, 8460, 8462]…  
  `[8453] Are you sure you'll be all right? I could always go for you.`
- csid **362** → msgs [8473, 8475, 8477, 8484, 8485, 8486]  
  `[8473] Oh, thank you thank you thank you thank you! Now I can rest easy knowing that a powerful advent...`
- csid **363** → msgs [8473, 8475, 8477, 8478, 8486]  
  `[8473] Oh, thank you thank you thank you thank you! Now I can rest easy knowing that a powerful advent...`
- csid **364** → msgs [8487, 8488]  
  `[8487] Thank you so much for watching over my brother. Now that the test is over, he seems to be in a ...`
- csid **365** → msgs [8475, 8479, 8480, 8481]  
  `[8475] The Wadi is an evil place crawling with ferocious beasts. Don't allow any of them to lay a fing...`
- csid **366** → msgs [8490]  
  `[8490] I do hope that you pass...`

## 18. `scripts/quests/bastok/Bait_and_Switch.lua`

**Salim** — METALWORKS (zone 237), entity `0x010ED01F`  
stub fires `[401, 402]`  ← **WRONG — NPC does not own it**

- csid **400** → msgs [7507]  
  `[7507] I must raise the Metalworks output before my term here ends. I should start by raising everyone...`

## 19. `scripts/quests/bastok/Escort_for_Hire.lua`

**Trilok** — PORT_BASTOK (zone 236), entity `0x010EC011`  
stub fires `[45]`  ← **WRONG — NPC does not own it**

- csid **44** → msgs [7483]  
  `[7483] Hey, you a rookie? If I were you, I'd go hunt lizards. They're worth the trouble--take my word ...`
- csid **291** → msgs [8855, 8856, 8857, 8858]  
  `[8855] Hey, I know you. You're that adventurer that everybody's been talking about. I've got a proposi...`
- csid **292** → msgs [8859, 8860, 8861, 8862]  
  `[8859] That Olavia said she'll be waiting at the entrance of the Crawlers' Nest, but she didn't say wh...`
- csid **293** → msgs [8863]  
  `[8863] Oh, ! I heard you met up with Olavia and helped her out. Here's your reward.`
- csid **294** → msgs [8864]  
  `[8864] Hmmm... I'm sorry, but there just isn't any good work these days. If I get anything, I'll hold ...`

**Olavia** — CRAWLERS_NEST (zone 197), entity `0x010C515F`  
stub fires `[52]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

**Trilok** — PORT_BASTOK (zone 236), entity `0x010EC011`  
stub fires `[46]`  ← **WRONG — NPC does not own it**

- csid **44** → msgs [7483]  
  `[7483] Hey, you a rookie? If I were you, I'd go hunt lizards. They're worth the trouble--take my word ...`
- csid **291** → msgs [8855, 8856, 8857, 8858]  
  `[8855] Hey, I know you. You're that adventurer that everybody's been talking about. I've got a proposi...`
- csid **292** → msgs [8859, 8860, 8861, 8862]  
  `[8859] That Olavia said she'll be waiting at the entrance of the Crawlers' Nest, but she didn't say wh...`
- csid **293** → msgs [8863]  
  `[8863] Oh, ! I heard you met up with Olavia and helped her out. Here's your reward.`
- csid **294** → msgs [8864]  
  `[8864] Hmmm... I'm sorry, but there just isn't any good work these days. If I get anything, I'll hold ...`

## 20. `scripts/quests/bastok/Fully_Mental_Alchemist.lua`

**Titus** — BASTOK_MINES (zone 234), entity `0x010EA020`  
stub fires `[900]`  ← **WRONG — NPC does not own it**

- csid **123** → msgs [7089, 7094, 7095, 7096, 7097, 7098]…  
  `[7089] Request...?  [Advanced synthesis/Synthesis/Synthesis] image support. Information on synthesis m...`
- csid **587** → msgs [14158, 14159, 14160, 14161, 14162, 14163]…  
  `[14158] Ahhh, the pain! The sheer agony! Here I stand on the verge of the single greatest breakthrough ...`
- csid **588** → msgs [14173, 14174]  
  `[14173] My adventuring friend! Have you managed to secure the enchanted gold dust I seek? Why, we mustn...`
- csid **589** → msgs [14175]  
  `[14175] Wait, could it be!? That self-satisfied expression! That sprightly gait! No, no, don't tell me,...`

**Titus** — BASTOK_MINES (zone 234), entity `0x010EA020`  
stub fires `[901]`  ← **WRONG — NPC does not own it**

- csid **123** → msgs [7089, 7094, 7095, 7096, 7097, 7098]…  
  `[7089] Request...?  [Advanced synthesis/Synthesis/Synthesis] image support. Information on synthesis m...`
- csid **587** → msgs [14158, 14159, 14160, 14161, 14162, 14163]…  
  `[14158] Ahhh, the pain! The sheer agony! Here I stand on the verge of the single greatest breakthrough ...`
- csid **588** → msgs [14173, 14174]  
  `[14173] My adventuring friend! Have you managed to secure the enchanted gold dust I seek? Why, we mustn...`
- csid **589** → msgs [14175]  
  `[14175] Wait, could it be!? That self-satisfied expression! That sprightly gait! No, no, don't tell me,...`

## 21. `scripts/quests/bastok/Hyper_Active.lua`

**Raibaht** — METALWORKS (zone 237), entity `0x010ED02C`  
stub fires `[502]`  ← **WRONG — NPC does not own it**

- csid **501** → msgs [7525]  
  `[7525] Do not bother the chief. Every second he spends away from his research is a loss to the Metalwo...`
- csid **510** → msgs [7925]  
  `[7925] An invitation from the Steaming Sheep? Hmm... Please do not mention this to the Chief. But tell...`
- csid **751** → msgs [8562, 8563, 8564, 8565, 8566]  
  `[8562] You're a dark knight, I see. I have a favor to ask that may be of some interest to you.`
- csid **872** → msgs [9953, 9954]  
  `[9953] The adventurer we seek has been ordered to travel to Delkfutt's Tower and defeat a monster know...`
- csid **873** → msgs [9962, 9963, 9964]  
  `[9962] Until recently, Chief Cid had been working on what he called a “semiperpetual motion engine.” H...`
- csid **874** → msgs [9987]  
  `[9987] .... If you ever wish to...rethink the name you have given the chief's airship, please bring an...`
- csid **933** → msgs [10685, 10690]  
  `[10685] 's badge flashes brightly.`

**Raibaht** — METALWORKS (zone 237), entity `0x010ED02C`  
stub fires `[503]`  ← **WRONG — NPC does not own it**

- csid **501** → msgs [7525]  
  `[7525] Do not bother the chief. Every second he spends away from his research is a loss to the Metalwo...`
- csid **510** → msgs [7925]  
  `[7925] An invitation from the Steaming Sheep? Hmm... Please do not mention this to the Chief. But tell...`
- csid **751** → msgs [8562, 8563, 8564, 8565, 8566]  
  `[8562] You're a dark knight, I see. I have a favor to ask that may be of some interest to you.`
- csid **872** → msgs [9953, 9954]  
  `[9953] The adventurer we seek has been ordered to travel to Delkfutt's Tower and defeat a monster know...`
- csid **873** → msgs [9962, 9963, 9964]  
  `[9962] Until recently, Chief Cid had been working on what he called a “semiperpetual motion engine.” H...`
- csid **874** → msgs [9987]  
  `[9987] .... If you ever wish to...rethink the name you have given the chief's airship, please bring an...`
- csid **933** → msgs [10685, 10690]  
  `[10685] 's badge flashes brightly.`

## 22. `scripts/quests/bastok/Return_of_the_Depths.lua`

**Ayame** — METALWORKS (zone 237), entity `0x010ED02F`  
stub fires `[502]`  ← **WRONG — NPC does not own it**

- csid **701** → msgs [7528]  
  `[7528] These cannons are nothing more than symbols now, and that is the way it should be.`
- csid **712** → msgs [7599, 7600, 7601, 7602, 7603, 7604]…  
  `[7599] You have a letter from the Chief Engineer? May I see it?`
- csid **718** → msgs [7814]  
  `[7814] The rendezvous point is across the Pashhow Marshlands, and right inside Beadeaux. Be prepared f...`
- csid **744** → msgs [8136]  
  `[8136] There is an emergency. Promptly make your way to the President's Office. Ask Naji, and he will ...`
- csid **804** → msgs [9104]  
  `[9104] Viresefilant...? What is going on here? I must speak with Senator Alois...`
- csid **860** → msgs [9932, 9933]  
  `[9932] A beastman lair has appeared in North Gustaberg. The Goblins living in this lair are a separate...`
- csid **876** → msgs [10000, 10001, 10002]  
  `[10000] He would like to employ an adventurer to communicate with the Moblins.`
- csid **880** → msgs [10025]  
  `[10025] Find the one in Movalpolos who can help us with the Moblin language.`
| _...6 more csids_ | | |

**Muckvix** — LOWER_JEUNO (zone 245), entity `0x010F5019`  
stub fires `[300, 302]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

**Magriffon** — KAZHAM (zone 250), entity `0x010FA02E`  
stub fires `[400]`  ← **WRONG — NPC does not own it**

- csid **143** → msgs [10250, 10251, 10252, 10253, 10254, 10255]…  
  `[10250] Beautiful maiden! Never did I dream that such a vision of loveliness would bedazzle mine eye in...`
- csid **144** → msgs [10258, 10259, 10260, 10261, 10262, 10263]…  
  `[10258] <Sigh>`
- csid **145** → msgs [10280]  
  `[10280] If I only had  gil, then I could complete my mission.`
- csid **146** → msgs [10281, 10282, 10283, 10284, 10285]  
  `[10281] It's a miracle! The Dawn Goddess has shone her light down upon me!`
- csid **147** → msgs [10286, 10287]  
  `[10286] Now I can complete my top-secret mission.`
- csid **148** → msgs [10258, 10259, 10260, 10292, 10293, 10294]…  
  `[10258] <Sigh>`
- csid **149** → msgs [10311, 10312]  
  `[10311] I will exchange with you the  that I received in Norg for a mere  gil.`
- csid **150** → msgs [10313, 10314, 10315, 10316, 10317]  
  `[10313] Oh! You have made a noble decision. I am, once again, in your debt.`
| _...6 more csids_ | | |

**Tarnotik** — OLDTON_MOVALPOLOS (zone 11), entity `0x0100B0D9`  
stub fires `[200]`  ← **WRONG — NPC does not own it**

- csid **30** → msgs [7572]  
  `[7572] ...No fun... Nothing around but rocks... I want to see pretty things... Crazy things...`
- csid **31** → msgs [7573, 7574, 7575, 7576, 7577, 7578]  
  `[7573] I'm Tarnotik.`
- csid **32** → msgs [7579, 7580, 7581, 7582]  
  `[7579] !`
- csid **33** → msgs [7583]  
  `[7583] Every day fun for Tarnotik! I loves my crazy goodies! I loves my crazy adventurer friend!`
- csid **34** → msgs [7577, 7578, 7586, 7587]  
  `[7577] You give me crazy flower and I take you to Shaft 2716.`
- csid **54** → msgs [7938, 7939, 7940, 7941, 7942, 7944]  
  `[7938] Hey! Hey! Hey! Crazy adventurer holding crazy lever! Crazy adventurer not supposed to have craz...`

## 23. `scripts/quests/bastok/The_Naming_Game.lua`

**Raibaht** — METALWORKS (zone 237), entity `0x010ED02C`  
stub fires `[504]`  ← **WRONG — NPC does not own it**

- csid **501** → msgs [7525]  
  `[7525] Do not bother the chief. Every second he spends away from his research is a loss to the Metalwo...`
- csid **510** → msgs [7925]  
  `[7925] An invitation from the Steaming Sheep? Hmm... Please do not mention this to the Chief. But tell...`
- csid **751** → msgs [8562, 8563, 8564, 8565, 8566]  
  `[8562] You're a dark knight, I see. I have a favor to ask that may be of some interest to you.`
- csid **872** → msgs [9953, 9954]  
  `[9953] The adventurer we seek has been ordered to travel to Delkfutt's Tower and defeat a monster know...`
- csid **873** → msgs [9962, 9963, 9964]  
  `[9962] Until recently, Chief Cid had been working on what he called a “semiperpetual motion engine.” H...`
- csid **874** → msgs [9987]  
  `[9987] .... If you ever wish to...rethink the name you have given the chief's airship, please bring an...`
- csid **933** → msgs [10685, 10690]  
  `[10685] 's badge flashes brightly.`

## 24. `scripts/quests/bastok/The_Wondrous_Whatchamacallit.lua`

**Selliste** — BASTOK_MINES (zone 234), entity `0x010EA0B5`  
stub fires `[800]`  ← **WRONG — NPC does not own it**

- csid **591** → msgs [10419, 10420, 10421, 10422, 10423, 10424]…  
  `[10419] No, that won't work either. Confound it! If only I could find a--`
- csid **592** → msgs [10437, 10438, 10439, 10440, 10442]  
  `[10437] It's just  ,  ,  ,  ,  ...`
- csid **593** → msgs [10443, 10444, 10445, 10446, 10447, 10448]…  
  `[10443] Why, yes! Yes, I'd recognize it anywhere! One hundred percent pure, unadulterated astral whatch...`
- csid **594** → msgs [10449, 10450]  
  `[10449] Well, if it isn't my favorite adventurer! Synergizing up a storm with the help of my miraculous...`
- csid **595** → msgs [10418]  
  `[10418] No, that won't work either. Confound it! If only there were a skilled synergist around here to ...`
- csid **596** → msgs [10451, 10452]  
  `[10451] What? Don't tell me you lost the  I made for you. I'm heartbroken! A lot of blood, sweat, and w...`

**Selliste** — BASTOK_MINES (zone 234), entity `0x010EA0B5`  
stub fires `[801]`  ← **WRONG — NPC does not own it**

- csid **591** → msgs [10419, 10420, 10421, 10422, 10423, 10424]…  
  `[10419] No, that won't work either. Confound it! If only I could find a--`
- csid **592** → msgs [10437, 10438, 10439, 10440, 10442]  
  `[10437] It's just  ,  ,  ,  ,  ...`
- csid **593** → msgs [10443, 10444, 10445, 10446, 10447, 10448]…  
  `[10443] Why, yes! Yes, I'd recognize it anywhere! One hundred percent pure, unadulterated astral whatch...`
- csid **594** → msgs [10449, 10450]  
  `[10449] Well, if it isn't my favorite adventurer! Synergizing up a storm with the help of my miraculous...`
- csid **595** → msgs [10418]  
  `[10418] No, that won't work either. Confound it! If only there were a skilled synergist around here to ...`
- csid **596** → msgs [10451, 10452]  
  `[10451] What? Don't tell me you lost the  I made for you. I'm heartbroken! A lot of blood, sweat, and w...`

## 25. `scripts/quests/crystalWar/A_Cait_Calls.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1440]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 26. `scripts/quests/crystalWar/A_Farewell_to_Felines.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1510]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 27. `scripts/quests/crystalWar/A_Feast_for_Gnats.lua`

**Robel-Akbel** — WINDURST_WATERS_S (zone 94), entity `0x0105E218`  
stub fires `[1050]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **24** → msgs [1373, 11926, 12789, 13889, 14312]  
  `[1373] Trial: Retrieve a set quantity of the assigned item.`
- csid **25** → msgs [128, 1373, 4046]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **134** → msgs [749]  
  `[749] Trial: Have your pet deal the finishing blow to a set number of [experience-yielding monsters/m...`
- csid **151** → msgs [128]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **186** → msgs [5400, 8355, 12854]  
  `[5400] Objective: / plantoid-type creature[/s]. Weapon Skill: Any axe weapon skill Equipment: Target i...`
- csid **233** → msgs [220, 287, 305, 3000, 8029, 14370]  
  `[220] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`

## 28. `scripts/quests/crystalWar/A_Forbidden_Reunion.lua`

**Adelbrecht** — BASTOK_MARKETS_S (zone 87), entity `0x010571CF`  
stub fires `[1340]`  ← **WRONG — NPC does not own it**

- csid **140** → msgs [11547, 11548, 11549, 11550, 11551, 11554]  
  `[11547] I thought you didn't have any questions! Alright, I'll try to make myself a little clearer this...`
- csid **141** → msgs [11548, 11549, 11550, 11555, 11556, 11557]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **142** → msgs [11548, 11549, 11550, 11559, 11560, 11561]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **162** → msgs [11569, 11570]  
  `[11569] What are you doing, soldier? Head over to the next window and speak with Legion Engineer Aureli...`

## 29. `scripts/quests/crystalWar/A_Jewelers_Lament.lua`

**Wahid** — BASTOK_MARKETS_S (zone 87), entity `0x0105724A`  
stub fires `[1100]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **335** → msgs [7625, 7626, 7627, 7628, 7629, 7630]…  
  `[7625] Well met! I am Wahid, a gem dealer of some repute. If you're a [man/woman] of class--<ahem!>--y...`
- csid **336** → msgs [7632]  
  `[7632] You haven't come across any , , or  in your travels, have you? Acquire one of each and I will p...`
- csid **337** → msgs [7633, 7634, 7635, 7636, 7638, 7639]…  
  `[7633] Oho! I knew I could count on you! After all, my sterling character judgment is quite renowned i...`
- csid **338** → msgs [7659, 7660]  
  `[7659] But worry not, friend! She'll come around, as she always does.  My infallible merchant's instin...`
- csid **339** → msgs [7661, 7662, 7663, 7664, 7665, 7666]  
  `[7661] Oh ho! There you are! Sorry you had to witness our little lovers' spat the other day. Hohoho...`
- csid **340** → msgs [7667]  
  `[7667] Please do let me know if you find any word of my wife. Hahaha, what's gotten into me? A busines...`
- csid **341** → msgs [7668, 7669, 7670, 7671, 7672, 7673]…  
  `[7668] Oh, it's you. Pray tell, have you any news of Swantje?`
- csid **342** → msgs [7709]  
  `[7709] Swantje...`
| _...2 more csids_ | | |

## 30. `scripts/quests/crystalWar/A_Manifest_Problem.lua`

**Rotih_Moalghett** — FORT_KARUGO_NARUGO_S (zone 96), entity `0x010602CE`  
stub fires `[1230]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **104** → msgs [7951]  
  `[7951] Who lets a child come alone to a place like this? I think he was tryin' to take a wander outsid...`
- csid **107** → msgs [7859, 7860]  
  `[7859] Those little sorcerers will be in all sorts of trrrouble if the fort is sieged by magic-immune ...`
- csid **108** → msgs [974, 7948]  
  `[974] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **109** → msgs [974, 7946]  
  `[974] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **113** → msgs [755, 791, 1084, 2243]  
  `[755] Trial: Defeat a set number of [experience-yielding monsters/monsters] afflicted with the prescr...`
- csid **114** → msgs [8130]  
  `[8130] A couple of nasty ones are rrrushing the western spire! You must hurry and head them off!`
- csid **232** → msgs [8204, 8205]  
  `[8204] If there's any trrrouble around here, we have to get word to the boss, Romaa Mihgo, as soon as ...`

## 31. `scripts/quests/crystalWar/A_New_Menace.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1470]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 32. `scripts/quests/crystalWar/A_World_in_Flux.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1490]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 33. `scripts/quests/crystalWar/Ad_Infinitum.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1580]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 34. `scripts/quests/crystalWar/At_Journeys_End.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1210]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 35. `scripts/quests/crystalWar/Battle_on_a_New_Front.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1420]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 36. `scripts/quests/crystalWar/Beast_from_the_East.lua`

**Nichais** — SOUTHERN_SAN_DORIA_S (zone 80), entity `0x010502C7`  
stub fires `[1240]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **72** → msgs [150, 13584, 13588, 13589]  
  `[150] Heating Smarts have taken effect.`
- csid **74** → msgs [150, 400, 13606, 13607, 13608, 13609]…  
  `[150] Heating Smarts have taken effect.`
- csid **75** → msgs [120, 150, 13616, 13617]  
  `[120] The synergy furnace regains its durability!`
- csid **76** → msgs [150, 400, 13618, 13620]  
  `[150] Heating Smarts have taken effect.`
- csid **77** → msgs [150, 2489, 13621, 13622]  
  `[150] Heating Smarts have taken effect.`
- csid **79** → msgs [13632]  
  `[13632] I have an elaborate jeweled box that I think may be just the thing! I shall make all the necess...`
- csid **80** → msgs [120, 200, 13633, 13634, 13635]  
  `[120] The synergy furnace regains its durability!`
- csid **83** → msgs [150, 13563, 13564, 13565]  
  `[150] Heating Smarts have taken effect.`

## 37. `scripts/quests/crystalWar/Beneath_the_Mask.lua`

**Gentle_Tiger** — BASTOK_MARKETS_S (zone 87), entity `0x010571D7`  
stub fires `[1110]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **17** → msgs [12523]  
  `[12523] I've been alert the entire time. How did he get in there...?`
- csid **28** → msgs [12628]  
  `[12628] That child crawled in through the ventilation shaft!? Well, at least my pay won't suffer this t...`
- csid **31** → msgs [12663]  
  `[12663] Who would've thought that the music shop owner belonged to some secret mercenary organization.....`
- csid **35** → msgs [12744]  
  `[12744] How could Chairman Pale Eagle be a suspect in the assassination case? What is this nation comin...`
- csid **47** → msgs [12202, 12203]  
  `[12202] Has the professor been located?`
- csid **58** → msgs [12997]  
  `[12997] If you're looking for Senator Karst, he's already left for his meeting with Chairman Pale Eagle...`
- csid **59** → msgs [12998, 12999]  
  `[12998] Terrible news! Five Moons has broken out of jail!`
- csid **61** → msgs [13056]  
  `[13056] If you're looking for the Mythril Musketeers, they've left to see to the deployment of the Spec...`
| _...23 more csids_ | | |

## 38. `scripts/quests/crystalWar/Between_a_Rock_and_Rift.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1500]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 39. `scripts/quests/crystalWar/Bonds_of_Mythril.lua`

**Klara** — BASTOK_MARKETS_S (zone 87), entity `0x010571F2`  
stub fires `[1190]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **34** → msgs [5680, 6205, 9999, 12306]  
  `[5680] Objective: [Monster/Monsters] of any family: /. Equipment: Target item must be equipped.`
- csid **65** → msgs [718, 3664]  
  `[718] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed weat...`
- csid **66** → msgs [1999, 4206, 8381, 8888, 8956]  
  `[1999] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`
- csid **71** → msgs [1233]  
  `[1233] Trial: Retrieve a set quantity of the assigned item.`
- csid **160** → msgs [1335, 1346]  
  `[1335] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **216** → msgs [1346, 1347, 1348]  
  `[1346] Trial: Retrieve a set quantity of the assigned item.`
- csid **608** → msgs [2984]  
  `[2984] Weapon Skill: Spinning Attack,  [time/times]. Enemy: Monsters of any family. Equipment: Target ...`

## 40. `scripts/quests/crystalWar/Brace_for_the_Unknown.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1540]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 41. `scripts/quests/crystalWar/Burden_of_Suspicion.lua`

**Gentle_Tiger** — BASTOK_MARKETS_S (zone 87), entity `0x010571D7`  
stub fires `[1220]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **17** → msgs [12523]  
  `[12523] I've been alert the entire time. How did he get in there...?`
- csid **28** → msgs [12628]  
  `[12628] That child crawled in through the ventilation shaft!? Well, at least my pay won't suffer this t...`
- csid **31** → msgs [12663]  
  `[12663] Who would've thought that the music shop owner belonged to some secret mercenary organization.....`
- csid **35** → msgs [12744]  
  `[12744] How could Chairman Pale Eagle be a suspect in the assassination case? What is this nation comin...`
- csid **47** → msgs [12202, 12203]  
  `[12202] Has the professor been located?`
- csid **58** → msgs [12997]  
  `[12997] If you're looking for Senator Karst, he's already left for his meeting with Chairman Pale Eagle...`
- csid **59** → msgs [12998, 12999]  
  `[12998] Terrible news! Five Moons has broken out of jail!`
- csid **61** → msgs [13056]  
  `[13056] If you're looking for the Mythril Musketeers, they've left to see to the deployment of the Spec...`
| _...23 more csids_ | | |

## 42. `scripts/quests/crystalWar/Champion_of_the_Dawn.lua`

**Adelbrecht** — BASTOK_MARKETS_S (zone 87), entity `0x010571CF`  
stub fires `[1320]`  ← **WRONG — NPC does not own it**

- csid **140** → msgs [11547, 11548, 11549, 11550, 11551, 11554]  
  `[11547] I thought you didn't have any questions! Alright, I'll try to make myself a little clearer this...`
- csid **141** → msgs [11548, 11549, 11550, 11555, 11556, 11557]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **142** → msgs [11548, 11549, 11550, 11559, 11560, 11561]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **162** → msgs [11569, 11570]  
  `[11569] What are you doing, soldier? Head over to the next window and speak with Legion Engineer Aureli...`

## 43. `scripts/quests/crystalWar/Crystal_Guardian.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1560]`  ← **WRONG — NPC does not own it**

_Only generic conquest/mog-tablet messages resolve — no quest-specific event._

## 44. `scripts/quests/crystalWar/Drafted_by_the_Duchy.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1410]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 45. `scripts/quests/crystalWar/Endings_and_Beginnings.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1570]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 46. `scripts/quests/crystalWar/Fire_in_the_Hole.lua`

**Klara** — BASTOK_MARKETS_S (zone 87), entity `0x010571F2`  
stub fires `[1030]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **34** → msgs [5680, 6205, 9999, 12306]  
  `[5680] Objective: [Monster/Monsters] of any family: /. Equipment: Target item must be equipped.`
- csid **65** → msgs [718, 3664]  
  `[718] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed weat...`
- csid **66** → msgs [1999, 4206, 8381, 8888, 8956]  
  `[1999] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`
- csid **71** → msgs [1233]  
  `[1233] Trial: Retrieve a set quantity of the assigned item.`
- csid **160** → msgs [1335, 1346]  
  `[1335] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **216** → msgs [1346, 1347, 1348]  
  `[1346] Trial: Retrieve a set quantity of the assigned item.`
- csid **608** → msgs [2984]  
  `[2984] Weapon Skill: Spinning Attack,  [time/times]. Enemy: Monsters of any family. Equipment: Target ...`

## 47. `scripts/quests/crystalWar/Glimmer_of_Hope.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1530]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 48. `scripts/quests/crystalWar/Guardian_of_the_Void.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1400]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 49. `scripts/quests/crystalWar/Healing_Herbs.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1000]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 50. `scripts/quests/crystalWar/Her_Memories_Verdure_Footfalls.lua`

**Adelbrecht** — BASTOK_MARKETS_S (zone 87), entity `0x010571CF`  
stub fires `[1310]`  ← **WRONG — NPC does not own it**

- csid **140** → msgs [11547, 11548, 11549, 11550, 11551, 11554]  
  `[11547] I thought you didn't have any questions! Alright, I'll try to make myself a little clearer this...`
- csid **141** → msgs [11548, 11549, 11550, 11555, 11556, 11557]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **142** → msgs [11548, 11549, 11550, 11559, 11560, 11561]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **162** → msgs [11569, 11570]  
  `[11569] What are you doing, soldier? Head over to the next window and speak with Legion Engineer Aureli...`

## 51. `scripts/quests/crystalWar/Honor_Under_Fire.lua`

**Gentle_Tiger** — BASTOK_MARKETS_S (zone 87), entity `0x010571D7`  
stub fires `[1070]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **17** → msgs [12523]  
  `[12523] I've been alert the entire time. How did he get in there...?`
- csid **28** → msgs [12628]  
  `[12628] That child crawled in through the ventilation shaft!? Well, at least my pay won't suffer this t...`
- csid **31** → msgs [12663]  
  `[12663] Who would've thought that the music shop owner belonged to some secret mercenary organization.....`
- csid **35** → msgs [12744]  
  `[12744] How could Chairman Pale Eagle be a suspect in the assassination case? What is this nation comin...`
- csid **47** → msgs [12202, 12203]  
  `[12202] Has the professor been located?`
- csid **58** → msgs [12997]  
  `[12997] If you're looking for Senator Karst, he's already left for his meeting with Chairman Pale Eagle...`
- csid **59** → msgs [12998, 12999]  
  `[12998] Terrible news! Five Moons has broken out of jail!`
- csid **61** → msgs [13056]  
  `[13056] If you're looking for the Mythril Musketeers, they've left to see to the deployment of the Spec...`
| _...23 more csids_ | | |

## 52. `scripts/quests/crystalWar/Howl_from_the_Heavens.lua`

**Robel-Akbel** — WINDURST_WATERS_S (zone 94), entity `0x0105E218`  
stub fires `[1140]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **24** → msgs [1373, 11926, 12789, 13889, 14312]  
  `[1373] Trial: Retrieve a set quantity of the assigned item.`
- csid **25** → msgs [128, 1373, 4046]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **134** → msgs [749]  
  `[749] Trial: Have your pet deal the finishing blow to a set number of [experience-yielding monsters/m...`
- csid **151** → msgs [128]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **186** → msgs [5400, 8355, 12854]  
  `[5400] Objective: / plantoid-type creature[/s]. Weapon Skill: Any axe weapon skill Equipment: Target i...`
- csid **233** → msgs [220, 287, 305, 3000, 8029, 14370]  
  `[220] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`

## 53. `scripts/quests/crystalWar/Manifest_Destiny.lua`

**Dhea_Prandoleh** — WINDURST_WATERS_S (zone 94), entity `0x0105E1FF`  
stub fires `[1200]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **26** → msgs [13580]  
  `[13580] ! You'rrre still standing around here? Master Lehko's waiting for you in Heavens Tower with a s...`
- csid **34** → msgs [13889, 13890]  
  `[13889] This is it, --the day that mercenaries like us live for. The crows have run rrroughshod over th...`
- csid **35** → msgs [13904, 13905, 13906]  
  `[13904] Master Lehko's f-fine. Yes, I'm s-surrre of it... He...`
- csid **36** → msgs [13950, 13951]  
  `[13950] If it isn't our star mercenary, ! Why, just by seeing you around I know that the Federation is ...`
- csid **43** → msgs [120, 188, 240, 300]  
  `[120] The synergy furnace regains its durability!`
- csid **131** → msgs [11674, 11675, 11676]  
  `[11674] I better get my kit together before the boss comes back...`
- csid **135** → msgs [11709, 11710]  
  `[11709] Even if he is a brrrat, you can't leave him to the mercy of the birdmen. You better head off to...`
- csid **136** → msgs [11744]  
  `[11744] Keep your claws sharp! You never know when you'll be called on again!`
| _...8 more csids_ | | |

## 54. `scripts/quests/crystalWar/No_Rest_for_the_Weary.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1480]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 55. `scripts/quests/crystalWar/Provenance.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1550]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 56. `scripts/quests/crystalWar/Quelling_the_Storm.lua`

**Klara** — BASTOK_MARKETS_S (zone 87), entity `0x010571F2`  
stub fires `[1060]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **34** → msgs [5680, 6205, 9999, 12306]  
  `[5680] Objective: [Monster/Monsters] of any family: /. Equipment: Target item must be equipped.`
- csid **65** → msgs [718, 3664]  
  `[718] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed weat...`
- csid **66** → msgs [1999, 4206, 8381, 8888, 8956]  
  `[1999] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`
- csid **71** → msgs [1233]  
  `[1233] Trial: Retrieve a set quantity of the assigned item.`
- csid **160** → msgs [1335, 1346]  
  `[1335] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **216** → msgs [1346, 1347, 1348]  
  `[1346] Trial: Retrieve a set quantity of the assigned item.`
- csid **608** → msgs [2984]  
  `[2984] Weapon Skill: Spinning Attack,  [time/times]. Enemy: Monsters of any family. Equipment: Target ...`

## 57. `scripts/quests/crystalWar/Redrafted_by_the_Duchy.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1460]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 58. `scripts/quests/crystalWar/Sins_of_the_Mothers.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1130]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 59. `scripts/quests/crystalWar/Son_and_Father.lua`

**Exoroche** — SOUTHERN_SAN_DORIA_S (zone 80), entity `0x010501AA`  
stub fires `[1170]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **156** → msgs [7583]  
  `[7583] <Sniff, sob>... Oh, do h-help me, kind [sir/miss]! I c-came here with my father, but now he's.....`
- csid **157** → msgs [7583, 7584, 7588, 7589]  
  `[7583] <Sniff, sob>... Oh, do h-help me, kind [sir/miss]! I c-came here with my father, but now he's.....`
- csid **158** → msgs [7588, 7589]  
  `[7588] <Sniff, sniff>... Father... Wherever did you go...?`
- csid **159** → msgs [7590, 7592, 7594, 7596, 7598, 7601]…  
  `[7590] What? You f-found my father, you say?`
- csid **160** → msgs [7603]  
  `[7603] M-my ...<sniff>... Without it, I c-cannot...<sob>...`
- csid **161** → msgs [7604, 7605, 7606, 7607]  
  `[7604] C-could it be? You've come to return this to me?`
- csid **162** → msgs [7608]  
  `[7608] <Sniff>... You are too kind, [milord/milady]. But I can accept that  when Father himself return...`
- csid **163** → msgs [7603, 7611, 7614, 7615, 7617, 7618]…  
  `[7603] M-my ...<sniff>... Without it, I c-cannot...<sob>...`
| _...1 more csids_ | | |

## 60. `scripts/quests/crystalWar/Storm_on_the_Horizon.lua`

**Klara** — BASTOK_MARKETS_S (zone 87), entity `0x010571F2`  
stub fires `[1020]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **34** → msgs [5680, 6205, 9999, 12306]  
  `[5680] Objective: [Monster/Monsters] of any family: /. Equipment: Target item must be equipped.`
- csid **65** → msgs [718, 3664]  
  `[718] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed weat...`
- csid **66** → msgs [1999, 4206, 8381, 8888, 8956]  
  `[1999] Trial: Defeat a set number of [experience-yielding monsters/monsters] under the prescribed cond...`
- csid **71** → msgs [1233]  
  `[1233] Trial: Retrieve a set quantity of the assigned item.`
- csid **160** → msgs [1335, 1346]  
  `[1335] Trial: Unleash the prescribed weapon skill a set number of times against certain [experience-yi...`
- csid **216** → msgs [1346, 1347, 1348]  
  `[1346] Trial: Retrieve a set quantity of the assigned item.`
- csid **608** → msgs [2984]  
  `[2984] Weapon Skill: Spinning Attack,  [time/times]. Enemy: Monsters of any family. Equipment: Target ...`

## 61. `scripts/quests/crystalWar/Succor_to_the_Sidhe.lua`

**Callisto** — GRAUBERG_S (zone 89), entity `0x0105935A`  
stub fires `[1150]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **4000** → msgs [8169, 8170, 8171, 8172, 8173, 8207]…  
  `[8169] My sisters are monitoring the strength of our enemies throughout the realm. By your leave, I sh...`
- csid **4001** → msgs [8239, 8240]  
  `[8239] Thy offer of aid is most kind. We shall hold thy  for safekeeping.`

## 62. `scripts/quests/crystalWar/The_Dawn_Also_Rises.lua`

**Adelbrecht** — BASTOK_MARKETS_S (zone 87), entity `0x010571CF`  
stub fires `[1330]`  ← **WRONG — NPC does not own it**

- csid **140** → msgs [11547, 11548, 11549, 11550, 11551, 11554]  
  `[11547] I thought you didn't have any questions! Alright, I'll try to make myself a little clearer this...`
- csid **141** → msgs [11548, 11549, 11550, 11555, 11556, 11557]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **142** → msgs [11548, 11549, 11550, 11559, 11560, 11561]…  
  `[11548] Or...maybe you're thinking of throwing in the towel.`
- csid **162** → msgs [11569, 11570]  
  `[11569] What are you doing, soldier? Head over to the next window and speak with Legion Engineer Aureli...`

## 63. `scripts/quests/crystalWar/The_Forbidden_Path.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1090]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 64. `scripts/quests/crystalWar/The_Long_March_North.lua`

**Robel-Akbel** — WINDURST_WATERS_S (zone 94), entity `0x0105E218`  
stub fires `[1080]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

_Only generic conquest/mog-tablet messages resolve — no quest-specific event._

## 65. `scripts/quests/crystalWar/The_Swarm.lua`

**Fortilace** — ROLANBERRY_FIELDS_S (zone 91), entity `0x0105B31A`  
stub fires `[1010]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **200** → msgs [7715, 7716, 7717, 7718, 7719, 7724]  
  `[7715] Attempt which objective?  None. . . . . . . . .`

## 66. `scripts/quests/crystalWar/The_Truth_Is_Out_There.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1450]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 67. `scripts/quests/crystalWar/The_Truth_Lies_Hid.lua`

**Gentle_Tiger** — BASTOK_MARKETS_S (zone 87), entity `0x010571D7`  
stub fires `[1180]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **17** → msgs [12523]  
  `[12523] I've been alert the entire time. How did he get in there...?`
- csid **28** → msgs [12628]  
  `[12628] That child crawled in through the ventilation shaft!? Well, at least my pay won't suffer this t...`
- csid **31** → msgs [12663]  
  `[12663] Who would've thought that the music shop owner belonged to some secret mercenary organization.....`
- csid **35** → msgs [12744]  
  `[12744] How could Chairman Pale Eagle be a suspect in the assassination case? What is this nation comin...`
- csid **47** → msgs [12202, 12203]  
  `[12202] Has the professor been located?`
- csid **58** → msgs [12997]  
  `[12997] If you're looking for Senator Karst, he's already left for his meeting with Chairman Pale Eagle...`
- csid **59** → msgs [12998, 12999]  
  `[12998] Terrible news! Five Moons has broken out of jail!`
- csid **61** → msgs [13056]  
  `[13056] If you're looking for the Mythril Musketeers, they've left to see to the deployment of the Spec...`
| _...23 more csids_ | | |

## 68. `scripts/quests/crystalWar/The_Young_and_the_Threadless.lua`

**Ponono** — WINDURST_WATERS_S (zone 94), entity `0x0105E1C2`  
stub fires `[1160]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **191** → msgs [7706, 7707, 7708, 7709, 7710, 7711]…  
  `[7706] My mercenary friend! All of Windurst is in your debtaru!`
- csid **192** → msgs [7715, 7716, 7717, 7718, 7719, 7720]…  
  `[7715] Oh, if it isn't my mercenary friend. How nice to see you sportaruing the  I gave you!`
- csid **193** → msgs [7732]  
  `[7732] Mercenaries from across the Federation are banging on my doors day and nightaru to get their gr...`
- csid **194** → msgs [7733, 7736]  
  `[7733] You've returned! Well? Were you able to enchant the three spooly-wools of thread?`
- csid **195** → msgs [7733, 7734, 7736]  
  `[7733] You've returned! Well? Were you able to enchant the three spooly-wools of thread?`
- csid **196** → msgs [7733, 7735, 7736]  
  `[7733] You've returned! Well? Were you able to enchant the three spooly-wools of thread?`
- csid **197** → msgs [7733, 7737, 7738, 7739, 7740, 7741]…  
  `[7733] You've returned! Well? Were you able to enchant the three spooly-wools of thread?`
- csid **198** → msgs [7706]  
  `[7706] My mercenary friend! All of Windurst is in your debtaru!`

## 69. `scripts/quests/crystalWar/Third_Tour_of_Duchy.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1520]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 70. `scripts/quests/crystalWar/Voidwalker_Op_126.lua`

**Lehko_Habhoka** — WINDURST_WATERS_S (zone 94), entity `0x0105E236`  
stub fires `[1430]`  ← **WRONG — NPC does not own it**

- csid **22** → msgs [120, 128, 164, 180, 216, 499]…  
  `[120] The synergy furnace regains its durability!`
- csid **25** → msgs [128, 1462, 1596, 2633, 3505]  
  `[128] The floor about the furnace is free of fewell fragments.`
- csid **168** → msgs [3026]  
  `[3026] Weapon Skill: Retribution,  [time/times]. Enemy: Any bird-type creature. Equipment: Target item...`
- csid **186** → msgs [585, 749, 3488, 6599, 7608, 12437]  
  `[585] Trial: Use the prescribed weapon skill to deal the finishing blow to a set number of [experienc...`
- csid **187** → msgs [177, 191, 1029, 8500, 9121, 11768]…  
  `[177] You are too far away to operate the synergy furnace.`

## 71. `scripts/quests/crystalWar/What_Price_Loyalty.lua`

**Gentle_Tiger** — BASTOK_MARKETS_S (zone 87), entity `0x010571D7`  
stub fires `[1120]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **17** → msgs [12523]  
  `[12523] I've been alert the entire time. How did he get in there...?`
- csid **28** → msgs [12628]  
  `[12628] That child crawled in through the ventilation shaft!? Well, at least my pay won't suffer this t...`
- csid **31** → msgs [12663]  
  `[12663] Who would've thought that the music shop owner belonged to some secret mercenary organization.....`
- csid **35** → msgs [12744]  
  `[12744] How could Chairman Pale Eagle be a suspect in the assassination case? What is this nation comin...`
- csid **47** → msgs [12202, 12203]  
  `[12202] Has the professor been located?`
- csid **58** → msgs [12997]  
  `[12997] If you're looking for Senator Karst, he's already left for his meeting with Chairman Pale Eagle...`
- csid **59** → msgs [12998, 12999]  
  `[12998] Terrible news! Five Moons has broken out of jail!`
- csid **61** → msgs [13056]  
  `[13056] If you're looking for the Mythril Musketeers, they've left to see to the deployment of the Spec...`
| _...23 more csids_ | | |

## 72. `scripts/quests/crystalWar/When_One_Man_Is_Not_Enough.lua`

**Dhea_Prandoleh** — WINDURST_WATERS_S (zone 94), entity `0x0105E1FF`  
stub fires `[1040]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **26** → msgs [13580]  
  `[13580] ! You'rrre still standing around here? Master Lehko's waiting for you in Heavens Tower with a s...`
- csid **34** → msgs [13889, 13890]  
  `[13889] This is it, --the day that mercenaries like us live for. The crows have run rrroughshod over th...`
- csid **35** → msgs [13904, 13905, 13906]  
  `[13904] Master Lehko's f-fine. Yes, I'm s-surrre of it... He...`
- csid **36** → msgs [13950, 13951]  
  `[13950] If it isn't our star mercenary, ! Why, just by seeing you around I know that the Federation is ...`
- csid **43** → msgs [120, 188, 240, 300]  
  `[120] The synergy furnace regains its durability!`
- csid **131** → msgs [11674, 11675, 11676]  
  `[11674] I better get my kit together before the boss comes back...`
- csid **135** → msgs [11709, 11710]  
  `[11709] Even if he is a brrrat, you can't leave him to the mercy of the birdmen. You better head off to...`
- csid **136** → msgs [11744]  
  `[11744] Keep your claws sharp! You never know when you'll be called on again!`
| _...8 more csids_ | | |

## 73. `scripts/quests/jeuno/A_Furious_Finale.lua`

**Laila** — UPPER_JEUNO (zone 244), entity `0x010F40BA`  
stub fires `[10123, 10124]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

## 74. `scripts/quests/jeuno/A_Reputation_in_Ruins.lua`

**Migliorozz** — UPPER_JEUNO (zone 244), entity `0x010F4085`  
stub fires `[10027]`  ← **WRONG — NPC does not own it**

- csid **10019** → msgs [3878, 12924]  
  `[3878] Objective:  [monster/monsters] of any family. Equipment: Target item must be equipped.`
- csid **10020** → msgs [201, 8536, 8537, 8538, 8539, 8540]…  
  `[201] Element and target value: [///////]`
- csid **10021** → msgs [8532, 8533, 8534, 8535]  
  `[8532] Find a way into the deepest section of the southwest tower, and activate the device that lies b...`
- csid **10022** → msgs [8542, 8543, 8544]  
  `[8542] What would happen should all of the devices be activated? I really couldn't say.`
- csid **10026** → msgs [8510]  
  `[8510] You must indeed be serious about your beliefs to choose the Temple of the Goddess over the bust...`

**Migliorozz** — UPPER_JEUNO (zone 244), entity `0x010F4085`  
stub fires `[10028]`  ← **WRONG — NPC does not own it**

- csid **10019** → msgs [3878, 12924]  
  `[3878] Objective:  [monster/monsters] of any family. Equipment: Target item must be equipped.`
- csid **10020** → msgs [201, 8536, 8537, 8538, 8539, 8540]…  
  `[201] Element and target value: [///////]`
- csid **10021** → msgs [8532, 8533, 8534, 8535]  
  `[8532] Find a way into the deepest section of the southwest tower, and activate the device that lies b...`
- csid **10022** → msgs [8542, 8543, 8544]  
  `[8542] What would happen should all of the devices be activated? I really couldn't say.`
- csid **10026** → msgs [8510]  
  `[8510] You must indeed be serious about your beliefs to choose the Temple of the Goddess over the bust...`

## 75. `scripts/quests/jeuno/A_Trial_in_Tandem.lua`

**Luto_Mewrilah** — UPPER_JEUNO (zone 244), entity `0x010F408C`  
stub fires `[10044]`  ← **WRONG — NPC does not own it**

- csid **10034** → msgs [9253]  
  `[9253] Thanks to you, I got my paws on some great information. Be in touch.`
- csid **10041** → msgs [8815, 8816, 8817]  
  `[8815] There're so many people in this town. It takes me by surprrrise no matter how many times I come...`
- csid **10042** → msgs [8901, 8902]  
  `[8901] Must be harrrd to have a child go missing.`
- csid **10045** → msgs [9037, 9038]  
  `[9037] That mirror should hold powers similar to the Glass of All-Seeing.`
- csid **10046** → msgs [9039, 9040, 9041, 9042, 9043, 9044]…  
  `[9039] Welcome back. How did everything go?`
- csid **10047** → msgs [9223, 9224, 9225, 9226, 9227, 9228]…  
  `[9223] What can I do for you?`
- csid **10048** → msgs [8997]  
  `[8997] The scent of treasure on you is making my nose twitch. Some people have all the luck...`
- csid **10049** → msgs [9240, 9241, 9242, 9243, 9244, 9245]…  
  `[9240] Say your farewells to [Feliz/Ferdinand/Gunnar/Massimo/Oldrich/Siegward/Theobald/Zenji]...`
| _...14 more csids_ | | |

**Magian_Moogle** — RULUDE_GARDENS (zone 243), entity `0x010F30DC`  
stub fires `[10045]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

## 76. `scripts/quests/jeuno/Chameleon_Capers.lua`

**Luto_Mewrilah** — UPPER_JEUNO (zone 244), entity `0x010F408C`  
stub fires `[10035]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10034** → msgs [9253]  
  `[9253] Thanks to you, I got my paws on some great information. Be in touch.`
- csid **10041** → msgs [8815, 8816, 8817]  
  `[8815] There're so many people in this town. It takes me by surprrrise no matter how many times I come...`
- csid **10042** → msgs [8901, 8902]  
  `[8901] Must be harrrd to have a child go missing.`
- csid **10045** → msgs [9037, 9038]  
  `[9037] That mirror should hold powers similar to the Glass of All-Seeing.`
- csid **10046** → msgs [9039, 9040, 9041, 9042, 9043, 9044]…  
  `[9039] Welcome back. How did everything go?`
- csid **10047** → msgs [9223, 9224, 9225, 9226, 9227, 9228]…  
  `[9223] What can I do for you?`
- csid **10048** → msgs [8997]  
  `[8997] The scent of treasure on you is making my nose twitch. Some people have all the luck...`
- csid **10049** → msgs [9240, 9241, 9242, 9243, 9244, 9245]…  
  `[9240] Say your farewells to [Feliz/Ferdinand/Gunnar/Massimo/Oldrich/Siegward/Theobald/Zenji]...`
| _...14 more csids_ | | |

## 77. `scripts/quests/jeuno/Girl_in_the_Looking_Glass.lua`

**Luto_Mewrilah** — UPPER_JEUNO (zone 244), entity `0x010F408C`  
stub fires `[10037]`  ← **WRONG — NPC does not own it**

- csid **10034** → msgs [9253]  
  `[9253] Thanks to you, I got my paws on some great information. Be in touch.`
- csid **10041** → msgs [8815, 8816, 8817]  
  `[8815] There're so many people in this town. It takes me by surprrrise no matter how many times I come...`
- csid **10042** → msgs [8901, 8902]  
  `[8901] Must be harrrd to have a child go missing.`
- csid **10045** → msgs [9037, 9038]  
  `[9037] That mirror should hold powers similar to the Glass of All-Seeing.`
- csid **10046** → msgs [9039, 9040, 9041, 9042, 9043, 9044]…  
  `[9039] Welcome back. How did everything go?`
- csid **10047** → msgs [9223, 9224, 9225, 9226, 9227, 9228]…  
  `[9223] What can I do for you?`
- csid **10048** → msgs [8997]  
  `[8997] The scent of treasure on you is making my nose twitch. Some people have all the luck...`
- csid **10049** → msgs [9240, 9241, 9242, 9243, 9244, 9245]…  
  `[9240] Say your farewells to [Feliz/Ferdinand/Gunnar/Massimo/Oldrich/Siegward/Theobald/Zenji]...`
| _...14 more csids_ | | |

## 78. `scripts/quests/jeuno/The_Miraculous_Dale.lua`

**Rakuru-Rakoru** — LOWER_JEUNO (zone 245), entity `0x010F50C0`  
stub fires `[10079]`

- csid **10078** → msgs [7063]  
  `[7063] And who might you be, eh? Hrmmm... You're a bit too green for my liking. Don'taru you have any ...`
- csid **10079** → msgs [7064, 7065, 7066, 7067, 7068, 7069]…  
  `[7064] Boy oh boy, am I in trouble-wouble!`
- csid **10080** → msgs [7087, 7088, 7089, 7090, 7091, 7092]…  
  `[7087] ★Dale's Monstaru List★  Close list. Tumbling Truffle [ /x] Tottering Toby [ /x] Blubbery Bulge ...`
- csid **10081** → msgs [7086, 7108, 7109, 7110, 7111, 7112]…  
  `[7086] If you wantaru to know more about each of the creatures, just ask me, okay?`
- csid **10082** → msgs [7115, 7116, 7117, 7118, 7119, 7120]…  
  `[7115] <Gasp!> The...the data. It...it's finally complete!`
- csid **10083** → msgs [7129]  
  `[7129] M-my promotion...my dreamy-weam of becoming leading citizen...all gone... <Sniff, sob>`

## 79. `scripts/quests/otherAreas/A_Generous_General.lua`

**Faulpie** — SOUTHERN_SAN_DORIA (zone 230), entity `0x010E6053`  
stub fires `[720]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **648** → msgs [6810, 6816, 6817, 6818, 6819, 6820]…  
  `[6810] Join the [Fishermen's/Carpenters'/Blacksmiths'/Goldsmiths'/Weavers'/Tanners'/Boneworkers'/Alche...`
- csid **649** → msgs [6813, 6877, 6878, 6879, 6880, 6881]…  
  `[6813] You are now recognized as [an amateur/a recruit/an initiate/a novice/an apprentice/a journeyman...`
- csid **760** → msgs [6915, 6916, 6917, 6918, 6919]  
  `[6915] What brings you by my humble guild today, [sir/ma'am]? Perhaps you wish to place a special orde...`
- csid **761** → msgs [6920, 6921, 6922, 6923, 6924]  
  `[6920] It will be a few more days before I can finish the pattern for your costume. Please come by aga...`
- csid **762** → msgs [6926]  
  `[6926] Wonderful. Now that I have everything I require, I can begin working on the final product.........`
- csid **763** → msgs [6932]  
  `[6932] I know that you must be in a hurry, but I haven't finished your order yet. Please come back lat...`
- csid **764** → msgs [6922, 6923, 6924, 6927, 6928, 6929]…  
  `[6922] If you choose to give up, the quest will be canceled and your quest log reset.`
- csid **765** → msgs [6933, 6934, 6935, 6936, 6937, 6938]…  
  `[6933] Ah, just the [man/woman] I was looking for. Here is your order!`
| _...30 more csids_ | | |

## 80. `scripts/quests/otherAreas/An_Affable_Adamantking.lua`

**Faulpie** — SOUTHERN_SAN_DORIA (zone 230), entity `0x010E6053`  
stub fires `[710]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **648** → msgs [6810, 6816, 6817, 6818, 6819, 6820]…  
  `[6810] Join the [Fishermen's/Carpenters'/Blacksmiths'/Goldsmiths'/Weavers'/Tanners'/Boneworkers'/Alche...`
- csid **649** → msgs [6813, 6877, 6878, 6879, 6880, 6881]…  
  `[6813] You are now recognized as [an amateur/a recruit/an initiate/a novice/an apprentice/a journeyman...`
- csid **760** → msgs [6915, 6916, 6917, 6918, 6919]  
  `[6915] What brings you by my humble guild today, [sir/ma'am]? Perhaps you wish to place a special orde...`
- csid **761** → msgs [6920, 6921, 6922, 6923, 6924]  
  `[6920] It will be a few more days before I can finish the pattern for your costume. Please come by aga...`
- csid **762** → msgs [6926]  
  `[6926] Wonderful. Now that I have everything I require, I can begin working on the final product.........`
- csid **763** → msgs [6932]  
  `[6932] I know that you must be in a hurry, but I haven't finished your order yet. Please come back lat...`
- csid **764** → msgs [6922, 6923, 6924, 6927, 6928, 6929]…  
  `[6922] If you choose to give up, the quest will be canceled and your quest log reset.`
- csid **765** → msgs [6933, 6934, 6935, 6936, 6937, 6938]…  
  `[6933] Ah, just the [man/woman] I was looking for. Here is your order!`
| _...30 more csids_ | | |

## 81. `scripts/quests/otherAreas/An_Understanding_Overlord.lua`

**Faulpie** — SOUTHERN_SAN_DORIA (zone 230), entity `0x010E6053`  
stub fires `[700]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **648** → msgs [6810, 6816, 6817, 6818, 6819, 6820]…  
  `[6810] Join the [Fishermen's/Carpenters'/Blacksmiths'/Goldsmiths'/Weavers'/Tanners'/Boneworkers'/Alche...`
- csid **649** → msgs [6813, 6877, 6878, 6879, 6880, 6881]…  
  `[6813] You are now recognized as [an amateur/a recruit/an initiate/a novice/an apprentice/a journeyman...`
- csid **760** → msgs [6915, 6916, 6917, 6918, 6919]  
  `[6915] What brings you by my humble guild today, [sir/ma'am]? Perhaps you wish to place a special orde...`
- csid **761** → msgs [6920, 6921, 6922, 6923, 6924]  
  `[6920] It will be a few more days before I can finish the pattern for your costume. Please come by aga...`
- csid **762** → msgs [6926]  
  `[6926] Wonderful. Now that I have everything I require, I can begin working on the final product.........`
- csid **763** → msgs [6932]  
  `[6932] I know that you must be in a hurry, but I haven't finished your order yet. Please come back lat...`
- csid **764** → msgs [6922, 6923, 6924, 6927, 6928, 6929]…  
  `[6922] If you choose to give up, the quest will be canceled and your quest log reset.`
- csid **765** → msgs [6933, 6934, 6935, 6936, 6937, 6938]…  
  `[6933] Ah, just the [man/woman] I was looking for. Here is your order!`
| _...30 more csids_ | | |

## 82. `scripts/quests/otherAreas/Picture_Perfect.lua`

**Clarion_Star** — PORT_BASTOK (zone 236), entity `0x010EC13C`  
stub fires `[443]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **434** → msgs [13445, 13446, 13447, 13448, 13449, 13450]…  
  `[13445] Hey! You there! I've got a proposition of sorts for [a fresh-faced/an able-bodied/a world-class...`
- csid **435** → msgs [13467, 13468, 13469]  
  `[13467] Your first task of sorts is to speak with Naji of the Mythril Musketeers, in the Metalworks. He...`
- csid **436** → msgs [13470, 13471, 13472, 13473, 13474, 13475]…  
  `[13470] How are you finding those alter egos? Need an explanation of sorts as to how they work?`
- csid **437** → msgs [13491, 13492, 13493, 13494, 13495, 13496]…  
  `[13491] I can't believe that you got your hands on  ! Amazing!`
- csid **438** → msgs [13446, 13449, 13453, 13454, 13455, 13456]…  
  `[13446] You can call me Clarion Star. I've come from Jeuno, the lovely city in the northeast that conne...`
- csid **442** → msgs [13446]  
  `[13446] You can call me Clarion Star. I've come from Jeuno, the lovely city in the northeast that conne...`
- csid **457** → msgs [13500, 13501, 13502]  
  `[13500] A curious case, this one...`
- csid **458** → msgs [13503, 13504, 13505]  
  `[13503] This cipher appears to be the real deal, but damned if I know who it'll actually call forth. Le...`
| _...1 more csids_ | | |

## 83. `scripts/quests/otherAreas/Survival_of_the_Wisest.lua`

**Indescript_Markings** — PASHHOW_MARSHLANDS_S (zone 90), entity `0x0105A303`  
stub fires `[200]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

## 84. `scripts/quests/otherAreas/The_Big_One.lua`

**Travonce** — TAVNAZIAN_SAFEHOLD (zone 26), entity `0x0101A03A`  
stub fires `[300]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **210** → msgs [10726, 10727, 10728, 10729, 10730, 10731]…  
  `[10726] <Sigh> I wonder if I'll ever have the chance to catch the “big one” before I cross that final r...`
- csid **211** → msgs [10740, 10741, 10742, 10748, 10749]  
  `[10740] Anyway, you'd better go make your preparations as well. When you're ready, I'll be waiting at t...`
- csid **212** → msgs [10743, 10744, 10745]  
  `[10743] And so the big one got away again... Maybe I am getting too old for this...`
- csid **213** → msgs [10726]  
  `[10726] <Sigh> I wonder if I'll ever have the chance to catch the “big one” before I cross that final r...`
- csid **214** → msgs [10738, 10739, 10740, 10741, 10742, 10747]  
  `[10738] Help him realize his dream?  How could you say no? How could you say yes?`
- csid **215** → msgs [10746]  
  `[10746] The other day, a fine young [man/lady] helped me go out in search of the “big one.” Come to thi...`

**Travonce** — TAVNAZIAN_SAFEHOLD (zone 26), entity `0x0101A03A`  
stub fires `[301]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **210** → msgs [10726, 10727, 10728, 10729, 10730, 10731]…  
  `[10726] <Sigh> I wonder if I'll ever have the chance to catch the “big one” before I cross that final r...`
- csid **211** → msgs [10740, 10741, 10742, 10748, 10749]  
  `[10740] Anyway, you'd better go make your preparations as well. When you're ready, I'll be waiting at t...`
- csid **212** → msgs [10743, 10744, 10745]  
  `[10743] And so the big one got away again... Maybe I am getting too old for this...`
- csid **213** → msgs [10726]  
  `[10726] <Sigh> I wonder if I'll ever have the chance to catch the “big one” before I cross that final r...`
- csid **214** → msgs [10738, 10739, 10740, 10741, 10742, 10747]  
  `[10738] Help him realize his dream?  How could you say no? How could you say yes?`
- csid **215** → msgs [10746]  
  `[10746] The other day, a fine young [man/lady] helped me go out in search of the “big one.” Come to thi...`

## 85. `scripts/quests/outlands/A_Discerning_Eye.lua`

**Swift** — KAZHAM (zone 250), entity `0x010FA07C`  
stub fires `[200]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10018** → msgs [10677, 10678, 10679, 10680, 10681, 10682]…  
  `[10677] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Swift** — KAZHAM (zone 250), entity `0x010FA07C`  
stub fires `[201]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10018** → msgs [10677, 10678, 10679, 10680, 10681, 10682]…  
  `[10677] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Swift** — KAZHAM (zone 250), entity `0x010FA07C`  
stub fires `[200]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10018** → msgs [10677, 10678, 10679, 10680, 10681, 10682]…  
  `[10677] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

## 86. `scripts/quests/outlands/The_Fireblom_Tree.lua`

**Soun_Abralah** — KAZHAM (zone 250), entity `0x010FA02A`  
stub fires `[100]`  ← **WRONG — NPC does not own it**

- csid **101** → msgs [10072, 10073]  
  `[10072] When we Mithra establish a new settlement, we call forth the powerrr of the guardian of that la...`
- csid **102** → msgs [10076, 10077, 10078, 10079, 10080, 10081]…  
  `[10076] Wait a minute. You wouldn't happen to be one of those adventurerrrs from the mainlands, would y...`
- csid **103** → msgs [10085, 10086, 10087]  
  `[10085] Travel to the hearrrt of the Yuhtunga Jungle and cut four vines from the Firebloom Tree.`
- csid **104** → msgs [10088, 10089]  
  `[10088] Look at it! Isn't it beautiful?`
- csid **105** → msgs [10090, 10091, 10092]  
  `[10090] By the way, have your trrravels ever taken you to Windurst?`
- csid **106** → msgs [10078, 10081, 10093, 10094]  
  `[10078] Listen to her offer?  Yes. No.`
- csid **186** → msgs [10375]  
  `[10375] Leave my worrrkshop. I cannot concentrate with that stench in my house.`

**Soun_Abralah** — KAZHAM (zone 250), entity `0x010FA02A`  
stub fires `[101]`

- csid **101** → msgs [10072, 10073]  
  `[10072] When we Mithra establish a new settlement, we call forth the powerrr of the guardian of that la...`
- csid **102** → msgs [10076, 10077, 10078, 10079, 10080, 10081]…  
  `[10076] Wait a minute. You wouldn't happen to be one of those adventurerrrs from the mainlands, would y...`
- csid **103** → msgs [10085, 10086, 10087]  
  `[10085] Travel to the hearrrt of the Yuhtunga Jungle and cut four vines from the Firebloom Tree.`
- csid **104** → msgs [10088, 10089]  
  `[10088] Look at it! Isn't it beautiful?`
- csid **105** → msgs [10090, 10091, 10092]  
  `[10090] By the way, have your trrravels ever taken you to Windurst?`
- csid **106** → msgs [10078, 10081, 10093, 10094]  
  `[10078] Listen to her offer?  Yes. No.`
- csid **186** → msgs [10375]  
  `[10375] Leave my worrrkshop. I cannot concentrate with that stench in my house.`

## 87. `scripts/quests/outlands/The_Search_for_Goldmane.lua`

**Zoriboh** — RABAO (zone 247), entity `0x010F7043`  
stub fires `[400]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **120** → msgs [10506]  
  `[10506] You've gotta get there before anything happens to her. I'll pay you myself if I have to, but pl...`
- csid **124** → msgs [10527, 10528]  
  `[10527] Sanctia hasn't come back from Tavnazia, and her father and I are worried.`
- csid **127** → msgs [10507, 10508]  
  `[10507] I've seen my fair share of towns, but Rabao is where I feel most comfortable.`
- csid **129** → msgs [10548]  
  `[10548] Sanctia's still young and full of fire. I'm sure she'll make a fine adventurer.`

**Zoriboh** — RABAO (zone 247), entity `0x010F7043`  
stub fires `[401]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **120** → msgs [10506]  
  `[10506] You've gotta get there before anything happens to her. I'll pay you myself if I have to, but pl...`
- csid **124** → msgs [10527, 10528]  
  `[10527] Sanctia hasn't come back from Tavnazia, and her father and I are worried.`
- csid **127** → msgs [10507, 10508]  
  `[10507] I've seen my fair share of towns, but Rabao is where I feel most comfortable.`
- csid **129** → msgs [10548]  
  `[10548] Sanctia's still young and full of fire. I'm sure she'll make a fine adventurer.`

## 88. `scripts/quests/sandoria/Escort_for_Hire.lua`

**Rondipur** — NORTHERN_SAN_DORIA (zone 231), entity `0x010E70EA`  
stub fires `[722]`

- csid **721** → msgs [13116, 13117, 13118, 13119]  
  `[13116] [Sir/Lady] ! Much I have heard of your noble efforts on the battlefield. If it is not too much ...`
- csid **722** → msgs [13120, 13121, 13122, 13123]  
  `[13120] You shall find Miss Cannau in the Eldieme Necropolis. That is, if you are lucky enough to spot ...`
- csid **723** → msgs [13124]  
  `[13124] Ah, I heard from my men that you have been successful in escorting the missus. I applaud you on...`
- csid **724** → msgs [13125]  
  `[13125] <Sigh> I have the feeling this may not be the last time the missus goes galavanting about the n...`
- csid **725** → msgs [13126]  
  `[13126] Forget not the labors of the common folk, as they ever support this mighty kingdom.`

**Cannau** — THE_ELDIEME_NECROPOLIS (zone 195), entity `0x010C31D6`  
stub fires `[52]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

**Rondipur** — NORTHERN_SAN_DORIA (zone 231), entity `0x010E70EA`  
stub fires `[723]`

- csid **721** → msgs [13116, 13117, 13118, 13119]  
  `[13116] [Sir/Lady] ! Much I have heard of your noble efforts on the battlefield. If it is not too much ...`
- csid **722** → msgs [13120, 13121, 13122, 13123]  
  `[13120] You shall find Miss Cannau in the Eldieme Necropolis. That is, if you are lucky enough to spot ...`
- csid **723** → msgs [13124]  
  `[13124] Ah, I heard from my men that you have been successful in escorting the missus. I applaud you on...`
- csid **724** → msgs [13125]  
  `[13125] <Sigh> I have the feeling this may not be the last time the missus goes galavanting about the n...`
- csid **725** → msgs [13126]  
  `[13126] Forget not the labors of the common folk, as they ever support this mighty kingdom.`

## 89. `scripts/quests/windurst/A_Discerning_Eye.lua`

**Pygmalion** — PORT_WINDURST (zone 240), entity `0x010F00BA`  
stub fires `[240]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10019** → msgs [12801, 12802, 12803, 12804, 12805, 12806]…  
  `[12801] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Pygmalion** — PORT_WINDURST (zone 240), entity `0x010F00BA`  
stub fires `[241]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10019** → msgs [12801, 12802, 12803, 12804, 12805, 12806]…  
  `[12801] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

**Pygmalion** — PORT_WINDURST (zone 240), entity `0x010F00BA`  
stub fires `[240]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **10019** → msgs [12801, 12802, 12803, 12804, 12805, 12806]…  
  `[12801] Excuse me, [sir/madam]. If you are boarding the airship, might I ask you a favor?`

## 90. `scripts/quests/windurst/Babban_Ny_Mheillea.lua`

**Khoto_Rokkorah** — WINDURST_WATERS (zone 238), entity `0x010EE119`  
stub fires `[989]`  ← **WRONG — NPC does not own it**  ·  **BARE CHECK**

- csid **990** → msgs [15122]  
  `[15122] I still can't get “The Adventures of Babban Ny Mheillea” out of my mind.`

**Khoto_Rokkorah** — WINDURST_WATERS (zone 238), entity `0x010EE119`  
stub fires `[990]`  ·  **BARE CHECK**

- csid **990** → msgs [15122]  
  `[15122] I still can't get “The Adventures of Babban Ny Mheillea” out of my mind.`

## 91. `scripts/quests/windurst/Escort_for_Hire.lua`

**Dehn_Harzhapan** — PORT_WINDURST (zone 240), entity `0x010F00B9`  
stub fires `[10019]`  ← **WRONG — NPC does not own it**

- csid **10014** → msgs [12790, 12791, 12792]  
  `[12790] Well if it isn't a strrrong, reliable-looking adventurer! How'd you like to get your paws on a ...`
- csid **10015** → msgs [12792, 12793, 12794, 12795]  
  `[12792] Your client's name is Wanzo-Unzozo. He should be waiting just inside the citadel's entrrrance.`
- csid **10016** → msgs [12796]  
  `[12796] Grrreat job, . I knew I could count on you to get the job done. Here's your reward.`
- csid **10017** → msgs [12797]  
  `[12797] Sorrrry, . I don't have any work for you today.`
- csid **10018** → msgs [12789]  
  `[12789] Ahhh, if only a strrrong, reliable adventurer would come by...`

**Wanzo-Unzozo** — GARLAIGE_CITADEL (zone 200), entity `0x010C81A3`  
stub fires `[61]`  ← **WRONG — NPC does not own it**

_No csid on this entity resolves to zone dialog — it owns no quest cutscene. The stub's start NPC or trigger mechanic is structurally wrong._

**Dehn_Harzhapan** — PORT_WINDURST (zone 240), entity `0x010F00B9`  
stub fires `[10020]`  ← **WRONG — NPC does not own it**

- csid **10014** → msgs [12790, 12791, 12792]  
  `[12790] Well if it isn't a strrrong, reliable-looking adventurer! How'd you like to get your paws on a ...`
- csid **10015** → msgs [12792, 12793, 12794, 12795]  
  `[12792] Your client's name is Wanzo-Unzozo. He should be waiting just inside the citadel's entrrrance.`
- csid **10016** → msgs [12796]  
  `[12796] Grrreat job, . I knew I could count on you to get the job done. Here's your reward.`
- csid **10017** → msgs [12797]  
  `[12797] Sorrrry, . I don't have any work for you today.`
- csid **10018** → msgs [12789]  
  `[12789] Ahhh, if only a strrrong, reliable adventurer would come by...`

## 92. `scripts/quests/windurst/Heaven_Cent.lua`

**Ropunono** — WINDURST_WATERS (zone 238), entity `0x010EE01A`  
stub fires `[284]`  ·  **BARE CHECK**

- csid **283** → msgs [7968, 7969]  
  `[7968] Windurst is protected by the stars. Here at the Optistery, we record the position of the stars ...`
- csid **284** → msgs [7970, 7971, 7972, 7973]  
  `[7970] Things are a total blur lately... I'm having trouble focusing...`
- csid **285** → msgs [7974, 7975]  
  `[7974] This telescope is really old, and it's about time to change its stellar mirror.`
- csid **288** → msgs [7980, 7981, 7982, 7983, 7984, 7985]…  
  `[7980] Ah! What's this? It can't really be  , can it!?`
- csid **289** → msgs [7987, 7988]  
  `[7987] If only I had  , I'd be able to inscribe the correct star positions onto the . Otherwise, I won...`
- csid **292** → msgs [6552, 7993, 7994, 7995]  
  `[6552] Obtained  gil.`
- csid **293** → msgs [7996, 7997]  
  `[7996] Oh then, Odin's to the north. Right and, Titan's to the south. Shivers, Shiva's to the east. An...`
- csid **296** → msgs [8002, 8003, 8004]  
  `[8002] I never thought you'd actually find one of these! What, did you travel back in time to ancient ...`
| _...1 more csids_ | | |

**Ropunono** — WINDURST_WATERS (zone 238), entity `0x010EE01A`  
stub fires `[285]`  ·  **BARE CHECK**

- csid **283** → msgs [7968, 7969]  
  `[7968] Windurst is protected by the stars. Here at the Optistery, we record the position of the stars ...`
- csid **284** → msgs [7970, 7971, 7972, 7973]  
  `[7970] Things are a total blur lately... I'm having trouble focusing...`
- csid **285** → msgs [7974, 7975]  
  `[7974] This telescope is really old, and it's about time to change its stellar mirror.`
- csid **288** → msgs [7980, 7981, 7982, 7983, 7984, 7985]…  
  `[7980] Ah! What's this? It can't really be  , can it!?`
- csid **289** → msgs [7987, 7988]  
  `[7987] If only I had  , I'd be able to inscribe the correct star positions onto the . Otherwise, I won...`
- csid **292** → msgs [6552, 7993, 7994, 7995]  
  `[6552] Obtained  gil.`
- csid **293** → msgs [7996, 7997]  
  `[7996] Oh then, Odin's to the north. Right and, Titan's to the south. Shivers, Shiva's to the east. An...`
- csid **296** → msgs [8002, 8003, 8004]  
  `[8002] I never thought you'd actually find one of these! What, did you travel back in time to ancient ...`
| _...1 more csids_ | | |

## 93. `scripts/quests/windurst/Nothing_Matters.lua`

**Koru-Moru** — WINDURST_WALLS (zone 239), entity `0x010EF021`  
stub fires `[350]`  ← **WRONG — NPC does not own it**

- csid **193** → msgs [7532]  
  `[7532] Ergh... Why, diddly-doodley, do you bother me? I was just riding on the back of a fire dragon a...`
- csid **194** → msgs [7533, 7534, 7535]  
  `[7533] Ergh... Why, diddly-doodley, do you bother me? I was just in mortal combat with the Shadow Lord...`
- csid **197** → msgs [7538, 7539, 7540, 7541, 7542, 7543]…  
  `[7538] Ergh... Why, diddly-doodley, do you bother me? I was just riding on an ice dragon as she flew a...`
- csid **198** → msgs [7546]  
  `[7546] Say, hey, doodily-do. Hurry up and find me that “rough black stone”-aroo I'm looking for! I'm w...`
- csid **199** → msgs [7547, 7548]  
  `[7547] Hey! Why do you have my love letter to my pen-pal sweet-eroony sweetie-pie Mojiji!?`
- csid **211** → msgs [7567, 7568]  
  `[7567] Oh, sweet-aroo! What's that stone-a-roney you have there?`
- csid **212** → msgs [7569, 7570]  
  `[7569] Hold diddly on-aron...! Is this really-doodily the stone-aroo I asked you for...? There's somet...`
- csid **213** → msgs [7571, 7572, 7573, 7574]  
  `[7571] Hoo-hoo-hoo-ho-hoo! I'm giddly-goodily glad you were able to fiddly-fondily find this stone-a-r...`
| _...35 more csids_ | | |

**Koru-Moru** — WINDURST_WALLS (zone 239), entity `0x010EF021`  
stub fires `[351]`  ← **WRONG — NPC does not own it**

- csid **193** → msgs [7532]  
  `[7532] Ergh... Why, diddly-doodley, do you bother me? I was just riding on the back of a fire dragon a...`
- csid **194** → msgs [7533, 7534, 7535]  
  `[7533] Ergh... Why, diddly-doodley, do you bother me? I was just in mortal combat with the Shadow Lord...`
- csid **197** → msgs [7538, 7539, 7540, 7541, 7542, 7543]…  
  `[7538] Ergh... Why, diddly-doodley, do you bother me? I was just riding on an ice dragon as she flew a...`
- csid **198** → msgs [7546]  
  `[7546] Say, hey, doodily-do. Hurry up and find me that “rough black stone”-aroo I'm looking for! I'm w...`
- csid **199** → msgs [7547, 7548]  
  `[7547] Hey! Why do you have my love letter to my pen-pal sweet-eroony sweetie-pie Mojiji!?`
- csid **211** → msgs [7567, 7568]  
  `[7567] Oh, sweet-aroo! What's that stone-a-roney you have there?`
- csid **212** → msgs [7569, 7570]  
  `[7569] Hold diddly on-aron...! Is this really-doodily the stone-aroo I asked you for...? There's somet...`
- csid **213** → msgs [7571, 7572, 7573, 7574]  
  `[7571] Hoo-hoo-hoo-ho-hoo! I'm giddly-goodily glad you were able to fiddly-fondily find this stone-a-r...`
| _...35 more csids_ | | |

---

# Appendix A — the two quests with no quest event on their NPC

These are answered, just not with a csid. Both NPCs own only generic
conquest / mog-tablet events, so the stub's premise is wrong at a structural
level, not merely off by an id.

- **`A_Furious_Finale.lua`** — Laila, Upper Jeuno, entity `0x010F40BA`. Owns only
  csids **10172** and **10221**, both 1-2 byte trigger stubs with an empty
  `data[]`. Zone-wide, 10221 resolves to conquest-standing chatter on several
  unrelated entities. Laila has no quest cutscene here; the stub's `10123/10124`
  are not hers either. Find the real start NPC before rebuilding.
- **`Survival_of_the_Wisest.lua`** — Indescript Markings, Pashhow Marshlands [S],
  entity `0x0105A303`. Owns exactly csid **2**, which is the shared mog-tablet /
  Kupower announcement event used by many entities in that zone. A "???"-style
  marking almost certainly uses a `messageSpecial` trigger, not a cutscene.

# Appendix B — The Rider Cometh, both halves decoded

The owner's blocker. Nashmau side (proxy entity `0x01035062`):

| csid | msgs | role |
|---|---|---|
| **318** | 11818-11840 | first Yoyoroon talk; 11839 "Along with the talisman, perhaps you could bring him a treat from his favorite teahouse", 11840 "Thank you, friend. Be safe in your travels." => {KI} Message from Yoyoroon |
| **327** | 11847-11868 | talisman + food trade and appraisal; 11868 = menu "Give a treat to Yoyoroon? / <item1> / <item2> / Both" (matches bg-wiki "or even both"); 11860-11862 = appraisal success |
| **324** | 11847-11854 | shorter trade branch |
| **320** | 11868-11873 | "One [keyitem], restored as closely as possible to its original glory" => {KI} Talisman of the rebel gods |
| **323** | 11869, 11873 | condensed handover |
| **326** | 11868 | trade menu alone |

Whitegate side — **csid 959** (proxy entity `0x01032269`, listed as `NPC[63]` in
npc_list), messages 14500-14507:

- 14502 "You keep doing good by me, **Captain** ${name-player}"
- 14503 "That foreboding visage known as the Dark Rider is now known to be none
  other than the nefarious god **Odin** himself. Reliable sources have confirmed
  rrrumors that he regularly haunts the **Hazhalm Testing Grounds**."
- 14507 "If this Odin really does exist... you must send him back to the hell
  from which he came!"

That is the quest description verbatim. The rolled-R speech is Naja Salaheem's,
not Nashmeira's, so the briefing is Naja's despite bg-wiki listing Nashmeira as
the start. Related: csid **882** covers 14918-15098 (the second spatial
distortion / Talisman key security thread).

**Still genuinely missing: the Odin Prime battlefield.** There is no
`scripts/battlefields/Hazhalm_Testing_Grounds/` directory, no `xi.battlefield.id`
entry, and no Odin Image mob. That is build work, not research — the csids are
no longer the blocker.

# Appendix C — Mythic arc, decoded

**Paparoon** (Nashmau, entity `0x0103505E`) owns csids 26-34 and 334-338. The DAT
gives the real task list, which is more specific than the bg-wiki summary:

- **11739** = the menu: "What will you ask about? Alexandrite gems / Wyrmseeker
  of Areuhat / Assault memoires / Holy relics"
- csid **28** -> 11739-11751 : task menu and in-progress lines
- csid **29** -> 11762-11765 : alexandrite turn-in
- csid **30** -> 11766-11768 : Wyrmseeker of Areuhat (picture book) turn-in
- csid **31** -> 11769-11774 : the five assault memoires, one line per area
  (Leujaoam / Mamool Ja / Lebros / Periqia / Ilrusi)
- 11777-11782 = all three tasks done, "special, shiny invitation... head to big
  gate in town" => completion of **Duties, Tasks, and Deeds**
- csid **32** -> 11793-11794 : Balrahn's eyepatch turn-in (**Coming Full Circle**);
  offer lines are 11788-11792
- csid **26** -> 11783 "I's the Paparoon! Imperial army honorary officer" = intro

The stubs fired 210 and 230; Paparoon owns neither.

**Nashmeira** (Whitegate, entity `0x010320A8`) owns csids 504, 825, 3027, 3034,
3052, 3078, 3090. The stubs fired 300 / 310 / 320 / 220 — she owns **none** of
them. Her quest events sit on proxies as above.

---

# Crystal War decode -- 2026-08-10 session

## New tool: `UpdateExtractor/xidat/csidscan.py`

`csidmsg.py`'s CLI prints NOTHING for several zones (80 Southern San d'Oria [S],
94 Windurst Waters [S], 95 West Sarutabaruta [S] at least), because its
high-precision `scan()` keys on opcodes 0x1D/0x48/0x24 and these programs carry
their text refs elsewhere. The fix is to call the WIDE scan,
`find_msg(blob, entry, data, targets)`, against an explicit target range.
`csidscan.py` wraps that:

    python3 xidat/csidscan.py <zone> [entity] [--lo N] [--hi N]

Regression-tested against the documented Katsunaga case (Mhaura 249, 17797157):
190->7078, 191->7079/7080, 193->7086-7089, 194->7090 -- exact match.

**Pick a sensible `--lo`.** The default is 7000 because `--lo 1` produces false
positives: small integers sitting in the data table (30, 11, 45, 120 ...) resolve
to "valid" low message ids and pollute every row. Bracket the zone's real quest
dialog and cross-check with `xi-dat dialog`.

**Holder pattern, again and again.** In Crystal War and old-world zones the real
program usually sits on an invisible `blank` / `DIRECTOR` entity a few indices from
the visible NPC, which carries only a 1-byte `0x00` stub of the same csid. Scan the
WHOLE zone (omit `entity`) whenever an NPC's own csid set looks empty or wrong.

## Nichais -- Southern San d'Oria [S] (zone 80), entity 17105607, 0x010502C7

| csid | messages | role |
|---|---|---|
| 83 | 13563-13565 | pre-quest approach |
| **72** | 13566-13589 | Beast from the East OFFER (13567 = "Does this talk interest you? / Immensely, yes. / Not in the least, no." -> option 0 accepts) |
| **74** | 13606-13615 | return after the altar; sets the riddle (13609) |
| 75 | 13616-13617 | wrong item -- "I'm not sure I see the relevance" |
| 76 | 13618-13620 | wrong item -- "a bit too large" |
| 77 | 13621-13622 | wrong item -- a rare tome |
| **78** | 13623-13632 | Shell Bug, the CORRECT trade. Program on holder `blank` 0x010502C5 (17105605), NOT on Nichais |
| 79 / 80 | 13632-13635 | closing scenes |

Timeworn Altar (17142597, zone 89 idx 837) owns exactly csids **17** and **18**,
both programs on holder `blank` 0x01059343 (17142595): 17 = 4023 B (first
cutscene), 18 = 16194 B (final cutscene + award).

Beast from the East is BUILT from this.

## Dhea Prandoleh -- Windurst Waters [S] (zone 94), entity 17162751, 0x0105E1FF

She is the giver for three of the remaining crystalWar stubs. Full resolved set:

| csid | messages | role |
|---|---|---|
| **26** | 13580 | Sins of the Mothers (53) -- start |
| **34** | 13889-13890 | Manifest Destiny (62) -- offer. 13889 "This is it, ${name-player}--the day that mercenaries like us live for.", 13890 "make for the Meriphataud encampment! Lehko and Romaa will have furrrther orders for you there." |
| **35** | 13904-13906 | When One Man Is Not Enough (39) -- offer. 13905 "Oh, it's no use, ${name-player}. I can't stop worrrying about him... Perhaps you could head to Sarutabaruta to take a look?" Context 13900-13902 sets it up: "I just got back from a sweep of Sarutabaruta... I think I saw you-know-who!" / "He was by that tower, but lying on the ground, and not moving..." |
| 36 | 13950-13951 | post-quest idle -- "If it isn't our star mercenary" |
| 166 | 13139-13140 | unrelated |
| 131/135/136/139/160/164 | 11072-11744 | other chains |

Also in that block, not yet assigned to a csid: **13947-13949** is a reward
handover with a full-inventory guard -- 13947 "If you're looking for your
${item-singular: 0[2]}, I've got it right here.", 13949 "I've never seen a bag so
full o' junk. Come back when you've strrraightened it out, will ya?" That is very
likely the 12x Red Rose delivery for When One Man Is Not Enough.

## When One Man Is Not Enough (39) -- what is still missing

Retail (bg-wiki): Dhea (H-10) -> examine the Sealed Entrance at the magic tower,
West Sarutabaruta [S] (F-11) -> optional second examine (Lehko complains of hunger)
-> back to Dhea -> trade one of Blackened Siredon / Forest Carp / Greedie / Pipira
(which fish changes the cutscene) -> 12x Red Rose. Prev: A Manifest Problem.
Next: A Feast for Gnats.

* Item ids all confirmed: `RED_ROSE` 941, `FOREST_CARP` 4289, `GREEDIE` 4500,
  `PIPIRA_1` 4464, and `BLACKENED_MUDDY_SIREDON` 5266 -- ALL FOUR already existed.
  Nothing needed adding.

  **Check by ID, not by name, before adding an enum.** Two redundant entries were
  written and reverted during this pass: a bare `PIPIRA` (4464 was already
  `PIPIRA_1`) and a `BLACKENED_SIREDON` (5266 was already
  `BLACKENED_MUDDY_SIREDON`, keyed on item_basic's `name` column rather than its
  sort name). `item_basic` rows carry both a name and a sort name and the enum may
  use either, so a name-only grep gives a false negative. Verify with a reverse
  id -> names map over scripts/enum/item.lua.
* **Which Sealed Entrance is the F-11 tower is UNRESOLVED.** Zone 95 has three:
  `Sealed_Entrance_1` 17167180 (-245.000, -18.100, 660.000),
  `Sealed_Entrance_2` 17167181 (263.600, -6.512, 40.000),
  `Sealed_Entrance_3` 17167182 (-340.000, 1.825, -364.825). All three have the
  unusual status 32769 (0x8001). Coordinate-to-map-letter reasoning favours _1,
  but that is inference and was NOT shipped on that basis.
* **None of the three owns any csid**, so the cutscene program is on a holder.
  Zone-95 scene ownership as far as it was mapped:
  17167179 (idx 843) csid 200 -> 7436-7445; 17167184 (idx 848) csid 102 -> 7462-7504
  (42 msgs, the Lehko confrontation: 7463 "Your sweet-talking will get you
  nowherrre, Lehko", 7471 "...If Lehko Habhoka is trrruly who you are!"),
  csid 103 -> 7508-7587 (79 msgs), csid 104 -> 7506-7507. Examine text is 7455
  "The door is sealed shut...".
  `xi-dat search 95 "hunger"` returns 0 hits, so bg-wiki's "complains of his hunger
  pains" is worded differently in the client -- do not use it as an anchor.

## Manifest Destiny (62) -- offer csid known, rest is large

Offer is Dhea csid **34**. But retail needs: examine the Mithran Bivouac in
Meriphataud Mountains [S] (I-8), enter Castle Oztroja [S] for a cutscene, farm
**three Dorter Keys** from Yagudo Eradicators / Knights Templar / Prioresses /
Prelates, then progress inside Oztroja. Prev: Howl from the Heavens.
Next: At Journey's End. Reward: Hi-Reraiser. This is a multi-zone chain with a key
farm, so it is materially bigger than Beast from the East.
