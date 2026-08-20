#!/usr/bin/env python3
"""Resolve a bg-wiki quest to its start NPC entity -- and VALIDATE the guess.

Name matching alone picks the wrong entity roughly a third of the time: zones
hold debug NPCs, duplicate sets, and NPCs that carry several quests. Six wrong
resolutions in one session (Veldeth, Gurren-Murren, Hegnor, Yocile, Bertenont,
Peppe-Aleppe) each cost several dialog reads to discover, and one shipped a
wrong quest file.

The validation: an entity that really owns a quest has that quest's ITEM or KEY
ITEM ids sitting in its event block's data[] table. Cross-checking the candidate
against the ids parsed from the quest's own bg-wiki |Item Reqs= / |Reward=
separates "right name" from "right NPC" without reading a line of dialog.

Emits a work queue: quest, zone, entity, csid->entry offsets, and the data[]
indices where its items appear.
"""

import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DAT = "/Users/jasonclift/Code/Lua/Personal/UpdateExtractor"
sys.path.insert(0, os.path.join(ROOT, "tools/coverage"))
sys.path.insert(0, os.path.join(DAT, "xidat"))
from resolve_item import load as load_items, resolve as resolve_item

# csidmsg lives in the UpdateExtractor checkout, added to sys.path just above,
# so it is resolvable at runtime but not statically.
import csidmsg as C  # pylint: disable=import-error


def wiki(title):
    p = "/tmp/wq/cache/" + re.sub(r"[^A-Za-z0-9]", "_", title) + ".json"
    try:
        return json.load(open(p))["parse"]["wikitext"]["*"]
    except Exception:
        return ""


def quest_item_ids(w, tables):
    ids = set()
    for field in ("Item Reqs", "Reward"):
        m = re.search(r"\|" + field + r"=(.*?)(?=\n\|[A-Za-z]|\n\}\})", w, re.S)
        if not m:
            continue
        names = set(re.findall(r"\[\[([^\]|#]+)", m.group(1)))
        names |= set(re.findall(r"ItemIcon\|([^|}]+)", m.group(1)))
        for n in names:
            n = n.strip()
            if len(n) < 4 or n.startswith(("Category", ":Category", "File", "Image")):
                continue
            for _src, v in resolve_item(n, tables):
                ids.add(v)
    return ids


def npc_index():
    idx = {}
    for line in open(
        os.path.join(ROOT, "sql/npc_list.sql"), encoding="utf-8", errors="replace"
    ):
        m = re.match(r"INSERT INTO `npc_list` VALUES \((\d+),'([A-Za-z_0-9'-]+)'", line)
        if m:
            idx.setdefault(m.group(2), []).append(int(m.group(1)))
    return idx


def main():
    tables = load_items()
    npcs = npc_index()
    rows = [
        l.rstrip("\n").split("\t")
        for l in open(os.path.join(ROOT, "tools/coverage/data/ledger.tsv"))
    ][1:]
    missing = [r for r in rows if r[2] == "MISSING"]
    validated, unvalidated = [], []
    for r in missing:
        w = wiki(r[0])
        if not w:
            continue
        st = re.search(r"\|Start=([^\n]*)", w)
        if not st:
            continue
        nm = re.search(r"\[\[([A-Za-z\' .-]+?)(?:\s*\(A\))?\]\]", st.group(1))
        raw = nm.group(1).strip() if nm else re.split(r"[,(]", st.group(1))[0].strip()
        key = raw.replace(" ", "_").replace("'", "")
        want = quest_item_ids(w, tables)
        if not want or key not in npcs:
            continue
        for eid in npcs[key]:
            z = (eid - 16777216) // 4096
            try:
                blocks = C.load(z, eid)[eid]
            except Exception:
                continue
            for blob, entries, data in blocks:
                hit = {v: data.index(v) for v in want if v in data}
                if hit:
                    validated.append((r[0], z, eid, key, sorted(entries.keys()), hit))
                    break
            else:
                continue
            break
        else:
            unvalidated.append((r[0], key, sorted(want)[:4]))
    print(
        f"VALIDATED {len(validated)} quests -- start NPC confirmed by its own data[] table\n"
    )
    for q, z, eid, key, csids, hit in sorted(validated):
        cs = [c for c in csids if c != 65535]
        print(
            f"  {q[:34]:36s} z={z:<4d} {key:<20s} e={eid} items@data{hit} csids={cs[:12]}"
        )
    print(
        f"\n{len(unvalidated)} could not be validated (wrong NPC, or items absent from data[])"
    )
    json.dump(
        [
            [q, z, e, k, cs, {str(a): b for a, b in h.items()}]
            for q, z, e, k, cs, h in validated
        ],
        open("/tmp/validated_queue.json", "w"),
    )


if __name__ == "__main__":
    main()
