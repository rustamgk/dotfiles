#!/usr/bin/env bash
# tmux-resurrect post-save-layout hook: $1 is the save file just written.
#
# If the tmux server died mid-save (WSL shutdown, kill-server) the file has no
# pane lines. Resurrect would still point `last` at it, and restoring an empty
# save kills session 0, which exits tmux. Copy the previous save over it
# instead; resurrect then sees "no change", deletes it and keeps `last` as is.
save_file="$1"
last="$(dirname "$save_file")/last"

[[ -f "$save_file" ]] || exit 0
grep -q '^pane' "$save_file" && exit 0

prev="$(readlink -f "$last" 2>/dev/null)"
if [[ -n "$prev" && -s "$prev" && "$prev" != "$(readlink -f "$save_file")" ]]; then
  cat "$prev" > "$save_file"
fi
