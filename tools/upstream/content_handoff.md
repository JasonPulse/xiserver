# Handoff: porting upstream content to our pinned client

This is a work queue for an agent picking up upstream content commits. Read all of it
before starting. The constraint in the next section is the whole reason this job exists.

## The constraint

We run FFXI client `30251227_0`, pinned on purpose. Upstream tracks current retail and is
five client versions ahead.

A zone's `scripts/zones/<Zone>/IDs.lua` holds three tables, and they are not equally
portable:

| table | source | portable? |
|---|---|---|
| `text` | client DAT offsets | **no** |
| `mob` | `mob_spawn_points.sql` | yes |
| `npc` | `npc_list.sql` | yes |

Upstream renumbers `text` on every client bump. Their numbers are wrong for us. Ours are
right. The `mob` and `npc` tables are server-side and must be taken from upstream, because
new content references new entity ids.

Two failure modes, both of which have already happened here:

- Take upstream's `text` values and every NPC in that zone says the wrong line. This is
  the failure that made the server unplayable in February.
- Drop the whole `IDs.lua` and content dies at load with
  `attempt to perform arithmetic on field 'X' (a nil value)`, because you threw away the
  `mob` ids it needs.

## The tool that does it correctly

```
python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> --from-commit
python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> --from-commit --write
```

It takes upstream's file and puts our `text` block back, byte for byte. Run without
`--write` first: it prints every text key upstream added that we do not have, with
upstream's value and the dialog string from the trailing comment.

## Per-commit procedure

1. `git cherry-pick -n -Xpatience <sha>`
2. `python tools/upstream/port_ids_lua.py --ours HEAD --theirs <sha> --from-commit --write`
3. `git add` the ported `IDs.lua` files.
4. Resolve any remaining conflicts in the content files. **Prefer ours** on gameplay
   content; take upstream's structure only where it is a crash fix or an API change.
5. If step 2 reported `NEEDS DAT LOOKUP` keys, resolve each one (next section) before
   committing. Do not guess a number, and do not reuse upstream's.
6. Verify (see the bar below), then commit.

## Resolving a new text key

`port_ids_lua.py` gives you the key name, upstream's value, and the dialog string. You
need OUR offset for that same string.

Use the sibling `UpdateExtractor` repo against the pinned client. Note the dump currently
sitting in `UpdateExtractor/out/` is from `30240806_0` (Aug 2024) and is **not** our pin,
so it cannot be used as-is. Regenerate with POLUtils MassExtractor on Windows against a
`30251227_0` install, then match on the dialog string, not the number.

Sanity check before you trust a value: pick two or three keys that already exist in our
`IDs.lua` for that same zone and confirm the fresh dump agrees with them. If it does not,
the dump is from the wrong client and every number you take from it is wrong.

If the string does not exist in our client at all, that dialog was added in a later client
version. Stop and record the commit as `blocked-client` in `ledger.csv` with a note. Do not
invent an id and do not substitute a nearby line.

## The verification bar

Nothing ships without all of these:

1. Builds with `WARNINGS_AS_ERRORS=TRUE`.
2. `xi_test` passes in full against a real MariaDB. Baseline is **265** tests as of
   2026-08-21. A drop in the *count* matters as much as a failure: it means a Lua file
   failed to load and the suite truncated.
3. No zone `IDs.lua` `text` block differs from ours.
4. `CLIENT_VER` is still `30251227_0`.
5. `SupportedXiloaderVersion` in `src/login/auth_session.h` is still `{2, 0, 0}`.

Checks 3 to 5 surface as "the server is broken" reports rather than build failures, so
they are the ones worth automating into your loop. `tools/upstream/README.md` has the
local Docker plus MariaDB recipe for 1 and 2.

## The queue

`tools/upstream/content_queue.csv`, 101 commits, sorted easiest first.

| column | meaning |
|---|---|
| `new_text_keys` | dialog keys needing a DAT lookup, 0 means none |
| `applies_clean` | `yes` = only step 2 needed |
| `blocked_on` | first files that conflict when `applies_clean` is `no` |
| `zones` | zones touched |

Shape of the queue:

- **25 apply clean** after the ID port. Of those, **22 need zero new text keys**, so they
  are pure mechanical ports and the obvious place to start.
- 76 need real merge work on the content files, usually because they depend on an earlier
  upstream commit we skipped.
- New text keys needed run 0 to 61 per commit, 953 across the whole content set.

Work easiest first and re-verify in batches of about ten, not one at a time. Record every
verdict in `ledger.csv` so the next pass does not redo it.

## Already done, do not redo

11 content commits are already ported and verified on the `upstream-picks-58` branch
(Norg Tales' Beginning ZM1, Bostaunieux trap doors, Rapid Raptors, Hyakume, Follow the
White Rabbit, ENM Pulling the Strings, and others). They are marked `adopted` in
`ledger.csv`.

Four commits in the content set are CLIENT_VER bumps (`6e7468d7b0`, `d767ed5251`,
`2f779f9a01`, `e1678ac8f9`). Never take them while the client is pinned.
