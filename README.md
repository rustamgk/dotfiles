# Rustam's Universal Development Environment

A full dotfiles repository and development environment setup for Ubuntu Desktop, WSL2, and Docker-based workflows. Provides a consistent ZSH setup, tools, and configurations across machines.

## 🚀 Quick Start - New Ubuntu Machine

### One-line bootstrap (Ubuntu 24.04+ / 25.10)

```bash
git clone https://github.com/rustamgk/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles && ./scripts/bootstrap.sh
```

Or with curl (no git clone needed first):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rustamgk/dotfiles/master/scripts/bootstrap.sh)
```

### Just link configs (if already have a machine with tools)

```bash
git clone https://github.com/rustamgk/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles && make install
```

### Sync your live configs back to the repo

```bash
cd ~/github/dotfiles && make sync
git add configs/ && git commit -m "sync: update configs from $(hostname)"
```

---

## 📦 What Gets Installed by bootstrap.sh

| Category | Tools |
|----------|-------|
| **Shell** | ZSH, Oh My ZSH, fzf-tab, zsh-syntax-highlighting |
| **Prompt** | Starship (with Ayu Mirage config) |
| **Terminal MUX** | tmux + TPM + plugins |
| **Editor** | Neovim (latest) + Lazy.nvim config |
| **Search** | fzf, ripgrep (rg), fd, bat |
| **Navigation** | zoxide (smart cd), autojump |
| **File tools** | eza (ls++), mc (Midnight Commander), delta (git diff) |
| **Kubernetes** | kubectl, helm, k9s, kubectx, kubens |
| **DevOps** | terraform, ansible, argocd, flux |
| **Cloud** | awscli, azure-cli, saml2aws |
| **Languages** | pyenv + Python 3.12, nvm + Node 20 LTS, Go, Rust/Cargo |
| **Misc** | lazygit, trashy, lolcat, cowsay, fortune |
| **Fonts** | JetBrainsMono Nerd Font |

## 📁 Repository Structure

```
dotfiles/
├── configs/                  # All dotfiles (symlinked to $HOME)
│   ├── .zshrc                # ZSH configuration (cross-platform)
│   ├── .tmux.conf            # Tmux config
│   ├── .tmux.base.conf       # Tmux base keybindings
│   ├── .gitconfig            # Git configuration
│   ├── starship.toml         # Starship prompt config
│   └── nvim/                 # Neovim config (Lazy.nvim)
├── scripts/
│   ├── bootstrap.sh          # Full Ubuntu setup (run once on new machine)
│   ├── install.sh            # Symlink configs to $HOME
│   └── entrypoint.sh         # Docker container entrypoint
├── themes/                   # Terminal color schemes (Ayu Mirage)
│   ├── linux-terminals/      # Alacritty, Kitty, Gnome Terminal, etc.
│   ├── macos-terminal/
│   └── windows-terminal/
└── Makefile                  # Shortcuts for common operations
```

## 🔧 Makefile Commands

```bash
make bootstrap    # Full install on a new machine
make install      # Just link configs to $HOME
make sync         # Copy live configs back into this repo
make build        # Build Docker image
make run          # Start Docker dev environment
make connect      # Connect to running Docker container
make stop         # Stop Docker container
make clean        # Remove Docker resources
```

## 🔐 Sensitive Configuration

Secrets are stored in `~/.zshrc.local` (not tracked in git). After running `install.sh`, a template is created automatically:

```bash
# ~/.zshrc.local
export GITLAB_ACCESS_TOKEN="your-token"
export GITLAB_USER_NAME="rustam.galimyanov"
export AWS_ACCESS_KEY_ID="..."
```

## 🌟 Features

- **Universal Package Management**: Uses Homebrew for consistent package installation across platforms
- **Rich Terminal Experience**: ZSH with Oh My Zsh, Starship prompt, and tmux
- **Development Tools**: kubectl, helm, k9s, nvim, git, fzf, and more
- **Platform Detection**: Automatically detects and configures for macOS, Linux, or Windows
- **Multiple Profiles**: Separate environments for personal and different work projects
- **Persistent Data**: Maintains history, sessions, and configurations across container restarts
- **SSH Integration**: Supports SSH key mounting for seamless git operations

## 🛠️ Included Tools

### Core Development Tools
- **Shell**: ZSH with Oh My Zsh and extensive plugins (autosuggestions, syntax highlighting)
- **Editor**: Neovim with LazyVim configuration featuring LSP, formatting, and DevOps tooling
- **Terminal Multiplexer**: tmux (latest version) with plugins for session management
- **Version Control**: Git with aliases and configuration for efficient workflows
- **File Manager**: Midnight Commander (mc) with custom theme for visual file navigation

### Cloud & DevOps Tools
- **Kubernetes Management**:
  - `kubectl` - Official Kubernetes command-line tool
  - `k9s` - Terminal-based UI for Kubernetes clusters
  - `helm` - Package manager for Kubernetes applications
  - `kubectx` - Fast context switching between Kubernetes clusters
  - `stern` - Multi-pod and container log tailing
  - `kustomize` - Template-free configuration customization
  - `krew` - Plugin manager for kubectl

- **Infrastructure as Code**:
  - `terraform` - Infrastructure provisioning and management
  - `terragrunt` - Terraform wrapper for DRY configurations
  - `tflint` - Terraform linter for catching errors and best practices
  - `ansible` - Configuration management and automation
  - `flux` - GitOps continuous delivery for Kubernetes

- **Cloud Platforms**:
  - `azure-cli` - Microsoft Azure command-line interface with DevOps extensions
  - `argocd` - Declarative GitOps continuous delivery tool

- **Messaging & Streaming**:
  - `nats` - Cloud-native messaging system CLI tools

- **Programming Languages**:
  - `go` - Go programming language and toolchain
  - `python3` with `pyenv` - Python version management
  - `node` - Node.js runtime and npm package manager

### Security & Compliance Tools
- **Container Security**:
  - `trivy` - Comprehensive vulnerability scanner for containers and filesystems
  - `grype` - Vulnerability scanner for container images and filesystems
  - `dive` - Tool for exploring Docker image layers and optimizing image size

- **Kubernetes Security**:
  - `kubeaudit` - Kubernetes security auditing tool
  - `kube-bench` - CIS Kubernetes Benchmark security scanner
  - `kube-hunter` - Kubernetes penetration testing tool

- **Code Quality & Security**:
  - `hadolint` - Dockerfile linter for best practices and security
  - `checkov` - Static code analysis for Terraform, CloudFormation, and more

### Productivity Tools
- **Search & Navigation**:
  - `fzf` - Command-line fuzzy finder for files, commands, and more
  - `zoxide` - Smarter cd command that learns your habits
  - `autojump` - Directory navigation based on frequency and recency

- **File Operations**:
  - `eza` - Modern replacement for ls with colors and icons
  - `bat` - Syntax-highlighted cat clone with Git integration
  - `ripgrep` - Ultra-fast text search tool (grep alternative)
  - `fd` - Simple, fast alternative to find command
  - `tree` - Display directory structures as trees

- **System Monitoring**:
  - `htop` - Interactive process viewer and system monitor
  - `btop` - Modern resource monitor with beautiful interface

- **Data Processing**:
  - `jq` - Command-line JSON processor
  - `yq` - YAML/XML/TOML processor (like jq for YAML)
  - `yamllint` - YAML linter for syntax and style checking

- **Git & Development**:
  - `lazygit` - Terminal UI for Git commands with visual interface
  - `gh` - GitHub CLI for repository management and workflows

- **Documentation & Help**:
  - `tldr` - Simplified man pages with practical examples

- **Terminal Enhancement**:
  - `starship` - Cross-shell prompt with Git, Kubernetes context, and more

- **Network & API Tools**:
  - `grpcurl` - Command-line tool for gRPC services (like curl for gRPC)

## 📁 Directory Structure

```
dotfiles/
├── Dockerfile                    # Main container definition (personal)
├── Dockerfile.sarna              # Sarna work environment
├── Dockerfile.sdui               # SDUI work environment
├── docker-compose.yml           # Personal environment (Linux/macOS)
├── docker-compose.sarna.yml     # Sarna work environment
├── docker-compose.sdui.yml      # SDUI work environment
├── docker-compose.windows.yml   # Windows native Docker configuration
├── devenv.sh                    # Universal management script (Linux/macOS)
├── devenv.ps1                   # PowerShell management script (Windows)
├── devenv.bat                   # Batch wrapper for Windows CMD
├── Makefile                     # Make shortcuts for Linux/macOS
├── configs/                     # Configuration files
│   ├── .zshrc                   # ZSH configuration
│   ├── .tmux.conf              # tmux configuration
│   ├── starship.toml           # Starship prompt configuration
│   ├── .gitconfig              # Git configuration
│   └── nvim/                   # LazyVim configuration
│       ├── init.lua            # Neovim entry point
│       └── lua/
│           ├── config/         # LazyVim config overrides
│           └── plugins/        # Custom plugin configurations
├── themes/                     # Terminal color themes (Ayu Mirage)
│   ├── windows-terminal/       # Windows Terminal theme
│   ├── macos-terminal/         # macOS Terminal theme
│   └── linux-terminals/        # Linux terminal themes (Kitty, Alacritty, etc.)
└── scripts/                     # Helper scripts
    ├── entrypoint.sh           # Container startup script
    └── setup-mounts.sh         # Platform-specific mount setup
