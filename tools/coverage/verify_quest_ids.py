#!/usr/bin/env python3
"""Join the quest id table to client ground truth and to real implementations.

    python3 tools/coverage/verify_quest_ids.py

Writes two files:

  tools/coverage/data/quest_id_map.tsv
      one row per declared id, with a verdict
  tools/coverage/data/client_quest_ids.tsv
      committed snapshot of the client id table, so the CI check can run
      without the extractor output, which lives outside this repo

Why this exists: the ledger had no quest id column, so every agent that needed
an id reopened the quest table, saw a `Converted` comment next to the quest, and
concluded the server implements it. That comment is upstream's claim about
upstream's code. This join replaces the guess with three checkable facts: the
client's id, whether an implementation file actually exists, and what bg-wiki
calls the quest.

Ground truth is POLUtils QuestInfo in UpdateExtractor/output/quests.xml, which
carries an explicit id field. It covers seven categories and stops before Mog
Garden, with nothing for Crystal War, Abyssea, Adoulin or Coalition. Anything
outside that coverage is reported UNCOVERED rather than guessed. The newer
quests-<area>.xml files are NOT used here: their `index` is a sequential block
counter, not the quest id, and it is gapless where the real table has gaps.

The category to log area mapping was not assumed. All 77 pairings were scored by
exact title match and the result was perfectly diagonal with zero cross-talk,
which is what fixes fr_qs_e to outlands.

The matcher is deliberately conservative. An earlier pass flagged
CURSES_FOILED_AGAIN_2 as ID_WRONG and THE_ALL_NEW_C_3000 as NAME_WRONG, both of
which are correct in the table and were artifacts of over-eager folding. A false
correction to this table is worse than no correction, so ID_WRONG and NAME_WRONG
are only claimed when the enum name positively resolves to a different client id.
Mere spelling variance between the enum and the client title is not a defect.

No regular expressions. Every input is line oriented and parses exactly with
plain string handling.
"""

import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
QUEST_TABLE = REPO / 'scripts' / 'globals' / 'quests.lua'
QUEST_IMPL_ROOT = REPO / 'scripts' / 'quests'
DATA = REPO / 'tools' / 'coverage' / 'data'
LEDGER = DATA / 'ledger.tsv'
MAP_OUT = DATA / 'quest_id_map.tsv'
READ_LOG = DATA / 'quest_read_log.tsv'
SNAPSHOT_OUT = DATA / 'client_quest_ids.tsv'

OUT_DIR = Path('/Users/jasonclift/Code/Lua/Personal/UpdateExtractor/output')
CLIENT_XML = OUT_DIR / 'quests.xml'

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

CATEGORY = {
    'sandoria': 'sd_qs_e',
    'bastok': 'bs_qs_e',
    'windurst': 'ws_qs_e',
    'jeuno': 'jn_qs_e',
    'otherAreas': 'ot_qs_e',
    'ahtUrhgan': 'at_qs_e',
    'outlands': 'fr_qs_e',
}

AREA_CODES = (
    '', 'JN', 'SD', 'BS', 'WS', 'OT', 'AT', 'FR',
    'SANDORIA', 'BASTOK', 'WINDURST', 'JEUNO', 'OTHERAREAS', 'AHTURHGAN',
)

APOSTROPHES = "'’ʼ`"


def _squash(text):
    out = []
    gap = False

    for ch in text.upper():
        if ch.isalnum():
            out.append(ch)
            gap = False
        elif not gap:
            out.append('_')
            gap = True

    return ''.join(out).strip('_')


def _drop_inner_periods(text):
    """`K.O.'s` is one word. `Foiled...Again` is two.

    A period is part of an abbreviation only when it sits directly between two
    alphanumerics. Everywhere else it separates.
    """
    out = []

    for index, ch in enumerate(text):
        if ch == '.':
            before = text[index - 1] if index else ''
            after = text[index + 1] if index + 1 < len(text) else ''

            if before.isalnum() and after.isalnum():
                continue

        out.append(ch)

    return ''.join(out)


def foldings(title):
    """Every plausible enum spelling of one client title."""
    forms = set()
    bases = {title}

    if title.endswith(')') and '(' in title:
        bases.add(title[:title.rindex('(')].strip())

    for base in bases:
        base = _drop_inner_periods(base)
        forms.add(_squash(''.join(ch for ch in base if ch not in APOSTROPHES)))
        forms.add(_squash(''.join(
            ' ' if ch in APOSTROPHES else ch for ch in base
        )))

    forms.discard('')

    return forms


