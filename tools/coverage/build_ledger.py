#!/usr/bin/env python3
"""Externally-driven quest ledger. bg-wiki is the denominator, always.

METHOD (non-invertible -- do not reorder):
  1. bg-wiki's category listing IS the quest list. retail_quests_master.json,
     1069 quests from 147 bg-wiki category pages.
  2. For each bg-wiki quest, its bg-wiki page is the spec.
  3. THEN ask whether an implementation of that bg-wiki quest exists.
  4. THEN check the implementation against the page.

HARD RULE: scripts/globals/quests.lua is NEVER read, and no enum symbol is ever
used to decide whether a quest exists. An id in that file is not evidence of
anything -- 357 of its ids are referenced nowhere in scripts/. Routing the
bg-wiki -> implementation join through enum symbol names is the same mistake one
layer down: 133 bg-wiki titles have no matching enum name, so that join fails
precisely where the enum naming is weakest, and a missing quest reads as present.

The join instead uses what each FILE declares about itself:
  - its header comment (LSB quest files name their quest on line 2), which is
    also what makes prefixed filenames (RQ7_, WOTG_BAS_1_, LB02_) resolve
    correctly instead of being guessed at by stripping prefixes;
  - its filename, as a fallback.

enforce_no_quest_enum() asserts this at runtime -- the script fails loudly rather
than quietly regressing to the enum. Every row carries its bg-wiki URL so any
line can be spot-checked against the source of truth directly.

Output: tools/coverage/data/ledger.tsv, ledger_summary.txt
"""

import json, re, glob, os, sys, urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = "/tmp/wq/cache"


def enforce_no_quest_enum():
    """Fail loudly if this script ever reaches for the quest enum again.

    Scans executable code only -- docstrings and comments are stripped first, and
    the needles are assembled at runtime so this check cannot match itself.
    """
    src = open(os.path.abspath(__file__), encoding="utf-8").read()
    code = re.sub(r'"""(?:.|\n)*?"""', "", src)  # drop all docstrings
    code = re.sub(r"#[^\n]*", "", code)  # drop comments
    needles = ["quests" + ".lua", "quest" + ".id", "quest" + "Log", "xi." + "quest"]
    for bad in needles:
        if bad in code:
            sys.exit(
                f"REFUSED: ledger must not reference {bad}. See the module docstring."
            )


def core(s):
    s = re.sub(r"\([^)]*\)", "", s)  # "(San d'Oria)", "(WOTG ... Bastok 1)"
    s = s.split("/")[0]  # "The Rivalry/The Competition"
    s = s.replace("_", " ")  # filenames use underscores, so the
    # article strip below must run against spaces or A_Beaked_Blusterer keeps its 'a'
    # bg-wiki keeps articles that LSB filenames drop, and not only leading ones:
    # "A Chocobo Riding Game (Bastok)" -> chocobo_riding_game.lua, and "Like a
    # Shining Subligar" -> Like_Shining_Subligar.lua, where the dropped article is
    # mid-string. Strip them wherever they appear as whole words.
    s = re.sub(r"\b(a|an|the)\b", " ", s, flags=re.I)
    return re.sub(r"[^a-z0-9]", "", s.lower())


def wiki_page(title):
    p = os.path.join(CACHE, re.sub(r"[^A-Za-z0-9]", "_", title) + ".json")
    if not os.path.exists(p):
        return None
    try:
        return json.load(open(p))["parse"]["wikitext"]["*"]
    except Exception:
        return None


PREFIX = (
    r"^(RQ\d+_|SOB\d+_|LB\d+_\d*_?|WOTG_[A-Z]+_\d+_|[A-Z]{3}_AF\d_|[A-Z]{3}_I_"
    r"|VW_OP_\d+_|[A-Z]{3}_)"
)

