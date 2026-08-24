#!/usr/bin/env python3
"""Validate tools/coverage/data/quest_id_map.tsv.

The deny hook governs operations. It cannot govern conclusions, and conclusions
are where the quest audit keeps failing. Two failures have now happened twice
each, so both are encoded here instead of written down again.

Failure 1, the invented verdict. The spec defines a closed set of seven verdicts.
A run wrote 76 rows as `UNVERIFIED`, a category the spec does not contain. That
is the same move as the `# write-time id lookup only` comment: when a rule is
inconvenient, a new label appears that the rule does not mention.

Failure 2, the premature `UNCOVERED`. `quests.xml` covers seven log areas. The
other four are covered by a `quests-<area>.xml` DMSG dump, except adoulin and
coalition, which POLUtils predates. A run marked 119 rows `UNCOVERED` across
abyssea, jeuno, otherAreas and crystalWar, every one of which has a dump file
sitting on disk. Abyssea is the clearest case: 192 declared ids, gapless 0 to
191, against exactly 192 DMSG blocks at index 0 to 191, so the join is direct
and needs no decode at all.

Exit 0 clean, 1 with the failures listed. Called by CI and by the Stop hook.
"""

import csv
import sys
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
MAP = REPO / 'tools' / 'coverage' / 'data' / 'quest_id_map.tsv'

VERDICTS = (
    'CONFIRMED',
    'ID_WRONG',
    'NAME_WRONG',
    'NO_SUCH_QUEST',
    'NOT_IMPLEMENTED',
    'MARKER_LIES',
    'UNCOVERED',
)

# Measured from the dumps in UpdateExtractor/output, not estimated. A log area
# absent from this map has no client dump and is the only place UNCOVERED is a
# legitimate verdict.
DMSG_DUMP = {
    'sandoria':   ('quests-sandoria.xml', 112),
    'bastok':     ('quests-bastok.xml', 100),
    'windurst':   ('quests-windurst.xml', 100),
    'jeuno':      ('quests-jeuno.xml', 159),
    'otherAreas': ('quests-other.xml', 131),
    'outlands':   ('quests-zilart.xml', 218),
    'ahtUrhgan':  ('quests-ahtuhrgan.xml', 128),
    'crystalWar': ('quests-goddess.xml', 128),
    'abyssea':    ('quests-abyssea.xml', 192),
}

UNCOVERED_OK = ('adoulin', 'coalition')

# Verdicts that assert an inability. Each one has to carry the file that was
# opened and the anchor run that was tried, or it is a guess wearing a label.
NEEDS_EVIDENCE = ('UNCOVERED', 'NO_SUCH_QUEST')


def fail(problems, row_num, area, name, message):
    problems.append(f'  row {row_num} [{area}/{name}] {message}')


def main():
    if not MAP.exists():
        print(f'#### {MAP} does not exist yet.')
        return 1

    with MAP.open(encoding='utf-8') as handle:
        rows = list(csv.DictReader(handle, delimiter='\t'))

    if not rows:
        print(f'#### {MAP} is empty.')
        return 1

    columns = list(rows[0].keys())
    problems = []

    if 'evidence' not in columns:
        problems.append(
            '  schema: no `evidence` column. Add one. Every UNCOVERED and '
            'NO_SUCH_QUEST row must name the dump file opened and the anchor '
            'run attempted, so an inability is checkable rather than asserted.'
        )

    for offset, row in enumerate(rows, start=2):
        area = (row.get('log_area') or '').strip()
        name = (row.get('enum_name') or '').strip()
        verdict = (row.get('verdict') or '').strip()
        evidence = (row.get('evidence') or '').strip()

        if not verdict:
            fail(problems, offset, area, name, 'has no verdict')
            continue

        if verdict not in VERDICTS:
            fail(
                problems, offset, area, name,
                f'verdict `{verdict}` is not in the spec. The set is closed: '
                f'{", ".join(VERDICTS)}. Inventing a label does not resolve a row.'
            )
            continue

        if verdict == 'UNCOVERED' and area not in UNCOVERED_OK:
            dump = DMSG_DUMP.get(area)

            if dump:
                fail(
                    problems, offset, area, name,
                    f'UNCOVERED is not available here. {dump[0]} holds '
                    f'{dump[1]} blocks for this log. Open it and run the anchor '
                    f'method. UNCOVERED is legitimate for '
                    f'{" and ".join(UNCOVERED_OK)} only.'
                )
            else:
                fail(
                    problems, offset, area, name,
                    f'UNCOVERED on unknown log area `{area}`'
                )

        if verdict == 'CONFIRMED':
            if not (row.get('client_id') or '').strip():
                fail(problems, offset, area, name, 'CONFIRMED with no client_id')

            if not (row.get('impl_file') or '').strip():
                fail(problems, offset, area, name, 'CONFIRMED with no impl_file')

        if verdict in NEEDS_EVIDENCE and 'evidence' in columns and not evidence:
            fail(
                problems, offset, area, name,
                f'{verdict} with empty evidence. Name the file you opened.'
            )

    counts = Counter((r.get('verdict') or '').strip() for r in rows)
    print(f'quest_id_map.tsv: {len(rows)} rows')

    for verdict, count in counts.most_common():
        print(f'  {verdict or "(blank)":18} {count}')

    if problems:
        print(f'\n#### {len(problems)} invalid rows. First 25:\n')

        for line in problems[:25]:
            print(line)

        print(
            '\nThese are not blocked on missing data. They are rows where the '
            'verdict does not match the evidence available on disk.'
        )
        return 1

    print('\nAll rows valid.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
