# Agent-driven in-game testing

How to let an AI agent do in-game FFXI testing — discovering and verifying the
event handshake (which **csid** fires, what **params** go out, what **option**
comes back, what **outcome** results, and whether the **dialog** is correct) —
while you keep editing server source. The agent works your backlog of
unimplemented content largely on its own, so each costly build image is
high-yield instead of a guess.

> **Why not the "Trackmania neural-net" approach?** That trained a CNN on screen
> pixels because the game was a black box. We own both ends (server + decoded
> client DATs), so the agent gets *structured* state and a clean action surface
> instead of learning from pixels. Far simpler, and it gives ground-truth data
> to assert against.

---

## Architecture at a glance

```
                 ┌──────────────────────── the agent (Claude Code) ───────────────────────┐
                 │  reads dumps via `xidat`   │   drives the live game via `xi-game`        │
                 └───────────────┬────────────┴───────────────────┬─────────────────────────┘
                                 │ (static, offline)               │ (live, JSON/TCP :27800)
                 ┌───────────────▼───────────────┐    ┌────────────▼───────────────┐
                 │  xidat  (dump index)           │    │  bridge / puppet            │
                 │  zones · events · dialog       │    │  Path A: Windower addon     │
                 │  updateextractor/xidat/        │    │  Path B: headless_bridge.py │
                 └────────────────────────────────┘    └────────────┬───────────────┘
                                                                     │ FFXI protocol
                                                          ┌──────────▼──────────┐
                                                          │   LSB map server    │
                                                          └─────────────────────┘
```

Two complementary capabilities:

- **`xidat`** (static) — answers *what exists*: which csids each NPC owns per
  zone, and the full dialog text table. No game running required.
- **`xi-game` + a puppet** (live) — answers *what actually happens*: fire a
  csid, capture the params/option, confirm the rendered dialog, observe the
  server outcome.

---

## The event handshake (what we're capturing)

Every FFXI event is a request/response between server and client:

| Direction | Packet | Carries | LSB hook |
|-----------|--------|---------|----------|
| server → client | `0x032` event | `UniqueNo`, `ActIndex`, **`EventNum`=csid**, params | `player:startEvent(csid, op1..op8)` |
| server → client | `0x033` eventstr | csid + strings (names, etc.) | `player:startEventString(...)` |
| server → client | `0x034` eventnum | event update / params | — |
| client → server | **`0x05B`** eventend | **`EndPara`=option**, csid, target | `onEventFinish/onEventUpdate(player, csid, option)` |

GM commands already in the repo to drive this: **`!cs <csid> op1..op8`**
(`scripts/commands/cs.lua` → `startEvent`) and **`!cs2`** (`startEventString`).

**Key fact:** the **dialog *text*** is rendered client-side from the client's
DAT files, keyed by `csid + params`. It is **not** on the wire (beyond the param
numbers) or on the server. So packet/log capture verifies the *skeleton*
(csid/params/option/outcome) but **cannot** verify the displayed sentence — that
needs either the rendered client (screenshot) or a decoded DAT lookup. This is
why we have both halves.

---

## Component 1 — `xidat` (static dump index) ✅ built

Location: `updateextractor/xidat/` (read-only over `ffxi_dats_decoded`; adds no
files to the dumps). Joins the three decoded layers:

- `zones.yml` → zone id ↔ `file_name`
- `events/<Zone>.yml` → `entity_id` → `[csid]` → `byte_code`
- `dialog/<Zone>.yml` → message id → text (with `${choice:N}[a/b/c]` markers)

Two findings baked in:
- **`entity_id` is the LSB npc-id** (`0x01000000 | zone<<12 | index`), so the
  dump joins straight onto server NPCs; `0x7FFFFFF0` = zone-global actor.
- **`${choice:N}[…]`** markers reveal what `op1..op8` mean at the text level —
  partial param semantics for free.

```bash
xidat events Bastok_Markets --csid-only   # NPC → its csids
xidat npc Bastok_Markets 0x010EB002        # one NPC's csids + byte_code
xidat dialog Bastok_Markets 0 --param 5    # dialog text, ${choice} resolved
xidat find "Mythril Musketeers"            # locate text across all zones
```

**Gap:** the event `byte_code` is the raw FFXI event-VM program, **undecoded**.
So `xidat` gives *candidate csids + the dialog table*, not "csid+params → which
exact line." Closing that is Component 3 (or the live client does it for us).

---

## Component 2 — `xi-game` + a puppet (live driver)

Location: `tools/agent_testing/`. The agent calls `xi-game` (a CLI); it talks to
a **bridge/puppet** over newline-JSON/TCP (:27800). Two puppet options, same
protocol:

