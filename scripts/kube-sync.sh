#!/usr/bin/env bash
# =============================================================================
# kube-sync.sh - Move ~/.kube configs between machines, ENCRYPTED
#
# Usage:
#   ./scripts/kube-sync.sh export   # ~/.kube/{config,*.yml,...} -> secrets/kube.tar.gpg
#   ./scripts/kube-sync.sh import   # secrets/kube.tar.gpg -> ~/.kube (backs up first)
#
# The kubeconfigs contain client private keys (client-key-data) and this repo
# is PUBLIC, so only the gpg-encrypted archive (AES256, passphrase) is ever
# written into the repo. Use a long, unique passphrase and keep it in
# 1Password - anyone with the passphrase gets cluster access.
#
# Run it in a real terminal: gpg asks for the passphrase interactively.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLOB="$DOTFILES_DIR/secrets/kube.tar.gpg"
KUBE_DIR="$HOME/.kube"

command -v gpg >/dev/null || { echo "gpg not installed (brew install gnupg / apt install gnupg)" >&2; exit 1; }
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null || true)}"

case "${1:-}" in
  export)
    [[ -d "$KUBE_DIR" ]] || { echo "No $KUBE_DIR" >&2; exit 1; }
    mkdir -p "$(dirname "$BLOB")"
    # Only kubeconfig files; skip caches, kubectx/kubens state, backups, junk.
    files=()
    while IFS= read -r f; do files+=("$f"); done < <(
      cd "$KUBE_DIR" && find . -maxdepth 1 -type f \
        ! -name '.DS_Store' ! -name 'kubectx' ! -name 'out.txt' \
        -exec grep -lq '^kind: Config' {} \; -print | sed 's#^\./##' | sort
    )
    [[ ${#files[@]} -gt 0 ]] || { echo "No kubeconfig files found in $KUBE_DIR" >&2; exit 1; }
    echo "Encrypting ${#files[@]} kubeconfig file(s): ${files[*]}"
    tmp="$(mktemp)"; trap 'rm -f "$tmp" "$tmp.gpg"' EXIT
    COPYFILE_DISABLE=1 tar -C "$KUBE_DIR" -czf "$tmp" "${files[@]}"
    gpg --batch --yes --pinentry-mode loopback --symmetric \
        --cipher-algo AES256 --s2k-digest-algo SHA512 --s2k-count 65011712 \
        --passphrase-fd 3 -o "$tmp.gpg" "$tmp" 3< <(
          read -rsp "Passphrase: " p1 </dev/tty; echo >/dev/tty
          read -rsp "Repeat passphrase: " p2 </dev/tty; echo >/dev/tty
          [[ -n "$p1" && "$p1" == "$p2" ]] || { echo "Passphrases empty or don't match" >&2; exit 1; }
          printf '%s' "$p1"
        )
    [[ -s "$tmp.gpg" ]] || { echo "Encryption failed, repo blob unchanged" >&2; exit 1; }
    mv "$tmp.gpg" "$BLOB"
    echo "Wrote $BLOB ($(wc -c < "$BLOB" | tr -d ' ') bytes)"
    ;;
  import)
    [[ -f "$BLOB" ]] || { echo "No encrypted kube archive at $BLOB" >&2; exit 1; }
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    gpg --decrypt --pinentry-mode loopback -o "$tmp/kube.tgz" "$BLOB"
    mkdir -p "$tmp/x" && tar -C "$tmp/x" -xzf "$tmp/kube.tgz"
    mkdir -p "$KUBE_DIR"; chmod 700 "$KUBE_DIR"
    backup="$KUBE_DIR/bak/$(date +%Y%m%d_%H%M%S)"
    for f in "$tmp/x"/*; do
      name="$(basename "$f")"
      if [[ -f "$KUBE_DIR/$name" ]] && ! cmp -s "$f" "$KUBE_DIR/$name"; then
        mkdir -p "$backup"; cp -p "$KUBE_DIR/$name" "$backup/"
      fi
      install -m 600 "$f" "$KUBE_DIR/$name"
      echo "  $KUBE_DIR/$name"
    done
    [[ -d "$backup" ]] && echo "Previous versions backed up to $backup"
    echo "Done. Current context: $(kubectl config current-context 2>/dev/null || echo '-')"
    ;;
  *)
    echo "Usage: $0 export|import" >&2; exit 1 ;;
esac
