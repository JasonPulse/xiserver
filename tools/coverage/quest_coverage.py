#!/usr/bin/env python3
"""quest_coverage.py -- find MISSING quests, not just broken ones.

    python3 tools/coverage/quest_coverage.py            # enum vs implementation
    python3 tools/coverage/quest_coverage.py --retail    # also diff vs bg-wiki

WHY THIS EXISTS
---------------
Every audit on this repo so far has run repo-inward-out: list the quest files we
have, look for stub markers, fix those. That method structurally CANNOT find a
quest that has no file at all -- and those are the expensive ones, because a stub
announces itself while an absent quest is invisible.

This tool runs the other direction. Two independent axes:

  1. ENUM vs IMPLEMENTATION.  `scripts/globals/quests.lua` mirrors the client's
     fixed quest-log slots, so it is the authoritative internal list. Any entry
     with no file declaring it is unimplemented.
  2. RETAIL vs ENUM.  bg-wiki's per-area quest Categories are the retail list.
     Any title with no enum entry means the enum itself is short.

Axis 1 alone is only a lower bound; you need axis 2 to know the enum is complete.
As of the first full run the enum tracked retail almost exactly (bastok 93 vs 94,
sandoria 82 vs 82, abyssea 192 vs 192), and the residual diffs were naming
artifacts rather than gaps -- so axis 1's number is trustworthy in practice.

MATCH BY DECLARATION, NOT BY FILENAME
-------------------------------------
Do not infer implementation from filenames. Upstream names files inconsistently
(`WOTG_BAS_6_Fire_in_the_Hole.lua`, `LB04_Riding_on_the_clouds.lua`,
`MNK_AF1_Ghosts_of_the_Past.lua`), so a filename diff produces false "missing"
hits. This reads each file's own `Quest:new(xi.questLog.X, xi.quest.id.area.NAME)`
declaration, plus `questId = xi.quest.id.area.NAME` for the table-driven helpers.
That distinction is load-bearing: on the first run, 10 of 47 git-deleted files
were correctly NOT flagged because the quest lives on under an upstream filename.

The parser SELF-VALIDATES against five known ids and raises if any drifts. If you
change quests.lua's layout and this starts returning zeros, fix the parser -- an
empty parse silently makes every quest look absent.
"""

import argparse
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# (area, enum name, id) -- if any of these stop matching, the parser has drifted.
SENTINELS = [
    ("sandoria", "A_SENTRYS_PERIL", 0),
    ("bastok", "A_DISCERNING_EYE", 71),
    ("jeuno", "A_REPUTATION_IN_RUINS", 73),
    ("outlands", "THE_FIREBLOOM_TREE", 1),
    ("crystalWar", "BEAST_FROM_THE_EAST", 30),
]

WIKI_CATEGORIES = {
    "bastok": "Bastok Quests",
    "sandoria": "San d'Oria Quests",
    "windurst": "Windurst Quests",
    "jeuno": "Jeuno Quests",
    "ahtUrhgan": "Aht Urhgan Quests",
    "crystalWar": "Crystal War Quests",
    "abyssea": "Abyssea Quests",
    "adoulin": "Adoulin Quests",
    "outlands": "Outlands Quests",
}


def parse_enum():
    """area -> {NAME: (id, converted_flag)} from scripts/globals/quests.lua."""
    path = os.path.join(ROOT, "scripts/globals/quests.lua")
    src = io.open(path, encoding="utf-8").read()
    areamap = dict(re.findall(r"\[xi\.questLog\.([A-Z_]+)\]\s*=\s*'([a-zA-Z]+)'", src))
    if len(areamap) < 11:
        sys.exit("quest_coverage: could not parse xi.quest.area")

    body = src[src.index("xi.quest.id =") :]
    enum, cur = {}, None
    for line in body.splitlines():
        head = re.match(
            r"^\s*\[xi\.quest\.area\[xi\.questLog\.([A-Z_]+)\]\]\s*=\s*$", line
        )
        if head:
            cur = areamap[head.group(1)]
            enum.setdefault(cur, {})
            continue
        ent = re.match(r"^\s{8}([A-Z][A-Z0-9_]*)\s*=\s*(\d+),(.*)$", line)
        if ent and cur:
            enum[cur][ent.group(1)] = (int(ent.group(2)), "Converted" in ent.group(3))

    for area, name, qid in SENTINELS:
        got = enum.get(area, {}).get(name)
        if got is None or got[0] != qid:
            sys.exit(
                f"quest_coverage: parser drift -- expected {area}.{name}={qid}, got {got}"
            )
    return enum


