#!/usr/bin/env python3
"""
probe.py — scripted event-decode sequences against the xi_agent_bridge.

Talks the same newline-JSON/TCP protocol as xi_game.py, but runs whole
probe sequences (menu open -> keypress pick -> option capture -> release)
in one invocation so the driving shell command stays a one-liner.

Host comes from $XIGAME_HOST (default 127.0.0.1), port $XIGAME_PORT (27800).

Subcommands:
    pick --csid 9704 --params 0,1 --downs 2
        Open the event, arrow down N times, press Enter, print the real
        client 0x05B option code, then !release. One JSON line out.

    chart-rows --kis 2895,2900,2910,2919 [--csid 9704 --params 0,1]
        Grant the key items, run `pick` for each row position, remove the
        key items, print {row: option} JSON.

    sweep-single --kis 2895,2896,... [--csid 9704 --params 0,1]
        For each key item alone: grant, open, Enter on the only row,
        capture option, release, remove. Print {ki: option} JSON.

    cleanup --kis 2895,...   Remove key items + !release (state repair).
"""

import argparse
import json
import os
import socket
import sys
import time


class Bridge:
    def __init__(self, host, port, timeout=12.0):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.sock.settimeout(timeout)
        self.buf = b''

    def _readline(self):
        while b'\n' not in self.buf:
            chunk = self.sock.recv(4096)
            if not chunk:
                raise ConnectionError('bridge closed')
            self.buf += chunk
        line, self.buf = self.buf.split(b'\n', 1)
        try:
            return json.loads(line.decode('utf-8', errors='replace'))
        except json.JSONDecodeError:
            # FFXI chat can smuggle raw bytes through the addon; skip the line
            return {'type': 'garbled'}

    def cmd(self, obj):
        self.sock.sendall((json.dumps(obj) + '\n').encode())

    def wait_for(self, types, deadline):
        """Return the first message of `types` — from the inbox of earlier
        non-matching reads first, then live off the socket. Non-matching
        live messages are stashed, never dropped."""
        if not hasattr(self, 'inbox'):
            self.inbox = []

        for i, msg in enumerate(self.inbox):
            if msg.get('type') in types:
                return self.inbox.pop(i)

        while time.time() < deadline:
            try:
                msg = self._readline()
            except socket.timeout:
                continue
            if msg.get('type') in types:
                return msg
            self.inbox.append(msg)
        return None

    def drain(self, seconds=0.5):
        end = time.time() + seconds
        self.sock.settimeout(0.2)
        try:
            while time.time() < end:
                try:
                    self._readline()
                except (socket.timeout, json.JSONDecodeError):
                    pass
        finally:
            self.sock.settimeout(12.0)

    def send_text(self, text):
        self.cmd({'cmd': 'send', 'text': text})
        self.wait_for({'ack'}, time.time() + 5)


def key_tap(br, key, hold=0.6):
    br.send_text(f'//setkey {key} down')
    time.sleep(hold)
    br.send_text(f'//setkey {key} up')
    time.sleep(0.4)


def open_event(br, csid, params):
    br.drain()
    br.send_text('!cs %d %s' % (csid, ' '.join(str(p) for p in params)))
    msg = br.wait_for({'event_in'}, time.time() + 10)
    return msg is not None


