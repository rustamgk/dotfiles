# Rustam's Universal Development Environment

A Docker-based development environment that provides a consistent setup across macOS, Linux, and Windows WSL2. This environment includes all your favorite tools, configurations, and settings in a portable container.

## 🌟 Features

- **Universal Package Management**: Uses Homebrew for consistent package installation across platforms
- **Rich Terminal Experience**: ZSH with Oh My Zsh, Starship prompt, and tmux
- **Development Tools**: kubectl, helm, k9s, nvim, git, fzf, and more
- **Platform Detection**: Automatically detects and configures for macOS, Linux, or Windows WSL2
- **Persistent Data**: Maintains history, sessions, and configurations across container restarts
- **SSH Integration**: Supports SSH key mounting for seamless git operations

## 🛠️ Included Tools

### Core Development Tools
- **Shell**: ZSH with Oh My Zsh and extensive plugins
- **Editor**: Neovim with custom configuration
- **Terminal Multiplexer**: tmux (latest version) with plugins
- **Version Control**: Git with aliases and configuration
- **File Manager**: Midnight Commander (mc) with custom theme

### Cloud & DevOps Tools
- **Kubernetes**: kubectl, k9s, helm, kubectx, stern
- **Infrastructure**: ansible, flux, terraform
- **ArgoCD**: argocd CLI
- **NATS**: nats CLI tools
- **Languages**: Go, Python3 (with pyenv), Node.js

### Productivity Tools
- **Search & Navigation**: fzf (fuzzy finder), zoxide, autojump
- **File Tools**: eza (better ls), bat (better cat), ripgrep, fd
- **System Monitoring**: htop, btop
- **Data Tools**: jq, yq, yamllint, tree
- **Git Tools**: lazygit, gh (GitHub CLI)
- **Documentation**: tldr
- **Prompt**: Starship with Kubernetes context display

## 📁 Directory Structure

```
dotfiles/
├── Dockerfile                    # Main container definition
├── docker-compose.yml           # Linux/macOS configuration
├── docker-compose.windows.yml   # Windows WSL2 configuration
├── devenv.sh                    # Universal management script
├── configs/                     # Configuration files
│   ├── .zshrc                   # ZSH configuration
│   ├── .tmux.conf              # tmux configuration
│   ├── starship.toml           # Starship prompt configuration
│   └── .gitconfig              # Git configuration
└── scripts/                     # Helper scripts
    ├── entrypoint.sh           # Container startup script
    └── setup-mounts.sh         # Platform-specific mount setup
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git (to clone this repository)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-dotfiles-repo-url>
   cd dotfiles
   ```

2. **Build and run** (one command does it all):
   ```bash
   ./devenv.sh run
   ```

3. **Connect to your environment**:
   ```bash
   ./devenv.sh connect
   ```

## 🖥️ Platform-Specific Setup

### macOS
- Workspace: `~/workspace` → `/home/rustamgk/workspace`
- Helm: `~/helm` → `/home/rustamgk/helm`

### Linux
- Workspace: `~/workspace` → `/home/rustamgk/workspace`
- Helm: `~/helm` → `/home/rustamgk/helm`

### Windows WSL2
- Workspace: `C:\Source\workspace` → `/home/rustamgk/workspace`
- Helm: `C:\Source\helm` → `/home/rustamgk/helm`

## 📋 Management Commands

The `devenv.sh` script provides easy management of your development environment:

```bash
# Build the Docker image
./devenv.sh build

# Start the environment (builds if needed)
./devenv.sh run

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
# Check Docker status
docker info

# View container logs
./devenv.sh logs

# Rebuild from scratch
docker system prune -a
./devenv.sh build
```

### Mount Issues on Windows
Ensure Docker Desktop has access to the C: drive and WSL2 integration is enabled.

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
