#!/usr/bin/env bash
# =============================================================================
# history-export.sh - Dump ~/.zsh_history into the repo (sanitized + deduped)
#
# Usage:
#   ./scripts/history-export.sh                 # ~/.zsh_history -> history/zsh_history
#   ./scripts/history-export.sh SRC DST         # custom paths
#
# What it does:
#   - Parses zsh EXTENDED_HISTORY entries (": <ts>:<dur>;<cmd>", multi-line aware)
#   - DROPS any entry that looks like it carries a secret (tokens, passwords,
#     keys, creds-in-URL, JWTs, --from-literal, export FOO_TOKEN=..., etc.)
#   - Dedupes by command text, keeping the most recent occurrence
#   - Writes a file in the same zsh format, so install.sh can merge it into
#     ~/.zsh_history on a new machine (e.g. WSL2 Ubuntu)
#
# The scrubber is conservative but not perfect - ALWAYS review the diff before
# committing, especially since the repo is public:
#   git diff --no-index /dev/null history/zsh_history | less
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${1:-${HISTFILE:-$HOME/.zsh_history}}"
DST="${2:-$DOTFILES_DIR/history/zsh_history}"

[[ -f "$SRC" ]] || { echo "No history file at $SRC" >&2; exit 1; }
mkdir -p "$(dirname "$DST")"

python3 -I - "$SRC" "$DST" <<'PY'
import re, sys

src, dst = sys.argv[1], sys.argv[2]
raw = open(src, "rb").read()

# ---- Parse entries (zsh continues multi-line commands with a trailing "\") ----
head = re.compile(rb"^: (\d+):(\d+);")
entries = []  # [ts, dur, cmd_bytes]
for line in raw.split(b"\n"):
    m = head.match(line)
    if m:
        entries.append([int(m.group(1)), m.group(2), line[m.end():]])
    elif entries and entries[-1][2].endswith(b"\\"):
        # zsh's own rule: a line ending in "\" continues onto the next one.
        # Keep the bytes verbatim so zsh re-reads the entry identically.
        entries[-1][2] += b"\n" + line
    # anything else (stray lines, trailing "" from the final newline) is ignored

# ---- Secret detection: drop the whole entry on any hit ----
SECRET = [re.compile(p, re.I) for p in [
    rb"(pass(word|wd)?|pwd|secret|token|api[_-]?key|access[_-]?key|private[_-]?key|client[_-]?secret|credentials?|auth[_-]?key|sas|signature|connection[_-]?string)[a-z0-9_]*\s*[=:]\s*\S",
    rb"--(password|passwd|pass|token|secret|client-secret|api-key|access-key|secret-key|private-key|auth|sas-token|account-key|registry-password)\b",
    rb"\bexport\s+[a-z0-9_]*(key|token|secret|pass|pwd|auth|cred)[a-z0-9_]*=",
    rb"\b(authorization|x-api-key|x-auth-token|private-token|cookie)\s*:",
    rb"\bbearer\s+\S",
    rb"--from-literal",
    rb"\b(mysql|mariadb|mysqldump|mysqladmin)\b.*\s-p\S",
    rb"\b(curl|wget|http)\b.*\s(-u|--user)\s*\S+:\S+",
    rb"\b(docker|podman|helm|oras|crane)\s+(registry\s+)?login\b.*\s-p\b",
    rb"\b(sshpass|htpasswd|chpasswd)\b",
    rb"[a-z][a-z0-9+.-]*://[^/\s:@]+:[^/\s@]+@",          # user:pass@ in URLs
    rb"-----BEGIN [A-Z ]*PRIVATE KEY",
    rb"\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}",          # GitHub
    rb"github_pat_[A-Za-z0-9_]{20,}",
    rb"glpat-[A-Za-z0-9_-]{16,}",                           # GitLab
    rb"\b(AKIA|ASIA)[0-9A-Z]{16}\b",                        # AWS key id
    rb"xox[abprs]-[A-Za-z0-9-]{10,}",                       # Slack
    rb"\bsk-(ant-|proj-)?[A-Za-z0-9_-]{20,}",               # OpenAI / Anthropic
    rb"\bhv[sb]\.[A-Za-z0-9_-]{20,}",                       # Vault
    rb"\bAIza[0-9A-Za-z_-]{30,}",                           # Google API
    rb"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}",        # JWT
    rb"\bnpm_[A-Za-z0-9]{30,}",
    rb"\bAccountKey=",
    rb"--(value|secret-value|encoded-value|literal|key-value|sas)\b\s*[= ]\s*\S",  # az/kubectl secret set
    rb"[A-Za-z0-9_.-]{3,}~[A-Za-z0-9_.~-]{25,}",           # Entra ID client secret
    rb"\bvault\s+(operator\s+unseal|login)\s+[^\s\\-]",     # unseal key / token inline
    rb"\b(sig|sv|se|sp)=[^&\s]{8,}&",                       # Azure SAS query string
    rb"\b(op|pass|gopass)\s+(read|show|item get)\b.*--reveal",
]]
# Long opaque blobs (>=40 chars mixing letters+digits) that aren't paths/URLs
BLOB = re.compile(rb"(?<![/\w.-])[A-Za-z0-9+/_=~.-]{32,}(?![/\w.-])")
def looks_secret(cmd: bytes) -> bool:
    if any(p.search(cmd) for p in SECRET):
        return True
    for m in BLOB.finditer(cmd):
        s = m.group(0)
        if re.search(rb"[0-9]", s) and re.search(rb"[A-Za-z]", s):
            return True
    return False

# Trivial noise not worth carrying across machines
NOISE = re.compile(rb"^\s*(ls|ll|la|l|cd|cd \.\.|clear|c|exit|pwd|history|reload|exec zsh|q|:q|vim|nvim|htop|btop|k9s|z|j|gs|gd|\s*)\s*$")

kept, dropped_secret, dropped_noise = {}, 0, 0
for ts, dur, cmd in entries:
    if NOISE.match(cmd):
        dropped_noise += 1
        continue
    if looks_secret(cmd):
        dropped_secret += 1
        continue
    prev = kept.get(cmd)
    if prev is None or ts >= prev[0]:
        kept[cmd] = (ts, dur)

out = sorted(((ts, dur, cmd) for cmd, (ts, dur) in kept.items()), key=lambda x: x[0])
with open(dst, "wb") as f:
    for ts, dur, cmd in out:
        f.write(b": %d:%s;%s\n" % (ts, dur, cmd))

print(f"parsed:          {len(entries)}")
print(f"dropped secrets: {dropped_secret}")
print(f"dropped noise:   {dropped_noise}")
print(f"unique written:  {len(out)}  ->  {dst}")
PY

chmod 600 "$DST"
echo "Review before committing (public repo!): less $DST"