def is_placeholder(title):
    """True when the client has no localised name for this id."""
    if any(ord(ch) > 0x2000 for ch in title):
        return True

    folded = ''.join(ch for ch in title.upper() if ch.isalnum())

    if 'QUEST' in folded:
        if folded.replace('QUEST', '').strip('0123456789') in AREA_CODES:
            return True

    return False


def split_entry(line):
    code, sep, comment = line.partition('--')

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

    return name, int(value), (comment.strip() if sep else '')


def parse_table():
    areas = defaultdict(list)
    current = None

    for line in QUEST_TABLE.read_text(encoding='utf-8').splitlines():
        stripped = line.strip()

        if stripped.startswith(AREA_PREFIX) and stripped.endswith(AREA_SUFFIX):
            current = LOG_AREAS.get(stripped[len(AREA_PREFIX):-len(AREA_SUFFIX)])
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


def parse_client():
    """{category: {id: title}} from the POLUtils dump.

    The dump is not well formed XML. Quest descriptions embed raw newlines and
    stray closing tags, so an XML parser chokes on it. Accepting only lines that
    both open with the field prefix and close with the tag skips every
    continuation line cleanly.
    """
    if not CLIENT_XML.exists():
        return None

    client = defaultdict(dict)
    record = None

    for line in CLIENT_XML.read_text(encoding='utf-8-sig', errors='replace').splitlines():
        stripped = line.strip()

        if stripped.startswith('<thing type="QuestInfo"'):
            record = {}
            continue

        if record is None:
            continue

        if stripped.startswith('<field name="') and stripped.endswith('</field>'):
            key = stripped[len('<field name="'):]
            key, _, rest = key.partition('">')
            value = rest[:-len('</field>')].strip()

            if key in ('category', 'id', 'name-1'):
                record[key] = value

            if key == 'name-1' and record.get('id', '').isdigit():
                client[record.get('category', '')][int(record['id'])] = value

    return client


SCAN_ROOTS = (
    'scripts/quests',
    'scripts/zones',
    'scripts/battlefields',
    'scripts/missions',
    'scripts/globals',
)

ID_REFERENCE = 'xi.quest.id.'


def _identifier_at(text, start):
    end = start

    while end < len(text) and (text[end].isalnum() or text[end] == '_'):
        end += 1

    return text[start:end], end


def implementation_index():
    """{log_area: {ENUM_NAME: relative_path}}, taken from what files declare.

    Filename matching was tried first and is wrong. It cannot tell
    Lure_of_the_Wildcat_Bastok.lua from Lure_of_the_Wildcat_Jeuno.lua without
    guessing, it misses The_Moogles_Picnic.lua for THE_MOOGLE_PICNIC, it misses
    every zone-NPC implementation whose filename is the NPC not the quest, and
    it misses Synergistic_Pursuits.lua for the misspelled SYNERGUSTIC_PURSUITS.
    Each of those produced a false MARKER_LIES.

    A file states which quest it implements by naming
    xi.quest.id.<log_area>.<ENUM_NAME>. That carries the log area, so the
    per-nation variants separate cleanly and no fuzzy matching is needed.

    Files under scripts/quests win over zone and global files, because a quest
    file is the implementation while a zone NPC is usually one step of it.
    """
    declared = defaultdict(dict)
    # {(area, name): [(distinct_refs_in_file, path), ...]} for files that carry no
    # Quest:new at all, i.e. old-style zone-NPC implementations.
    npc_candidates = defaultdict(list)

    for root in SCAN_ROOTS:
        base = REPO / root

        if not base.is_dir():
            continue

        preferred = root == 'scripts/quests'

        for path in sorted(base.rglob('*.lua')):
            try:
                text = path.read_text(encoding='utf-8', errors='replace')
            except OSError:
                continue

            if ID_REFERENCE not in text:
                continue

            rel = str(path.relative_to(REPO))
            has_quest_new = ':new(' in text
            refs = []
            cursor = 0

            while True:
                found = text.find(ID_REFERENCE, cursor)

                if found == -1:
                    break

                area, after = _identifier_at(text, found + len(ID_REFERENCE))
                cursor = after

                if not area or after >= len(text) or text[after] != '.':
                    continue

                name, after = _identifier_at(text, after + 1)
                cursor = after

                if not name or not name[0].isupper():
                    continue

                # A file that merely NAMES another area's quest is checking it as
                # a prerequisite, not implementing it. Ownership is declared two
                # ways in this repo: inline in a `Quest:new(...)` call, or as the
                # `questId` field of a params table handed to a helper
                # constructor such as xi.jeuno.helpers.BorghertzQuests:new.
                # Without this, scripts/quests/outlands/A_Question_of_Taste.lua
                # claimed windurst's A_POSE_BY_ANY_OTHER_NAME purely because it
                # gates on it, and the Borghertz hand quests claimed the nation
                # quests listed in their `requiredQuestId`.
                line_start = text.rfind('\n', 0, found) + 1
                line_end = text.find('\n', found)
                line = text[line_start:line_end if line_end != -1 else len(text)]
                stripped_line = line.strip()

                declares = (
                    'Quest:new(' in line or
                    stripped_line.startswith('questId')
                )

                # A file that lives under scripts/quests/<area>/ belongs to that
                # area. Two of Borghertz's hand quests otherwise claimed a
                # sandoria and a windurst quest off a same-line reference.
                parts = rel.split('/')
                misplaced = (
                    len(parts) > 2 and parts[0] == 'scripts' and
                    parts[1] == 'quests' and parts[2] in LOG_AREAS.values() and
                    parts[2] != area
                )

                if declares and not misplaced:
                    declared[area].setdefault(name, rel)
                elif not has_quest_new:
                    # No Quest:new anywhere in the file, so this is an old-style
                    # implementation rather than a prerequisite check.
                    refs.append((area, name))

            # A file inside an Interaction Framework quest owns only what it
            # declares. Its other references gate on prerequisites, which is why
            # Borghertz's hand quests were claiming five other areas' quests.
            for area, name in refs:
                npc_candidates[(area, name)].append((len(set(refs)), rel))

    # A declaration always wins. Otherwise take the NPC file that references the
    # fewest distinct quests: a dedicated NPC names one or two, while a hub like
    # the Past Event Watcher names twenty and implements none of them.
    for (area, name), options in npc_candidates.items():
        if name in declared[area]:
            continue

        declared[area][name] = min(options)[1]

    return declared


