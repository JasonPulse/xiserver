# Harvesting upstream commits

This fork does not merge with upstream LandSandBoat. It harvests from it. This directory
holds the tool that finds what is worth taking and the ledger that remembers what we
already looked at.

## Why we do not merge

We are pinned to FFXI client `30251227_0` (see `CLIENT_VER` in
`settings/default/login.lua`). Upstream tracks current retail and is several client
versions ahead.

Every time Square Enix ships a client update, the dialog tables inside the client's DATs
get new entries inserted, and upstream shifts the text IDs in `scripts/zones/*/IDs.lua`
to match. Those IDs are offsets into the client's tables. Adopt upstream's shifted IDs
against our older client and every NPC says the wrong line.

The shifts cannot be undone arithmetically. Of 298 zone `IDs.lua` files upstream changed,
only 3 shift by a single uniform amount. The rest shift by different amounts in different
ID ranges within the same file, because insertions happen at scattered points. There is no
offset to subtract. Do not write a script that tries.

So: a merge is off the table until either the client is unpinned or every `IDs.lua` is
regenerated from our own client's DATs with the sibling `UpdateExtractor` repo, whose
README covers exactly that ("update `zones/<zone_name>/IDs.lua` text ID's in place,
handling ... ID shifts"). That needs POLUtils MassExtractor on Windows with the pinned
client installed.

## What the tool does

`mine_upstream.py` walks every commit we do not have, discards the ones that can never
work, tests whether the survivors still apply, and records each verdict in `ledger.csv`.

Routed by what they touch:

- touches `settings/default/login.lua` -> `blocked-client` (client bump, never take)
- touches *only* `scripts/zones/*/IDs.lua` -> `blocked-client` (pure text renumber)
- touches `IDs.lua` **plus content** -> `content-queued`, the portable case; see
  `content_handoff.md` and `port_ids_lua.py`
- more than 40 files -> `skip-large` (restructure, not a fix)

The IDs.lua rule used to reject the third case outright. That was wrong: 118 of 124
such commits are real content with one `IDs.lua` riding along, and they port fine once
the `text` block is kept as ours.

Survivors get a tier from their subject line:

- **A** crash, corruption, exploit, overflow, leak, use-after-free
- **B** upstream's own `[core]` engine tag
- **C** anything else calling itself a fix
- **D** everything else

## Running it

```
python tools/upstream/mine_upstream.py                                  # classify only
python tools/upstream/mine_upstream.py --test-apply --tier A B C        # + apply test
python tools/upstream/mine_upstream.py --show-candidates --tier A B     # print shortlist
```

Fetch upstream first (`git fetch upstream`). `--test-apply` cherry-picks and resets, so it
refuses to run against a dirty working tree. Everything else is read-only.

The ledger is keyed by short sha and is only ever added to. A row whose `status` is
anything other than `candidate` is treated as already ruled on and left untouched, so your
notes survive re-runs. That is what makes this cheap to repeat.

## Ledger statuses

| status | meaning |
|---|---|
| `adopted` | cherry-picked in |
| `candidate` | applies clean, unreviewed |
| `conflict` | needs hand work |
| `content-queued` | content behind an IDs.lua, portable |
| `blocked-client` | client-coupled, never safe |
| `blocked-infra` | needs upstream internals we lack |
| `skip-large` | structural, out of scope |
| `skip` | reviewed, not wanted |

## The bar for adopting anything

Applying cleanly proves nothing. A commit can apply and still not compile, because upstream
kept refactoring the things it calls. Two of the first batch needed a source tweak
(`xi::StatusEffect::Hysteria` back to `EFFECT_HYSTERIA`), and one had to be dropped
outright because it needs upstream's `EntityID_t::resolve<T>()` handle where ours is still
a plain POD.

So for any batch, before it goes near the live server:

1. It builds with `WARNINGS_AS_ERRORS=TRUE`.
2. `xi_test` passes in full against a real MariaDB.
3. `CLIENT_VER` is still `30251227_0`.
4. No `scripts/zones/*/IDs.lua` text ID moved.
5. `SupportedXiloaderVersion` in `src/login/auth_session.h` is unchanged. Upstream raised
   it to `{2,1,0}` and the check at `auth_session.cpp` is exact major.minor equality, not
   a minimum, so taking it locks out every player not on xiloader 2.1.x.

Checks 3 to 5 are the ones that turn into "the server is broken" reports rather than a
failed build, so do not skip them.

## Porting content (the other half)

`IDs.lua` is not one thing. `text` is client-coupled and must stay ours; `mob` and `npc`
are server-side and must come from upstream. `port_ids_lua.py` does that split, and
`content_handoff.md` is the brief for whoever works the content queue.

Dropping a whole `IDs.lua` instead of splitting it looks like it works and then kills
content at load with `attempt to perform arithmetic on field 'X' (a nil value)`, because
the `mob` ids went with it. That also truncates the xi_test run, so watch the test
*count*, not just pass or fail.