def pick_row(br, csid, params, downs):
    """Open event, move to row (downs), Enter, return real option code."""
    if not open_event(br, csid, params):
        print(json.dumps({'debug': 'event_in never arrived'}), flush=True)
        br.send_text('!release')
        time.sleep(1.0)
        return None
    time.sleep(1.0)
    for _ in range(downs):
        key_tap(br, 'down')
    br.send_text('//setkey enter down')
    time.sleep(0.6)
    br.send_text('//setkey enter up')
    msg = br.wait_for({'event_out'}, time.time() + 12)
    if msg is None:
        print(json.dumps({'debug': 'no event_out after enter'}), flush=True)
    br.send_text('!release')
    time.sleep(1.0)
    return msg.get('option') if msg else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['pick', 'chart-rows', 'sweep-single', 'cleanup',
                                     'open', 'release', 'answer', 'sweep-params'])
    ap.add_argument('--option', type=int, default=0)
    ap.add_argument('--mode-answer', default='update', choices=['update', 'end'])
    ap.add_argument('--param-sets', default='',
                    help='semicolon-separated param tuples, e.g. "2;3;0,2;0,0,1"')
    ap.add_argument('--shot-dir', default='/tmp')
    ap.add_argument('--display', default='3')
    ap.add_argument('--csid', type=int, default=9704)
    ap.add_argument('--params', default='0,1')
    ap.add_argument('--downs', type=int, default=0)
    ap.add_argument('--kis', default='')
    ap.add_argument('--host', default=os.environ.get('XIGAME_HOST', '127.0.0.1'))
    ap.add_argument('--port', type=int, default=int(os.environ.get('XIGAME_PORT', '27800')))
    args = ap.parse_args()

    params = [int(x) for x in args.params.split(',') if x != '']
    kis = [int(x) for x in args.kis.split(',') if x != '']
    br = Bridge(args.host, args.port)

    if args.mode == 'pick':
        opt = pick_row(br, args.csid, params, args.downs)
        print(json.dumps({'downs': args.downs, 'option': opt}))

    elif args.mode == 'chart-rows':
        for k in kis:
            br.send_text(f'!addkeyitem {k}')
            time.sleep(1.0)
        chart = {}
        for row, k in enumerate(kis):
            opt = pick_row(br, args.csid, params, row)
            chart[k] = opt
            print(json.dumps({'row': row + 1, 'ki': k, 'option': opt}), flush=True)
        for k in kis:
            br.send_text(f'!delkeyitem {k}')
            time.sleep(0.8)
        br.send_text('!release')
        print(json.dumps(chart))

    elif args.mode == 'sweep-single':
        results = {}
        for k in kis:
            br.send_text(f'!addkeyitem {k}')
            time.sleep(1.0)
            results[k] = pick_row(br, args.csid, params, 0)
            br.send_text(f'!delkeyitem {k}')
            time.sleep(0.8)
            print(json.dumps({'ki': k, 'option': results[k]}), flush=True)
        print(json.dumps(results))

    elif args.mode == 'cleanup':
        for k in kis:
            br.send_text(f'!delkeyitem {k}')
            time.sleep(0.6)
        br.send_text('!release')
        print(json.dumps({'cleaned': kis}))

    elif args.mode == 'open':
        # Open the event and LEAVE it up (caller screenshots), reporting the
        # event_in params. Does not release — use `release` mode after.
        ok = open_event(br, args.csid, params)
        msg = None
        if ok:
            # the event_in was consumed by open_event's wait; re-read inbox
            for m in getattr(br, 'inbox', []):
                if m.get('type') == 'event_in':
                    msg = m
                    break
        print(json.dumps({'opened': ok, 'event_in': msg}))

    elif args.mode == 'release':
        br.send_text('!release')
        print(json.dumps({'released': True}))

    elif args.mode == 'sweep-params':
        import subprocess as sp
        sets = [s for s in args.param_sets.split(';') if s != '']
        for idx, pset in enumerate(sets):
            plist = [int(x) for x in pset.split(',') if x != '']
            open_event(br, args.csid, plist)
            time.sleep(1.8)
            shot = f'{args.shot_dir}/sweep_{args.csid}_{idx}_{pset.replace(",", "-")}.png'
            sp.run(['screencapture', '-x', '-D', args.display, shot])
            br.send_text('!release')
            time.sleep(1.2)
            print(json.dumps({'set': pset, 'shot': shot}), flush=True)

    elif args.mode == 'answer':
        # Answer the currently-open event (server-side) and capture the reply
        # the client sends, without touching the keyboard.
        br.cmd({'cmd': 'answer', 'option': args.option, 'mode': args.mode_answer})
        msg = br.wait_for({'event_out', 'event_update', 'ack'}, time.time() + 10)
        print(json.dumps({'answer': args.option, 'reply': msg}))


if __name__ == '__main__':
    sys.exit(main())
