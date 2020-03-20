# -----------------------------------------
# ZSH config file
# Author: Galimyanov Rustam
# Initial date: 2007
# Current year of config: 2019
# -----------------------------------------

# Core PATH settings
export PATH="/usr/local/bin:/usr/bin:/usr/local/opt/ruby/bin:/usr/local/go/bin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export ZSH=/Users/rustomgalimyanov/.oh-my-zsh
export GOPATH=$HOME/go

export CHEATCOLORS=true
export HOMEBREW_GITHUB_API_TOKEN="0e58102448f07495e0350f09e32ae746e3e1d2ef"

export GITLAB_TOKEN="Upy1-LX-F862eM7z1Pxh"

ZSH_THEME="spaceship"

SPACESHIP_PROMPT_ORDER=(
  time
  user
  host
  dir
  git
  package
  node
  ruby
  xcode
  swift
  golang
  docker
  aws
  conda
  kubectl
  kubectl_version
  kubectl_context
  terraform
  battery
  exec_time
  line_sep
  vi_mode
  jobs
  exit_code
  char
  )

autoload -Uz compinit && compinit
plugins=(zsh-navigation-tools)
# ----------------------------------------
source ~/.zplug/init.zsh

if ! zplug check; then
        zplug install
fi

zplug "jonmosco/kube-ps1"
zplug "plugins/zsh-navigation-tools", from:oh-my-zsh
zplug "lib/theme-and-appearance", from:oh-my-zsh
zplug "lib/clipboard", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/directories", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/history", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh
zplug "plugins/ansible", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/man", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/brew", from:oh-my-zsh
zplug "plugins/pip", from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "hlissner/zsh-autopair"
zplug "MikeDacre/careful_rm"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "denysdovhan/spaceship-prompt", as:theme
zplug "agkozak/zsh-z"

zplug load

# --------------------------------------
source $ZSH/oh-my-zsh.sh

# --------------------------------------
# My aliases. Git aliases in gitconfig
# --------------------------------------

alias reload="source ~/.zshrc"
alias venv="virtualenv"
# alias do_oracle12c="docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle sath89/oracle-12c"
alias s="sudo"
#alias sdi="sudo dnf install"
#alias sdr="sudo dnf remove" 
#alias sdu="sudo dnf update"
alias kctl="kubectl"
alias bri="brew install"
alias bru="brew uninstall"
alias brs="brew search"
alias brl="brew list"
alias labbox01="ssh rustam.gk@10.0.10.5"
#alias doams02="ssh root@95.85.39.87"
alias wt="curl wttr.in/krakow"
alias juc="soccer --team=JUVE --upcoming --time=30"
alias cas="soccer --standings --league=SA"
alias car="soccer --league=SA"
alias zshconfig="vim ~/.zshrc"
alias vlm5="setvolume 50"
alias vlm1="setvolume 100"
alias vlm0="setvolume 0"
alias rm="trash"
#alias ohmyzsh="vim ~/.oh-my-zsh"
alias tmuxc="vim ~/.tmux.conf"
alias tmuxcp="vim ~/.tmux-powerlinerc"
alias mc="mc -S nicedark"
alias ss="exec $SHELL"
alias e="/usr/local/bin/vim"
alias myip="ifconfig | grep \"inet \" | grep -v 127.0.0.1 | cut -d\  -f2"
alias gr="git-recall"
alias ls="ls -G"
alias ll="ls -lht"
alias dnsrefresh="dscacheutil -flushcache"
alias grep="grep --color=auto"
alias ping="ping -c 5"
alias ds="du -shc"
alias dsf="du -h -d 2 | sort -hr"
alias df="df -h"
alias up="cd .."
alias clr="clear"
alias upp="cd ..."
alias ec2vol="aws ec2 describe-volumes --output table"
alias ec2ins="aws ec2 describe-instances --output table"
#alias rm="rm -i"
alias tlps="sudo tlp-stat -s"
alias vg="vagrant"
alias bc="bc -l"
alias ports="netstat -tulanp"
#alias rm="rm -I --preserve-root"
alias restartaudio="sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'`"
# Git aliases
alias glo="git log --oneline"
# git
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
alias gl="git log --pretty --oneline --graph"
alias gA="git add -A"
alias gri="git rebase -i"
alias grc="git rebase --continue"
alias gra="git rebase --abort"

# ----------------------------------------
# Some ssh aliase for better management
# -----------------------------------------
#alias sshDoLightProd="ssh -p 24986 mayalabs@128.199.53.215"

# -----------------------------------------
# User configuration
# -----------------------------------------

# MC skin
export MC_SKIN=~/.mc/solarized.ini

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='vim'
 fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/dsa_id"
export EDITOR='vim'
# export PAGER='vim'

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


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/rustomgalimyanov/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/rustomgalimyanov/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/rustomgalimyanov/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/rustomgalimyanov/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

fortune | cowsay | lolcat

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
