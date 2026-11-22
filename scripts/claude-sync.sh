#!/usr/bin/env bash
# =============================================================================
# claude-sync.sh - Move Claude Code sessions + memory between machines, ENCRYPTED
#
# Usage:
#   ./scripts/claude-sync.sh export          # ~/.claude -> secrets/claude.part*.gpg (fresh snapshot)
#   ./scripts/claude-sync.sh import          # secrets/claude.part*.gpg -> ~/.claude
#   ./scripts/claude-sync.sh pull user@host  # copy straight from another machine over ssh (no repo)
#
# What is carried over:
#   ~/.claude/projects/        sessions (*.jsonl, used by --resume) + per-project memory/
#   ~/.claude/skills/ agents/ commands/ CLAUDE.md settings.json keybindings.json
#   ~/.claude/history.jsonl    prompt history (merged, not replaced)
#   ~/.claude.json             only .projects (trust/allowed tools) and .mcpServers
# Not carried: login (macOS Keychain / ~/.claude/.credentials.json -> run /login),
#   plugins/ (reinstalled from settings.json via /plugin), caches, file-history.
#
# Claude keys sessions by the absolute path of the folder you start it in
# (/Users/rustamgk/workspaces/_sarna -> projects/-Users-rustamgk-workspaces--sarna).
# On import the source $HOME is rewritten to this machine's $HOME, both in the
# folder names and inside the files, so ~/workspaces/_sarna on WSL
# (/home/rustamgk/...) sees the sessions made on the Mac. Repos must live at
# the same path relative to $HOME (and inside the Linux fs, not /mnt/c).
#
# Import never deletes anything: files that are newer locally are kept, and
# anything it overwrites is saved under ~/.claude-sync-backups/<timestamp>/.
#
# Sessions contain code, command output and possibly secrets, and this repo is
# PUBLIC, so only an AES256 passphrase-encrypted, xz-compressed archive is
# committed, split into <50MB parts (GitHub warns above 50MB, rejects >100MB).
# Every export is a new full blob in git history - snapshot when it's worth it.
#
# Passphrase: asked on the terminal, or taken from $CLAUDE_SYNC_PASSPHRASE.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="$DOTFILES_DIR/secrets"
PART_PREFIX="claude.part"          # secrets/claude.partaa.gpg, claude.partab.gpg, ...
PART_SIZE="45m"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_JSON="$HOME/.claude.json"
MANIFEST=".claude-sync-manifest"
PARTIAL_JSON=".claude-sync-claude.json"
# Top-level entries of ~/.claude that are synced (missing ones are skipped).
ITEMS=(projects skills agents commands CLAUDE.md settings.json keybindings.json history.jsonl)

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }
has_tty() { { : </dev/tty; } 2>/dev/null; }
need() { for c in "$@"; do command -v "$c" >/dev/null || die "$c not installed (brew/apt install $c)"; done; }

export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null || true)}"

# Claude's project-folder encoding: every non-alphanumeric char becomes '-'.
encode_path() { printf '%s' "$1" | sed 's/[^a-zA-Z0-9]/-/g'; }

ask_pass() {  # $1=confirm|once  -> sets PASS
  if [[ -n "${CLAUDE_SYNC_PASSPHRASE:-}" ]]; then PASS="$CLAUDE_SYNC_PASSPHRASE"; return; fi
  has_tty || die "No terminal for the passphrase; set CLAUDE_SYNC_PASSPHRASE"
  read -rsp "Passphrase: " PASS </dev/tty; echo >/dev/tty
  if [[ "$1" == confirm ]]; then
    local p2; read -rsp "Repeat passphrase: " p2 </dev/tty; echo >/dev/tty
    [[ "$PASS" == "$p2" ]] || die "Passphrases don't match"
  fi
  [[ -n "$PASS" ]] || die "Empty passphrase"
}

warn_if_running() {
  if pgrep -x claude >/dev/null 2>&1; then
    echo "WARNING: Claude Code is running. It rewrites ~/.claude.json on exit and may"
    echo "         be mid-write to a session. Quit all claude sessions for a clean sync."
    if has_tty && [[ -z "${CLAUDE_SYNC_YES:-}" ]]; then
      read -rp "Continue anyway? [y/N] " a </dev/tty; [[ "$a" == [yY]* ]] || exit 1
    fi
  fi
}

present_items() {  # prints the ITEMS that exist under $1
  local d="$1" i; for i in "${ITEMS[@]}"; do [[ -e "$d/$i" ]] && echo "$i"; done; return 0
}

