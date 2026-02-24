#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh - Bootstrap script for Ubuntu Desktop / WSL2 Ubuntu
# Author: Rustam Galimyanov
# Repo: github.com/rustamgk/dotfiles
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rustamgk/dotfiles/master/scripts/bootstrap.sh | bash
#   -- OR --
#   git clone https://github.com/rustamgk/dotfiles.git ~/github/dotfiles
#   cd ~/github/dotfiles && ./scripts/bootstrap.sh
#
# What this installs:
#   - ZSH + Oh My ZSH + plugins (fzf-tab, zsh-syntax-highlighting)
#   - Starship prompt
#   - Tmux + TPM (Tmux Plugin Manager)
#   - Neovim (latest)
#   - fzf, ripgrep, fd, bat, eza, zoxide, autojump, delta
#   - lazygit, k9s, kubectx, kubens, kubectl, helm, terraform
#   - pyenv + Python, nvm + Node.js, Go, Rust/Cargo
#   - Linuxbrew + brew packages
#   - Nerd Fonts (JetBrainsMono)
#   - dotfiles symlinked to $HOME
# =============================================================================

set -euo pipefail

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo"
fi

# ---- Detect environment ----
IS_WSL=false
IS_DESKTOP=false
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
  log_info "Detected WSL2 environment"
else
  IS_DESKTOP=true
  log_info "Detected native Linux environment"
fi

# ---- Dotfiles directory ----
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/github/dotfiles}"

# ============================================================================
# 1. System packages
# ============================================================================
log_section "Installing system packages"

$SUDO apt-get update -qq

# Add required repos
log_info "Adding apt repositories..."

# GitHub CLI
if ! has gh; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $SUDO tee /etc/apt/sources.list.d/github-cli.list > /dev/null
fi

# Neovim PPA (stable)
if ! has nvim; then
  $SUDO add-apt-repository -y ppa:neovim-ppa/stable 2>/dev/null || true
fi

$SUDO apt-get update -qq

# Core packages
APT_PACKAGES=(
  # Shell
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  # Terminal multiplexer
  tmux
  # Editors
  neovim
  # Version control
  git
  git-lfs
  gh
  # Build tools
  build-essential
  cmake
  pkg-config
  # Search & navigation
  fzf
  ripgrep
  fd-find
  bat
  autojump
  zoxide
  tree
  # File tools
  mc
  unzip
  zip
  p7zip-full
  # Network tools
  curl
  wget
  net-tools
  dnsutils
  # Process tools
  htop
  btop
  # JSON/YAML
  jq
  yq
  # Fun stuff
  cowsay
  fortune-mod
  lolcat
  # Python
  python3
  python3-pip
  python3-venv
  python3-dev
  # Ansible
  ansible
  # Go (base, pyenv/nvm will manage versions)
  golang-go
  # Node.js
  nodejs
  npm
  # Rust deps
  libssl-dev
  # Font support
  fontconfig
  # Misc
  stow
  tmux
  xclip
  xsel
)

# Desktop-only packages
if [[ "$IS_DESKTOP" == "true" ]]; then
  APT_PACKAGES+=(
    alacritty
    fonts-font-awesome
  )
fi

log_info "Installing apt packages..."
$SUDO apt-get install -y "${APT_PACKAGES[@]}" 2>&1 | grep -E "^(Setting up|E:|W:)" || true
log_success "Apt packages installed"

# ============================================================================
# 2. Linuxbrew (Homebrew for Linux)
# ============================================================================
log_section "Installing Linuxbrew"

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

# Brew packages
log_info "Installing brew packages..."
BREW_PACKAGES=(
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
)

for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "${pkg##*/}" &>/dev/null; then
    log_info "brew: ${pkg##*/} already installed"
  else
    log_info "brew: installing ${pkg##*/}..."
    brew install "$pkg" 2>&1 | tail -1 || log_warn "Failed to install brew package: $pkg"
  fi
done
log_success "Brew packages installed"

# ============================================================================
# 3. kubectl
# ============================================================================
log_section "Installing kubectl"

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

