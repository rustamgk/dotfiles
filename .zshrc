# -----------------------------------------
# ZSH config file
# Author: Galimyanov Rustam
# Year of start: 2015
# Current year of config: 2017
# -----------------------------------------

# Core ZSH settings
export PATH=$HOME/bin:/usr/local/bin:/usr/local/go/bin:$HOME/.local/bin:$PATH
export ZSH=/home/rustam.gk/.oh-my-zsh
export GOPATH=$HOME/go
export CHEATCOLORS=true
export PYTHONPATH=""

#export JAVA_HOME=/usr/java/latest
#export PATH=$PATH:/usr/local/go/bin
ZSH_THEME="agnostermy/agnosterzak"
plugins=(systemd pip ansible fasd sdkman vagrant aws git fedora git-flow gem dnf docker git-extras git-prompt history man python tmux yum zsh-navigation-tools )
source $ZSH/oh-my-zsh.sh

# --------------------------------------
# My aliases. Git aliases in gitconfig
# --------------------------------------
alias do_oracle12c="docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle sath89/oracle-12c
"

alias s="sudo"
alias sdi="sudo dnf install"
alias sdr="sudo dnf remove" 
alias sdu="sudo dnf update"
alias labbox01="ssh rustam.gk@10.0.10.5"
alias doams02="ssh root@95.85.39.87"
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
alias e="/bin/vim"
alias myip="ifconfig | grep \"inet \" | grep -v 127.0.0.1 | cut -d\  -f2"
alias gr="git-recall"
#alias ls="ls --color=auto"
#alias ll="ls --group-directories-first -l --human-readable"
alias dnsrefresh="dscacheutil -flushcache"
alias grep="grep --color=auto"
alias ping="ping -c 5"
alias ds="du -shc"
alias dsf="du -h --max-depth=1 | sort -hr"
alias df="df -h"
alias up="cd .."
alias clr="clear"
alias upp="cd ..."
alias ec2vol="aws ec2 describe-volumes --output table"
alias ec2ins="aws ec2 describe-instances --output table"
alias rm="rm -i"
alias tlps="sudo tlp-stat -s"
alias vg="vagrant"
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

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

fortune | cowsay | lolcat

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/rustam.gk/.sdkman"
[[ -s "/home/rustam.gk/.sdkman/bin/sdkman-init.sh" ]] && source "/home/rustam.gk/.sdkman/bin/sdkman-init.sh"

if [ -z "$TMUX" ]
then
            tmux attach -t TMUX || tmux new -s TMUX
    fi
