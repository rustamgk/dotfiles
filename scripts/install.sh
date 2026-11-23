#!/usr/bin/env bash
# =============================================================================
# install.sh - Link dotfiles config files to $HOME
# Author: Rustam Galimyanov
# Repo: github.com/rustamgk/dotfiles
#
# Usage:
#   ./scripts/install.sh            # Interactive (asks before overwriting)
#   ./scripts/install.sh --force    # Overwrite existing files without asking
#   ./scripts/install.sh --dry-run  # Show what would be linked without doing it
# =============================================================================

set -euo pipefail

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[LINKED]${NC} $*"; }
log_skip()    { echo -e "${YELLOW}[SKIP]${NC} $*"; }
log_backup()  { echo -e "${CYAN}[BACKUP]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_dry()     { echo -e "${CYAN}[DRY-RUN]${NC} $*"; }

# ---- Parse args ----
FORCE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --force)   FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --help)
      echo "Usage: $0 [--force] [--dry-run]"
      echo "  --force    Overwrite existing dotfiles without asking"
      echo "  --dry-run  Show what would happen without doing it"
      exit 0
      ;;
  esac
done

# ---- Paths ----
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="$DOTFILES_DIR/configs"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Configs directory:  $CONFIGS_DIR"
[[ "$DRY_RUN" == "true" ]] && log_info "DRY RUN mode - no changes will be made"

# ---- Link function ----
link_file() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "$src -> $dst"
    return
  fi

  # Create parent dir if needed
  mkdir -p "$dst_dir"

  # Handle existing file/symlink
  if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
    # Already pointing to our file - skip
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
      log_skip "$dst (already linked)"
      return
    fi

    if [[ "$FORCE" == "true" ]]; then
      mkdir -p "$BACKUP_DIR"
      mv "$dst" "$BACKUP_DIR/"
      log_backup "Backed up existing $dst to $BACKUP_DIR/"
    else
      echo -e "${YELLOW}File exists:${NC} $dst"
      echo -n "  Overwrite? [Y/n/b(ackup)] "
      # Read from the terminal, not stdin: under `curl ... | bash` stdin is the
      # script itself, and `read` would swallow the next line of bootstrap.sh.
      # Empty answer (Enter) -> overwrite. No tty at all (CI/docker) -> skip.
      response=""
      if ! read -r response < /dev/tty 2>/dev/null; then
        response="n"
      fi
      case "$response" in
        ""|[yY])
          rm -rf "$dst"
          ;;
        [bB])
          mkdir -p "$BACKUP_DIR"
          mv "$dst" "$BACKUP_DIR/"
          log_backup "Backed up $dst"
          ;;
        *)
          log_skip "$dst"
          return
          ;;
      esac
    fi
  fi

  ln -sf "$src" "$dst"
  log_success "$dst -> $src"
}

