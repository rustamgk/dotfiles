#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh - Bootstrap macOS / Ubuntu Desktop / WSL2
# Author: Rustam Galimyanov
# Repo: github.com/rustamgk/dotfiles
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rustamgk/dotfiles/master/scripts/bootstrap.sh | bash
#   -- OR --
#   git clone https://github.com/rustamgk/dotfiles.git ~/github/dotfiles
#   cd ~/github/dotfiles && ./scripts/bootstrap.sh
#
# Flags:
#   --skip-packages, --dotfiles-only   Skip Homebrew/apt/tool installation and
#                                       only clone + symlink the dotfiles.
#                                       (curl ... | bash -s -- --skip-packages)
#                                       Same effect as SKIP_PACKAGES=true env var.
#
# Supports:
#   - macOS 13+ (Apple Silicon M1/M2/M3 & Intel)
#   - Ubuntu 22.04+ / 24.04+ / 25.10 (native desktop)
#   - WSL2 Ubuntu
# =============================================================================

set -euo pipefail

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---- Logging ----
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_section() { echo -e "\n${CYAN}===== $* =====${NC}"; }

# ---- Check if command exists ----
has() { command -v "$1" &>/dev/null; }

# ---- Run with sudo if needed ----
SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

# ---- Dotfiles directory ----
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/github/dotfiles}"

# ---- Flags ----
SKIP_PACKAGES="${SKIP_PACKAGES:-false}"

for arg in "$@"; do
  case "$arg" in
    --skip-packages|--dotfiles-only)
      SKIP_PACKAGES=true
      ;;
    -h|--help)
      echo "Usage: bootstrap.sh [--skip-packages|--dotfiles-only]"
      echo "  --skip-packages, --dotfiles-only   Skip tool installation, only clone + symlink dotfiles"
      exit 0
      ;;
    *)
      log_warn "Unknown argument: $arg"
      ;;
  esac
done

# ============================================================================
# OS Detection
# ============================================================================
IS_MACOS=false
IS_LINUX=false
IS_WSL=false

if [[ "$(uname)" == "Darwin" ]]; then
  IS_MACOS=true
  log_info "Detected macOS $(sw_vers -productVersion) on $(uname -m)"
  if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi
elif grep -qi microsoft /proc/version 2>/dev/null; then
  IS_LINUX=true
  IS_WSL=true
  log_info "Detected WSL2 Ubuntu"
else
  IS_LINUX=true
  log_info "Detected native Linux $(lsb_release -ds 2>/dev/null || uname -r)"
fi

# ---- Brew packages shared between macOS Homebrew and Linuxbrew ----
COMMON_BREW_PACKAGES=(
  k9s
  kubectx
  lazygit
  eza
  git-delta
  saml2aws
  argocd
  fluxcd/tap/flux
  popeye
  websocat
  ranger
  kustomize
  openvpn
  stern
  awscli
  azure-cli
)

# ---- macOS-only GUI apps (Homebrew casks) ----
MACOS_CASK_PACKAGES=(
  kitty
  docker-desktop
  1password-cli
)

if [[ "$SKIP_PACKAGES" == "true" ]]; then
  log_section "Skipping package/tool installation (--skip-packages)"
else

# ============================================================================
# 1. macOS: Xcode CLT + Homebrew
# ============================================================================
if [[ "$IS_MACOS" == "true" ]]; then
  log_section "macOS: Xcode Command Line Tools"
  if ! xcode-select -p &>/dev/null; then
    log_warn "Xcode CLT not found. Starting installation..."
    xcode-select --install 2>/dev/null || true
    log_warn "Waiting for the CLT installation dialog to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    log_success "Xcode CLT installation finished"
  fi
  log_success "Xcode CLT: $(xcode-select -p)"

  log_section "macOS: Homebrew"
  if ! has brew; then
    log_info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    log_success "Homebrew installed"
  else
    log_info "Homebrew already installed, updating..."
    brew update --quiet
    eval "$(brew shellenv)"
  fi
  log_success "Homebrew: $(brew --version | head -1)"
fi

