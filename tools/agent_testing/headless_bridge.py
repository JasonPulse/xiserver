#!/usr/bin/env python3
"""
headless_bridge — Path B puppet: drive event testing with NO game client.

Wraps tools/headlessxi/HXIClient and exposes the SAME newline-JSON/TCP protocol
as the Windower addon, so `xi_game.py` drives either one identically. A headless
puppet needs no Windows VM, no GUI, and many can run in parallel — ideal for
mechanical sweeps (csid / option / params / outcome) across a big backlog.

STATUS: scaffold. Two things must be finished against a *live* LSB server
(they can't be written correctly blind):

  1. OUTGOING ENCRYPTION — HXIClient currently sends map packets un-blowfished;
     real map traffic is blowfish-encrypted after zone-in. `to_map_5b` below
     builds the correct 0x05B body (layout verified from LSB
     src/map/packets/c2s/0x05b_eventend.h); wiring encryption is a TODO.
  2. INCOMING PARSE — HXIClient.parse_incoming_packet is a stub. To capture
     events you must: de-blowfish (self.bf) -> decompress (decompress.py) ->
     split into sub-packets [id|size] -> dispatch 0x032/0x033/0x034. The
     `on_event_*` hooks below are where parsed events get pushed to agents.

Until those land, this puppet can CONNECT and SEND (e.g. `!cs` via /say if the
account is GM) but cannot yet CAPTURE. The Windower addon (Path A) covers
capture today; finishing this file is the strategic upgrade.

Reference for every packet field: https://github.com/atom0s/XiPackets
"""

import json
import os
import socket
import struct
import sys
import threading

# make `tools.headlessxi` importable from the repo root
_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if _REPO not in sys.path:
    sys.path.insert(0, _REPO)

# pylint: disable=import-error,wrong-import-position
from tools.headlessxi.hxiclient import HXIClient  # noqa: E402
from tools.headlessxi.util import util, PACKET_HEAD  # noqa: E402

BIND_HOST = "0.0.0.0"
BIND_PORT = 27800


# --- 0x05B builder (event end / update) -------------------------------------
# Layout (LSB 0x05b_eventend.h), body starting after the [type,size,seq] head:
#   u32 UniqueNo; u32 EndPara(option); u16 ActIndex; u16 Mode; u16 EventNum(csid); u16 EventPara
def to_map_5b(unique_no, act_index, csid, option, mode_end=True):
    body = 0x14  # 20 bytes
    data = bytearray(PACKET_HEAD + body + 16)  # head + body + md5
    data[PACKET_HEAD + 0x00] = 0x5B
    data[PACKET_HEAD + 0x01] = body // 4  # size in 4-byte words
    struct.pack_into("<I", data, PACKET_HEAD + 0x04, unique_no & 0xFFFFFFFF)
    struct.pack_into("<I", data, PACKET_HEAD + 0x08, option & 0xFFFFFFFF)
    struct.pack_into("<H", data, PACKET_HEAD + 0x0C, act_index & 0xFFFF)
    struct.pack_into("<H", data, PACKET_HEAD + 0x0E, 0 if mode_end else 1)
    struct.pack_into("<H", data, PACKET_HEAD + 0x10, csid & 0xFFFF)
    struct.pack_into("<H", data, PACKET_HEAD + 0x12, 0)
    util.packet_md5(data)
    # TODO: blowfish-encrypt `data` here once the encrypted send path is wired.
    return data


