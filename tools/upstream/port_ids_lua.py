#!/usr/bin/env python3
"""Port an upstream zone IDs.lua onto our pinned client.

A zone's IDs.lua holds three tables and they are not equally portable:

    text = { ... }   offsets into the CLIENT's dialog DATs. Client-coupled. Upstream
                     renumbers these on every client bump, so upstream's values are
                     wrong for us and ours are right.
    mob  = { ... }   server-side entity ids from mob_spawn_points.sql. Portable.
    npc  = { ... }   server-side entity ids from npc_list.sql. Portable.

So the correct port is: take upstream's file, then put our `text` block back. That
keeps the mob and npc ids new content needs while leaving dialog numbering alone.

Dropping the whole file instead is a trap. Content that references a new mob id then
dies at load with "attempt to perform arithmetic on field 'X' (a nil value)".

Text keys upstream added that we do not have cannot be resolved from git at all. They
are new dialog, and their real offset has to come out of our own client's DATs. This
script reports them, with upstream's value and the dialog text from the trailing
comment, so they can be looked up.

Usage:
    python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> \\
        scripts/zones/Mine_Shaft_2716/IDs.lua

    python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> --write <paths...>

    # every IDs.lua a commit touches, report only
    python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> --from-commit
"""

import argparse
import os
import re
import subprocess
import sys

KEY_RE = re.compile(r"^\s*([A-Z][A-Z0-9_]*)\s*=\s*(\d+)\s*,(?:\s*--\s*(.*))?$", re.MULTILINE)


def git_show(ref, path):
    """Return the file at ref, or None when it does not exist there."""
    result = subprocess.run(
        ["git", "show", f"{ref}:{path}"], capture_output=True, text=True, check=False
    )
    return None if result.returncode != 0 else result.stdout


def find_block(text, name):
    """Locate `name = { ... }` and return (start_of_brace, end_after_brace) or None."""
    match = re.search(rf"\b{name}\s*=\s*", text)
    if not match:
        return None
    index = match.end()
    while index < len(text) and text[index] != "{":
        if not text[index].isspace():
            return None
        index += 1
    if index >= len(text):
        return None
    depth = 0
    for pos in range(index, len(text)):
        if text[pos] == "{":
            depth += 1
        elif text[pos] == "}":
            depth -= 1
            if depth == 0:
                return index, pos + 1
    return None


def keys_in(block):
    """Map KEY -> (value, comment) for every entry in a block."""
    return {m.group(1): (int(m.group(2)), (m.group(3) or "").strip()) for m in KEY_RE.finditer(block)}


def port_file(path, ours_ref, theirs_ref):
    """Return (merged_text, added_text_keys, note). merged_text is None when nothing to do."""
    ours = git_show(ours_ref, path)
    theirs = git_show(theirs_ref, path)
    if theirs is None:
        return None, [], "absent upstream, nothing to port"
    if ours is None:
        # Whole new zone file. Every text key is unresolved for us.
        their_block = find_block(theirs, "text")
        added = []
        if their_block:
            for key, (value, comment) in keys_in(theirs[their_block[0] : their_block[1]]).items():
                added.append((key, value, comment))
        return theirs, added, "new zone file, all text keys need DAT lookup"

    our_block = find_block(ours, "text")
    their_block = find_block(theirs, "text")
    if our_block is None or their_block is None:
        return None, [], "no text block found on one side, port by hand"

    our_text = ours[our_block[0] : our_block[1]]
    their_text = theirs[their_block[0] : their_block[1]]

    our_keys = keys_in(our_text)
    their_keys = keys_in(their_text)
    added = [
        (key, value, comment)
        for key, (value, comment) in their_keys.items()
        if key not in our_keys
    ]

    merged = theirs[: their_block[0]] + our_text + theirs[their_block[1] :]
    return merged, added, "ok"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="*", help="IDs.lua paths to port")
    parser.add_argument("--ours", default="HEAD", help="our ref (default HEAD)")
    parser.add_argument("--theirs", required=True, help="upstream ref or sha")
    parser.add_argument(
        "--from-commit",
        action="store_true",
        help="use every IDs.lua touched by --theirs instead of explicit paths",
    )
    parser.add_argument("--write", action="store_true", help="write merged files to disk")
    args = parser.parse_args()

    paths = list(args.paths)
    if args.from_commit:
        touched = subprocess.run(
            ["git", "show", "--name-only", "--format=", "-m", "--first-parent", args.theirs],
            capture_output=True,
            text=True,
            check=False,
        ).stdout.split()
        paths += [p for p in touched if p.endswith("/IDs.lua")]
    if not paths:
        print("no IDs.lua paths given", file=sys.stderr)
        return 1

    total_added = 0
    for path in sorted(set(paths)):
        merged, added, note = port_file(path, args.ours, args.theirs)
        status = "WROTE" if (merged and args.write) else ("would port" if merged else "skip")
        print(f"{status:11} {path}  ({note})")
        if merged and args.write:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(merged)
        for key, value, comment in sorted(added):
            total_added += 1
            print(f"    NEEDS DAT LOOKUP  {key} = {value}  -- {comment[:90]}")

    print(f"\n{total_added} text key(s) need a value from our own client's DATs")
    if total_added:
        print("Resolve each by finding that dialog string in the pinned client's dump")
        print("(UpdateExtractor / POLUtils) and using OUR offset, not upstream's.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