# Rewrite $old -> $new in every file under the given paths that mentions it,
# keeping each file's mtime (so "newer file wins" on merge still means something).
rewrite_paths() {
  local old="$1" new="$2"; shift 2
  local files=() f
  while IFS= read -r -d '' f; do files+=("$f"); done < <(grep -rlF --null -- "$old" "$@" 2>/dev/null || true)
  [[ ${#files[@]} -gt 0 ]] || return 0
  info "Rewriting $old -> $new in ${#files[@]} file(s)"
  OLD="$old" NEW="$new" perl -e '
    my ($old, $new) = ($ENV{OLD}, $ENV{NEW});
    for my $f (@ARGV) {
      my @st = stat $f or next;
      open my $in, "<", $f or next; local $/; my $c = <$in>; close $in;
      # only whole path components: /Users/rustamgk, /Users/rustamgk/..., not /Users/rustamgkX
      $c =~ s/\Q$old\E(?![A-Za-z0-9_.-])/$new/g;
      open my $out, ">", $f or die "$f: $!"; print $out $c; close $out;
      utime $st[8], $st[9], $f;
    }' "${files[@]}"
}

# Install an unpacked tree ($1, laid out like ~/.claude plus the two sidecar
# files) that came from a machine whose $HOME was $2.
apply_tree() {
  local x="$1" src_home="$2"
  local ts backup; ts="$(date +%Y%m%d_%H%M%S)"; backup="$HOME/.claude-sync-backups/$ts"

  if [[ "$src_home" != "$HOME" ]]; then
    local old_enc new_enc d base
    old_enc="$(encode_path "$src_home")"; new_enc="$(encode_path "$HOME")"
    if [[ -d "$x/projects" ]]; then
      for d in "$x/projects/$old_enc" "$x/projects/$old_enc"-*; do
        [[ -d "$d" ]] || continue
        base="$(basename "$d")"; base="$new_enc${base#"$old_enc"}"
        if [[ -e "$x/projects/$base" ]]; then
          cp -Rp "$d/." "$x/projects/$base/" && rm -rf "$d"
        else
          mv "$d" "$x/projects/$base"
        fi
        echo "  projects/$(basename "$d") -> projects/$base"
      done
    fi
    local targets=(); while IFS= read -r i; do targets+=("$x/$i"); done < <(present_items "$x")
    [[ -f "$x/$PARTIAL_JSON" ]] && targets+=("$x/$PARTIAL_JSON")
    [[ ${#targets[@]} -gt 0 ]] && rewrite_paths "$src_home" "$HOME" "${targets[@]}"
  fi

  mkdir -p "$CLAUDE_DIR"; chmod 700 "$CLAUDE_DIR"

  # history.jsonl: union of both, ordered by timestamp
  if [[ -f "$x/history.jsonl" && -f "$CLAUDE_DIR/history.jsonl" ]]; then
    mkdir -p "$backup"; cp -p "$CLAUDE_DIR/history.jsonl" "$backup/"
    cat "$CLAUDE_DIR/history.jsonl" "$x/history.jsonl" \
      | jq -cs 'unique | sort_by(.timestamp // 0) | .[]' > "$x/history.merged"
    mv "$x/history.merged" "$x/history.jsonl"
    touch "$x/history.jsonl"
  fi

  # Everything else: copy in, keep files that are newer locally, back up what we replace.
  local items=(); while IFS= read -r i; do items+=("$i"); done < <(present_items "$x")
  if [[ ${#items[@]} -gt 0 ]]; then
    info "Merging into $CLAUDE_DIR: ${items[*]}"
    (cd "$x" && rsync -a --update --backup --backup-dir="$backup/claude" "${items[@]}" "$CLAUDE_DIR/")
  fi

  # ~/.claude.json: add snapshot's projects/mcpServers; local entries win.
  if [[ -f "$x/$PARTIAL_JSON" ]]; then
    if [[ -f "$CLAUDE_JSON" ]]; then
      mkdir -p "$backup"; cp -p "$CLAUDE_JSON" "$backup/claude.json"
      jq -s '.[0] as $l | .[1] as $s | $l + {
               projects:   (($s.projects   // {}) * ($l.projects   // {})),
               mcpServers: (($s.mcpServers // {}) * ($l.mcpServers // {}))
             }' "$CLAUDE_JSON" "$x/$PARTIAL_JSON" > "$x/claude.json.new"
    else
      cp "$x/$PARTIAL_JSON" "$x/claude.json.new"
    fi
    install -m 600 "$x/claude.json.new" "$CLAUDE_JSON"
    info "Merged projects + mcpServers into $CLAUDE_JSON"
  fi

  [[ -d "$backup" ]] && echo "Replaced files backed up to $backup"
  local n; n="$(find "$CLAUDE_DIR/projects" -maxdepth 2 -name '*.jsonl' 2>/dev/null | wc -l | tr -d ' ')"
  echo "Done: $n session(s) in $CLAUDE_DIR/projects:"
  ls -1 "$CLAUDE_DIR/projects" 2>/dev/null | sed 's/^/  /'
  echo
  echo "Next: run 'claude', then /login (credentials are not synced) and /plugin to"
  echo "reinstall enabled plugins. Check MCP servers in ~/.claude.json for host-only commands."
}

case "${1:-}" in
  export)
    need tar xz gpg split jq
    [[ -d "$CLAUDE_DIR" ]] || die "No $CLAUDE_DIR"
    warn_if_running
    items=(); while IFS= read -r i; do items+=("$i"); done < <(present_items "$CLAUDE_DIR")
    [[ ${#items[@]} -gt 0 ]] || die "Nothing to export in $CLAUDE_DIR"
    ask_pass confirm

    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/meta" "$tmp/out"
    {
      echo "SRC_HOME=$HOME"
      echo "SRC_HOST=$(hostname -s 2>/dev/null || hostname)"
      echo "SRC_OS=$(uname -s)"
      echo "CREATED=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    } > "$tmp/meta/$MANIFEST"
    if [[ -f "$CLAUDE_JSON" ]]; then
      jq '{projects: (.projects // {}), mcpServers: (.mcpServers // {})}' "$CLAUDE_JSON" > "$tmp/meta/$PARTIAL_JSON"
    fi

    info "Packing ${items[*]} from $CLAUDE_DIR ($(du -sh "$CLAUDE_DIR/projects" 2>/dev/null | cut -f1) of projects)..."
    tar_opts=(--exclude '.DS_Store')
    [[ "$(uname -s)" == Darwin ]] && tar_opts+=(--no-xattrs --no-mac-metadata)  # no Apple pax headers
    COPYFILE_DISABLE=1 tar -cf - "${tar_opts[@]}" \
        -C "$tmp/meta" . -C "$CLAUDE_DIR" "${items[@]}" \
      | xz -6 -T0 \
      | gpg --batch --yes --pinentry-mode loopback --symmetric --compress-algo none \
            --cipher-algo AES256 --s2k-digest-algo SHA512 --s2k-count 65011712 \
            --passphrase-fd 3 3< <(printf '%s' "$PASS") \
      | split -b "$PART_SIZE" - "$tmp/out/$PART_PREFIX"

    parts=("$tmp/out/$PART_PREFIX"*)
    [[ -s "${parts[0]}" ]] || die "Encryption failed, repo snapshot unchanged"
    mkdir -p "$SECRETS_DIR"
    rm -f "$SECRETS_DIR/$PART_PREFIX"*.gpg
    for p in "${parts[@]}"; do mv "$p" "$SECRETS_DIR/$(basename "$p").gpg"; done
    echo "Wrote ${#parts[@]} part(s), $(cat "$SECRETS_DIR/$PART_PREFIX"*.gpg | wc -c | awk '{printf "%.1f MB", $1/1048576}'):"
    ls -1 "$SECRETS_DIR/$PART_PREFIX"*.gpg | sed "s#^$DOTFILES_DIR/#  #"
    echo "Commit:  git add secrets/ && git commit -m 'sync: claude sessions snapshot' && git push"
    ;;

  import)
    need tar xz gpg jq rsync perl
    parts=("$SECRETS_DIR/$PART_PREFIX"*.gpg)
    [[ -f "${parts[0]}" ]] || die "No snapshot at $SECRETS_DIR/${PART_PREFIX}*.gpg (run export on the source machine)"
    warn_if_running
    ask_pass once
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/x"
    info "Decrypting ${#parts[@]} part(s)..."
    cat "${parts[@]}" \
      | gpg --batch --quiet --pinentry-mode loopback --decrypt --passphrase-fd 3 3< <(printf '%s' "$PASS") \
      | xz -d | tar -C "$tmp/x" -xf - \
      || die "Decrypt/unpack failed (wrong passphrase?) - nothing changed"
    src_home="$(sed -n 's/^SRC_HOME=//p' "$tmp/x/$MANIFEST")"
    [[ -n "$src_home" ]] || die "Snapshot has no manifest"
    echo "Snapshot: $(tr '\n' ' ' < "$tmp/x/$MANIFEST")"
    apply_tree "$tmp/x" "$src_home"
    ;;

  pull)
    need rsync ssh jq perl
    host="${2:-}"; [[ -n "$host" ]] || die "Usage: $0 pull user@host"
    warn_if_running
    src_home="$(ssh "$host" 'printf %s "$HOME"')"
    [[ -n "$src_home" ]] || die "Could not read \$HOME on $host"
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/x"
    incl=(); for i in "${ITEMS[@]}"; do incl+=(--include="/$i" --include="/$i/***"); done
    info "Copying $host:$src_home/.claude ..."
    rsync -az --exclude='.DS_Store' "${incl[@]}" --exclude='*' "$host:.claude/" "$tmp/x/"
    if scp -q "$host:.claude.json" "$tmp/claude.json" 2>/dev/null; then
      jq '{projects: (.projects // {}), mcpServers: (.mcpServers // {})}' "$tmp/claude.json" > "$tmp/x/$PARTIAL_JSON"
    fi
    apply_tree "$tmp/x" "$src_home"
    ;;

  *)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 1 ;;
esac
