#!/usr/bin/env python3
"""Partition the bg-wiki RETAIL quest master list into per-area verification batches.

    python3 tools/coverage/build_batches.py <master.json>

RETAIL-FIRST. The master list comes from bg-wiki's quest categories, NOT from
scripts/globals/quests.lua. The repo is what gets checked against it, never the
other way round. Anchoring on the enum cannot find a quest the enum omits, and the
enum demonstrably omits later-era content.

Each batch row is { retail_title, categories, repo_candidates } where
repo_candidates are files that DECLARE a matching quest id, plus a filename match.
Candidates are a starting point for the verifier, not a verdict -- normalisation is
lossy and has produced false "missing" hits repeatedly (apostrophes, hyphens,
numeric suffixes like CURSES_FOILED_AGAIN_1, "Cafe...teria" vs CAFETERIA).
"""

import glob
import io
import json
import os
import re
import sys

LOGS = {
    "San d'Oria Quests": "sandoria",
    "Bastok Quests": "bastok",
    "Windurst Quests": "windurst",
    "Jeuno Quests": "jeuno",
    "Other Area Quests": "otherAreas",
    "Outlands Quests": "outlands",
    "Aht Urhgan Quests": "ahtUrhgan",
    "Crystal War Quests": "crystalWar",
    "Abyssea Quests": "abyssea",
    "Adoulin Quests": "adoulin",
}


def norm(t):
    """bg-wiki title -> enum-style name.

    Apostrophes are DELETED (possessives: One's -> ONES). Hyphens, colons, commas,
    periods, slashes and dashes become separators. Getting either backwards
    produces false gaps -- both mistakes have been made here.
    """
    t = re.sub(r"\s*\(.*?\)\s*$", "", t)
    t = t.replace("&", " and ")
    t = t.replace("'", "").replace("’", "")
    t = re.sub(r"[-:/,\.\?!–]", " ", t)
    t = re.sub(r"[^A-Za-z0-9 ]", " ", t)
    return re.sub(r"\s+", "_", t.strip()).upper()


def main():
    master = json.load(io.open(sys.argv[1], encoding="utf-8"))

    declared = {}
    for f in glob.glob("scripts/quests/**/*.lua", recursive=True):
        s = io.open(f, encoding="utf-8", errors="replace").read()
        for _, n in re.findall(r"xi\.quest\.id\.([a-zA-Z]+)\.([A-Z][A-Z0-9_]*)", s):
            declared.setdefault(n, set()).add(f)
        stem = f.split("/")[-1][:-4]
        declared.setdefault(norm(stem), set()).add(f)
        declared.setdefault(
            re.sub(
                r"^(WOTG_[A-Z]+_\d+_|LB\d+_|[A-Z]{3}_AF\d+_|SOB\d+_|RQ\d+_|VW_OP_\d+_)",
                "",
                stem,
            ).upper(),
            set(),
        ).add(f)

    assign = {}
    for t, cats in master.items():
        area = next((LOGS[c] for c in cats if c in LOGS), "unlogged")
        assign.setdefault(area, []).append(t)

    out = "tools/coverage/data/batches"
    os.makedirs(out, exist_ok=True)
    total = 0
    for area, titles in sorted(assign.items()):
        rows = [
            {
                "retail_title": t,
                "categories": master[t],
                "repo_candidates": sorted(declared.get(norm(t), [])),
            }
            for t in sorted(titles)
        ]
        json.dump(rows, io.open(f"{out}/{area}.json", "w", encoding="utf-8"), indent=1)
        nocand = sum(1 for r in rows if not r["repo_candidates"])
        print(f"  {area:<12} {len(rows):>4} quests  {nocand:>4} with no repo candidate")
        total += len(rows)
    print(f"  total {total}")
    if "windurst" not in assign:
        sys.exit(
            "ABORT: no windurst partition -- the Windurst Quests category fetch failed again"
        )


if __name__ == "__main__":
    main()