class AgentBridge(HXIClient):
    def __init__(self, *a, **kw):
        super().__init__(*a, **kw)
        self.clients = []
        self.clients_lock = threading.Lock()
        self.active_event = None  # {'unique_no','act_index','csid'} from last 0x032

    # --- agent-facing TCP server -------------------------------------------

    def serve(self, host=BIND_HOST, port=BIND_PORT):
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((host, port))
        srv.listen(4)
        print(f"headless_bridge: listening on {host}:{port}")
        while True:
            conn, _ = srv.accept()
            with self.clients_lock:
                self.clients.append(conn)
            self._emit_to(
                conn,
                {
                    "type": "hello",
                    "puppet": "headless",
                    "char": getattr(self, "char_name", ""),
                },
            )
            threading.Thread(
                target=self._client_loop, args=(conn,), daemon=True
            ).start()

    def _emit_to(self, conn, obj):
        try:
            conn.sendall((json.dumps(obj) + "\n").encode("utf-8"))
        except OSError:
            self._drop(conn)

    def broadcast(self, obj):
        with self.clients_lock:
            targets = list(self.clients)
        for c in targets:
            self._emit_to(c, obj)

    def _drop(self, conn):
        with self.clients_lock:
            if conn in self.clients:
                self.clients.remove(conn)
        try:
            conn.close()
        except OSError:
            pass

    def _client_loop(self, conn):
        buf = b""
        while True:
            try:
                chunk = conn.recv(4096)
            except OSError:
                break
            if not chunk:
                break
            buf += chunk
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                if line.strip():
                    self._dispatch(conn, json.loads(line.decode("utf-8", "replace")))
        self._drop(conn)

    def _dispatch(self, conn, msg):
        cmd = msg.get("cmd")
        if cmd == "ping":
            self._emit_to(conn, {"type": "pong"})
        elif cmd == "send":
            self.send_say(msg["text"])  # GM `!cs ...` is invoked via chat
            self._emit_to(conn, {"type": "ack", "cmd": "send"})
        elif cmd == "answer":
            if not self.active_event:
                self._emit_to(
                    conn, {"type": "error", "msg": "no active event captured yet"}
                )
                return
            ev = self.active_event
            pkt = to_map_5b(
                ev["unique_no"],
                ev["act_index"],
                ev["csid"],
                int(msg.get("option", 0)),
                mode_end=(msg.get("mode", "end") == "end"),
            )
            self.map_sock.sendto(pkt, self.map_server)
            self._emit_to(conn, {"type": "ack", "cmd": "answer"})
        elif cmd == "state":
            self._emit_to(
                conn,
                {
                    "type": "state",
                    "char": getattr(self, "char_name", ""),
                    "note": "headless: no render; mechanical state only",
                },
            )
        else:
            self._emit_to(conn, {"type": "error", "msg": f"unknown cmd {cmd}"})

    # --- incoming parse (THE work to finish) -------------------------------

    def parse_incoming_packet(self, data):
        """Override HXIClient's stub. Pipeline to implement against a live server:
        1) self.bf.decrypt(...)  de-blowfish the map payload
        2) decompress.py         inflate the compressed block
        3) walk sub-packets: each starts [u16 id_and_size]; id = low 9 bits,
           size = high 7 bits (in 4-byte words)
        4) for id in (0x032, 0x033, 0x034): parse fields, call on_event_*
        """
        # TODO(1-3): decrypt + decompress + split. Until done, nothing is parsed.
        return

    def on_event_in(self, csid, unique_no, act_index, params, raw_hex):
        """Call this from parse_incoming_packet once 0x032 is decoded."""
        self.active_event = {
            "unique_no": unique_no,
            "act_index": act_index,
            "csid": csid,
        }
        self.broadcast(
            {
                "type": "event_in",
                "id": "0x032",
                "csid": csid,
                "unique_no": unique_no,
                "act_index": act_index,
                "params": params,
                "raw": raw_hex,
            }
        )

    def on_event_update(self, csid, params, raw_hex):
        self.broadcast(
            {
                "type": "event_update",
                "id": "0x034",
                "csid": csid,
                "params": params,
                "raw": raw_hex,
            }
        )


def main():
    import argparse

    ap = argparse.ArgumentParser(description="headless FFXI puppet bridge")
    ap.add_argument("--user", required=True)
    ap.add_argument("--password", required=True)
    ap.add_argument("--server", required=True, help="LSB host/ip")
    ap.add_argument("--slot", type=int, default=0)
    ap.add_argument("--port", type=int, default=BIND_PORT)
    args = ap.parse_args()
    bot = AgentBridge(args.user, args.password, args.server, slot=args.slot)
    bot.login()
    bot.serve(port=args.port)


if __name__ == "__main__":
    main()
