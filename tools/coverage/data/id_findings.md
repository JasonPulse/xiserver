# Quest id integrity findings

Produced by `tools/coverage/verify_quest_ids.py`. Everything here is a claim about
the quest id table, checked against the client, not against upstream's comments.

## Confirmed correct

- **Crystal War, all 95 ids.** `quests-goddess.xml` matches the declared table at
  block index == id across the whole range, 91 exact plus 4 that differ only in
  spelling (`MESSAGE_ON_THE_WINDS` vs "Message on the Wind",
  `HER_MEMORIES_THE_GRAVE_RESOLVE` vs "Her Memories: Grave Resolve",
  `VOIDWALKER_OP_126` vs "VW Op. #126: Qufim Incursion", `REDRAFTED_BY_THE_DUCHY`
  vs "Re-Drafted by the Duchy"). A 95-long run with no drift, including across the
  four id gaps, is what makes this decisive.
- **Abyssea ids 0 to 123.** 124 consecutive title matches at delta 0.
- **586 ids across the seven categories `quests.xml` covers.** Those have an
  explicit id field, so they are direct comparisons rather than inference.

## One real anomaly, not corrected

**Abyssea Grauberg Dominion Ops #10 to #14 are declared out of position.**

The table declares:

    115..123   DOMINION_OP_01..09_GRAUBERG
    124..186   Ward Warden, Desert Rain, Crimson Carpet, Refuel and Replenish,
               A Mightier Martello, and the Abyssea storyline
    187..191   DOMINION_OP_10..14_GRAUBERG

Two independent lines of evidence say 187 to 191 is the wrong home for those five:

1. `quests-abyssea.xml` places "Dominion Op #10 (Grauberg)" through
   "#14 (Grauberg)" at blocks 124 to 128, immediately after #09 at block 123.
   Every entry from 124 onward then sits 5 blocks later than the table declares.
2. Every other Abyssea zone declares its fourteen Dominion Ops contiguously.
   Uleguerand is 101 to 114, Altepa ends at 100. Grauberg is the only zone split
   across two ranges, with a 63-id gap in the middle.

**This has not been corrected, and the correct ids cannot be derived from the data
on hand.** The DMSG block index is a block counter, not an id, so its ordering
shows the five are misplaced but cannot say what the right ids are. Resolving it
needs either a retail id source for Abyssea or a live check.

Blast radius if someone corrects it blind: 68 ids move, and Abyssea quest files
reference these by enum name, so every one of them would change which client log
slot it occupies. Getting it wrong breaks 68 working quests.

## Why the DMSG files may confirm an id but never correct one

`quests-<area>.xml` is a `DMSGStringBlock` dump. Its `index` is a sequential block
counter and it is gapless where the real table has gaps.

Proof, from a region where `quests.xml` gives the real ids:

    quests.xml         ot_qs_e id 106 = "An Understanding Overlord?"
    quests-other.xml   block     105 = "An Understanding Overlord?"

A uniform -1 across the tail of `otherAreas` follows from that, and reading it as a
defect would have "corrected" 22 ids that are already right, including the entire
Mog Garden block 112 to 131 and the ten Mog Garden quests built against it.

An earlier pass of this script did emit those 22, plus 21 in Jeuno and 68 in
Abyssea, as ID_WRONG. All 111 were artifacts of the block counter. The script now
accepts a DMSG placement only at delta 0 backed by a run of at least six
consecutive ids, and treats any nonzero delta as UNCOVERED.

## Still uncovered, 311 ids

    adoulin      97   no client file exists
    coalition    95   no client file exists
    abyssea      68   the shifted tail described above
    jeuno        25   beyond jn_qs_e, DMSG cannot place them
    otherAreas   22   beyond ot_qs_e, DMSG cannot place them
    crystalWar    4   spelling variance blocks the automated match

Adoulin and Coalition have no `quests-*.xml` at all, so no offline source can place
them. They need a retail id source or a live check.