# Older zone-NPC implementations declare their quest with a DESCRIPTOR PREFIX:
#   scripts/zones/Port_Windurst/npcs/Sigismund.lua
#     -- Starts and Finishes Quest: To Catch a Falling Star
#   scripts/zones/West_Sarutabaruta/npcs/Twinkle_Tree.lua
#     -- Involved in Quest: To Catch a Falling Star
# Indexing the whole line keys on the prefix, so the bare bg-wiki title never
# matched and EVERY old-style implementation read as MISSING -- To Catch a Falling
# Star is fully working across those two files and was reported absent. The bare
# remainder is now indexed as well as the raw line.
# [^:]* cannot cross a colon, so only the leading descriptor is removed. Titles are
# safe: "Endings and Beginnings" needs Ends?\b (it has no word break after "End")
# and has no colon at all.
DESCRIPTOR = re.compile(
    r"^(?:Starts?|Finishes?|Ends?|Involved|Requires?|Part|Quests?)\b[^:]*:\s*", re.I
)


def build_impl_index():
    """What each FILE says it implements. Header comment first, filename as
    fallback. Two things this has to survive, both found by hand-checking the
    diff against the discarded enum join:

      - a quest can be implemented as a BATTLEFIELD or inside a MISSION file,
        not only under scripts/quests -- Class Reunion lives in
        scripts/battlefields/Cloister_of_Frost/class_reunion.lua;
      - a file's own header can be WRONG. SAM_AF3_A_Thief_in_Norg.lua is headed
        "Yomi Okuri", so the header signal alone loses it and the filename (with
        its job/AF prefix stripped) is what recovers it.

    Prefix stripping is a filename heuristic. It is not, and must not become, a
    lookup of the quest enum.
    """
    idx = {}
    # scripts/globals/*.lua does NOT reach scripts/globals/abyssea/, and quest
    # systems do live in those subdirectories -- resistance_sapper.lua implements
    # eighteen bg-wiki rows and was invisible until this became recursive.
    globs = [
        "scripts/quests/**/*.lua",
        "scripts/zones/**/npcs/*.lua",
        # Zone.lua legitimately implements quests through onZoneIn / onEventFinish.
        # A Moral Manifest? is added AND completed in scripts/zones/Altar_Room/Zone.lua
        # and was invisible while only npcs/ was scanned.
        "scripts/zones/**/Zone.lua",
        "scripts/globals/**/*.lua",
        "scripts/battlefields/**/*.lua",
        "scripts/missions/**/*.lua",
        "scripts/zones/**/instances/*.lua",
    ]
    for g in globs:
        for p in glob.glob(os.path.join(ROOT, g), recursive=True):
            rel = os.path.relpath(p, ROOT)
            try:
                lines = (
                    open(p, encoding="utf-8", errors="replace").read(4000).split("\n")
                )
            except Exception:
                continue

            # The first 8 lines catch the ordinary case, where a quest file names
            # its quest on line 2. But a SHARED implementation names one title per
            # line and can hold more than eight of them: kupofried_moogle_magic.lua
            # implements fourteen bg-wiki rows from one file. So also take the
            # header's opening separator-delimited block, which is where LSB puts
            # titles by convention.
            #
            # Deliberately NOT the whole header: the blocks below the title block
            # hold bg-wiki prose that quotes OTHER quests' names in |Previous= and
            # |Next= fields, and indexing those would attribute a quest to whichever
            # unrelated file happened to mention it.
            head = lines[:8]
            seps = [i for i, l in enumerate(lines[:80]) if re.match(r"^-{5,}\s*$", l)]
            if len(seps) >= 2:
                head = head + lines[seps[0] + 1 : seps[1]]
            for line in head:
                m = re.match(r'^--\s*([A-Z0-9"\'].*?)\s*$', line)
                if m and not m.group(1).startswith(
                    ("Area:", "NPC:", "Zone:", "Log ID", "!pos", "Variable", "Mob:")
                ):
                    decl = m.group(1)
                    idx.setdefault(core(decl), rel)
                    bare = DESCRIPTOR.sub("", decl)
                    if bare and bare != decl:
                        idx.setdefault(core(bare), rel)
                        # A descriptor line is often a LIST of quests, and the whole
                        # list matches none of them:
                        #   Kuroido-Moido.lua "Starts and Finishes: Making Amens!,
                        #                      Orastery Woes"  (both implemented)
                        #   Irmilant.lua      "Starts and Ends Quests: The Immortal
                        #                      Lu Shang and Indomitable Spirit"
                        # Splitting is confined to post-descriptor remainders, which
                        # are declarative lists by construction -- an arbitrary header
                        # is never split, so a comma inside a real title (e.g. "The
                        # Good, the Bad, the Clement") is untouched.
                        for part in re.split(r",|\band\b", bare):
                            part = part.strip()
                            if len(part) > 3:
                                idx.setdefault(core(part), rel)
            b = os.path.basename(p)[:-4]
            for cand in (b, re.sub(PREFIX, "", b), re.sub(r"^[A-Z][a-z]+_", "", b)):
                idx.setdefault(core(cand), rel)
    return idx


