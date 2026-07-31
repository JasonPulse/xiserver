# Trust Systems Backlog

Everything remaining from the 2026-07-31 trust overhaul. The per-trust **gambit + trait
layer is done** (all ~120 trusts audited against their full FFXIclopedia pages). What is
left below is **system / feature work** — none of it is "just a gambit."

## ===== FINAL STATUS (2026-07-31) — systems build complete =====
BUILT: (1) synergy infra + Ark Angel 5-set + Nashmeira→Mnejing/Ovjang + Karaha←Star Sibyl +
Mumor↔Uka + Chebukki-Meteor→Kukki; (2) passive Indi-aura (Moogle, Ygnas) + Kupofried XP/Dedication
aura + Sakura no-enmity(ENMITY-50); (3) dark auto-attacks (balamor; teodor partial); (4) Rejuvenation
(Selh'teus); (5) Quick Draw C++ select QD_WEAKNESS (Luzaf); (6) Morimar mobskills (12 Blades of
Remorse + Vehement Resolution); (7) Dryad's Kiss→Haste (rosulatia); King of Hearts Temper→DA mod;
Iroha II Flare II MB.
DISCARDED: undead classification (balamor/teodor — not worth it, party-Cure-damage downside).
APPROXIMATED (already covered by existing gambits, no dedicated build): **Arciela / Arciela II**
Bellatrix/Ascension-Descension stance switch — both already cast their buff AND enfeeble sets, so
the stance-alternation is cosmetic. Also **d_shantotto** "won't cast while holding hate" — minor
safety nuance, skipped.
BLOCKED ON CLIENT DATA (need real animation IDs from DAT captures — cannot fabricate): **Tongue Lash**
(rongelouts AoE Terror), **Lhu** Spinning Axe + Decimation (2 of her 4 WS; Rampage+Onslaught work),
**Mnejing** automaton WS (Chimera Ripper/Slapstick/String Clipper/Shield Subverter — has generic
sword WS meanwhile), **Lilisette II** Vivifying Waltz + Rousing Samba (no ja enums / ability scripts).
LOW-VALUE DEFERRED: cast-on-specific-trust synergies (Pieuje→Trion, Prishe II→Ulmia — only matter
when both are fielded; ai.t.CURILLA precedent is hardcoded-by-name, doesn't generalize cleanly).
=================================================================

Source of truth for trust behavior: fetch the FULL wikitext, NOT WebSearch summaries:
```
curl -sS -A "Mozilla/5.0" "https://ffxiclopedia.fandom.com/api.php?action=parse&page=Trust:_<Name>&prop=wikitext&format=json&redirects=1"
```

---

## 1. Passive Indi-aura (party buff, entity performs no actions)
INFRASTRUCTURE BUILT (2026-07-31) in `scripts/globals/trust.lua`:
- `xi.trust.applyAura(mob, effectId, power)` — radiate a GEO_* aura to party (modeled on
  Avatar's Favor: addStatusEffectEx with auraTarget.ALLIES + effectFlag.AURA, duration 0).
- `xi.trust.removeAura(mob, effectId)`; `xi.trust.conditionalAura(mob, effectId, power, {gatingIds}, name)`.
- GEO_REFRESH effect (541) → its handler grants REFRESH mod = power. Distinct from EFFECT_REFRESH so it STACKS.

| Trust | Aura | Status |
|---|---|---|
| Moogle | Full-time Indi-Refresh 2 MP/tick | **DONE** — applyAura(GEO_REFRESH, 2); removed non-retail Refresh/Cure gambits |
| Ygnas | Indi-Refresh 2 MP/tick ONLY when Arciela/Arciela II present | **DONE** — conditionalAura |
| Kupofried | XP/CP bonus aura (NOT a stat aura — needs battle-reward hook) + magic skill-up | TODO — different mechanic (XP modifier), not the GEO aura helper |
| Sakura | "No-enmity" aura (monsters never target her) | TODO — different mechanic (enmity/detection on the trust itself, not a party aura) |

VERIFY IN GAME: duration-0 permanent AURA radiation (Avatar's Favor re-applies each tick with
duration 15; if Moogle's aura doesn't persist/radiate out of combat, refresh it on a timer).
Also: Moogle "magic skill-up rate" bonus not modeled (obscure).

Note: Brygid, Star Sibyl, Kuyin Hathdenna are pure no-ops (correct as empty stubs — NOT auras).

---

## 2. Undead classification + physical/dark auto-attack switch
PARTIALLY BUILT (2026-07-31). `xi.trust.darkAutoAttacks(mob)` in trust.lua adds a permanent
dark enspell (ENSPELL=DARK + ENSPELL_DMG = mainLvl) so swings deal dark magic damage.

| Trust | Status |
|---|---|
| balamor | **DONE (dark AA)** — melees, so dark enspell is fully active. |
| teodor | **PARTIAL** — darkAutoAttacks added, but he stays a caster (autoattack disabled), so it only matters if he melees. His real "ranged dark attack" is the Mammet-family ranged magic auto-attack (see ajido page too) — a distinct engine mechanic, not modeled. |

**DISCARDED — undead classification NOT implemented (2026-07-31).** Decision: not worth an
engine change for one trust, and making them undead would let party AoE Cures damage them.
Noted in balamor.lua / teodor.lua. Dark auto-attacks cover the visible half. (Also skipped:
teodor swipe→Silence, balamor Last Laugh self-heal, teodor Mammet-style ranged dark auto-attack.)

---

## 3. Unique aura mobskills — **BUILT (2026-07-31)**
Morimar was a complete stub (auto-attack only). His mob_skill ROWS existed (3676/3680) but the
SCRIPTS didn't. Built:
- `scripts/actions/mobskills/12_blades_of_remorse.lua` — 3-hit AoE physical, SLASHING; mob_skill
  3680 flags fixed to aoe=1 + primary_sc=13 (Light). Added to his skill_list 1105 (his TP WS).
- `scripts/actions/mobskills/vehement_resolution.lua` — full self-heal + `delStatusEffectsByFlag(ERASABLE)`
  + Regen aura (30 HP/tick, 60s); mob_skill 3676 flags fixed to valid_targets=1 (self).
- morimar.lua: TP WS at 1000 + Vehement Resolution gambit at HPP<50 (ai.r.MS SPECIFIC 3676, 120s cd).
SIMPLIFICATION: "12 Blades only during aura" relaxed — it's a normal TP weaponskill now. Loader
uses a file-path load so the digit-leading filename is fine (1000_needles.lua etc. exist).

---

## 4. Quick Draw (engine gambit-select support) — **BUILT (2026-07-31)**
Added C++ gambit-select `G_SELECT::QD_WEAKNESS` (= ai.s.QD_WEAKNESS = 18): in the JA execution
path it reads the battle target's 6 elemental RES_RANK mods (Fire..Water are consecutive 192-197),
picks the lowest, and fires the matching shot ability (ABILITY_FIRE_SHOT..WATER_SHOT, 125-130).
Files: gambits_container.h (enum), gambits_container.cpp (SelectToString + JA handler), gambits.lua.

| Trust | Status |
|---|---|
| Luzaf | **DONE** — Triple Shot + Dark Shot (when target has a dispelable buff) + Quick Draw weakness shot + ranged. No Phantom Roll (correct). |
| Qultada | ai.s.QD_WEAKNESS now available to her too if wanted (she already has rolls). TODO: Dedication-gated Corsair's Roll + roll "busting" (behavioral). |

TODO (minor): Light Shot to sleep — skipped (sleeping the party's tanked target is counterproductive, like the AATT Sleepga call).

---

## 5. Rejuvenation ability (Selh'teus) — **BUILT (2026-07-31)**
- `rejuvenation.lua` made party-aware: if the caster has a master (trust), it restores HP/MP/TP
  to the whole party (`master:getPartyWithTrusts()`); else single-target (boss 1509 unchanged).
- mob_skill 3622 flags fixed: valid_targets 4→1 (self), aoe 0→1 so the MS gambit self-targets.
- selh_teus.lua: gambit `ai.r.MS SPECIFIC 3622` gated `PARTY_HPP_LT 75` with 90s cooldown; +ACC 1000 (forced ~95% hit). WS (Revelation/Luminous Lance) already in skill_list 1094.
- APPROXIMATION: retail trigger is "3+ members ≤75% OR any asleep"; PARTY_HPP_LT fires if ANY member <75% (more lenient, but 90s cooldown bounds it). No PARTY-asleep condition exists — could add one. Restore is full HP/MP + TP to 3000 (very strong; tune if needed).

---

## 6. Casting stance switch (Arciela family)
A two-mode caster: switch between an enhancing/light mode and an enfeebling/dark mode,
casting different spell sets per mode.

| Trust | Modes |
|---|---|
| Arciela | Bellatrix of Light (buffs self+summoner only: Protect V/Shell V/Haste II/Refresh II) vs Bellatrix of Shadows (Slow II/Paralyze II). Regain trait done. |
| Arciela II | Ascension (Enhancing) vs Descension (Enfeebling); both also deal magic damage; MBs off skillchains. UFASTCAST done. |

---

## 7. Party-member synergies (buff/behavior when a specific other trust is present)
INFRASTRUCTURE BUILT (2026-07-31) in `scripts/globals/trust.lua`:
- `xi.trust.getPartyTrustIds(mob)` → set of trust IDs in party
- `xi.trust.partyHasAllTrusts(mob, {ids})` / `xi.trust.partyHasAnyTrust(mob, {ids})`
- `xi.trust.arkAngelSynergy(mob)` → +MDEF while all 5 AAs present
Pattern for mod-synergies: `mob:addListener('COMBAT_TICK', 'NAME', fn)` that re-checks each tick and setMod()s (see uka_totlihn/mumor/mnejing/karaha-baruha). NOTE: COMBAT_TICK only fires IN COMBAT.

| Source trust | Effect | Status |
|---|---|---|
| Rainemard → Curilla | Haste/Phalanx II/Refresh on Curilla | **DONE** (ai.t.CURILLA gambits) |
| Ark Angels (all 5) | +Magic Defense when all 5 present | **DONE** (arkAngelSynergy on all 5; MDEF 25 — tune) |
| Mnejing ← Nashmeira | +Defense + Enmity | **DONE** (COMBAT_TICK; DEF 100 / ENMITY 130 — tune) |
| Karaha-Baruha ← Star Sibyl | +2 MP/tick Refresh | **DONE** (COMBAT_TICK REFRESH 1→3) |
| Mumor ↔ Uka Totlihn | Mumor +Samba dur / Uka +Waltz pot | **DONE** (both pre-existing) |
| Pieuje → Trion | Casts Regen on Trion | TODO — needs cast-on-specific-trust (no ai.t.TRION target; needs new gambit target or listener that casts) |
| Nashmeira → Ovjang | +def/+enmity on Ovjang | TODO (Ovjang side; add COMBAT_TICK on ovjang like mnejing) |
| Karaha ↔ Robel-Akbel | Skillchain together | TODO (skillchain-coordination behavior) |
| Ingrid II ← Koru-Moru | Receives Refresh | TODO (Koru-Moru casts Refresh on trusts already? verify; likely needs Koru target logic) |
| Prishe II → Ulmia | Cure/Curaga on Ulmia | TODO (cast-on-specific-trust like Pieuje→Trion) |
| Tenzen ↔ Mildaurion | Tsukikage→Fragmentation after Light Blade | TODO (skillchain-timing behavior) |
| Chebukki trio | Meteor dmg boost chant | TODO (Kukki Meteor +dmg when Makki+Cherukiki present — COMBAT_TICK mod on kukki) |

REMAINING SYNERGY TYPES: (a) mod-buff-when-present → easy, use the COMBAT_TICK pattern above;
(b) cast-a-spell-on-a-specific-trust (Pieuje→Trion, Prishe II→Ulmia) → needs a new gambit
target for the named trust, OR a listener that manually casts; (c) skillchain-coordination → hard.

---

## 8. Abilities / mob_skills that don't exist yet (need enum + script)
| Ability | Trust | Notes |
|---|---|---|
| Dryad's Kiss | Rosulatia | Self-Haste JA — no ja enum |
| Tongue Lash | Rongelouts | AoE Terror — no ja enum |
| Vivifying Waltz + Rousing Samba | Lilisette II | No ja enums — blocks her DNC kit |
| Spinning Axe + Decimation | Lhu Mhakaracca | mob_skills don't exist (Rampage 940 + Onslaught 1192 already in her list 1058) |
| Chimera Ripper / Slapstick / String Clipper / Shield Subverter | Mnejing | Automaton WS — his skill list currently has generic sword WS instead |
| Flashbulb / Disruptor | Mnejing | Automaton attachment abilities |
| Bored to Tears / Envoutement / Memento Mori / Silence Seal | Ullegore | Unique BLM JAs |
| Antiphase / Blow / Blank Gaze / Uppercut | Abenzio | Unique monster WS |

---

## 9. Miscellaneous behavior gates (nice-to-have)
| Trust | Behavior |
|---|---|
| D. Shantotto | "Will NOT cast while she has enough threat to be a melee target" (enmity-gate on casting) |
| King of Hearts | Temper full-time; levels up after weapon skills (effect unknown) |
| Iroha II | Magic Burst with Flare II (minor — working-tier trust, left light-touch) |
| Iron Eater / Abquhbah | While Restraint active, hold WS until 300% TP (minor) |

---

## Already handled (for reference — do NOT redo)
- 0-damage weaponskills fixed: chant_du_cygne / cloudsplitter / tachi_fudo / arrogance_incarnate mobskill scripts created.
- Enmity mod (+100 = 2x hate) on 10 tanks: AAEV, August, Curilla, Trion, Halver, Mnejing, Rahal, Rughadjeen, Valaineral, Excenmille.
- DB rows added: valaineral Protect I-IV/Reprisal/Phalanx/Enlight; Selh'teus WS; Lhu Rampage+Onslaught; AAGK Fudo+Dragonfall restored; AAEV Reprisal; ajido Dispel.
- Behavioral trait mods applied where page-noted (UFASTCAST, FASTCAST, REFRESH, REGAIN, REGEN, DMG, CURE_POTENCY, BEAST_KILLER, STORETP, ACC).