DMSG_FILES = {
    'abyssea': 'quests-abyssea.xml',
    'crystalWar': 'quests-goddess.xml',
    'otherAreas': 'quests-other.xml',
    'jeuno': 'quests-jeuno.xml',
    'bastok': 'quests-bastok.xml',
    'sandoria': 'quests-sandoria.xml',
    'windurst': 'quests-windurst.xml',
    'ahtUrhgan': 'quests-ahtuhrgan.xml',
}

MIN_ANCHOR_RUN = 6


def parse_dmsg(filename):
    """{block_index: title} from a POLUtils DMSGStringBlock dump.

    The index is a sequential block counter, not the quest id, and it is gapless
    where the real table has gaps. Nothing here assumes otherwise; the anchor
    logic below is what establishes whether index and id happen to coincide over
    a given stretch.

    Some titles carry a leading '+'. It is a marker in the client data, not part
    of the name, and folding it as a separator broke every comparison until it
    was stripped.
    """
    path = OUT_DIR / filename

    if not path.exists():
        return {}

    blocks = {}
    index = None

    for line in path.read_text(encoding='utf-8-sig', errors='replace').splitlines():
        stripped = line.strip()

        if stripped.startswith('<thing type="DMSGStringBlock"'):
            index = None
            continue

        if stripped.startswith('<field name="index">') and stripped.endswith('</field>'):
            index = int(stripped[len('<field name="index">'):-len('</field>')])
            continue

        if stripped.startswith('<field name="string-2">') and stripped.endswith('</field>'):
            title = stripped[len('<field name="string-2">'):-len('</field>')].strip()

            if index is not None:
                blocks[index] = title.lstrip('+').strip()

            index = None

    return blocks


def dmsg_deltas(area, declared):
    """{quest_id: (block_index, delta)} for ids the DMSG can place.

    declared is {quest_id: enum_name}. A placement is only accepted when the
    same delta also holds for a run of MIN_ANCHOR_RUN consecutive declared ids
    ending at this one, or starting at it. One anchor is never enough: the
    delta is only piecewise constant, so a lone coincidental title match would
    otherwise invent an id.
    """
    filename = DMSG_FILES.get(area)

    if not filename:
        return {}

    blocks = parse_dmsg(filename)

    if not blocks:
        return {}

    by_fold = defaultdict(set)

    for index, title in blocks.items():
        if is_placeholder(title):
            continue

        for form in foldings(title):
            by_fold[form].add(index)

    # Candidate delta per id, only where the title resolves to exactly one block.
    candidate = {}

    for quest_id, name in declared.items():
        hits = by_fold.get(name)

        if hits and len(hits) == 1:
            index = next(iter(hits))
            candidate[quest_id] = (index, index - quest_id)

    ordered = sorted(candidate)
    confirmed = {}

    for position, quest_id in enumerate(ordered):
        index, delta = candidate[quest_id]
        run = 1

        back = position - 1
        while back >= 0 and candidate[ordered[back]][1] == delta:
            run += 1
            back -= 1

        forward = position + 1
        while forward < len(ordered) and candidate[ordered[forward]][1] == delta:
            run += 1
            forward += 1

        if run >= MIN_ANCHOR_RUN:
            confirmed[quest_id] = (index, delta)

    return confirmed


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

    return header, rows


