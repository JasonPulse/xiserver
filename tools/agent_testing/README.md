# agent_testing — in-game testing harness

Lets an agent drive a live FFXI "puppet" to discover/verify event flow (csid,
params, options, outcomes) while you keep editing server source. See the full
design in [`documentation/agent_ingame_testing.md`](../../documentation/agent_ingame_testing.md).

## Files

| File | Role |
|------|------|
| `xi_game.py` | **agent-facing CLI** — talks to a bridge over JSON/TCP; puppet-agnostic |
| `windower_addon/xi_agent_bridge.lua` | **Path A puppet** — Windower 4 addon on a real client (works today) |
| `headless_bridge.py` | **Path B puppet** — scaffold over `tools/headlessxi` (no client; needs recv path finished) |

Both puppets speak the **same** protocol, so `xi_game.py` drives either.

## Protocol (newline-delimited JSON over TCP, default port 27800)

```
agent  -> bridge : {"cmd":"ping|send|trigger|answer|state"}
bridge -> agent  : {"type":"pong|ack|event_in|event_out|event_update|state|error", ...}
```

## CLI quickstart

```bash
export XIGAME_HOST=<puppet ip>   # Tailscale/LAN ip of the box running the bridge
xi-game ping
xi-game trigger 52 --capture        # send `!cs 52`, wait for the event_in (csid/params)
xi-game answer 1 --capture          # respond with option 1, capture the event_out
xi-game state
xi-game listen --count 20           # stream raw bridge messages (logging)
```

Global flags (`--host/--port/--timeout`) work before or after the subcommand.

## Status

- `xi_game.py` — done, protocol verified against a mock bridge.
- `xi_agent_bridge.lua` — complete; **on first run, confirm the 0x05B field
  names** against a logged `event_out` from a manual menu pick before trusting
  `answer` (Windower's packet-lib field names vary by version).
- `headless_bridge.py` — scaffold. Sends today; **capturing** needs the
  HXIClient receive path (de-blowfish → decompress → split → dispatch) finished
  against a live server. See the TODOs in the file.

Pairs with the static **`xidat`** dump index
(`updateextractor/xidat/`) — use that to find candidate csids per NPC/zone,
then this harness to verify them live.
