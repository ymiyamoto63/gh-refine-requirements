#!/usr/bin/env bash
# Installs the refine-requirements skill.
#   ./tools/install.sh                                -> Claude Code (~/.claude/skills/)
#   ./tools/install.sh --copilot-target <repo-root>   -> also copy into <repo-root>/.github/skills/
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

copilot_target=""
if [[ "${1:-}" == "--copilot-target" ]]; then
  copilot_target="${2:?usage: $0 [--copilot-target <repo-root>]}"
elif [[ $# -gt 0 ]]; then
  echo "usage: $0 [--copilot-target <repo-root>]" >&2
  exit 2
fi

claude_dest="$HOME/.claude/skills/refine-requirements"
mkdir -p "$claude_dest"
cp -R skills/refine-requirements/. "$claude_dest/"
echo "Installed for Claude Code: $claude_dest (restart Claude Code to pick it up)"

if [[ -n "$copilot_target" ]]; then
  [[ -d "$copilot_target" ]] || { echo "Copilot target not found: $copilot_target" >&2; exit 1; }
  copilot_dest="$copilot_target/.github/skills/refine-requirements"
  mkdir -p "$copilot_dest"
  cp -R skills/refine-requirements/. "$copilot_dest/"
  echo "Installed for GitHub Copilot: $copilot_dest"
fi