```

## 🚀 Quick Start

### Prerequisites
- Docker Desktop (Windows users need native Docker Desktop)
- Git (to clone this repository)
- **Windows users**: Docker Desktop for Windows (no WSL2 required)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-dotfiles-repo-url>
   cd dotfiles
   ```

2. **Run the environment** (automatically pulls or builds image):
   
   The system will automatically try to pull a pre-built image from Docker Hub first, and only build locally if needed.
   
   **Linux/macOS:**
   ```bash
   # Personal environment (default)
   ./devenv.sh run
   # or explicitly
   ./devenv.sh personal run
   
   # Work environments
   ./devenv.sh work_sarna run
   ./devenv.sh work_sdui run
   ```
   
   **Windows (PowerShell):**
   ```powershell
   # Personal environment (default)
   .\devenv.ps1 run
   # or explicitly
   .\devenv.ps1 personal run
   
   # Work environments
   .\devenv.ps1 work_sarna run
   .\devenv.ps1 work_sdui run
   ```
   
   **Windows (Command Prompt):**
   ```cmd
   devenv.bat personal run
   devenv.bat work_sarna run
   devenv.bat work_sdui run
   ```

3. **Connect to your environment**:
   
   **Linux/macOS:**
   ```bash
   ./devenv.sh personal connect
   ./devenv.sh work_sarna connect
   ./devenv.sh work_sdui connect
   ```
   
   **Windows:**
   ```powershell
   .\devenv.ps1 personal connect
   .\devenv.ps1 work_sarna connect
   .\devenv.ps1 work_sdui connect
   ```