# ============================================================================
# 4. Helm
# ============================================================================
log_section "Installing Helm"

if ! has helm; then
  log_info "Installing helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  log_success "Helm installed"
else
  log_info "Helm already installed: $(helm version --short 2>/dev/null || true)"
fi

# ============================================================================
# 5. Terraform
# ============================================================================
log_section "Installing Terraform"

if ! has terraform; then
  log_info "Installing terraform via brew..."
  brew install terraform
  log_success "Terraform installed"
else
  log_info "Terraform already installed"
fi

# ============================================================================
# 6. Starship prompt
# ============================================================================
log_section "Installing Starship prompt"

if ! has starship; then
  log_info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  log_success "Starship installed"
else
  log_info "Starship already installed: $(starship --version 2>/dev/null | head -1)"
fi

# ============================================================================
# 7. Oh My ZSH
# ============================================================================
log_section "Installing Oh My ZSH"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_info "Installing Oh My ZSH..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log_success "Oh My ZSH installed"
else
  log_info "Oh My ZSH already installed, updating..."
  git -C "$HOME/.oh-my-zsh" pull --quiet origin master 2>/dev/null || true
fi

# Oh My ZSH custom plugins
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# fzf-tab
if [[ ! -d "$OMZ_CUSTOM/plugins/fzf-tab" ]]; then
  log_info "Installing fzf-tab plugin..."
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$OMZ_CUSTOM/plugins/fzf-tab"
  log_success "fzf-tab installed"
else
  log_info "fzf-tab already installed"
fi

