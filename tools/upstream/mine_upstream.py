#!/usr/bin/env python3
"""Find upstream LandSandBoat commits that are safe to cherry-pick into this fork.

This fork is pinned to an older FFXI client, so a plain merge with upstream is not
possible: upstream shifts every zone's dialog text IDs whenever Square Enix ships a
client update, and adopting those shifts against our client makes every NPC say the
wrong line. See tools/upstream/README.md for the full reasoning.

So instead of merging, we harvest. This script walks the commits we do not have,
throws out the ones that are unsafe or unusable by construction, tests whether each
survivor still applies cleanly, and records the verdict in ledger.csv so the next run
only has to look at what is new.

Usage:
    python tools/upstream/mine_upstream.py                     # classify, no apply test
    python tools/upstream/mine_upstream.py --test-apply        # also test cherry-pick
    python tools/upstream/mine_upstream.py --tier A B          # only these tiers
    python tools/upstream/mine_upstream.py --show-candidates   # print the shortlist

The ledger is the source of truth for what has been looked at. Nothing here mutates
the working tree unless --test-apply is given, and that always resets afterwards.
"""

import argparse
import csv
import os
import re
import subprocess
import sys

LEDGER_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ledger.csv")

LEDGER_COLUMNS = ["sha", "date", "tier", "area", "files", "status", "note", "subject"]

# Statuses. Anything not in here is treated as a free-form human note.
STATUS_ADOPTED = "adopted"  # cherry-picked into our tree
STATUS_CANDIDATE = "candidate"  # applies cleanly, not yet reviewed
STATUS_CONFLICT = "conflict"  # does not apply cleanly, needs hand work
STATUS_CLIENT = "blocked-client"  # touches client-coupled data, never safe for us
STATUS_INFRA = "blocked-infra"  # needs upstream infrastructure we do not have
STATUS_LARGE = "skip-large"  # structural or mass migration, out of scope
STATUS_SKIP = "skip"  # reviewed and not wanted
STATUS_CONTENT = "content-queued"  # real content behind a client-coupled IDs.lua

# Commits touching these are never safe while the client is pinned.
ZONE_IDS_RE = re.compile(r"^scripts/zones/.+/IDs\.lua$")
CLIENT_FILES = {"settings/default/login.lua"}

# A commit touching more than this many files is a restructure, not a fix.
LARGE_FILE_COUNT = 40

# Tier A: things that crash, corrupt, or can be abused. Highest value per line.
TIER_A_RE = re.compile(
    r"\b(crash|nullptr|null check|nil check|asan|ubsan|use-after-free|uaf|leak"
    r"|overflow|underflow|stackoverflow|stack overflow|reentrant|double free"
    r"|race condition|deadlock|exploit|dupe|duplicat|out of bounds|oob"
    r"|segfault|assert|infinite loop|hang|desync|corrupt)\b",
    re.IGNORECASE,
)
# Tier B: engine behaviour, tagged [core] by upstream.
TIER_B_RE = re.compile(r"^\[core\]|\[core,", re.IGNORECASE)
# Tier C: everything else that calls itself a fix.
TIER_C_RE = re.compile(r"\b(fix|fixes|fixed|correct|prevent|guard|sanity)\b", re.IGNORECASE)


def git(*args, check=True):
    """Run a git command and return stdout, or '' when check is False and it fails."""
    result = subprocess.run(
        ["git", *args], capture_output=True, text=True, check=False
    )
    if result.returncode != 0 and check:
        raise RuntimeError(f"git {' '.join(args)} failed:\n{result.stderr}")
    return result.stdout


