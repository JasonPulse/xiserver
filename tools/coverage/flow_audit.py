#!/usr/bin/env python3
"""flow_audit.py -- emit a retail-vs-repo comparison sheet, one quest at a time.

    python3 tools/coverage/flow_audit.py <area> [start] [count]
    python3 tools/coverage/flow_audit.py bastok 0 5

THE POINT OF THIS TOOL
----------------------
"Does a lua file exist" is NOT a finding. Every audit of this repo has drifted into
counting files and reporting coverage, and every one has been wrong because of it.
The only question that matters is:

    does the repo flow follow the steps on the bg-wiki page?

So this tool puts the wiki's Quest Header + Walkthrough steps directly beside the
repo's control flow for the same quest, and makes no judgement itself. A human or
agent reads the two columns and decides. It deliberately does not emit a verdict,
because a tool that guesses a verdict is how the counting trap gets re-entered.

INPUTS
------
* `tools/coverage/data/batches/<area>.json` -- the RETAIL quest list for that area,
  built from bg-wiki categories by build_batches.py. Retail is the source of truth;
  the repo is what gets checked against it.
* `/tmp/bgwiki/*.wiki|.json` -- cached wiki pages. Fetch missing ones with
  `curl -sL "https://www.bg-wiki.com/api.php?action=parse&page=TITLE&prop=wikitext&format=json"`,
  sleeping ~2s between calls (bg-wiki returns HTTP 429 under load, and a throttled
  fetch previously came back as an EMPTY category that silently looked like "this
  quest does not exist").

FINDING THE IMPLEMENTATION
--------------------------
By DECLARATION -- every file mentioning `xi.quest.id.<area>.<ENUM>` -- and that
search covers `scripts/zones/**` as well as `scripts/quests/**`. This matters: many
older quests are implemented ENTIRELY inside a legacy `scripts/zones/<Zone>/npcs/
<Npc>.lua` and never construct a Quest object at all. Searching only
`scripts/quests/` reports those as missing when they are fully playable, and that
error is what produced a bogus "408 missing quests" figure.

Filename matching does not work and must not be used: upstream ships
`WOTG_BAS_6_Fire_in_the_Hole.lua`, `MNK_AF1_Ghosts_of_the_Past.lua`, `LB04_*`.

TITLE NORMALISATION
-------------------
Apostrophes are DELETED (possessive: `One's` -> `ONES`); hyphens, colons, commas,
periods and slashes become separators. Both halves of that rule have been got
wrong here before, each time inventing false gaps -- `Eco-Warrior` must reach
`ECO_WARRIOR` not `ECOWARRIOR`, and `A Boy's Dream` must reach `A_BOYS_DREAM` not
`A_BOY_S_DREAM`.

WHEN A QUEST LOOKS ABSENT
-------------------------
Do not conclude it from this tool. Search the enum block in
`scripts/globals/quests.lua` for a near-name (there are real typos in there, e.g.
`SYNERGUSTIC_PURSUITS`), then search by the numeric quest id, then by filename.
Only then is MISSING defensible.
"""
import glob
import io
import json
import os
import re
import sys

HEADER_FIELDS = ['Start', 'Quest Reqs', 'Fame', 'FLevel', 'Item Reqs',
                 'Repeatable', 'Previous', 'Next', 'Title', 'Reward']

# Lines that actually describe control flow / rewards. Everything else is noise.
FLOW = re.compile(
    r'check = function|return status|hasCompletedQuest|hasCompletedMission|getFameLevel|'
    r'getMainLvl|getMainJob|hasKeyItem|progressEvent|quest:event\(|onTrade|onTrigger|'
    r'onEventFinish|onZoneIn|onMobDeath|\[\d+\] = function|addItem|giveItem|giveKeyItem|'
    r'delKeyItem|addGil|addFame|addExp|setTitle|addTitle|complete\(player\)|begin\(player\)|'
    r'confirmTrade|tradeComplete|setVar|getVar|\[xi\.zone\.|startEvent'
)


def norm(title):
    t = re.sub(r'\s*\(.*?\)\s*$', '', title)
    t = t.replace('&', ' and ').replace("'", '').replace('’', '')
    t = re.sub(r'[-:/,\.\?!–]', ' ', t)
    t = re.sub(r'[^A-Za-z0-9 ]', ' ', t)
    return re.sub(r'\s+', '_', t.strip()).upper()


def cache_key(name):
    return re.sub(r'[^a-z0-9]', '', os.path.splitext(name)[0].lower())


def find_wiki(title, cache):
    for k in (cache_key(title), cache_key(re.sub(r'\s*\(.*?\)\s*$', '', title))):
        for suffix in ('', 'quest'):
            hit = cache.get(k + suffix)
            if hit:
                return hit
    return None


def wikitext(path):
    s = io.open(path, encoding='utf-8', errors='replace').read()
    if path.endswith('.json'):
        try:
            s = json.loads(s)['parse']['wikitext']['*']
        except Exception:
            pass
    if s.strip().lower().startswith('#redirect'):
        return s + '\n[NOTE: this page is a REDIRECT -- follow it, do not treat as absent]'
    return s


def declaring_files(area, enum):
    out = []
    for f in glob.glob('scripts/**/*.lua', recursive=True):
        s = io.open(f, encoding='utf-8', errors='replace').read()
        if re.search(r'xi\.quest\.id\.' + area + r'\.' + enum + r'\b', s):
            out.append(f)
    return sorted(out)


def main():
    area = sys.argv[1]
    start = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    count = int(sys.argv[3]) if len(sys.argv) > 3 else 5

    rows = json.load(io.open(f'tools/coverage/data/batches/{area}.json', encoding='utf-8'))
    cache = {cache_key(os.path.basename(p)): p for p in glob.glob('/tmp/bgwiki/*')}

    for row in rows[start:start + count]:
        title = row['retail_title']
        enum = norm(title)
        print('=' * 78)
        print(f'QUEST: {title}   [enum guess: {enum}]')

        wpath = find_wiki(title, cache)
        if not wpath:
            print('  !! no cached wiki page -- FETCH IT before judging this quest')
        else:
            w = wikitext(wpath)
            head = re.search(r'\{\{Quest Header(.*?)\n\}\}', w, re.S)
            if head:
                for f in HEADER_FIELDS:
                    m = re.search(r'\|' + re.escape(f) + r'=(.*?)(?=\n\s*\|[A-Za-z]|\Z)',
                                  head.group(1), re.S)
                    v = re.sub(r'\s+', ' ', m.group(1)).strip() if m else ''
                    if v:
                        print(f'  {f:<11}: {v[:150]}')
            walk = re.search(r'==\s*Walkthrough\s*==(.*?)(\n==|\Z)', w, re.S)
            if walk:
                print('  WIKI STEPS:')
                for line in walk.group(1).splitlines():
                    t = re.sub(r'\s+', ' ', line).strip()
                    if t.startswith('*'):
                        print('    ' + t[:170])

        files = declaring_files(area, enum)
        if not files:
            print('  !! no file DECLARES this enum -- see "WHEN A QUEST LOOKS ABSENT" in the docstring')
        for f in files:
            src = io.open(f, encoding='utf-8', errors='replace').read().splitlines()
            print(f'  --- REPO {f} ({len(src)}L)')
            for i, line in enumerate(src, 1):
                t = line.strip()
                if t and not t.startswith('--') and FLOW.search(t):
                    print(f'   {i:>4}| {t[:140]}')


if __name__ == '__main__':
    main()