# ============================================================================
# 2. Linux: System packages (apt)
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Linux: System packages (apt)"

  $SUDO apt-get update -qq

  log_info "Adding apt repositories..."

  # GitHub CLI
  if ! has gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | $SUDO tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  fi

  # Neovim PPA (stable)
  if ! has nvim; then
    $SUDO add-apt-repository -y ppa:neovim-ppa/stable 2>/dev/null || true
  fi

  $SUDO apt-get update -qq

  APT_PACKAGES=(
    zsh zsh-autosuggestions zsh-syntax-highlighting
    tmux neovim
    git git-lfs gh
    build-essential cmake pkg-config
    fzf ripgrep fd-find bat autojump zoxide tree
    mc unzip zip p7zip-full
    curl wget net-tools dnsutils
    htop btop
    jq yq
    cowsay fortune-mod lolcat
    python3 python3-pip python3-venv python3-dev
    ansible
    golang-go nodejs npm
    libssl-dev fontconfig
    stow xclip xsel
  )

  log_info "Installing apt packages..."
  $SUDO apt-get install -y "${APT_PACKAGES[@]}" 2>&1 | grep -E "^(Setting up|E:|W:)" || true
  log_success "Apt packages installed"
fi

# ============================================================================
# 3. Linux: Linuxbrew
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Linux: Linuxbrew"

  if [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    log_info "Installing Homebrew for Linux..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_success "Linuxbrew installed"
  else
    log_info "Linuxbrew already installed, updating..."
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew update --quiet
  fi

  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ============================================================================
# 4. macOS: All Homebrew packages
# ============================================================================
if [[ "$IS_MACOS" == "true" ]]; then
  log_section "macOS: Homebrew packages"

  MACOS_BREW_PACKAGES=(
    # Shell & terminal
    zsh tmux neovim
    # Version control
    git git-lfs gh
    # Build tools
    cmake pkg-config
    # Search & navigation
    fzf ripgrep fd bat autojump zoxide tree
    # File tools
    mc p7zip ranger
    # Network & process
    wget htop btop
    # Data tools
    jq yq
    # Fun stuff
    cowsay fortune lolcat
    # DevOps / Kubernetes (macOS gets kubectl/helm/tf here, not separately)
    kubectl helm terraform
    # Go (brew manages on macOS; pyenv/nvm handle Python/Node versions)
    go
    # Ansible
    ansible
    # Build deps for pyenv
    openssl readline xz zlib
    # Common devops tools
    "${COMMON_BREW_PACKAGES[@]}"
  )

  log_info "Installing Homebrew packages (this may take a few minutes)..."
  for pkg in "${MACOS_BREW_PACKAGES[@]}"; do
    formula_name="${pkg##*/}"     # strip tap prefix e.g. fluxcd/tap/flux -> flux
    formula_name="${formula_name%@*}"  # strip version e.g. node@20 -> node
    if brew list "$formula_name" &>/dev/null 2>&1; then
      log_info "brew: $formula_name already installed"
    else
      log_info "brew: installing $formula_name..."
      brew install "$pkg" 2>&1 | tail -1 || log_warn "Failed to install: $pkg"
    fi
  done
  log_success "macOS brew packages installed"

  log_info "Installing GUI apps (Homebrew casks)..."
  for pkg in "${MACOS_CASK_PACKAGES[@]}"; do
    if brew list --cask "$pkg" &>/dev/null 2>&1; then
      log_info "brew cask: $pkg already installed"
    else
      log_info "brew cask: installing $pkg..."
      brew install --cask "$pkg" 2>&1 | tail -1 || log_warn "Failed to install: $pkg"
    fi
  done
  log_success "macOS casks installed"
fi

# ============================================================================
# 5. Linux: DevOps tools via Linuxbrew
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Linux: DevOps tools (Linuxbrew)"

  for pkg in "${COMMON_BREW_PACKAGES[@]}"; do
    formula="${pkg##*/}"
    if brew list "$formula" &>/dev/null 2>&1; then
      log_info "brew: $formula already installed"
    else
      log_info "brew: installing $formula..."
      brew install "$pkg" 2>&1 | tail -1 || log_warn "Failed: $pkg"
    fi
  done
  log_success "Linuxbrew packages installed"
fi

# ============================================================================
# 6. Linux: kubectl
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "kubectl"

  if ! has kubectl; then
    log_info "Downloading kubectl..."
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    $SUDO install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log_success "kubectl ${KUBECTL_VERSION} installed"
  else
    log_info "kubectl already installed: $(kubectl version --client --short 2>/dev/null || true)"
  fi
fi

# ============================================================================
# 7. Linux: Helm
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Helm"

  if ! has helm; then
    log_info "Installing helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "Helm installed"
  else
    log_info "Helm already installed: $(helm version --short 2>/dev/null || true)"
  fi
fi

# ============================================================================
# 8. Linux: Terraform (via Linuxbrew)
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Terraform"

  if ! has terraform; then
    brew install terraform
    log_success "Terraform installed"
  else
    log_info "Terraform already installed"
  fi
fi

# ============================================================================
# 9. Starship prompt (both platforms)
# ============================================================================
log_section "Starship prompt"

if ! has starship; then
  log_info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  log_success "Starship installed"
else
  log_info "Starship already installed: $(starship --version 2>/dev/null | head -1)"
fi

# ============================================================================
# 10. Oh My ZSH + plugins (both platforms)
# ============================================================================
log_section "Oh My ZSH"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_info "Installing Oh My ZSH..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log_success "Oh My ZSH installed"
else
  log_info "Oh My ZSH already installed, updating..."
  git -C "$HOME/.oh-my-zsh" pull --quiet origin master 2>/dev/null || true
fi

OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$OMZ_CUSTOM/plugins/fzf-tab" ]]; then
  log_info "Installing fzf-tab plugin..."
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$OMZ_CUSTOM/plugins/fzf-tab"
  log_success "fzf-tab installed"
else
  log_info "fzf-tab already installed"
fi

if [[ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    mkdir -p "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
    ln -sf /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
      "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
    log_success "zsh-syntax-highlighting linked from system package"
  else
    log_info "Installing zsh-syntax-highlighting plugin..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
  fi
else
  log_info "zsh-syntax-highlighting already installed"
fi

# ============================================================================
# 11. pyenv + Python (both platforms)
# ============================================================================
log_section "pyenv + Python"

if [[ ! -d "$HOME/.pyenv" ]]; then
  log_info "Installing pyenv..."
  curl -fsSL https://pyenv.run | bash
  log_success "pyenv installed"
else
  log_info "pyenv already installed"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

PYTHON_VERSION="3.12.9"
if ! pyenv versions 2>/dev/null | grep -q "$PYTHON_VERSION"; then
  log_info "Installing Python $PYTHON_VERSION via pyenv..."
  pyenv install "$PYTHON_VERSION" 2>&1 | tail -3
  pyenv global "$PYTHON_VERSION"
  log_success "Python $PYTHON_VERSION installed"
else
  log_info "Python $PYTHON_VERSION already installed"
fi

# ============================================================================
# 12. nvm + Node.js (both platforms)
# ============================================================================
log_section "nvm + Node.js"

NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  log_success "nvm installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! nvm ls 20 &>/dev/null 2>&1; then
  log_info "Installing Node.js 20 LTS via nvm..."
  nvm install 20
  nvm use 20
  nvm alias default 20
  log_success "Node.js 20 LTS installed"
else
  log_info "Node.js 20 already installed via nvm"
fi

# ============================================================================
# 13. Rust / Cargo (both platforms)
# ============================================================================
log_section "Rust"

if ! has rustc; then
  log_info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  log_success "Rust installed"
else
  log_info "Rust already installed: $(rustc --version 2>/dev/null)"
fi

export PATH="$HOME/.cargo/bin:$PATH"

CARGO_TOOLS=(trashy)
for tool in "${CARGO_TOOLS[@]}"; do
  if has "$tool"; then
    log_info "cargo: $tool already installed"
  else
    log_info "cargo: installing $tool..."
    cargo install "$tool" 2>&1 | tail -2 || log_warn "Failed: $tool"
  fi
done

# ============================================================================
# 14. kubech (both platforms)
# ============================================================================
log_section "kubech"

if [[ ! -d "$HOME/.kubech" ]]; then
  log_info "Installing kubech..."
  git clone --depth 1 https://github.com/0xMALVEE/kubech.git "$HOME/.kubech"
  log_success "kubech installed"
else
  log_info "kubech already installed"
fi

# ============================================================================
# 15. FZF (from source — ensures shell integrations/key bindings)
# ============================================================================
log_section "FZF (from source)"

if [[ ! -d "$HOME/.fzf" ]]; then
  log_info "Installing fzf from source..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
  log_success "fzf installed from source"
else
  log_info "fzf source already present"
fi

# ============================================================================
# 16. Tmux Plugin Manager (both platforms)
# ============================================================================
log_section "Tmux Plugin Manager"

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  log_info "Installing TPM..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  log_success "TPM installed"
else
  log_info "TPM already installed"
fi

# ============================================================================
# 17. Nerd Fonts — JetBrainsMono
# ============================================================================
log_section "Nerd Fonts (JetBrainsMono)"

FONT_VERSION="v3.3.0"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"

if [[ "$IS_MACOS" == "true" ]]; then
  FONT_DIR="$HOME/Library/Fonts"
  mkdir -p "$FONT_DIR"
  FONT_COUNT=$(ls "$FONT_DIR"/JetBrainsMono* 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$FONT_COUNT" -eq 0 ]]; then
    log_info "Downloading JetBrainsMono Nerd Font..."
    TMP_FONT=$(mktemp -d)
    curl -fsSL "$FONT_URL" -o "$TMP_FONT/JetBrainsMono.zip"
    unzip -q "$TMP_FONT/JetBrainsMono.zip" -d "$TMP_FONT/fonts"
    cp "$TMP_FONT/fonts"/*.ttf "$FONT_DIR/"
    rm -rf "$TMP_FONT"
    log_success "JetBrainsMono installed to ~/Library/Fonts"
  else
    log_info "JetBrainsMono already installed"
  fi
else
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if ! fc-list | grep -qi "JetBrainsMono"; then
    log_info "Downloading JetBrainsMono Nerd Font..."
    TMP_FONT=$(mktemp -d)
    curl -fsSL "$FONT_URL" -o "$TMP_FONT/JetBrainsMono.zip"
    unzip -q "$TMP_FONT/JetBrainsMono.zip" -d "$TMP_FONT/fonts"
    cp "$TMP_FONT/fonts"/*.ttf "$FONT_DIR/"
    fc-cache -f "$FONT_DIR"
    rm -rf "$TMP_FONT"
    log_success "JetBrainsMono installed"
  else
    log_info "JetBrainsMono already installed"
  fi
fi

# ============================================================================
# 18. Go — Linux only (macOS gets it via brew above)
# ============================================================================
if [[ "$IS_LINUX" == "true" ]]; then
  log_section "Go"

  if ! has go; then
    log_info "Installing Go 1.23.5..."
    GO_VERSION="1.23.5"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
    $SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    export PATH="/usr/local/go/bin:$PATH"
    log_success "Go ${GO_VERSION} installed to /usr/local/go"
  else
    log_info "Go already installed: $(go version 2>/dev/null)"
  fi
fi

fi # SKIP_PACKAGES

# ============================================================================
# 19. Dotfiles
# ============================================================================
log_section "Dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  log_info "Cloning dotfiles repository..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone https://github.com/rustamgk/dotfiles.git "$DOTFILES_DIR"
  log_success "Dotfiles cloned to $DOTFILES_DIR"
fi

log_info "Linking config files..."
bash "$DOTFILES_DIR/scripts/install.sh"

# ============================================================================
# 20. Set ZSH as default shell
# ============================================================================
log_section "Default shell: ZSH"

if [[ "$IS_MACOS" == "true" ]]; then
  # Prefer Homebrew zsh (newer) over the ancient macOS system zsh
  BREW_ZSH="$(brew --prefix)/bin/zsh"
  ZSH_BIN="${BREW_ZSH:-/bin/zsh}"
else
  ZSH_BIN="$(which zsh)"
fi

if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  log_info "Changing default shell to $ZSH_BIN..."
  if ! grep -q "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | $SUDO tee -a /etc/shells
  fi
  chsh -s "$ZSH_BIN"
  log_success "Default shell changed to $ZSH_BIN"
else
  log_info "ZSH already set as default ($SHELL)"
fi

# ============================================================================
# 21. Tmux plugins (headless)
# ============================================================================
log_section "Tmux plugins"

if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  log_info "Installing tmux plugins via TPM..."
  "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" 2>&1 \
    || log_warn "TPM install may need a live tmux session — run prefix+I inside tmux"
  log_success "Tmux plugins installed"
fi

# ============================================================================
# Done!
# ============================================================================
echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}  Bootstrap complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "\nNext steps:"
echo -e "  1. ${YELLOW}Start a new shell${NC} or run: ${CYAN}exec zsh${NC}"
echo -e "  2. Open ${CYAN}tmux${NC} and press ${YELLOW}prefix + I${NC} to install plugins"
echo -e "  3. Open ${CYAN}nvim${NC} — lazy.nvim auto-installs plugins on first launch"
echo -e "  4. Fill in ${YELLOW}~/.zshrc.local${NC} with your secrets:"
echo -e "     ${CYAN}export GITLAB_ACCESS_TOKEN='your-token'${NC}"
echo -e "     ${CYAN}export AWS_ACCESS_KEY_ID='...'${NC}"
echo -e "  5. Set up SSH keys: ${CYAN}ssh-keygen -t ed25519 -C 'rustam.gk@gmail.com'${NC}"
if [[ "$IS_MACOS" == "true" ]]; then
  echo -e "  6. ${YELLOW}macOS:${NC} Set terminal font to 'JetBrainsMono Nerd Font'"
  echo -e "     in iTerm2/Terminal/Alacritty preferences"
fi