def parse_declared():
    """area -> {NAME: [files]} taken from each file's own declaration."""
    declared = {}
    files = glob.glob(
        os.path.join(ROOT, "scripts/quests/**/*.lua"), recursive=True
    ) + glob.glob(os.path.join(ROOT, "scripts/missions/**/*.lua"), recursive=True)
    for f in files:
        s = io.open(f, encoding="utf-8", errors="replace").read()
        rel = os.path.relpath(f, ROOT)
        pats = [
            r"Quest:new\(\s*xi\.questLog\.[A-Z_]+\s*,\s*xi\.quest\.id\.([a-zA-Z]+)\.([A-Z][A-Z0-9_]*)",
            r"questId\s*=\s*xi\.quest\.id\.([a-zA-Z]+)\.([A-Z][A-Z0-9_]*)",
        ]
        for p in pats:
            for area, name in re.findall(p, s):
                declared.setdefault(area, {}).setdefault(name, []).append(rel)
    return declared


def normalise(title):
    """bg-wiki page title -> enum-style name.

    Hyphens and colons become underscores rather than vanishing: 'Eco-Warrior'
    must reach ECO_WARRIOR, not ECOWARRIOR. Getting this wrong makes real matches
    look like coverage gaps -- it produced a dozen false 'missing' hits first time.
    """
    t = re.sub(r"\s*\(.*?\)\s*$", "", title)  # drop a trailing "(Bastok)"
    t = t.replace("&", " and ")
    t = re.sub(r"[-:/]", " ", t)  # separators, not deletions
    t = re.sub(r"[^A-Za-z0-9 ]", "", t)
    return re.sub(r"\s+", "_", t.strip()).upper()


def fetch_category(title, limit=1000):
    import urllib.parse
    import urllib.request

    out, cont = [], None
    while True:
        p = {
            "action": "query",
            "list": "categorymembers",
            "cmtitle": "Category:" + title,
            "cmlimit": "500",
            "format": "json",
            "cmtype": "page",
        }
        if cont:
            p["cmcontinue"] = cont
        url = "https://www.bg-wiki.com/api.php?" + urllib.parse.urlencode(p)
        req = urllib.request.Request(
            url, headers={"User-Agent": "xiserver-quest-coverage/1.0"}
        )
        d = json.load(urllib.request.urlopen(req))
        out += [m["title"] for m in d.get("query", {}).get("categorymembers", [])]
        cont = d.get("continue", {}).get("cmcontinue")
        if not cont or len(out) >= limit:
            return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--retail",
        action="store_true",
        help="also diff the enum against bg-wiki categories",
    )
    ap.add_argument("--json", help="write the full gap lists here")
    args = ap.parse_args()

    enum = parse_enum()
    declared = parse_declared()

    print("%-12s %6s %6s %9s %9s" % ("AREA", "ENUM", "conv", "IMPL", "NO_FILE"))
    gaps, tot = {}, [0, 0, 0, 0]
    for area in sorted(enum):
        impl = declared.get(area, {})
        missing = sorted(n for n in enum[area] if n not in impl)
        conv = sum(1 for _, (_, c) in enum[area].items() if c)
        gaps[area] = {
            "missing": missing,
            "missing_marked_converted": sorted(n for n in missing if enum[area][n][1]),
        }
        print(
            "%-12s %6d %6d %9d %9d"
            % (area, len(enum[area]), conv, len(impl), len(missing))
        )
        tot = [
            tot[0] + len(enum[area]),
            tot[1] + conv,
            tot[2] + len(impl),
            tot[3] + len(missing),
        ]
    print("%-12s %6d %6d %9d %9d" % ("TOTAL", *tot))

    if args.retail:
        print("\n%-12s %5s %5s %9s" % ("AREA", "ENUM", "WIKI", "wiki-only"))
        for area, cat in WIKI_CATEGORIES.items():
            try:
                wiki = fetch_category(cat)
            except Exception as e:
                print("%-12s  fetch failed: %s" % (area, e))
                continue
            wn = {normalise(t): t for t in wiki}
            only = sorted(wn[k] for k in set(wn) - set(enum.get(area, {})))
            gaps.setdefault(area, {})["wiki_only"] = only
            print(
                "%-12s %5d %5d %9d"
                % (area, len(enum.get(area, {})), len(wiki), len(only))
            )

    if args.json:
        json.dump(gaps, io.open(args.json, "w", encoding="utf-8"), indent=1)
        print("\nwrote", args.json)


if __name__ == "__main__":
    main()
