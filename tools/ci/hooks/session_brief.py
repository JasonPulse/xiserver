#!/usr/bin/env python3
"""SessionStart hook. Re-injects the facts that keep getting forgotten.

Stdout from this hook lands in the model's context. It fires on startup, resume
and compact, and `compact` is the one that matters: the transcript audit found
the worst relapse runs sat directly on compaction boundaries. One resume run ran
76 Bash greps and 13 quest-table accesses. Two more of the worst five followed a
resume. Rules that live only in chat history do not survive a summary, so the
facts are re-stated here at exactly the moment they are lost.

This prints facts and live counts, not instructions. CLAUDE.md carries the rules.
What the model loses at a compaction boundary is not the rule, it is the ground
truth that makes the rule obviously correct.
"""

import csv
import sys
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
MAP = REPO / 'tools' / 'coverage' / 'data' / 'quest_id_map.tsv'
SENTINEL = REPO / '.claude' / 'strict-read-mode'

COVERAGE = """Client quest-id coverage, measured from UpdateExtractor/output. Do not re-derive
this and do not claim an area is uncovered without opening the file named here.

  log area      ids   quests.xml      DMSG dump                 blocks
  sandoria       82   sd_qs_e 112     quests-sandoria.xml          112
  bastok         93   bs_qs_e 100     quests-bastok.xml            100
  windurst       90   ws_qs_e 100     quests-windurst.xml          100
  jeuno         153   jn_qs_e 132     quests-jeuno.xml             159
  otherAreas     87   ot_qs_e 109     quests-other.xml             131
  outlands       56   fr_qs_e 219     quests-zilart.xml            218
  ahtUrhgan      72   at_qs_e 128     quests-ahtuhrgan.xml         128
  crystalWar     95   none            quests-goddess.xml           128
  abyssea       192   none            quests-abyssea.xml           192
  adoulin        97   none            none
  coalition      95   none            none

abyssea joins directly: 192 declared ids, gapless 0 to 191, against exactly 192
DMSG blocks at index 0 to 191. Title comparison, no decode.

adoulin and coalition are the ONLY areas with no client dump. They are the only
place an UNCOVERED verdict is legitimate. Everywhere else, reaching the edge of
quests.xml means opening the DMSG file above, not writing a report about it."""


def counts():
    if not MAP.exists():
        return 'quest_id_map.tsv does not exist yet.'

    try:
        with MAP.open(encoding='utf-8') as handle:
            rows = list(csv.DictReader(handle, delimiter='\t'))
    except OSError:
        return 'quest_id_map.tsv could not be read.'

    if not rows:
        return 'quest_id_map.tsv is empty.'

    tally = Counter((r.get('verdict') or '').strip() for r in rows)
    body = '  '.join(f'{k or "(blank)"}={v}' for k, v in tally.most_common())
    return f'quest_id_map.tsv: {len(rows)} rows.  {body}'


def main():
    # Read and discard the payload so the hook never blocks on framing.
    sys.stdin.read()

    print('=== xiserver quest audit brief ===')
    print()
    print(counts())
    print()
    print(COVERAGE)
    print()

    if SENTINEL.exists():
        print(
            'strict-read-mode is ON. Searching is denied by hook and the Stop '
            'gate is live: this run cannot end while '
            'tools/coverage/validate_quest_id_map.py fails.'
        )
    else:
        print('strict-read-mode is off. Searching is allowed and the Stop gate is off.')

    sys.exit(0)


if __name__ == '__main__':
    main()
