#!/usr/bin/env python3
"""
xi_probe — agent-side helper that talks to the xi_agent_bridge Windower addon.

Reads newline-delimited JSON from the bridge (no chunk-size assumption — keeps
reading until it sees \\n, so screenshot payloads up to several MB stream
cleanly). Three modes:

    xi_probe.py cs <csid>           fire !cs <csid>, capture event_in + any
                                    chat lines that print in the listen window
    xi_probe.py shot [out.png]      ask the bridge for a fresh screenshot,
                                    write the PNG to disk, print path
    xi_probe.py raw <json-cmd>      send arbitrary {"cmd":"..."} and dump
                                    every reply for `--listen` seconds

Defaults: host 100.86.64.19, port 27800. Override via $XIPROBE_HOST / $XIPROBE_PORT.
"""

import argparse
import base64
import json
import os
import socket
import sys
import time


def connect(host, port, timeout=15):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    s.connect((host, port))
    return s


def recv_lines(sock, deadline):
    """Read newline-delimited JSON until deadline. Yields parsed objects.
    Handles payloads larger than the OS recv buffer (screenshots are ~500KB+)."""
    buf = b''
    while True:
        remaining = deadline - time.time()
        if remaining <= 0:
            return
        sock.settimeout(min(remaining, 2.0))
        try:
            chunk = sock.recv(65536)
        except socket.timeout:
            continue
        if not chunk:
            return
        buf += chunk
        while b'\n' in buf:
            line, buf = buf.split(b'\n', 1)
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line.decode('utf-8', 'replace'))
            except json.JSONDecodeError:
                yield {'type': 'parse_error', 'raw': line.decode('utf-8', 'replace')[:200]}


def cmd_cs(args, sock):
    sock.sendall((json.dumps({'cmd': 'send', 'text': f'!cs {args.csid}'}) + '\n').encode())
    deadline = time.time() + args.listen
    for obj in recv_lines(sock, deadline):
        t = obj.get('type')
        if t == 'chat':
            print(f"  chat[{obj.get('mode')}]: {obj.get('text')}")
        elif t == 'event_in':
            print(f"  event_in csid={obj.get('csid')} unique_no={obj.get('unique_no')} "
                  f"act_index={obj.get('act_index')} params={obj.get('params')}")
        elif t == 'event_out':
            print(f"  event_out csid={obj.get('csid')} option={obj.get('option')}")
        elif t in ('ack', 'pong', 'hello'):
            pass
        else:
            print(f"  {t}: {json.dumps(obj)[:160]}")


def cmd_shot(args, sock):
    sock.sendall(b'{"cmd":"screenshot"}\n')
    deadline = time.time() + args.listen
    for obj in recv_lines(sock, deadline):
        t = obj.get('type')
        if t == 'screenshot':
            data = base64.b64decode(obj['data'])
            out_path = os.path.abspath(args.out)
            with open(out_path, 'wb') as f:
                f.write(data)
            print(f"shot OK: {obj.get('name')} -> {out_path} ({obj.get('bytes')} bytes)")
            return
        elif t == 'error':
            print(f"shot ERROR: {obj.get('msg')}")
            return
        elif t == 'hello':
            continue
        else:
            print(f"  skip {t}: {json.dumps(obj)[:160]}")
    print("shot TIMEOUT — no screenshot reply within listen window")


def cmd_raw(args, sock):
    sock.sendall((args.payload + '\n').encode())
    deadline = time.time() + args.listen
    for obj in recv_lines(sock, deadline):
        print(json.dumps(obj)[:400])


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--host', default=os.environ.get('XIPROBE_HOST', '100.86.64.19'))
    p.add_argument('--port', type=int, default=int(os.environ.get('XIPROBE_PORT', '27800')))
    p.add_argument('--listen', type=float, default=25.0,
                   help='seconds to wait for replies (default 25 — FFXI CS '
                        'dialog runs long, do not shorten without reason)')
    sub = p.add_subparsers(dest='cmd', required=True)

    pcs = sub.add_parser('cs')
    pcs.add_argument('csid', type=int)
    pcs.set_defaults(func=cmd_cs)

    psh = sub.add_parser('shot')
    psh.add_argument('out', nargs='?', default='/tmp/xi_shot.png')
    psh.set_defaults(func=cmd_shot)

    pra = sub.add_parser('raw')
    pra.add_argument('payload')
    pra.set_defaults(func=cmd_raw)

    args = p.parse_args()
    s = connect(args.host, args.port)
    try:
        # drain hello
        time.sleep(0.3)
        s.settimeout(1.0)
        try:
            s.recv(4096)
        except socket.timeout:
            pass
        args.func(args, s)
    finally:
        s.close()


if __name__ == '__main__':
    main()
