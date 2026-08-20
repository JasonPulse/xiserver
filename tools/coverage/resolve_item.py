#!/usr/bin/env python3
"""Resolve a bg-wiki item name to an id, across EVERY table it could live in.

Written because grepping one file and concluding "this item does not exist" is
how three quests got deferred on a false negative: "Tahrongi tree nut", "Cup of
Tahrongi cactus water" and "Super soup pot" are all KEY items, and a grep of
sql/item_basic.sql cannot see them. item_basic also carries BOTH a name and a
sort name, so "Malachite" is `piece_of_malachite`/`malachite` and "Torigashira"
is `torigashiranotachi`/`torigashira` -- a name-only grep misses either.

Checks, in order:
  sql/item_basic.sql      name column, then sortname column
  scripts/enum/item.lua   enum name
  scripts/enum/key_item.lua  enum name  (KEY ITEM -- different Lua namespace)

Usage: python3 tools/coverage/resolve_item.py "Tahrongi tree nut" "Super soup pot"
"""

import re, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def norm(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())


def load():
    basic_name, basic_sort = {}, {}
    for line in open(
        os.path.join(ROOT, "sql/item_basic.sql"), encoding="utf-8", errors="replace"
    ):
        m = re.match(
            r"INSERT INTO `item_basic` VALUES \((\d+),\d+,'([^']*)','([^']*)'", line
        )
        if m:
            basic_name.setdefault(norm(m.group(2)), int(m.group(1)))
            basic_sort.setdefault(norm(m.group(3)), int(m.group(1)))

    def enum(path):
        d = {}
        for line in open(os.path.join(ROOT, path), encoding="utf-8", errors="replace"):
            m = re.match(r"\s+([A-Z_0-9]+)\s*=\s*(\d+),", line)
            if m:
                d.setdefault(norm(m.group(1)), (m.group(1), int(m.group(2))))
        return d

    return (
        basic_name,
        basic_sort,
        enum("scripts/enum/item.lua"),
        enum("scripts/enum/key_item.lua"),
    )


# item_basic keeps a container/measure word that bg-wiki drops: "Miasmal
# Counteragent" is `phial_of_miasmal_counteragent`, "Giant Sheep Meat" is
# `slice_of_giant_sheep_meat`, "Malachite" is `piece_of_malachite`. Matching the
# bare name against the tail of a prefixed name recovers these.
CONTAINERS = (
    "phialof",
    "vialof",
    "cupof",
    "bucketof",
    "sliceof",
    "clumpof",
    "squareof",
    "pieceof",
    "bagof",
    "jarof",
    "bowlof",
    "pinchof",
    "setof",
    "pairof",
    "bunchof",
    "chunkof",
    "servingof",
    "blockof",
    "lumpof",
    "flaskof",
    "potof",
    "sheetof",
    "ballof",
    "handfulof",
)


def resolve(name, tables=None):
    bn, bs, ie, ke = tables or load()
    k = norm(name)
    out = []
    if k in bn:
        out.append(("item_basic.name", bn[k]))
    if k in bs:
        out.append(("item_basic.sortname", bs[k]))
    if k in ie:
        out.append(("xi.item." + ie[k][0], ie[k][1]))
    if k in ke:
        out.append(("xi.ki." + ke[k][0], ke[k][1]))
    if out:
        return out
    # container-prefixed fallback, exact tail match only -- no fuzzy guessing
    for pre in CONTAINERS:
        if pre + k in bn:
            out.append((f"item_basic.name ({pre}...)", bn[pre + k]))
            return out
    return out


if __name__ == "__main__":
    t = load()
    for arg in sys.argv[1:]:
        hits = resolve(arg, t)
        print(f'{arg:38s} {hits if hits else "NOT FOUND in any table"}')
