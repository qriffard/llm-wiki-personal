#!/usr/bin/env bash
# SessionStart: make sure the obsidian-wiki framework is installed and pointed
# at brain/, verify the vault, and inject its memory recap into the session.
#   1. install `obsidian-wiki` if missing (cloud containers only — on a laptop
#      it prints the install command instead of touching the system Python);
#   2. run `obsidian-wiki setup` when the config doesn't point at this vault
#      (or the installed version changed). Framework session hooks are NOT
#      registered: hooks added mid-SessionStart don't fire in this session, and
#      the Stop capture hook would push session chatter into brain/ via
#      sync-wiki.sh. Step 4 replaces the SessionStart recap hook;
#   3. `doctor` + `lint`: one line of context on failure, silent otherwise;
#   4. print `memory recap` (stdout is added to the session context).
# Never fails the session.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
VAULT="$ROOT/brain"
[ -d "$VAULT" ] || exit 0
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian-wiki/config"

if ! command -v obsidian-wiki >/dev/null 2>&1; then
  if [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]; then
    pip install -q obsidian-wiki >/dev/null 2>&1 \
      || pip install -q --break-system-packages obsidian-wiki >/dev/null 2>&1
  fi
  if ! command -v obsidian-wiki >/dev/null 2>&1; then
    echo "obsidian-wiki is not installed; /wiki-* skills won't work. Install: pip install obsidian-wiki && obsidian-wiki setup --vault \"$VAULT\" --no-hooks" >&2
    exit 0
  fi
fi

version="$(obsidian-wiki --version 2>/dev/null | awk '{print $2}')"
if ! grep -qxF "OBSIDIAN_VAULT_PATH=\"$VAULT\"" "$CONFIG" 2>/dev/null \
   || ! grep -qxF "OBSIDIAN_WIKI_VERSION=\"$version\"" "$CONFIG" 2>/dev/null; then
  obsidian-wiki setup --vault "$VAULT" --no-hooks </dev/null >/dev/null 2>&1 \
    || echo "obsidian-wiki setup failed; run: obsidian-wiki setup --vault \"$VAULT\" --no-hooks" >&2
fi

# doctor's session-hooks check fails by design (see step 2); judge the rest.
problems="$(obsidian-wiki doctor 2>/dev/null | grep -E '^(❌|⚠️)' | grep -v 'session-hooks')"
lint_status="$(obsidian-wiki lint "$VAULT" 2>/dev/null | head -1)"
if [ -n "$problems" ] || [ "$lint_status" = "obsidian-wiki lint: fail" ]; then
  echo "⚠️ brain/ vault check: ${problems:+doctor: $(echo "$problems" | tr '\n' ' ')}${lint_status} — run 'obsidian-wiki doctor' and 'obsidian-wiki lint brain'."
fi

obsidian-wiki memory recap --vault "$VAULT" 2>/dev/null
exit 0
