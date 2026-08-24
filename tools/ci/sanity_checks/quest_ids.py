#!/usr/bin/env python3
"""Sanity check for the quest id table.

Prints one line per problem to stdout and exits 1 when anything is wrong, which
is the convention the other checks in this directory follow.

It fails the build when:

  1. an enum name appears twice inside one log area
  2. an id appears twice inside one log area
  3. an id disagrees with the client for a category the client covers
  4. a quest_id in the coverage ledger has no matching entry in the table

Check 3 compares against tools/coverage/data/client_quest_ids.tsv, a snapshot of
the POLUtils QuestInfo table committed to the repo. The extractor output it came
from lives outside this repo and is not available in CI, so the snapshot is what
makes this check runnable anywhere. Regenerate it with
tools/coverage/verify_quest_ids.py.

A one-off audit rots. This runs on every build, for every agent, and bans
nothing.

No regular expressions. The quest id table has one entry per line in a fixed
shape and plain string handling parses it exactly.
"""

import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
QUEST_TABLE = REPO / 'scripts' / 'globals' / 'quests.lua'
CLIENT_SNAPSHOT = REPO / 'tools' / 'coverage' / 'data' / 'client_quest_ids.tsv'
LEDGER = REPO / 'tools' / 'coverage' / 'data' / 'ledger.tsv'

AREA_PREFIX = '[xi.quest.area[xi.questLog.'
AREA_SUFFIX = ']] ='

LOG_AREAS = {
    'SANDORIA': 'sandoria',
    'BASTOK': 'bastok',
    'WINDURST': 'windurst',
    'JEUNO': 'jeuno',
    'OTHER_AREAS': 'otherAreas',
    'OUTLANDS': 'outlands',
    'AHT_URHGAN': 'ahtUrhgan',
    'CRYSTAL_WAR': 'crystalWar',
    'ABYSSEA': 'abyssea',
    'ADOULIN': 'adoulin',
    'COALITION': 'coalition',
}


def split_entry(line):
    code, _, _ = line.partition('--')

    if not code.strip():
        return None

    name, eq, value = code.partition('=')

    if not eq:
        return None

    name = name.strip()
    value = value.strip().rstrip(',').strip()

    if not name or not value or not value.isdigit():
        return None

    if not (name[0].isalpha() or name[0] == '_'):
        return None

    for ch in name:
        if not (ch.isalnum() or ch == '_'):
            return None

    return name, int(value)


def parse_table():
    """Return {log_area: [(name, id), ...]} in file order."""
    areas = {}
    current = None

    for line in QUEST_TABLE.read_text(encoding='utf-8').splitlines():
        stripped = line.strip()

        if stripped.startswith(AREA_PREFIX) and stripped.endswith(AREA_SUFFIX):
            constant = stripped[len(AREA_PREFIX):-len(AREA_SUFFIX)]
            current = LOG_AREAS.get(constant)

            if current is not None:
                areas[current] = []

            continue

        if current is None:
            continue

        if stripped in ('}', '},'):
            current = None
            continue

        parsed = split_entry(line)

        if parsed is not None:
            areas[current].append(parsed)

    return areas


def read_tsv(path):
    rows = []

    with path.open(encoding='utf-8') as handle:
        header = handle.readline().rstrip('\n').split('\t')

        for line in handle:
            if not line.strip():
                continue

            values = line.rstrip('\n').split('\t')
            values += [''] * (len(header) - len(values))
            rows.append(dict(zip(header, values)))

    return rows


def main():
    problems = []

    if not QUEST_TABLE.exists():
        print('#### Quest id table is missing.')
        return 1

    areas = parse_table()

    for area, entries in sorted(areas.items()):
        seen_names = {}
        seen_ids = {}

        for name, quest_id in entries:
            if name in seen_names:
                problems.append(
                    '#### Duplicate enum name ' + name + ' in ' + area
                    + ' (ids ' + str(seen_names[name]) + ' and ' + str(quest_id) + ')'
                )
            else:
                seen_names[name] = quest_id

            if quest_id in seen_ids:
                problems.append(
                    '#### Duplicate id ' + str(quest_id) + ' in ' + area
                    + ' (' + seen_ids[quest_id] + ' and ' + name + ')'
                )
            else:
                seen_ids[quest_id] = name

    declared = {}

    for area, entries in areas.items():
        for name, quest_id in entries:
            declared[(area, quest_id)] = name

    if CLIENT_SNAPSHOT.exists():
        for row in read_tsv(CLIENT_SNAPSHOT):
            area = row.get('log_area', '')
            name = row.get('enum_name', '')
            client_id = row.get('client_id', '')

            if not area or not name or not client_id.isdigit():
                continue

            entries = dict(areas.get(area, []))

            if name not in entries:
                continue

            if entries[name] != int(client_id):
                problems.append(
                    '#### Quest id disagrees with the client: ' + area + '.' + name
                    + ' declares ' + str(entries[name])
                    + ', client says ' + client_id
                )
    else:
        problems.append(
            '#### ' + str(CLIENT_SNAPSHOT.name) + ' is missing, so ids cannot be '
            'checked against the client. Regenerate it with '
            'tools/coverage/verify_quest_ids.py and commit it.'
        )

    if LEDGER.exists():
        for row in read_tsv(LEDGER):
            quest_id = (row.get('quest_id') or '').strip()

            if not quest_id or not quest_id.isdigit():
                continue

            area = (row.get('log_area') or '').strip()

            if not area:
                continue

            if (area, int(quest_id)) not in declared:
                problems.append(
                    '#### Ledger row "' + row.get('bgwiki_title', '?')
                    + '" carries quest_id ' + quest_id + ' in ' + area
                    + ' but no such id is declared in the quest id table.'
                )

    for problem in problems:
        print(problem)

    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
