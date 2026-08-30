#!/usr/bin/env bash
# SessionStart: register the qriffard/personal-skills marketplace and enable its
# plugins in this container's ~/.claude/settings.json. Remote sessions run in
# ephemeral containers, so this file otherwise wouldn't survive between
# sessions -- this hook re-applies it every startup. Deep-merges via jq so any
# other keys already in settings.json (or added later by other hooks/tools)
# are preserved, and it's safe to run repeatedly.
set -uo pipefail

# Only meaningful on Claude Code on the web / remote containers.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

command -v jq >/dev/null 2>&1 || exit 0

SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

FRAGMENT='{
  "extraKnownMarketplaces": {
    "personal-skills": {
      "source": { "source": "git", "url": "https://github.com/qriffard/personal-skills" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "llm-wiki@personal-skills": true,
    "data-viz-design@personal-skills": true,
    "diagnose-network-latency@personal-skills": true,
    "llm-council@personal-skills": true,
    "session-handoff@personal-skills": true,
    "everything-tracker@personal-skills": true,
    "storm-research@personal-skills": true,
    "agent-practice-audit@personal-skills": true,
    "find-research-papers@personal-skills": true
  }
}'

TMP="$(mktemp)"
if jq -s '.[0] * .[1]' "$SETTINGS" <(echo "$FRAGMENT") > "$TMP" 2>/dev/null && jq -e . "$TMP" >/dev/null 2>&1; then
  mv "$TMP" "$SETTINGS"
else
  rm -f "$TMP"
  echo "register-personal-skills: failed to merge into $SETTINGS (invalid JSON?) -- left untouched." >&2
fi
exit 0
