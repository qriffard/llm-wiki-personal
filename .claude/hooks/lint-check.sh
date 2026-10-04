#!/usr/bin/env bash
# SessionStart hook: nudge when a lint (health-check) pass is overdue.
# Counts ingest-type entries in brain/log.md since the last LINT entry; past the
# threshold it prints a notice, which Claude Code adds to the session context.
# This hook only DETECTS and REMINDS; the pass itself is `/wiki-lint`.
set -uo pipefail

LOG="${CLAUDE_PROJECT_DIR:-$PWD}/brain/log.md"
[ -f "$LOG" ] || exit 0

THRESHOLD=10

# obsidian-wiki log lines look like:  - [2026-10-04T19:55:52Z] INGEST source=...
#                                      - [2026-10-04T20:10:00Z] LINT issues_found=...
last_lint=$(grep -n '^- \[[^]]*\] LINT\b' "$LOG" | tail -1 | cut -d: -f1)
ingests=$(tail -n +"$(( ${last_lint:-0} + 1 ))" "$LOG" \
  | grep -cE '^- \[[^]]*\] ([A-Z_]*INGEST|CAPTURE|IMPORT|WIKI_UPDATE)\b')

if [ "${ingests:-0}" -ge "$THRESHOLD" ]; then
  echo "⚠️ Lint due: ${ingests} ingests since the last health check. Run /wiki-lint on brain/ before continuing."
fi

exit 0
