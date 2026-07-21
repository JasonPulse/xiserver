#!/usr/bin/env python3
"""
xi-game — agent-facing CLI for driving a live FFXI puppet during in-game testing.

It talks to a *bridge* (either the Windower addon `xi_agent_bridge.lua` or the
headless `headless_bridge.py`) over a newline-delimited-JSON TCP protocol, so
the same CLI works regardless of which puppet is running.

    agent  --(JSON lines / TCP)-->  bridge  --(game protocol)-->  LSB map server

Protocol (one JSON object per line):
    agent -> bridge : {"cmd": "ping|send|trigger|answer|state|shot"}
    bridge -> agent : {"type": "pong|ack|event_in|event_out|event_update|state|error", ...}

Commands:
    xi-game ping
    xi-game send "<chat/GM text>"          e.g. send "!cs 100 1 2"
    xi-game trigger <csid> [params...]     formats `!cs <csid> <params>` and sends
        [--capture] [--timeout S]          ...then waits for the resulting event_in
    xi-game answer <option> [--mode end|update] [--capture]
                                           respond to the active event (0x05B)
    xi-game capture [--type T] [--timeout S]   read next bridge message (default any)
    xi-game listen  [--timeout S] [--count N]  stream bridge messages as JSON lines
    xi-game state                          player/target snapshot
    xi-game shot [path]                    screenshot the puppet (out-of-band hook)

Connection: --host/--port or $XIGAME_HOST (default 127.0.0.1) / $XIGAME_PORT (27800).
All data-bearing output is JSON (one object per line) so an agent can parse it.
"""

import argparse
import json
import os
import socket
import subprocess
import sys
import time

DEFAULT_HOST = os.environ.get("XIGAME_HOST", "127.0.0.1")
DEFAULT_PORT = int(os.environ.get("XIGAME_PORT", "27800"))
EVENT_TYPES = {"event_in", "event_out", "event_update"}


class Bridge:
    """One short-lived TCP connection to the bridge, line-delimited JSON."""

    def __init__(self, host, port, timeout):
        self.host, self.port, self.timeout = host, port, timeout
        self.sock = None
        self._buf = b""

    def __enter__(self):
        self.sock = socket.create_connection((self.host, self.port), timeout=5)
        self.sock.settimeout(self.timeout)
        return self

    def __exit__(self, *exc):
        if self.sock:
            try:
                self.sock.close()
            except OSError:
                pass

    def send(self, obj):
        self.sock.sendall((json.dumps(obj) + "\n").encode("utf-8"))

    def lines(self, deadline):
        """Yield parsed JSON objects until the deadline elapses."""
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return
            self.sock.settimeout(remaining)
            while b"\n" not in self._buf:
                try:
                    chunk = self.sock.recv(8192)
                except socket.timeout:
                    return
                if not chunk:
                    return
                self._buf += chunk
            line, self._buf = self._buf.split(b"\n", 1)
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line.decode("utf-8", "replace"))
            except json.JSONDecodeError:
                yield {"type": "raw", "line": line.decode("utf-8", "replace")}


def out(obj):
    print(json.dumps(obj, ensure_ascii=False))


def connect_fail(args, err):
    out({"type": "error", "msg": f"cannot reach bridge at {args.host}:{args.port}: {err}",
         "hint": "is the puppet/bridge running and reachable (Tailscale/LAN)?"})
    sys.exit(2)


# --- commands ---------------------------------------------------------------

def _simple(args, payload, expect=("ack", "pong")):
    try:
        with Bridge(args.host, args.port, args.timeout) as b:
            b.send(payload)
            deadline = time.monotonic() + args.timeout
            for msg in b.lines(deadline):
                if msg.get("type") in expect or msg.get("type") == "error":
                    out(msg)
                    return
            out({"type": "timeout", "waited_for": list(expect)})
    except OSError as e:
        connect_fail(args, e)


def cmd_ping(args):
    _simple(args, {"cmd": "ping"}, expect=("pong", "ack"))


def cmd_send(args):
    _simple(args, {"cmd": "send", "text": args.text})


def cmd_interact(args):
    req = {"cmd": "interact"}
    if args.index is not None:
        req["index"] = args.index
    else:
        req["name"] = args.name
    _simple(args, req, expect=("ack", "error"))


def _capture_loop(b, deadline, want):
    for msg in b.lines(deadline):
        out(msg)
        t = msg.get("type")
        if t == "error":
            return True
        if want == "any" and t in EVENT_TYPES:
            return True
        if t == want:
            return True
    return False


