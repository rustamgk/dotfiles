# -----------------------------------------
# ZSH config file
# Author: Galimyanov Rustam
# Initial date: 2007
# Current year of config: 2019
# -----------------------------------------

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/opt/ruby/bin:/usr/local/go/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export ZSH=/Users/rustamgk/.oh-my-zsh
#export CHEATCOLORS=true
export HOMEBREW_GITHUB_API_TOKEN="69c0fe0465cfd6c21c3a696e7ca6b1ba205bbdcc"
export GITLAB_TOKEN="ffad8810bc3dc1e0760360d85d17d3a6c4a1632c"
export GITLAB_ACCESS_TOKEN="PtK2opxAymkzwZ6zv_Tt"
#export GOPATH = "/Users/rustamgk/go"
#export GOROOT = "$(brew --prefix golang)/libexec"
#export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

#export FPATH = /opt/homebrew/share/zsh/site-functions:$FPATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
autoload -Uz compinit && compinit
# ----------------------------------------

plugins=(zsh-syntax-highlighting zsh-autosuggestions autojump vscode zsh-interactive-cd tmux ubuntu thefuck terraform  git kubectl docker python pyenv helm history golang common-aliases colored-man-pages ansible aliases  zsh-navigation-tools)

# --------------------------------------
#source $ZSH/oh-my-zsh.sh

# --------------------------------------
# My aliases. Git aliases in gitconfig
# --------------------------------------
alias cdvc="cd ~/repos/_vc"
alias 1pl="op signin grk_family"
alias kuctx="kubectx"
alias kuns="kubens"
alias reload="source ~/.zshrc"
alias venv="virtualenv"
# alias do_oracle12c="docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle sath89/oracle-12c"
alias s="sudo"
#alias sdi="sudo dnf install"
#alias sdr="sudo dnf remove" 
#alias sdu="sudo dnf update"
alias ku="kubectl"
alias bri="brew install"
alias bru="brew uninstall"
alias brs="brew search"
alias brl="brew list"
alias labbox01="ssh rustam.gk@10.0.10.5"
#alias doams02="ssh root@95.85.39.87"
alias wt="curl wttr.in/berlin"
alias juc="soccer --team=JUVE --upcoming --time=30"
alias cas="soccer --standings --league=SA"
alias car="soccer --league=SA"
alias zshconfig="vim ~/.zshrc"
alias vlm5="setvolume 50"
alias vlm1="setvolume 100"
alias vlm0="setvolume 0"
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
alias gl="git log --pretty --oneline --graph"
alias gA="git add -A"
alias gri="git rebase -i"
alias grc="git rebase --continue"
alias gra="git rebase --abort"
alias mvim="open -a MacVim"
alias oktaws='saml2aws login --profile=default && eval $(saml2aws script --profile=default)'
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
export SSH_KEY_PATH="~/.ssh/"
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

# fortune | cowsay | lolcat

# autoload -U +X bashcompinit && bashcompinit
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath+=(~/.config/hcloud/completion/zsh)
source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
autoload -Uz compinit && compinit


#autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

