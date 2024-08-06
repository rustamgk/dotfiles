# -----------------------------------------
# ZSH config file
# Author: Galimyanov Rustam
# Initial date: 2007
# Current year of config: 2022
# -----------------------------------------
export PATH="/.local/bin/:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/golang/bin"
export ZSH=/home/rustamgk/.oh-my-zsh
export GITLAB_USER_NAME="rustam.galimyanov"
export GITLAB_ACCESS_TOKEN="accdQoNmxpNUhYDqyUSi"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# ----------------------------------------
plugins=(pyenv aliases fzf starship zsh-syntax-highlighting autojump vscode tmux terraform git kubectl docker python helm history golang colored-man-pages ansible zsh-navigation-tools)

# --------------------------------------
#source $ZSH/oh-my-zsh.sh

# --------------------------------------
# My aliases. Git aliases in gitconfig
# --------------------------------------
alias sdi="sudo dnf install"
alias sdu="sudo dnf uninstall"
alias sds="sudo dnf search"
alias lg="lazygit"
alias tp="trashy"
alias eza="eza --icons"
alias es="eza -l --icons --git -a"
alias et="eza --tree --level=2 --long --icons --git"
alias eg="eza -l --git --git-repos --header"
alias cd="z"
alias cdsd="z ~/work/_sdui"
alias 1pl="op signin grk_family"
alias kctx="kubectx"
alias kuns="kubens"
alias reload="source ~/.zshrc"
alias venv="virtualenv"
alias s="sudo"
alias bri="brew install"
alias bru="brew remove" 
alias brs="brew search"
alias ku="kubectl"
alias wt="curl wttr.in/berlin"
alias juc="soccer --team=JUVE --upcoming --time=30"
alias cas="soccer --standings --league=SA"
alias car="soccer --league=SA"
alias zshconfig="e ~/.zshrc"
alias tmuxc="vim ~/.tmux.conf"
alias mc="mc -S nicedark"
alias e="/usr/bin/nvim"
alias vim=nvim
alias v=nvim
alias myip="ifconfig | grep \"inet \" | grep -v 127.0.0.1 | cut -d\  -f2"
alias grep="grep --color=auto"
alias ping="ping -c 5"
alias ds="du -shc"
alias dsf="du -h -d 2 | sort -hr"
alias df="df -h"
alias up="cd .."
alias clr="clear"
alias upp="cd ..."
alias tlps="sudo tlp-stat -s"
alias vg="vagrant"
alias bc="bc -l"
alias ports="netstat -tulanp"
# Git aliases
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
alias oktaws='saml2aws login --profile=default && eval $(saml2aws script --profile=default)'
# ----------------------------------------
# Some ssh aliase for better management
# -----------------------------------------
#alias sshDoLightProd="ssh -p 24986 mayalabs@128.199.53.215"

# -----------------------------------------
# User configuration
# -----------------------------------------

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/"
export EDITOR='nvim'

# function to extract archives
# EXAMPLE: unpack file
unpack () {
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2)   tar xjfv $1                             ;;
      *.tar.gz)    tar xzfv $1                             ;;
      *.tar.xz)    tar xvJf $1                             ;;
      *.bz2)       bunzip2 $1                              ;;
      *.gz)        gunzip $1                               ;;
      *.rar)       unrar x $1                              ;;
      *.tar)       tar xf $1                               ;;
      *.tbz)       tar xjvf $1                             ;;
      *.tbz2)      tar xjf $1                              ;;
      *.tgz)       tar xzf $1                              ;;
      *.zip)       unzip $1                                ;;
      *.Z)         uncompress $1                           ;;
      *.7z)        7z x $1                                 ;;
      *)           echo "I don't know how to extract '$1'" ;;
    esac
  else
    case $1 in
      *help)       echo "Usage: unpack ARCHIVE_NAME"       ;;
      *)           echo "'$1' is not a valid file"         ;;
    esac
  fi
}
# function to create archives
# EXAMPLE: pack tar file
pack () {
  if [ $1 ]; then
    case $1 in
      tar.bz2)     tar -cjvf $2.tar.bz2 $2                 ;;
      tar.gz)      tar -czvf $2.tar.bz2 $2                 ;;
      tar.xz)      tar -cf - $2 | xz -9 -c - > $2.tar.xz   ;;
      bz2)         bzip $2                                 ;;
      gz)          gzip -c -9 -n $2 > $2.gz                ;;
      tar)         tar cpvf $2.tar  $2                     ;;
      tbz)         tar cjvf $2.tar.bz2 $2                  ;;
      tgz)         tar czvf $2.tar.gz  $2                  ;;
      zip)         zip -r $2.zip $2                        ;;
      7z)          7z a $2.7z $2                           ;;
      *help)       echo "Usage: pack TYPE FILES"           ;;
      *)           echo "'$1' cannot be packed via pack()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# fortune | cowsay | lolcat

# autoload -U +X bashcompinit && bashcompinit
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

#eval "$(starship init zsh)"
#autoload -Uz compinit && compinit
autoload -U compinit; compinit
source /home/rustamgk/github/fzf-tab/fzf-tab.plugin.zsh

#autoload -U +X bashcompinit && bashcompinit
#complete -o nospace -C /opt/homebrew/bin/terraform terraform

ZSH_TMUX_AUTOSTART=true

if [ -z "$TMUX" ]
then
    tmux attach -t main || tmux new -s main
fi

eval "$(fzf --zsh)"

eval "$(zoxide init zsh)"