## � Docker Hub Integration

The development environment is automatically built and published to Docker Hub via GitHub Actions. This means:

### Automatic Image Pulling
- **First run**: Automatically pulls the latest pre-built image from Docker Hub
- **Fallback**: Builds locally if the pull fails or image doesn't exist
- **Fast startup**: No need to build locally on first use

### Available Images
- `rustamgk/dotfiles:latest` - Personal development environment
- `rustamgk/dotfiles:sarna` - Sarna work environment  
- `rustamgk/dotfiles:sdui` - SDUI work environment

### Manual Image Management
```bash
# Pull latest image from Docker Hub
./devenv.sh personal pull
./devenv.sh work_sarna pull

# Force rebuild locally
./devenv.sh personal rebuild
./devenv.sh work_sarna rebuild

# Check image status
./devenv.sh status
```

### Manual GitHub Actions Trigger
You can manually trigger image builds from GitHub:

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select "Build and Push Docker Images" workflow
4. Click **Run workflow** button
5. Choose options:
   - **Profile**: `all`, `personal`, `sarna`, or `sdui`
   - **Platforms**: `linux/amd64,linux/arm64` (recommended) or single platform
6. Click **Run workflow**

This is useful for:
- Building specific profiles only
- Testing changes before merging
- Rebuilding images after configuration updates

### GitHub Actions
Images are automatically built and pushed to Docker Hub when:
- Code is pushed to main/master branch
- Dockerfile or configs are modified
- **Manual workflow dispatch** is triggered (you can choose specific profiles and platforms)

## �🖥️ Platform-Specific Setup

### macOS
- Workspace: `~/workspace` → `/home/rustamgk/workspace`
- Helm: `~/helm` → `/home/rustamgk/helm`