# zsh-syntax-highlighting (via custom plugin if not via apt)
if [[ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]] && [[ ! -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  log_info "Installing zsh-syntax-highlighting plugin..."
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
  log_success "zsh-syntax-highlighting installed"
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && [[ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  # Link system package version
  mkdir -p "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
  ln -sf /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
  log_success "zsh-syntax-highlighting linked from system package"
fi

# ============================================================================
# 8. pyenv + Python
# ============================================================================
log_section "Installing pyenv"

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

# Install Python 3.12 (stable)
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
# 9. nvm + Node.js
# ============================================================================
log_section "Installing nvm + Node.js"

NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  log_success "nvm installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! nvm ls 20 &>/dev/null; then
  log_info "Installing Node.js 20 LTS via nvm..."
  nvm install 20
  nvm use 20
  nvm alias default 20
  log_success "Node.js 20 LTS installed"
else
  log_info "Node.js 20 already installed via nvm"
fi

# ============================================================================
# 10. Rust / Cargo
# ============================================================================
log_section "Installing Rust"

if ! has rustc; then
  log_info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  log_success "Rust installed"
else
  log_info "Rust already installed: $(rustc --version 2>/dev/null)"
fi

export PATH="$HOME/.cargo/bin:$PATH"

# Cargo tools
log_info "Installing cargo tools..."
CARGO_TOOLS=(
  trashy
)
for tool in "${CARGO_TOOLS[@]}"; do
  if has "$tool"; then
    log_info "cargo: $tool already installed"
  else
    log_info "cargo: installing $tool..."
    cargo install "$tool" 2>&1 | tail -2 || log_warn "Failed to install cargo tool: $tool"
  fi
done

# ============================================================================
# 11. kubechc (kubech)
# ============================================================================
log_section "Installing kubech"

if [[ ! -d "$HOME/.kubech" ]]; then
  log_info "Installing kubech..."
  git clone --depth 1 https://github.com/0xMALVEE/kubech.git "$HOME/.kubech"
  log_success "kubech installed"
else
  log_info "kubech already installed"
fi

# ============================================================================
# 12. FZF (from source for latest version if not up to date)
# ============================================================================
log_section "Setting up FZF"

if [[ ! -d "$HOME/.fzf" ]]; then
  log_info "Installing fzf from source..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
  log_success "fzf installed from source"
else
  log_info "fzf source already present"
fi

# ============================================================================
# 13. Tmux Plugin Manager (TPM)
# ============================================================================
log_section "Installing Tmux Plugin Manager"

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  log_info "Installing TPM..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  log_success "TPM installed"
else
  log_info "TPM already installed"
fi

# ============================================================================
# 14. Nerd Fonts
# ============================================================================
log_section "Installing Nerd Fonts (JetBrainsMono)"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if ! fc-list | grep -qi "JetBrainsMono"; then
  log_info "Downloading JetBrainsMono Nerd Font..."
  FONT_VERSION="v3.3.0"
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
  TMP_FONT_DIR=$(mktemp -d)
  curl -fsSL "$FONT_URL" -o "$TMP_FONT_DIR/JetBrainsMono.zip"
  unzip -q "$TMP_FONT_DIR/JetBrainsMono.zip" -d "$TMP_FONT_DIR/JetBrainsMono"
  cp "$TMP_FONT_DIR/JetBrainsMono"/*.ttf "$FONT_DIR/"
  fc-cache -f "$FONT_DIR"
  rm -rf "$TMP_FONT_DIR"
  log_success "JetBrainsMono Nerd Font installed"
else
  log_info "JetBrainsMono Nerd Font already installed"
fi

# ============================================================================
# 15. Go latest (optional upgrade)
# ============================================================================
log_section "Setting up Go"

if ! has go; then
  log_info "Installing Go..."
  GO_VERSION="1.23.5"
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
  $SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz
  log_success "Go ${GO_VERSION} installed to /usr/local/go"
else
  log_info "Go already installed: $(go version 2>/dev/null)"
fi

# ============================================================================
# 16. Install dotfiles configs
# ============================================================================
log_section "Installing dotfiles"

# Clone dotfiles if not present
if [[ ! -d "$DOTFILES_DIR" ]]; then
  log_info "Cloning dotfiles repository..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone https://github.com/rustamgk/dotfiles.git "$DOTFILES_DIR"
  log_success "Dotfiles cloned to $DOTFILES_DIR"
fi

# Run install script to link configs
log_info "Linking config files..."
bash "$DOTFILES_DIR/scripts/install.sh"

# ============================================================================
# 17. Set ZSH as default shell
# ============================================================================
log_section "Setting ZSH as default shell"

ZSH_BIN=$(which zsh)
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  log_info "Changing default shell to ZSH..."
  if grep -q "$ZSH_BIN" /etc/shells; then
    chsh -s "$ZSH_BIN"
    log_success "Default shell changed to $ZSH_BIN"
  else
    echo "$ZSH_BIN" | $SUDO tee -a /etc/shells
    chsh -s "$ZSH_BIN"
    log_success "Added $ZSH_BIN to /etc/shells and set as default"
  fi
else
  log_info "ZSH is already the default shell"
fi

# ============================================================================
# 18. Install tmux plugins (headless)
# ============================================================================
log_section "Installing tmux plugins"

if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  log_info "Installing tmux plugins via TPM..."
  "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" 2>&1 || log_warn "TPM install might need a tmux session to complete. Run: tmux new-session -d -s install && tmux source ~/.tmux.conf"
  log_success "Tmux plugins installed"
fi

# ============================================================================
# Done!
# ============================================================================
echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}  Bootstrap complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "\nNext steps:"
echo -e "  1. ${YELLOW}Log out and back in${NC} (or run ${CYAN}exec zsh${NC}) for ZSH to be active"
echo -e "  2. Open ${CYAN}tmux${NC} and press ${YELLOW}prefix + I${NC} to install tmux plugins"
echo -e "  3. Open ${CYAN}nvim${NC} to trigger plugin installation"
echo -e "  4. Configure ${YELLOW}~/.zshrc.local${NC} with your secrets (tokens, keys, etc.)"
echo -e "  5. Set up SSH keys: ${CYAN}ssh-keygen -t ed25519 -C 'rustam.gk@gmail.com'${NC}"
echo -e "\nSensitive config template (~/.zshrc.local):"
echo -e "  ${CYAN}export GITLAB_ACCESS_TOKEN='your-token'${NC}"
echo -e "  ${CYAN}export GITLAB_USER_NAME='rustam.galimyanov'${NC}"
echo -e "  ${CYAN}export AWS_ACCESS_KEY_ID='...'${NC}"
