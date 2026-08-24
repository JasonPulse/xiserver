#!/usr/bin/env python3
"""PreToolUse deny hook.

Reads a Claude Code tool call as JSON on stdin. Exit 2 with a message on stderr
blocks the call. Exit 0 allows it.

Two tiers, because several agents share this repo.

Tier 1 is unconditional and applies to every agent. It denies direct access to
the quest id table, and it denies any attempt to modify the strict-read sentinel
or this hook. The quest id table carries `+` and `Converted` comments inherited
from upstream. They describe upstream's codebase, were never verified in this
fork, and every agent that has opened that file has read them as proof this
server implements the quest. Making the file unreachable is the only measure
that has held.

Tier 2 is opt-in and denies searching. It is live only while the sentinel file
.claude/strict-read-mode exists. The owner creates and removes that file. The
database and systems agents need grep and must not be blocked when it is absent.

There is deliberately no escape hatch. No env var, no marker comment, no
allowlist, no force flag. The previous text-only ban on the quest id table had
one narrow carve-out and 60 accesses were routed through it. If this hook
over-blocks, the owner loosens it.
"""

import json
import os
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]

SENTINEL = REPO / '.claude' / 'strict-read-mode'
SELF = Path(__file__).resolve()

# Matching the joined path catches the absolute form, the repo-relative form and
# the bare `globals/quests.lua` in one comparison.
QUEST_TABLE_MARKER = os.path.join('globals', 'quests.lua')

PROTECTED_NAMES = (
    os.path.join('.claude', 'strict-read-mode'),
    os.path.join('.claude', 'settings.json'),
    os.path.join('tools', 'ci', 'hooks', 'deny_banned_ops.py'),
)

MUTATING_TOKENS = (
    'rm ', 'rm-', 'unlink', 'shred', 'truncate', 'mv ', 'cp ', 'dd ',
    'tee ', 'sed -i', 'chmod', 'chown', 'ln ', 'install ',
    'git checkout', 'git restore', 'git clean', '>',
)

SEARCH_TOKENS = (
    'grep', ' rg ', 'rg -', '|rg', 'git grep',
    're.finditer', 're.search', 're.findall',
)

QUEST_TABLE_MESSAGE = (
    'DENIED: scripts/globals/quests.lua is an id table only.\n'
    'Its `+` and `Converted` comments are upstream\'s claim about upstream\'s code. '
    'They were never verified in this fork and are not evidence that anything is '
    'implemented here.\n'
    'Read tools/coverage/data/ledger.tsv for implementation status, or '
    'tools/coverage/data/quest_id_map.tsv for ids joined to client ground truth.\n'
    'To add an id, run: tools/quests/add_quest_id.py <log_area> <ENUM_NAME> <id>'
)

PROTECTED_MESSAGE = (
    'DENIED: that path is the enforcement itself and agents cannot modify it.\n'
    '.claude/strict-read-mode is created and removed by the owner only. '
    'tools/ci/hooks/deny_banned_ops.py protects itself by design.\n'
    'If the hook over-blocks, ask the owner to loosen it.'
)

SEARCH_MESSAGE = (
    'DENIED: strict read mode is on (.claude/strict-read-mode exists), so searching '
    'is off.\n'
    'Read the file instead: `wc -l <file>` first, then `sed -n \'START,ENDp\' <file>`.\n'
    'If you genuinely need a sweep across many files, delegate it to a subagent. '
    'Subagents may search. You read.'
)


def blob(value):
    """Flatten any tool input to one searchable string."""
    if isinstance(value, str):
        return value

    try:
        return json.dumps(value, ensure_ascii=False)
    except (TypeError, ValueError):
        return str(value)


def touches_protected_path(text):
    return any(name in text for name in PROTECTED_NAMES)


def would_mutate(command):
    return any(token in command for token in MUTATING_TOKENS)


def deny(message):
    sys.stderr.write(message + '\n')
    sys.exit(2)


def main():
    raw = sys.stdin.read()

    try:
        payload = json.loads(raw)
    except (TypeError, ValueError):
        # A hook that hard-fails on framing would brick every tool call.
        sys.exit(0)

    tool = payload.get('tool_name') or ''
    tool_input = payload.get('tool_input')
    text = blob(tool_input)

    # Tier 1, unconditional.
    if QUEST_TABLE_MARKER in text:
        deny(QUEST_TABLE_MESSAGE)

    if tool in ('Write', 'Edit', 'MultiEdit', 'NotebookEdit'):
        target = ''

        if isinstance(tool_input, dict):
            target = str(tool_input.get('file_path') or tool_input.get('notebook_path') or '')

        if touches_protected_path(target):
            deny(PROTECTED_MESSAGE)

    if tool == 'Bash':
        command = ''

        if isinstance(tool_input, dict):
            command = str(tool_input.get('command') or '')

        if touches_protected_path(command) and would_mutate(command):
            deny(PROTECTED_MESSAGE)

        # Tier 2, only while the owner's sentinel is present.
        if SENTINEL.exists() and any(token in command for token in SEARCH_TOKENS):
            deny(SEARCH_MESSAGE)

    sys.exit(0)


if __name__ == '__main__':
    main()