### Linux
- Workspace: `~/workspace` → `/home/rustamgk/workspace`
- Helm: `~/helm` → `/home/rustamgk/helm`

### Windows
- Workspace: `C:\workspace` → `/home/rustamgk/workspace`
- Helm: `C:\helm` → `/home/rustamgk/helm`

## 📋 Management Commands

### Linux/macOS
The `devenv.sh` script provides easy management of your development environment:

```bash
# Start environment (pulls from Docker Hub or builds locally)
./devenv.sh run

# Pull latest image from Docker Hub
./devenv.sh pull

# Build image locally
./devenv.sh build

# Force rebuild locally (ignores existing image)
./devenv.sh rebuild

# Connect to running environment
./devenv.sh connect

# Stop the environment
./devenv.sh stop

# Restart the environment
./devenv.sh restart

# View container logs
./devenv.sh logs

# Check status
./devenv.sh status

# Show help
./devenv.sh help
```

### Windows (PowerShell)
The `devenv.ps1` script provides the same functionality for Windows:

```powershell
# Start environment (pulls from Docker Hub or builds locally)
.\devenv.ps1 run

# Pull latest image from Docker Hub
.\devenv.ps1 pull

# Build image locally
.\devenv.ps1 build

# Force rebuild locally (ignores existing image)
.\devenv.ps1 rebuild

# Connect to running environment
.\devenv.ps1 connect

# Stop the environment
.\devenv.ps1 stop

# Restart the environment
.\devenv.ps1 restart

# View container logs
.\devenv.ps1 logs

# Check status
.\devenv.ps1 status

# Show help
.\devenv.ps1 help
```

### Windows (Command Prompt)
Use the batch file for CMD:

```cmd
devenv.bat run
devenv.bat connect
devenv.bat stop
```

## 🎯 Tool Usage Examples

### Kubernetes Workflows
```bash
# Switch between clusters quickly
kubectx production
kubectx staging

# Monitor multiple pods
stern app-name

# Interactive cluster management
k9s

# Package management
helm search repo nginx
helm install my-nginx stable/nginx

# Security scanning
kube-bench run --targets=node,policies,managedservices
kubeaudit all
```

### Container Security Scanning
```bash
# Scan container images for vulnerabilities
trivy image nginx:latest
grype nginx:latest

# Analyze image layers for optimization
dive nginx:latest

# Lint Dockerfiles
hadolint Dockerfile
```

### Infrastructure as Code
```bash
# Terraform workflows with validation
terraform plan
tflint
terragrunt plan-all

# Security scanning for infrastructure
checkov -f main.tf
checkov -d ./terraform/

# YAML processing and validation
yamllint docker-compose.yml
yq eval '.services.*.image' docker-compose.yml
```

### Development Productivity
```bash
# Fast file finding and navigation
fz # fuzzy find files
z project-name # jump to frequently used directories

# Enhanced file operations
eza -la --git # beautiful ls with git status
bat config.json # syntax highlighted file viewing
rg "TODO" --type rust # fast text search

# Git workflows
lazygit # visual git interface
gh pr create # create GitHub pull requests
gh issue list # manage GitHub issues
```

### Data Processing
```bash
# JSON processing
curl -s api/endpoint | jq '.data[] | select(.status == "active")'

# YAML manipulation
yq eval '.spec.containers[0].image = "nginx:1.21"' deployment.yaml

# Log analysis
stern app-name | grep ERROR
```

### Neovim/LazyVim Features
```bash
# LSP features for multiple languages
:LspInfo # Check active language servers

# DevOps specific shortcuts
<leader>dk # Get Kubernetes pods
<leader>dh # List Helm releases  
<leader>dt # Terraform plan
<leader>dg # Run Go tests

# File operations
<leader>ff # Find files (Telescope)
<leader>fg # Live grep
<leader>fb # Browse buffers

# YAML/JSON formatting
<leader>yf # Format YAML with yq
<leader>jf # Format JSON with jq

# Git integration
<leader>gg # LazyGit interface
<leader>gs # Git status
```

## 🔧 Customization

### Adding New Packages

Edit the `Dockerfile` and add packages to the Homebrew install section:

```dockerfile
RUN /home/linuxbrew/.linuxbrew/bin/brew install \
    # ... existing packages ... \
    your-new-package \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup
```

### Modifying Configurations

