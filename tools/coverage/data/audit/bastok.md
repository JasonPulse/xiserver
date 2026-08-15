# Bastok retail-flow audit

Method: bg-wiki page (cached in /tmp/bgwiki) gives the quest list AND the steps.
Repo implementation found by DECLARATION (`xi.quest.id.bastok.<ENUM>`), including
legacy `scripts/zones/**` implementations. Verdict is based on whether the repo
flow follows the wiki steps — **having a file is not a pass**.

| # | Quest | Verdict | Note |
|---|---|---|---|
| 2 | A Discerning Eye (Bastok) | REBUILT-THIS-SESSION | thin wrapper over scripts/globals/discerning_eye.lua; wiki steps (picture -> board airship -> 8 lookalike passengers -> one chance -> 500 gil, 3 title tiers) all present. Picture param needs an in-game `!cs 295` probe |
| 3 | A Flash in the Pan | CORRECT | wiki: talk Aquillina, trade Flint Stone x4, 100 gil, repeatable. repo: begin csid 217, onTrade -> 219 complete + confirmTrade, section2 check `status ~= QUEST_AVAILABLE` gives the repeat path. gil 100 matches |
| 4 | A Foreman's Best Friend | CORRECT | wiki: Gudav -> Dog Collar -> Map of the Gusgen Mines + 2,000 XP. repo: begin 110, onTrade -> 112, `addExp(2000)` + `giveKeyItem(MAP_OF_THE_GUSGEN_MINES)`, plus Dehlner flavour event 111 |