### Path A — Windower addon (works today) ✅ built
`windower_addon/xi_agent_bridge.lua` on a **real client** logged in as a parked
GM character (Windows VM). The client does all crypto + dialog rendering; the
addon taps `0x032/0x033/0x034`, relays `!cs` as input, injects `0x05B`, and
reports `state`.
- **Pro:** working in hours; the only way to verify *rendered dialog* (screenshot).
- **Con:** needs a Windows VM + a logged-in client; one puppet at a time.
- **First-run check:** confirm the `0x05B` field names against a logged
  `event_out` from a manual menu pick before trusting `answer`.

### Path B — headless puppet (strategic) ⬜ scaffolded
`headless_bridge.py` over `tools/headlessxi` (pure-Python FFXI client). No VM, no
GUI, **many puppets in parallel** — ideal for mechanical sweeps at backlog scale.
- **State:** logs in + sends today. **Capture needs two things finished against a
  live server** (can't be written blind): (1) outgoing blowfish encryption,
  (2) the receive path — `parse_incoming_packet` is a stub; implement
  de-blowfish → decompress → split sub-packets → dispatch `0x032/0x033/0x034`.
  The correct `0x05B` builder and the `on_event_*` push hooks are already in place.
- **Limit:** headless has no renderer, so it gives *mechanical* truth only;
  dialog-text confirmation still needs Path A or Component 3.

### CLI
```bash
export XIGAME_HOST=<puppet ip>
xi-game trigger 52 --capture     # !cs 52 → capture event_in (csid, params)
xi-game answer 1 --capture       # option 1 → capture event_out + outcome
xi-game state ; xi-game listen   # snapshot / stream
```

---

## Component 3 — event-VM disassembler (optional, later) ⬜

Decode the `byte_code` opcodes to resolve `csid + params → message id` fully
offline, removing the need for a live client to confirm dialog. Real but bounded
reverse-engineering; opcode reference: <https://github.com/atom0s/XiPackets>.
Not a blocker — Path A covers dialog verification today.

---

## The agent's per-item loop

For each backlog item the agent runs, roughly:

1. **Scope (xidat):** `xidat npc <zone> <entityId>` → candidate csids; pull the
   dialog table for those messages.
2. **Trigger (xi-game):** `trigger <csid> <params> --capture` → confirm the
   `0x032` fired with the expected params.
3. **Verify dialog:** screenshot + read it (Path A) and/or cross-check against
   `xidat dialog`; catch "right csid, wrong param → wrong line."
4. **Enumerate options:** `answer <0..N> --capture` per branch → record which
   option drives which outcome (read from the `0x05B` / `onEventFinish` path).
5. **Implement & confirm:** write `onEventFinish(player, csid, option, npc)` from
   the captured map; re-run to confirm the server outcome (item/var/next-CS).
6. **Commit per item** — a reviewable trail, not one giant blob.

Because steps 1–5 run against an already-deployed image, the agent front-loads
correct params so each ~30-min build is high-yield.

---

## Build status

| Component | Status |
|-----------|--------|
| `xidat` index + CLI | ✅ done, tested against the real dumps |
| `xi-game` CLI | ✅ done, protocol verified vs mock bridge |
| Windower bridge addon (Path A) | ✅ written; verify `0x05B` field names on first run |
| Headless bridge (Path B) | ⬜ scaffold; finish recv path on a live server |
| Event-VM disassembler (C3) | ⬜ optional, later |

---

## Next steps (in order)

1. **Stand up the Path A puppet.** Windows VM on Proxmox: FFXI client + Windower
   4, drop `xi_agent_bridge.lua` into `Windower4/addons/`, `lua load
   xi_agent_bridge`, log in a parked GM char. Put the VM on Tailscale/LAN so the
   agent box can reach `:27800`.
2. **Smoke-test the live loop.** From the agent box: `xi-game ping`, then
   `xi-game trigger <known-csid> --capture` on a zone you know. Confirm
   `event_in` shows the right csid/params.
3. **Verify `0x05B`.** Manually pick a menu option in-game, watch the logged
   `event_out`, confirm the option value + field offsets; adjust the addon's
   `answer` field names if Windower's differ. Then test `xi-game answer`.
4. **Wire screenshots** (dialog check): set `$XIGAME_SHOT_CMD` to a VM/hypervisor
   screen-grab so `xi-game shot` works; the agent reads the dialog via vision.
5. **Point the agent at the backlog** with the per-item loop above; have it
   commit per item.
6. **(Parallel track)** Finish the Path B receive path to unlock parallel headless
   sweeps for the mechanical-only items.
7. **(Later)** Component 3 if you want offline dialog resolution.

## Related docs
- `interaction-framework.md` — LSB's quest/event interaction model
- `AI_Events.txt`, `MessageSystemIDs.log` — event/message references
- `updateextractor/xidat/README.md` — dump index usage
- `tools/agent_testing/README.md` — harness usage