def cmd_trigger(args):
    text = "!cs " + " ".join([str(args.csid)] + [str(p) for p in args.params])
    try:
        with Bridge(args.host, args.port, args.timeout) as b:
            b.send({"cmd": "send", "text": text})
            deadline = time.monotonic() + args.timeout
            if not args.capture:
                for msg in b.lines(deadline):
                    if msg.get("type") in ("ack", "error"):
                        out(msg)
                        return
                out({"type": "ack", "sent": text})
                return
            out({"type": "sent", "text": text})
            if not _capture_loop(b, deadline, "event_in"):
                out({"type": "timeout", "waited_for": "event_in", "after": text})
    except OSError as e:
        connect_fail(args, e)


def cmd_answer(args):
    payload = {"cmd": "answer", "option": args.option, "mode": args.mode}
    try:
        with Bridge(args.host, args.port, args.timeout) as b:
            b.send(payload)
            deadline = time.monotonic() + args.timeout
            saw_ack = False
            for msg in b.lines(deadline):
                out(msg)
                t = msg.get("type")
                if t == "error":
                    return
                if t == "ack":
                    saw_ack = True
                    if not args.capture:
                        return
                if args.capture and t in EVENT_TYPES:
                    return
            if not saw_ack:
                out({"type": "timeout", "waited_for": "ack"})
    except OSError as e:
        connect_fail(args, e)


def cmd_capture(args):
    try:
        with Bridge(args.host, args.port, args.timeout) as b:
            deadline = time.monotonic() + args.timeout
            if not _capture_loop(b, deadline, args.type):
                out({"type": "timeout", "waited_for": args.type})
    except OSError as e:
        connect_fail(args, e)


def cmd_listen(args):
    try:
        with Bridge(args.host, args.port, args.timeout) as b:
            deadline = time.monotonic() + args.timeout
            n = 0
            for msg in b.lines(deadline):
                out(msg)
                n += 1
                if args.count and n >= args.count:
                    return
    except OSError as e:
        connect_fail(args, e)


def cmd_state(args):
    _simple(args, {"cmd": "state"}, expect=("state",))


def cmd_shot(args):
    """Screenshot the puppet. Headless has no render; the real client needs an
    out-of-band grab. Set $XIGAME_SHOT_CMD to a command that captures the VM
    screen (use {path} as a placeholder for the output file)."""
    cmd = os.environ.get("XIGAME_SHOT_CMD")
    path = args.path or "xi_shot.png"
    if not cmd:
        out({"type": "error", "msg": "no screenshot hook configured",
             "hint": "set $XIGAME_SHOT_CMD, e.g. a hypervisor/Windows screen grab; "
                     "use {path} for the output file"})
        sys.exit(2)
    try:
        subprocess.run(cmd.format(path=path), shell=True, check=True)
        out({"type": "shot", "path": os.path.abspath(path)})
    except subprocess.CalledProcessError as e:
        out({"type": "error", "msg": f"screenshot command failed: {e}"})
        sys.exit(2)


def build_parser():
    # common connection flags, accepted both before AND after the subcommand
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--host", default=DEFAULT_HOST)
    common.add_argument("--port", type=int, default=DEFAULT_PORT)
    common.add_argument("--timeout", type=float, default=10.0,
                        help="seconds to wait for bridge replies (default 10)")

    p = argparse.ArgumentParser(prog="xi-game", description=__doc__, parents=[common],
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    def add(name):
        return sub.add_parser(name, parents=[common])

    add("ping").set_defaults(func=cmd_ping)

    s = add("send"); s.add_argument("text"); s.set_defaults(func=cmd_send)

    s = add("interact")
    s.add_argument("name", nargs="?", help="NPC name (nearest match)")
    s.add_argument("--index", type=int, help="target by mob index instead of name")
    s.set_defaults(func=cmd_interact)

    s = add("trigger")
    s.add_argument("csid", type=int)
    s.add_argument("params", nargs="*", help="op1..op8 for !cs")
    s.add_argument("--capture", action="store_true",
                   help="wait for the resulting event_in")
    s.set_defaults(func=cmd_trigger)

    s = add("answer")
    s.add_argument("option", type=int)
    s.add_argument("--mode", choices=["end", "update"], default="end")
    s.add_argument("--capture", action="store_true")
    s.set_defaults(func=cmd_answer)

    s = add("capture")
    s.add_argument("--type", default="any",
                   help="event_in|event_out|event_update|state|any (default any)")
    s.set_defaults(func=cmd_capture)

    s = add("listen")
    s.add_argument("--count", type=int, default=0, help="stop after N messages")
    s.set_defaults(func=cmd_listen)

    add("state").set_defaults(func=cmd_state)

    s = add("shot"); s.add_argument("path", nargs="?")
    s.set_defaults(func=cmd_shot)
    return p


def main(argv=None):
    args = build_parser().parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
