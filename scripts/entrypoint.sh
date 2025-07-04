#!/bin/bash

# Container entrypoint script
echo "🚀 Starting Rustam's Development Environment..."

# Setup mounts
/home/rustamgk/setup-mounts.sh

# Initialize Homebrew environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Initialize starship
eval "$(starship init zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)"

# Initialize pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Setup SSH agent
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval "$(ssh-agent)"
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock

# Initialize fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Install tmux plugins if not already installed
if [ ! -d ~/.tmux/plugins/tmux-sensible ]; then
    echo "Installing tmux plugins..."
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

# Install additional zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "✅ Environment setup complete!"
echo "📁 Workspace: /home/rustamgk/workspace"
echo "⎈ Helm: /home/rustamgk/helm"
echo "🔧 Tools: kubectl, helm, k9s, nvim, tmux, git, and more!"

# Execute the command passed to the container
exec "$@"