# ---- Link config directory ----
link_dir() {
  local src="$1"
  local dst="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "$src -> $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      mkdir -p "$BACKUP_DIR"
      mv "$dst" "$BACKUP_DIR/"
      log_backup "Backed up $dst"
    else
      log_skip "$dst (directory exists, use --force to replace)"
      return
    fi
  elif [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    log_skip "$dst (already linked)"
    return
  fi

  ln -sf "$src" "$dst"
  log_success "$dst -> $src"
}

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  Linking dotfiles to \$HOME${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ============================================================================
# Shell configs
# ============================================================================
echo -e "${BLUE}--- Shell ---${NC}"
link_file "$CONFIGS_DIR/.zshrc"           "$HOME/.zshrc"
link_file "$CONFIGS_DIR/.tmux.conf"       "$HOME/.tmux.conf"
link_file "$CONFIGS_DIR/.tmux.base.conf"  "$HOME/.tmux.base.conf"
mkdir -p "$HOME/.tmux"
link_file "$CONFIGS_DIR/tmux/resurrect-guard.sh" "$HOME/.tmux/resurrect-guard.sh"
if [[ "$(uname -s)" == "Linux" ]] && command -v systemctl &>/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  link_file "$CONFIGS_DIR/systemd/tmux.service" "$HOME/.config/systemd/user/tmux.service"
  [[ "$DRY_RUN" == "true" ]] || systemctl --user daemon-reload 2>/dev/null || true
fi

# ============================================================================
# Git config
# ============================================================================
echo -e "\n${BLUE}--- Git ---${NC}"
link_file "$CONFIGS_DIR/.gitconfig" "$HOME/.gitconfig"

# Create a global gitignore if it doesn't exist
if [[ ! -f "$HOME/.gitignore_global" ]]; then
  if [[ "$DRY_RUN" == "false" ]]; then
    cat > "$HOME/.gitignore_global" << 'EOF'
# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db
Desktop.ini

# Editors
*.swp
*.swo
*~
.idea/
.vscode/settings.json
*.code-workspace

# Python
__pycache__/
*.py[cod]
.env
.venv
*.egg-info/

# Node
node_modules/
.npm

# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl

# Misc
*.log
*.pid
EOF
    log_success "Created $HOME/.gitignore_global"
  else
    log_dry "Would create $HOME/.gitignore_global"
  fi
fi

# ============================================================================
# Starship prompt
# ============================================================================
echo -e "\n${BLUE}--- Starship ---${NC}"
mkdir -p "$HOME/.config"
link_file "$CONFIGS_DIR/starship.toml" "$HOME/.config/starship.toml"

# ============================================================================
# Neovim config
# ============================================================================
echo -e "\n${BLUE}--- Neovim ---${NC}"
link_dir "$CONFIGS_DIR/nvim" "$HOME/.config/nvim"

# ============================================================================
# Kitty terminal
# ============================================================================
echo -e "\n${BLUE}--- Kitty ---${NC}"
mkdir -p "$HOME/.config/kitty"
link_file "$CONFIGS_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file "$CONFIGS_DIR/quick-access-terminal.conf" "$HOME/.config/kitty/quick-access-terminal.conf"

# ============================================================================
# Terminal themes (optional, only if relevant dirs exist)
# ============================================================================
echo -e "\n${BLUE}--- Terminal themes ---${NC}"
if [[ -d "$DOTFILES_DIR/themes" ]]; then
  log_info "Terminal theme files available in $DOTFILES_DIR/themes/"
  log_info "Apply manually based on your terminal emulator"
fi

# ============================================================================
# Create ~/.zshrc.local template if it doesn't exist
# ============================================================================
echo -e "\n${BLUE}--- Local config ---${NC}"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  if [[ "$DRY_RUN" == "false" ]]; then
    cat > "$HOME/.zshrc.local" << 'EOF'
# ~/.zshrc.local - Machine-specific configuration
# This file is NOT tracked in git - put secrets and local overrides here

# GitLab credentials
# export GITLAB_USER_NAME="rustam.galimyanov"
# export GITLAB_ACCESS_TOKEN="your-token-here"

# AWS credentials (prefer using aws configure or aws-vault)
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_DEFAULT_REGION="eu-central-1"

# Azure
# export AZURE_SUBSCRIPTION_ID=""

# Workspace shortcuts
# alias cdwork="z ~/workspace"

# Machine-specific PATH additions
# export PATH="$PATH:/path/to/custom/bin"
EOF
    log_success "Created ~/.zshrc.local template (fill in your secrets)"
  else
    log_dry "Would create $HOME/.zshrc.local template"
  fi
else
  log_skip "~/.zshrc.local already exists"
fi

# ============================================================================
# ZSH history - merge the sanitized dump from the repo (see history-export.sh)
# ============================================================================
echo -e "\n${BLUE}--- ZSH history ---${NC}"
HIST_DUMP="$DOTFILES_DIR/history/zsh_history"
HIST_FILE="$HOME/.zsh_history"
HIST_MARK="$HOME/.zsh_history.dotfiles-imported"
if [[ -f "$HIST_DUMP" ]]; then
  dump_sum="$(cksum < "$HIST_DUMP")"
  if [[ "$(cat "$HIST_MARK" 2>/dev/null)" == "$dump_sum" ]]; then
    log_skip "history dump already imported"
  elif [[ "$DRY_RUN" == "true" ]]; then
    log_dry "Would merge $HIST_DUMP into $HIST_FILE"
  else
    # Dump (older entries) first, then this machine's own history, so local
    # commands stay the most recent in Ctrl-R.
    tmp_hist="$(mktemp)"
    cat "$HIST_DUMP" > "$tmp_hist"
    [[ -f "$HIST_FILE" ]] && cat "$HIST_FILE" >> "$tmp_hist"
    [[ -f "$HIST_FILE" ]] && cp "$HIST_FILE" "$HIST_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    mv "$tmp_hist" "$HIST_FILE"
    chmod 600 "$HIST_FILE"
    echo "$dump_sum" > "$HIST_MARK"
    log_success "Merged $(grep -c '^: [0-9]' "$HIST_DUMP") history entries into $HIST_FILE"
  fi
else
  log_skip "no history dump at $HIST_DUMP"
fi

# ============================================================================
# zoxide ranking - re-add dirs from history/zoxide.txt (see zoxide-sync.sh)
# ============================================================================
echo -e "\n${BLUE}--- zoxide ---${NC}"
if [[ -f "$DOTFILES_DIR/history/zoxide.txt" ]] && command -v zoxide >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "Would import zoxide dirs from history/zoxide.txt"
  else
    bash "$DOTFILES_DIR/scripts/zoxide-sync.sh" import || true
  fi
else
  log_skip "zoxide import (no dump or zoxide not installed)"
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Dotfiles installed!${NC}"
echo -e "${GREEN}============================================${NC}"
if [[ -d "$BACKUP_DIR" ]]; then
  echo -e "\nBackups saved to: ${YELLOW}$BACKUP_DIR${NC}"
fi
echo -e "\nRun ${CYAN}exec zsh${NC} or open a new terminal to apply changes."
