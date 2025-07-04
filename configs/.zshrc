# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME=""

# Plugins (expanded based on your setup)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    tmux
    fzf
    kubectl
    helm
    docker
    azure
    github
    fluxcd
    argocd
    pyenv
    aliases
    starship
    terraform
    python
    history
    goes
    ansible
    zsh-navigation-tools
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='nvim'
export VISUAL='nvim'

# Development environment variables
export DOTNET_ROOT=$HOME/.dotnet
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Aliases (based on your actual aliases)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias e='nvim'

# Your custom aliases
alias lg="lazygit"
alias eza="eza --icons"
alias es="eza -l --icons --git -a"
alias et="eza --tree --level=2 --long --icons --git"
alias eg="eza -l --git --git-repos --header"
alias cd="z"
alias cdsd="z ~/workspace/_sarna"
alias kctx="kubectx"
alias kuns="kubens"
alias reload="source ~/.zshrc"
alias ku="kubectl"
alias wt="curl wttr.in/berlin"
alias zshconfig="e ~/.zshrc"
alias tmuxc="vim ~/.tmux.conf"
alias mc="mc -S nicedark"
alias myip="ifconfig | grep \"inet \" | grep -v 127.0.0.1 | cut -d\  -f2"
alias ping="ping -c 5"
alias ds="du -shc"
alias s="sudo"
alias bri="brew install"
alias bru="brew remove"
alias brs="brew search"

# Extract function
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Auto-start tmux session
if [ -z "$TMUX" ]; then
    tmux attach -t main || tmux new -s main
fi

# Initialize tools
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Homebrew environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