def read_ledger():
    """Load ledger.csv into a dict keyed by short sha."""
    if not os.path.exists(LEDGER_PATH):
        return {}
    rows = {}
    with open(LEDGER_PATH, "r", encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            rows[row["sha"]] = row
    return rows


def write_ledger(rows):
    """Write ledger.csv sorted by date then sha, so diffs stay readable."""
    ordered = sorted(rows.values(), key=lambda r: (r.get("date", ""), r.get("sha", "")))
    with open(LEDGER_PATH, "w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=LEDGER_COLUMNS, lineterminator="\n")
        writer.writeheader()
        for row in ordered:
            writer.writerow({col: row.get(col, "") for col in LEDGER_COLUMNS})


def collect_commits(base, upstream):
    """Return every non-merge commit in base..upstream with its file list."""
    raw = git(
        "log",
        "--no-merges",
        "--format=@@@%H|%ad|%s",
        "--date=short",
        "--name-only",
        f"{base}..{upstream}",
    )
    commits = []
    for block in raw.split("@@@"):
        block = block.strip()
        if not block:
            continue
        head, *rest = block.split("\n")
        sha, date, subject = head.split("|", 2)
        files = [line for line in rest if line.strip()]
        commits.append({"sha": sha, "date": date, "subject": subject, "files": files})
    return commits


def area_of(files):
    """Summarise which parts of the tree a commit touches."""
    areas = set()
    for path in files:
        if path.startswith("src/"):
            areas.add("cpp")
        elif path.startswith("sql/"):
            areas.add("sql")
        elif path.startswith("scripts/"):
            areas.add("lua")
        elif path.startswith("modules/"):
            areas.add("mod")
        elif path.startswith("settings/"):
            areas.add("cfg")
        elif path.startswith("tools/"):
            areas.add("tools")
    return "+".join(sorted(areas)) or "other"


def disqualify(commit):
    """Return (status, note) when a commit needs special handling, else (None, None)."""
    for path in commit["files"]:
        if path in CLIENT_FILES:
            return STATUS_CLIENT, "changes CLIENT_VER"

    ids = [p for p in commit["files"] if ZONE_IDS_RE.match(p)]
    if ids:
        # A commit touching only IDs.lua is a pure text-ID renumber for a newer client.
        # Useless to us. But most commits that touch IDs.lua are real content dragging
        # one along, and those are portable once the text block is kept as ours.
        # See tools/upstream/content_handoff.md.
        if len(ids) == len(commit["files"]):
            return STATUS_CLIENT, "pure text-ID renumber, our client is pinned"
        return STATUS_CONTENT, f"content + {len(ids)} IDs.lua, port text block with port_ids_lua.py"

    if len(commit["files"]) > LARGE_FILE_COUNT:
        return STATUS_LARGE, f"{len(commit['files'])} files, structural"
    return None, None


def tier_of(subject):
    """Bucket a commit by how much we care about it."""
    if TIER_A_RE.search(subject):
        return "A"
    if TIER_B_RE.search(subject):
        return "B"
    if TIER_C_RE.search(subject):
        return "C"
    return "D"


def test_apply(sha, base):
    """Cherry-pick sha onto the current tree, then undo. True when it applied clean."""
    result = subprocess.run(
        ["git", "cherry-pick", "-n", "--strategy=recursive", "-Xpatience", sha],
        capture_output=True,
        text=True,
        check=False,
    )
    unmerged = git("diff", "--name-only", "--diff-filter=U", check=False).strip()
    clean = result.returncode == 0 and not unmerged
    subprocess.run(["git", "cherry-pick", "--abort"], capture_output=True, check=False)
    subprocess.run(["git", "reset", "--hard", "-q", base], capture_output=True, check=False)
    subprocess.run(["git", "clean", "-qfd"], capture_output=True, check=False)
    return clean


def working_tree_is_clean():
    return not git("status", "--porcelain").strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="HEAD", help="our ref (default HEAD)")
    parser.add_argument("--upstream", default="upstream/base", help="upstream ref")
    parser.add_argument(
        "--test-apply",
        action="store_true",
        help="cherry-pick each candidate to see if it still applies (mutates then resets)",
    )
    parser.add_argument(
        "--tier",
        nargs="+",
        default=["A", "B", "C"],
        help="tiers to consider for apply-testing (default A B C)",
    )
    parser.add_argument(
        "--show-candidates", action="store_true", help="print the clean shortlist"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="do not write the ledger"
    )
    args = parser.parse_args()

    if args.test_apply and not working_tree_is_clean():
        print(
            "refusing to --test-apply with a dirty working tree: commit or stash first",
            file=sys.stderr,
        )
        return 1

    ledger = read_ledger()
    commits = collect_commits(args.base, args.upstream)
    print(f"{len(commits)} non-merge commits in {args.base}..{args.upstream}")
    print(f"{len(ledger)} already in the ledger")

    new_rows = 0
    to_test = []
    for commit in commits:
        short = commit["sha"][:10]
        tier = tier_of(commit["subject"])
        status, note = disqualify(commit)

        existing = ledger.get(short)
        if existing and existing.get("status") not in ("", STATUS_CANDIDATE):
            # A human (or a previous run) already ruled on this one. Leave it alone.
            continue

        row = {
            "sha": short,
            "date": commit["date"],
            "tier": tier,
            "area": area_of(commit["files"]),
            "files": str(len(commit["files"])),
            "status": status or (existing or {}).get("status", ""),
            "note": note or (existing or {}).get("note", ""),
            "subject": commit["subject"],
        }
        if not existing:
            new_rows += 1
        ledger[short] = row

        if not status and tier in args.tier:
            to_test.append((short, commit["sha"]))

    print(f"{new_rows} new commits added to the ledger")

    if args.test_apply:
        print(f"apply-testing {len(to_test)} commits in tiers {' '.join(args.tier)}")
        clean = 0
        for index, (short, full) in enumerate(to_test, 1):
            ok = test_apply(full, args.base)
            ledger[short]["status"] = STATUS_CANDIDATE if ok else STATUS_CONFLICT
            clean += int(ok)
            if index % 50 == 0:
                print(f"  {index}/{len(to_test)} tested, {clean} clean")
        print(f"clean: {clean}   conflicting: {len(to_test) - clean}")

    if not args.dry_run:
        write_ledger(ledger)
        print(f"ledger written: {LEDGER_PATH}")

    counts = {}
    for row in ledger.values():
        counts[row.get("status") or "unclassified"] = (
            counts.get(row.get("status") or "unclassified", 0) + 1
        )
    print("\nledger status counts:")
    for status, count in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {count:5d}  {status}")

    if args.show_candidates:
        shortlist = [
            row
            for row in ledger.values()
            if row.get("status") == STATUS_CANDIDATE and row.get("tier") in args.tier
        ]
        shortlist.sort(key=lambda r: (r["tier"], r["date"]))
        print(f"\ncandidates ({len(shortlist)}):")
        for row in shortlist:
            print(
                f"  {row['tier']}  {row['sha']}  {row['date']}  "
                f"[{row['area']:9}] {row['files']:>3}f  {row['subject'][:80]}"
            )

    return 0


if __name__ == "__main__":
    sys.exit(main())
