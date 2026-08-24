#!/usr/bin/env python3
"""Stop hook. Refuses to let a run end while the quest audit artifact is invalid.

The deny hook stops banned operations. It has held. What it cannot stop is the
run that reaches a real limitation, writes it up well, and ends the turn with the
work unfinished. That pattern is the reason this file exists, measured over three
weeks: 46 of 126 runs touched zero quest files and still closed with a 2,000 to
4,000 character report. Asking for 20 to 30 quests a run was restated about
twenty times and never held, because a request the model grades itself on is not
a constraint.

So the quota is not a number in a prompt any more. A run ends when
validate_quest_id_map.py passes. Exit 2 puts the failures back in front of the
model and the turn continues.

Scoped to the owner's sentinel, .claude/strict-read-mode, for the same reason the
search ban is: the database and systems agents share this repo and must be able
to finish a turn.

Stall escape. If the invalid count does not drop between two consecutive blocks,
the run is allowed to end and the stall is printed loudly. A gate that can loop
forever gets disabled by the first person it traps, which would cost more than it
saves. Forcing work while work is happening is the whole goal; trapping a genuine
dead end is not.
"""

import json
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]

SENTINEL = REPO / '.claude' / 'strict-read-mode'
VALIDATOR = REPO / 'tools' / 'coverage' / 'validate_quest_id_map.py'
STATE = REPO / 'tools' / 'coverage' / 'data' / '.progress_gate'


def read_last_count():
    try:
        return int(STATE.read_text(encoding='utf-8').strip())
    except (OSError, ValueError):
        return None


def write_count(value):
    try:
        STATE.write_text(f'{value}\n', encoding='utf-8')
    except OSError:
        pass


def main():
    try:
        payload = json.loads(sys.stdin.read())
    except (TypeError, ValueError):
        sys.exit(0)

    # Owner-controlled scope. Absent sentinel means this gate is off entirely.
    if not SENTINEL.exists():
        sys.exit(0)

    if not VALIDATOR.exists():
        sys.exit(0)

    result = subprocess.run(
        [sys.executable, str(VALIDATOR)],
        capture_output=True,
        text=True,
        cwd=str(REPO),
        check=False,
    )

    if result.returncode == 0:
        write_count(0)
        sys.exit(0)

    report = result.stdout.strip()
    invalid = report.count('\n  row ')
    previous = read_last_count()
    write_count(invalid)

    # No movement since the last block means this is a real dead end, not a
    # premature stop. Surface it to the owner rather than looping.
    if previous is not None and previous <= invalid and payload.get('stop_hook_active'):
        sys.stderr.write(
            'PROGRESS GATE STALLED. The invalid row count did not drop between '
            f'two blocks (was {previous}, now {invalid}). Allowing this run to '
            'end so the owner can look at it. This is the message to escalate, '
            'not to work around.\n'
        )
        sys.exit(0)

    sys.stderr.write(
        'The run cannot end yet. quest_id_map.tsv still has rows whose verdict '
        'does not match the evidence on disk.\n\n'
        f'{report}\n\n'
        'None of these are blocked on missing data. Fix the rows, then stop.\n'
        'Run tools/coverage/validate_quest_id_map.py yourself to check.\n'
    )
    sys.exit(2)


if __name__ == '__main__':
    main()
