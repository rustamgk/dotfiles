# -----------------------------------------
# ZSH config file
# Author: Galimyanov Rustam
# Initial date: 2007
# Managed via: github.com/rustamgk/dotfiles
# -----------------------------------------

# ---- Oh My ZSH setup ----
export ZSH=$HOME/.oh-my-zsh
export DOTNET_ROOT=$HOME/.dotnet
export PYENV_ROOT="$HOME/.pyenv"

# ---- FZF Tab plugin style ----
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# ---- Consolidated PATH ----
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$DOTNET_ROOT:$DOTNET_ROOT/tools:$PYENV_ROOT/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/golang/bin:$HOME/.cargo/bin:$HOME/.pulumi/bin:$PATH"

# ---- WSL2-specific additions ----
if grep -qi microsoft /proc/version 2>/dev/null; then
  export PATH="$PATH:/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/AppData/Local/Programs/Microsoft VS Code/bin"
fi

# ---- Linuxbrew ----
if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ---- Oh My Zsh Plugins ----
# NOTE: 'pyenv' plugin removed - causes issues with modern pyenv, manual init below instead
plugins=(
  aws
  azure
  github
  fluxcd
  argocd
  fzf-tab
  aliases
  fzf
  starship
  zsh-syntax-highlighting
  autojump
  tmux
  terraform
  git
  kubectl
  docker
  python
  helm
  history
  golang
  colored-man-pages
  ansible
  zsh-navigation-tools
)


source $ZSH/oh-my-zsh.sh

# ---- Pyenv initialization ----
# Must be after oh-my-zsh to override plugin's outdated init
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# -------------------------------------------
# My aliases - Git aliases in .gitconfig
# -------------------------------------------

# -- Navigation --
alias cd="z"
alias up="cd .."
alias upp="cd ..."
alias clr="clear"

# -- Kubernetes --
alias kux="kubechc"
alias kctx="kubectx"
alias kuns="kubens"
alias ku="kubectl"

# -- Package management --
alias sdi="sudo apt install"
alias sdu="sudo apt remove"
alias sds="apt search"
alias bri="brew install"
alias bru="brew remove"
alias brs="brew search"
alias s="sudo"

# -- Editors --
alias e=nvim
alias vim=nvim
alias v=nvim
alias zshconfig="nvim ~/.zshrc"
alias tmuxc="nvim ~/.tmux.conf"

# -- eza (better ls) --
alias eza="eza --icons"
alias es="eza -l --icons --git -a"
alias et="eza --tree --level=2 --long --icons --git"
alias eg="eza -l --git --git-repos --header"

# -- Tools --
alias lg="lazygit"
alias tp="trashy"
alias mc="mc -S nicedark"
alias reload="source ~/.zshrc"
alias venv="virtualenv"
alias 1pl="op signin grk_family"

# -- Network --
alias wt="curl wttr.in/berlin"
alias myip="curl -s https://api.ipify.org && echo"
alias ports="netstat -tulanp"
alias ping="ping -c 5"

# -- Disk --
alias ds="du -shc"
alias dsf="du -h -d 2 | sort -hr"
alias df="df -h"

# -- Misc --
alias grep="grep --color=auto"
alias bc="bc -l"
alias vg="vagrant"
alias tlps="sudo tlp-stat -s"

# -- Git aliases --
alias glo="git log --oneline"
alias gcm="git checkout master"
alias gcb="git checkout -b"
alias gc="git commit"
alias gs="git status"
alias gd="git diff"
alias gf="git fetch"
alias gm="git merge"
alias gma="git merge --abort"
alias gr="git rebase"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gu="git unstage"
alias gg="git graph"
alias glp="git log --pretty --oneline --graph"
alias gA="git add -A"
alias gri="git rebase -i"
alias grc="git rebase --continue"
alias gra="git rebase --abort"
alias cdsd="z ~/workspace"
alias oktaws='saml2aws login --profile=default && eval $(saml2aws script --profile=default)'

# -------------------------------------------
# User configuration
# -------------------------------------------
export EDITOR='nvim'
export ARCHFLAGS="-arch x86_64"
export SSH_KEY_PATH="~/.ssh/"

# -------------------------------------------
# AWS helper functions
# -------------------------------------------
function use-eu() {
  export AWS_REGION=eu-central-1
  export AWS_DEFAULT_REGION=eu-central-1
  echo "Switched to EU (eu-central-1)"
}

function use-tokyo() {
  export AWS_REGION=ap-northeast-1
  export AWS_DEFAULT_REGION=ap-northeast-1
  echo "Switched to Tokyo (ap-northeast-1)"
}

# -------------------------------------------
# Archive helpers
# -------------------------------------------
unpack () {
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2)   tar xjfv $1    ;;
      *.tar.gz)    tar xzfv $1    ;;
      *.tar.xz)    tar xvJf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.gz)        gunzip $1      ;;
      *.rar)       unrar x $1     ;;
      *.tar)       tar xf $1      ;;
      *.tbz)       tar xjvf $1    ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "I don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

pack () {
  if [ $1 ]; then
    case $1 in
      tar.bz2)   tar -cjvf $2.tar.bz2 $2               ;;
      tar.gz)    tar -czvf $2.tar.gz $2                 ;;
      tar.xz)    tar -cf - $2 | xz -9 -c - > $2.tar.xz ;;
      bz2)       bzip $2                                ;;
      gz)        gzip -c -9 -n $2 > $2.gz               ;;
      tar)       tar cpvf $2.tar $2                     ;;
      tbz)       tar cjvf $2.tar.bz2 $2                 ;;
      tgz)       tar czvf $2.tar.gz $2                  ;;
      zip)       zip -r $2.zip $2                       ;;
      7z)        7z a $2.7z $2                          ;;
      *)         echo "'$1' cannot be packed via pack()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# -------------------------------------------
# Auto-attach to tmux (skip in vscode terminal)
# -------------------------------------------
if [ -z "$TMUX" ] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
  command -v fortune >/dev/null && command -v cowsay >/dev/null && command -v lolcat >/dev/null && fortune | cowsay | lolcat
  tmux attach -t main || tmux new -s main
fi

# ---- Zoxide (smarter cd) ----
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ---- FZF ----
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ---- Kubech ----
[ -f ~/.kubech/kubech ] && source ~/.kubech/kubech

# ---- VSCode shell integration ----
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)" 2>/dev/null

# ---- Pulumi ----
export PATH=$PATH:$HOME/.pulumi/bin

# -------------------------------------------
# Sensitive / machine-specific config
# Load from ~/.zshrc.local if it exists (not tracked in git)
# Example: GITLAB_ACCESS_TOKEN, AWS keys, custom paths
# -------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