def start_npc_file(page):
    """For a row with no impl match, does the bg-wiki START NPC have a script?

    A header/filename join cannot see an implementation whose file declares nothing
    about its quest, and plenty do not -- Churano-Shurano.lua fully implements the
    Magicked astrolabe purchase (10,000 gil, csids 1080/1081, the key item) behind a
    header of only Area:/NPC:/!pos, and Ambrosius.lua likewise implements The Postman
    Always K.O.'s Twice. Both read as MISSING, and rebuilding either would have
    duplicated working code.

    bg-wiki already tells us who starts the quest, so resolve that name against
    scripts/zones/<Zone>/npcs/. A hit is NOT a verdict -- the file may only sell
    something unrelated -- it is a "READ THIS BEFORE BUILDING" marker.
    """
    if not page:
        return ""
    m = re.search(r"\|Start\s*=\s*(.*)", page)
    if not m:
        return ""
    raw = m.group(1)
    npc = re.sub(r"\[\[|\]\]", "", raw.split(",")[0]).split("|")[-1].strip()
    npc = re.sub(r"\s*\([^)]*\)\s*$", "", npc).strip().replace(" ", "_")
    if not npc or len(npc) < 3:
        return ""
    hits = sorted(glob.glob(os.path.join(ROOT, "scripts/zones/*/npcs/", npc + ".lua")))
    if not hits:
        return ""
    # NPC names repeat across zones and the wrong file is worse than none: it sends
    # you to read Bastok Mines' alchemy Sieglinde for an Abyssea-Misareaux quest, or
    # a generic Moogle for an Abyssea one. bg-wiki states the zone right after the
    # NPC, so require the directory to match it before reporting a hit.
    zone_txt = re.sub(r"\[\[|\]\]", " ", raw)
    zkey = re.sub(r"[^a-z0-9]", "", zone_txt.lower())
    for h in hits:
        d = os.path.basename(os.path.dirname(os.path.dirname(h)))
        if re.sub(r"[^a-z0-9]", "", d.lower()) in zkey:
            return os.path.relpath(h, ROOT)
    return ""


