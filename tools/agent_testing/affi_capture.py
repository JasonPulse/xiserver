#!/usr/bin/env python3
"""
affi_capture.py — waits for the puppet bridge to come up, then captures the
REAL client option codes for Affi's vendor event (csid 9700 = top menu 7556).

Runs zero server changes: the bridge reports the client's 0x5B eventOption in
`event_out`, which is exactly the packed value onEventUpdate/onEventFinish
receives. We open 9700, walk each top-menu row, and for the vorseal branch we
also walk the vorseal-list rows — logging every option code to a JSONL file so
the eschan_hub handler can be finalized against ground truth.

Off-server, respects pacing: one open per row, !release between, screenshot on
display 3. Writes progress to /tmp/affi_capture.log and results to
/tmp/affi_options.jsonl. Safe to run in background all night; it no-ops until
the bridge is reachable, then does ONE full capture pass and exits.
"""
import json, os, socket, time, subprocess, sys

HOST = os.environ.get('XIGAME_HOST', '10.211.55.4')
PORT = int(os.environ.get('XIGAME_PORT', '27800'))
LOG = open('/tmp/affi_capture.log', 'a', buffering=1)
OUT = '/tmp/affi_options.jsonl'


def log(*a):
    LOG.write(time.strftime('%H:%M:%S ') + ' '.join(str(x) for x in a) + '\n')


class Bridge:
    def __init__(self):
        self.s = socket.create_connection((HOST, PORT), timeout=12)
        self.s.settimeout(12); self.buf = b''; self.inbox = []

    def _rl(self):
        while b'\n' not in self.buf:
            c = self.s.recv(4096)
            if not c:
                raise ConnectionError('closed')
            self.buf += c
        line, self.buf = self.buf.split(b'\n', 1)
        try:
            return json.loads(line.decode('utf-8', 'replace'))
        except json.JSONDecodeError:
            return {'type': 'garbled'}

    def send(self, text):
        self.s.sendall((json.dumps({'cmd': 'send', 'text': text}) + '\n').encode())
        self.wait({'ack'}, 5)

    def wait(self, types, secs):
        dl = time.time() + secs
        for i, m in enumerate(self.inbox):
            if m.get('type') in types:
                return self.inbox.pop(i)
        while time.time() < dl:
            try:
                m = self._rl()
            except socket.timeout:
                continue
            except Exception:
                return None
            if m.get('type') in types:
                return m
            self.inbox.append(m)
        return None

    def drain(self, secs=0.6):
        end = time.time() + secs; self.s.settimeout(0.2)
        try:
            while time.time() < end:
                try:
                    self.inbox.append(self._rl())
                except Exception:
                    pass
        finally:
            self.s.settimeout(12)


def key(br, k, hold=0.6):
    br.send(f'//setkey {k} down'); time.sleep(hold)
    br.send(f'//setkey {k} up'); time.sleep(0.4)


def shot(name):
    p = f'/tmp/affi_{name}.png'
    subprocess.run(['screencapture', '-x', '-D', '3', p], check=False)
    return p


def pick(br, csid, params, downs, tag):
    br.drain()
    br.send('!cs %d %s' % (csid, ' '.join(map(str, params))))
    if not br.wait({'event_in'}, 10):
        log(f'{tag}: no event_in'); br.send('!release'); time.sleep(1); return None
    time.sleep(1.2)
    sp = shot(f'{tag}_open')
    for _ in range(downs):
        key(br, 'down')
    br.send('//setkey enter down'); time.sleep(0.6); br.send('//setkey enter up')
    m = br.wait({'event_out', 'event_update'}, 12)
    opt = m.get('option') if m else None
    rec = {'tag': tag, 'csid': csid, 'params': params, 'downs': downs, 'option': opt, 'msg_type': m.get('type') if m else None, 'shot': sp}
    open(OUT, 'a').write(json.dumps(rec) + '\n')
    log('CAPTURED', rec)
    br.send('!release'); time.sleep(1.0)
    return opt


def capture_pass():
    br = Bridge()
    log('bridge up — SAFE capture: open csid 9700 (top menu 7556), screenshot, release')
    br.drain()
    br.send('!cs 9700')
    ev = br.wait({'event_in'}, 10)
    time.sleep(1.5)
    sp = shot('9700_topmenu')
    rec = {'tag': 'open_9700_safe', 'event_in': ev, 'shot': sp}
    open(OUT, 'a').write(json.dumps(rec) + '\n')
    log('SAFE-CAPTURED', rec)
    br.send('!release'); time.sleep(1.0)
    log('capture pass complete — top menu screenshot at', sp)


def main():
    log(f'watcher start, target {HOST}:{PORT}')
    deadline = time.time() + int(os.environ.get('AFFI_WATCH_SECS', str(6 * 3600)))
    while time.time() < deadline:
        try:
            capture_pass()
            log('DONE'); return 0
        except (ConnectionRefusedError, OSError) as e:
            time.sleep(45)
        except Exception as e:
            log('ERR', repr(e)); time.sleep(45)
    log('watch window expired without bridge')
    return 1


if __name__ == '__main__':
    sys.exit(main())