Edit files in the `configs/` directory:
- `.zshrc` - ZSH shell configuration
- `.tmux.conf` - tmux configuration and plugins
- `starship.toml` - Prompt customization
- `.gitconfig` - Git aliases and settings

### Adding New Scripts

Place executable scripts in the `scripts/` directory and reference them in the Dockerfile.

## 🔐 SSH Configuration

To use SSH keys with git and other tools:

1. **Mount your SSH directory** (already configured in docker-compose files):
   ```yaml
   volumes:
     - ${HOME}/.ssh:/home/rustamgk/.ssh:ro
   ```

2. **SSH Agent**: The entrypoint script automatically sets up SSH agent forwarding.

## 📊 Persistent Data

The following data persists across container restarts:
- **ZSH History**: Command history and settings
- **tmux Sessions**: Session state with tmux-resurrect
- **Git Configuration**: Local git settings

## 🔧 Troubleshooting

### Container Won't Start
```bash
# Linux/macOS
docker info
./devenv.sh logs
docker system prune -a
./devenv.sh build
```

```powershell
# Windows PowerShell
docker info
.\devenv.ps1 logs
docker system prune -a
.\devenv.ps1 build
```

### Windows-Specific Issues

**Docker Desktop Not Running:**
- Ensure Docker Desktop is started
- Check system tray for Docker icon
- Restart Docker Desktop if needed

**Source Directories Not Found:**
The PowerShell script automatically creates `C:\workspace` and `C:\helm` directories if they don't exist.

**PowerShell Execution Policy:**
If you get execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**File Sharing Issues:**
Ensure Docker Desktop has access to the C: drive:
1. Docker Desktop → Settings → Resources → File Sharing
2. Add C:\ to shared drives if not already present
3. Apply & Restart

### Mount Issues on Windows
Ensure Docker Desktop has access to the C: drive:
1. Docker Desktop → Settings → Resources → File Sharing
2. Add C:\ to shared drives
3. Apply & Restart

### SSH Key Permissions
If SSH keys have permission issues:
```bash
# Fix permissions on host
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 700 ~/.ssh
```

## 🎨 Customization Examples

### Adding a New Alias
Edit `configs/.zshrc`:
```bash
alias myalias='my command'
```

### Installing Additional tmux Plugins
Edit `configs/.tmux.conf`:
```bash
set -g @plugin 'your-new/plugin'
```

### Modifying the Prompt
Edit `configs/starship.toml` to customize the Starship prompt.

## 🎨 Terminal Themes

The repository includes Ayu Mirage color theme files for various terminal emulators to ensure a consistent visual experience across platforms.

### Available Theme Files

#### Windows Terminal
- **File**: `themes/windows-terminal/ayu-mirage.json`
- **Installation**: Copy to Windows Terminal color schemes
- **Documentation**: See `themes/windows-terminal/README.md`

#### macOS Terminal
- **File**: `themes/macos-terminal/Ayu-Mirage.terminal`
- **Installation**: Double-click to import or use Terminal preferences
- **Documentation**: See `themes/macos-terminal/README.md`

#### Linux Terminals
Located in `themes/linux-terminals/`:

- **Kitty**: `kitty-ayu-mirage.conf`
- **Alacritty**: `alacritty-ayu-mirage.yml`
- **GNOME Terminal**: `gnome-terminal-ayu-mirage.sh` (installer script)
- **Konsole**: `konsole-ayu-mirage.colorscheme`
- **Terminator**: `terminator-ayu-mirage.conf`

### Theme Color Palette

The Ayu Mirage theme provides a dark, modern look with the following colors:

- **Background**: `#1F2430` (Dark blue-grey)
- **Foreground**: `#CBCCC6` (Light grey)
- **Cursor**: `#FFCC66` (Golden yellow)
- **Selection**: `#33415E` (Blue-grey)

The theme includes 16 ANSI colors optimized for readability and syntax highlighting in development environments.

### Usage

1. **For host terminal**: Apply the theme to your host terminal for consistency
2. **In container**: The container already uses compatible colors via tmux and Neovim
3. **Documentation**: Each theme directory contains detailed installation instructions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./devenv.sh run`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋‍♂️ Support

If you encounter issues:
1. Check the troubleshooting section
2. Review container logs with `./devenv.sh logs`
3. Create an issue with your platform and error details

---

**Happy coding! 🚀**