def main():
    areas = parse_table()
    client = parse_client()

    if client is None:
        raise SystemExit('client ground truth not found: ' + str(CLIENT_XML))

    _, ledger_rows = read_tsv(LEDGER)
    impl_index = implementation_index()

    # CONFIRMED is never inferred. It is only granted to an entry whose
    # implementation was actually read end to end, and that read is recorded by
    # hand in quest_read_log.tsv. Everything else that looks fine mechanically
    # stays UNVERIFIED, because "the marker says so" is the exact inference this
    # whole join exists to kill.
    reads = {}

    if READ_LOG.exists():
        _, read_rows = read_tsv(READ_LOG)

        for row in read_rows:
            key = (row.get('log_area', ''), row.get('enum_name', ''))
            reads[key] = row.get('result', '')

    ledger_by_fold = {}

    for row in ledger_rows:
        for form in foldings(row.get('bgwiki_title', '')):
            ledger_by_fold.setdefault(form, row)

    # Highest id the client actually publishes per category. Anything above it
    # is outside coverage, which is a different fact from "does not exist".
    max_client_id = {
        category: (max(table) if table else -1)
        for category, table in client.items()
    }

    # Enum names that only differ by a trailing disambiguator digit.
    sibling_base = defaultdict(set)

    for area, entries in areas.items():
        names = {name for name, _, _ in entries}

        for name in names:
            head, sep, tail = name.rpartition('_')

            if sep and tail.isdigit() and len(tail) == 1:
                for other in names:
                    if other != name and other.startswith(head + '_'):
                        sibling_base[area].add(name)
                        break

    client_by_fold = defaultdict(dict)

    for category, table in client.items():
        for quest_id, title in table.items():
            if is_placeholder(title):
                continue

            for form in foldings(title):
                client_by_fold[category].setdefault(form, quest_id)

    # A handful of titles exist once per nation (Eco-Warrior, Escort for Hire,
    # A Discerning Eye, Lure of the Wildcat) and the ledger keys on title, so it
    # collapses them into a single row holding one nation's file. Counting how
    # many declared ids claim each ledger row identifies them generically,
    # without hardcoding the list.
    claim_count = defaultdict(int)

    for area in LOG_AREAS.values():
        for name, _, _ in areas.get(area, []):
            key = name
            row = ledger_by_fold.get(key)

            if row is not None:
                claim_count[row.get('bgwiki_title', '')] += 1

    # Where quests.xml has no coverage, fall back to the DMSG block lists under
    # the anchor rule. Their index is a block counter, so a placement is only
    # trusted when a run of consecutive ids shares one delta.
    dmsg_placement = {}
    dmsg_titles = {}

    for area in LOG_AREAS.values():
        declared = {qid: name for name, qid, _ in areas.get(area, [])}
        dmsg_placement[area] = dmsg_deltas(area, declared)
        dmsg_titles[area] = parse_dmsg(DMSG_FILES.get(area, '')) if DMSG_FILES.get(area) else {}

    rows = []
    snapshot = []

    for area in LOG_AREAS.values():
        category = CATEGORY.get(area)

        for name, declared_id, marker in areas.get(area, []):
            lookup = {name}

            if name in sibling_base[area]:
                lookup.add(name.rpartition('_')[0])

            ledger_row = None

            for candidate in lookup:
                if candidate in ledger_by_fold:
                    ledger_row = ledger_by_fold[candidate]
                    break

            bgwiki_title = ledger_row.get('bgwiki_title', '') if ledger_row else ''

            impl_file = ''

            for candidate in lookup:
                if candidate in impl_index.get(area, {}):
                    impl_file = impl_index[area][candidate]
                    break

            if not impl_file and ledger_row:
                candidate_path = ledger_row.get('impl_file', '')

                # Several titles exist once per nation (Eco-Warrior, Escort for
                # Hire, A Discerning Eye, Lure of the Wildcat). The ledger keys
                # on title, so it collapses them to one row and hands back
                # another nation's file. Accepting that would report this log
                # area's quest as implemented on the strength of a different
                # log area's code.
                parts = candidate_path.split('/')
                cross_area = (
                    len(parts) > 2
                    and parts[0] == 'scripts'
                    and parts[1] == 'quests'
                    and parts[2] in LOG_AREAS.values()
                    and parts[2] != area
                )

                # Ambiguous title: the ledger cannot say which nation's copy
                # this file implements, so it is not evidence for this one.
                ambiguous = claim_count.get(bgwiki_title, 0) > 1

                if not cross_area and not ambiguous:
                    impl_file = candidate_path

            claims_impl = marker.startswith('+') or 'Converted' in marker

            client_id = ''
            client_title = ''
            verdict = ''

            covered = category is not None and declared_id <= max_client_id.get(category, -1)

            if not covered:
                placed = dmsg_placement.get(area, {}).get(declared_id)

                # The DMSG may CONFIRM an id. It may never correct one.
                #
                # Its index is a block counter, and where it disagrees with the
                # real table the difference is its own compression, not our
                # error. Proof from a region quests.xml does cover: quests.xml
                # puts "An Understanding Overlord?" at ot_qs_e id 106, while
                # quests-other.xml puts it at block 105. Reading that -1 as a
                # defect would have "corrected" 22 correct otherAreas ids,
                # including the whole Mog Garden block, and pointed twenty
                # working quests at the wrong log slots.
                #
                # So a nonzero delta means only that this file cannot place the
                # id, which is UNCOVERED, not ID_WRONG.
                if placed is not None and placed[1] == 0:
                    block = placed[0]
                    client_id = str(block)
                    client_title = dmsg_titles[area].get(block, '')
                else:
                    verdict = 'UNCOVERED'
            else:
                title = client.get(category, {}).get(declared_id)
                elsewhere = None

                for candidate in lookup:
                    if candidate in client_by_fold[category]:
                        elsewhere = client_by_fold[category][candidate]
                        break

                if title is None:
                    if elsewhere is not None:
                        client_id = str(elsewhere)
                        client_title = client[category][elsewhere]
                        verdict = 'ID_WRONG'
                    elif not bgwiki_title:
                        verdict = 'NO_SUCH_QUEST'
                    else:
                        verdict = 'UNCOVERED'
                else:
                    client_id = str(declared_id)
                    client_title = title
                    snapshot.append((area, name, declared_id, title))

                    matched = is_placeholder(title) or bool(lookup & foldings(title))

                    if not matched and elsewhere is not None and elsewhere != declared_id:
                        client_id = str(elsewhere)
                        client_title = client[category][elsewhere]
                        verdict = 'ID_WRONG'
                    elif not matched and elsewhere is None:
                        # The enum spells it differently but resolves to nothing
                        # else. Spelling variance, not a wrong id.
                        verdict = ''

            if not verdict:
                if claims_impl and not impl_file:
                    verdict = 'MARKER_LIES'
                elif not impl_file:
                    verdict = 'NOT_IMPLEMENTED'
                elif reads.get((area, name)) == 'CONFIRMED':
                    verdict = 'CONFIRMED'
                else:
                    # Never CONFIRMED without a recorded read.
                    verdict = 'UNVERIFIED'

            rows.append((
                area, name, str(declared_id), client_id, client_title,
                bgwiki_title, impl_file, marker, verdict,
            ))

    DATA.mkdir(parents=True, exist_ok=True)

    with MAP_OUT.open('w', encoding='utf-8') as handle:
        handle.write(
            'log_area\tenum_name\tdeclared_id\tclient_id\tclient_title\t'
            'bgwiki_title\timpl_file\tmarker\tverdict\n'
        )

        for row in rows:
            handle.write('\t'.join(f.replace('\t', ' ') for f in row) + '\n')

    with SNAPSHOT_OUT.open('w', encoding='utf-8') as handle:
        handle.write('log_area\tenum_name\tclient_id\tclient_title\n')

        for area, name, quest_id, title in snapshot:
            handle.write('%s\t%s\t%d\t%s\n' % (area, name, quest_id, title.replace('\t', ' ')))

    counts = defaultdict(int)

    for row in rows:
        counts[row[8]] += 1

    print('rows: %d' % len(rows))

    for verdict, count in sorted(counts.items(), key=lambda kv: -kv[1]):
        print('  %-16s %4d' % (verdict, count))

    print('snapshot rows: %d -> %s' % (len(snapshot), SNAPSHOT_OUT.name))

    return 0


if __name__ == '__main__':
    sys.exit(main())
