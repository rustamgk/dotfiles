#!/usr/bin/env bash
# =============================================================================
# zoxide-sync.sh - Move zoxide's directory ranking between machines
#
# Usage:
#   ./scripts/zoxide-sync.sh export   # zoxide db -> history/zoxide.txt
#   ./scripts/zoxide-sync.sh import   # history/zoxide.txt -> zoxide db
#
# zoxide's db.zo is binary and stores absolute paths (/Users/x/... on macOS,
# /home/x/... on Linux), so it can't be copied as-is. Export keeps only dirs
# under $HOME, stored as "~/rel/path<TAB>weight". Import re-adds each one with
# `zoxide add` (repeated `weight` times so the ranking order is kept). That
# works on any zoxide version.
#
# zoxide refuses dirs that don't exist, so import skips them. Clone your
# workspaces, then re-run import: dirs already imported are tracked in a
# marker file and never added twice.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DUMP="$DOTFILES_DIR/history/zoxide.txt"
ZO_DIR="${_ZO_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zoxide}"
[[ "$(uname)" == "Darwin" && -z "${_ZO_DATA_DIR:-}" ]] && ZO_DIR="$HOME/Library/Application Support/zoxide"
MARK="$ZO_DIR/.dotfiles-imported"

command -v zoxide >/dev/null || { echo "zoxide not installed" >&2; exit 1; }

case "${1:-}" in
  export)
    mkdir -p "$(dirname "$DUMP")"
    # `--score` is frecency (raw rank x recency bonus up to 4x); /4 brings it
    # back near the raw visit count so imported dirs don't drown new ones.
    zoxide query --list --score | awk -v home="$HOME" '
      {
        score = $1; sub(/^[ \t]*[0-9.]+[ \t]+/, ""); path = $0
        if (path == home || index(path, home "/") != 1) next
        w = int(score / 4 + 0.5); if (w < 1) w = 1
        printf "~%s\t%d\n", substr(path, length(home) + 1), w
      }' > "$DUMP"
    echo "Exported $(wc -l < "$DUMP" | tr -d ' ') dirs -> $DUMP"
    ;;
  import)
    [[ -f "$DUMP" ]] || { echo "No dump at $DUMP" >&2; exit 1; }
    mkdir -p "$ZO_DIR"; touch "$MARK"
    added=0 missing=0 done_before=0
    while IFS=$'\t' read -r rel weight; do
      dir="$HOME${rel#\~}"
      if grep -qxF "$dir" "$MARK"; then done_before=$((done_before + 1)); continue; fi
      if [[ ! -d "$dir" ]]; then missing=$((missing + 1)); continue; fi
      for ((i = 0; i < weight; i++)); do zoxide add "$dir"; done
      echo "$dir" >> "$MARK"
      added=$((added + 1))
    done < "$DUMP"
    echo "zoxide: imported $added, already imported $done_before, missing (re-run after cloning) $missing"
    ;;
  *)
    echo "Usage: $0 export|import" >&2; exit 1 ;;
esac