def main():
    enforce_no_quest_enum()
    master = dict(
        json.load(
            open(os.path.join(ROOT, "tools/coverage/data/retail_quests_master.json"))
        )
    )
    impl = build_impl_index()

    zone_csids, zmap = {}, {}
    if os.path.exists("/tmp/zone_csids.json"):
        zone_csids = {
            int(k): set(v) for k, v in json.load(open("/tmp/zone_csids.json")).items()
        }
    for m in re.finditer(
        r"^\s+([A-Z_0-9]+)\s*=\s*(\d+),",
        open(os.path.join(ROOT, "scripts/enum/zone.lua")).read(),
        re.M,
    ):
        zmap[m.group(1)] = int(m.group(2))

    # Quest ids come from the derived join, never from the enum. The join is
    # produced by tools/coverage/verify_quest_ids.py, which checks every id
    # against the client's own table. Reading it here is what lets an agent
    # answer "what id is this quest" from the ledger alone.
    id_map = {}
    map_path = os.path.join(ROOT, "tools/coverage/data/quest_id_map.tsv")
    if os.path.exists(map_path):
        with open(map_path, encoding="utf-8") as fh:
            head = fh.readline().rstrip("\n").split("\t")
            for line in fh:
                if not line.strip():
                    continue
                vals = line.rstrip("\n").split("\t")
                vals += [""] * (len(head) - len(vals))
                row = dict(zip(head, vals))
                key = core(row.get("bgwiki_title", ""))
                if key and key not in id_map:
                    id_map[key] = (row.get("log_area", ""), row.get("declared_id", ""))

    rows = []
    for title in sorted(master):
        cats = [c for c in master[title] if c != "Quests"]
        area, qid = id_map.get(core(title), ("", ""))
        f = impl.get(core(title), "")
        page = wiki_page(title)
        # only meaningful for rows we could not match
        npc_file = "" if f else start_npc_file(page)
        csid_state = ""
        if f:
            src = re.sub(
                r"--[^\n]*",
                "",
                open(os.path.join(ROOT, f), encoding="utf-8", errors="replace").read(),
            )
            cur, bad, tot = None, [], 0
            for line in src.split("\n"):
                zm = re.search(r"\[xi\.zone\.([A-Z_0-9]+)\]\s*=", line)
                if zm:
                    cur = zmap.get(zm.group(1))
                    continue
                if cur is None:
                    continue
                cs = [int(x) for x in re.findall(r"progressEvent\((\d+)", line)]
                cs += [int(x) for x in re.findall(r"(?<!progress)\bevent\((\d+)", line)]
                for c in cs:
                    if c >= 8000 or cur not in zone_csids:
                        continue
                    tot += 1
                    if c not in zone_csids[cur]:
                        bad.append(f"{cur}:{c}")
            if tot:
                csid_state = (
                    ("CSID_MISSING(" + ",".join(sorted(set(bad))) + ")")
                    if bad
                    else "csids_ok"
                )
        rows.append(
            [
                title,
                cats[0] if cats else "",
                "MISSING" if not f else "implemented",
                f,
                "no_wiki_page_cached" if page is None else "",
                csid_state,
                npc_file,
                "https://www.bg-wiki.com/ffxi/"
                + urllib.parse.quote(title.replace(" ", "_")),
                area,
                qid,
            ]
        )

    out = os.path.join(ROOT, "tools/coverage/data/ledger.tsv")
    with open(out, "w") as fh:
        fh.write(
            "bgwiki_title\tcategory\tstate\timpl_file\twiki_fetch\tcsid_check\t"
            "start_npc_file\twiki_url\tlog_area\tquest_id\n"
        )
        for r in rows:
            fh.write("\t".join(r) + "\n")

    miss = [r for r in rows if r[2] == "MISSING"]
    s = [
        f"bg-wiki quests (denominator): {len(rows)}",
        f"  implemented                 : {len(rows)-len(miss)}",
        f"  NO IMPLEMENTATION           : {len(miss)}",
        f'  implemented but csid absent : {len([r for r in rows if r[5].startswith("CSID_MISSING")])}',
        f"  wiki page not cached        : {len([r for r in rows if r[4]])}",
        f'  MISSING w/ start-NPC script : {len([r for r in rows if r[2] == "MISSING" and r[6]])}'
        f"   <- READ THESE FIRST, may already be implemented",
    ]
    open(os.path.join(ROOT, "tools/coverage/data/ledger_summary.txt"), "w").write(
        "\n".join(s) + "\n"
    )
    print("\n".join(s))


if __name__ == "__main__":
    main()
