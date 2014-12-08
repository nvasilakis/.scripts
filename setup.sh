#!/bin/bash

SYSTEM="$(uname)"
VIM=~/.vim/
SCRIPTS=~/scripts/
EMACS=~/.emacs.d/
SHELL=~/.dotrc/
FILES=".bashrc .conkyrc .hgrc .irbrc .vimrc .zshrc .pythonrc .emacs";
FILES="${FILES} .screenrc .pentadactylrc  .gitconfig .Xdefaults .ss";
BAK=".rc_backups"
GIT_EXEC=$(which git > /dev/null && echo '0' || echo '1')
WGET_EXEC=$(which wget > /dev/null && echo '0' || echo '1')
CURL_EXEC=$(which curl > /dev/null && echo '0' || echo '1')
# Packages to install -- git is the absolute minimum
MIN="git"
MID="zsh screen htop"
MAX="autoconf libncurses5-dev"
TRY_UPGRADE="True"
ABS_MIN="https://github.com/nvasilakis/dotrc/archive/master.zip"
PKG_MGR=""

if [[ `uname` == 'Linux' ]]; then
  echo -n "Do you also want to try upgrade?[Y/n]"
  read pls
  if [[ $pls == 'n' || $pls == 'N' ]]; then
    TRY_UPGRADE='False'
  fi
fi

usage () {
  cat <<EOF
    Setup environment based on nikos.vasilak.is/rc, after backing up

      ./${0} [--{min,mid,max}] [--help]

      will download environment from github
      * min  will install minimum required packages (git)
          -- if this is not available, will fall back to http
      * mid  will include zsh, screen and htop on Linux
      * max  will compile latest stable gnu screen
      * help shows this message
EOF
}

isInstalled () {
  [ -x "$(which $1)" ]
}

cleanup () {
  echo "cleaning up $FNAME $THIS"
  rm "$FNAME" "$THIS"
}

#cleanup everything
clean () {
 rm -rf ${VIM}
 rm -rf ${SCRIPTS}
 rm -rf ${EMACS}
 rm -rf ${SHELL}
 for f in $FILES; do
   touch ~/${f} && rm "~/${f}"
 done
}

# Keep a backup of everything, in case we need to rollback
# N.b.: only .*rc files
function backup {
  dt=$(date "+%Y.%m.%d.%H.%M.%S")
  echo "Backing up .*rc files in $BAK/$dt"
  mkdir -p ~/$BAK/$dt
  cp ~/.*rc ~/$BAK/$dt/
  echo "Backup complete"
}

icheck () {
  sudo apt-get install "$1" || echo "Install $1";
}

check_install () {
  for prog; do
    #echo "Install ${prog}"
    command -v "${prog}" >/dev/null 2>&1 || { icheck "${prog}"; }
  done
}

linkEm () {
  for i in $FILES; do
    echo "installing: ~/.dotrc/$i ~/$i"
    rm -rf ~/$i
    ln -s ~/.dotrc/$i ~/$i
  done
}

main () {
  if [[ `uname` == 'Linux' ]]; then
    if isInstalled apt-get ; then 
      echo "Found apt-get, updating"
      sudo apt-get update 
      if [[ $TRY_UPGRADE == 'True' ]]; then
       sudo apt-get upgrade
      fi
      PKG_MGR="apt-get install -y ";
    elif isInstalled yum ; then 
      PKG_MGR="yum";
    elif isInstalled pacman ; then 
      PKG_MGR="pacman"
    elif isInstalled emerge ; then 
      PKG_MGR="emerge"
    elif isInstalled zypp ; then 
      PKG_MGR="zypp"
    fi
  fi


  # Most probably OSX, and if true, will use curl
  if [[ $PKG_MGR == "" ]]; then
    echo 'Could not find package manager,' 
    echo '..proceeding just with configuration fetch (min)'
    if [[ $GIT_EXEC == '1' ]]; then
      echo 'Could not even find git -- proceeding with the absolute minimum!'
      if [[ $WGET_EXEC == '0' ]]; then
        wget $ABS_MIN
        linkEm
      elif [[ $CURL_EXEC == '0' ]]; then
        curl -LOk $ABS_MIN
        linkEm
      else
        echo 'You lack package manager, wget and curl -- no luck!  Aborting..'
        exit -1
      fi
    fi
  else
    echo 'FIXME: min|mid|max'
    PKGS="$MIN $MID" #FIXME
    sudo $PKG_MGR $PKGS

    echo "Trying to generate and setup keys"
    wget https://raw.github.com/nvasilakis/scripts/master/setup-keys.sh
    chmod +x setup-keys.sh # FIXME: See below
    ./setup-keys.sh # FIXME: Make sure this returns correct result!
    if [[ $? == 0 ]]; then # if success
      git clone git@github.com:nvasilakis/immateriia.git ${VIM}
      git clone git@github.com:nvasilakis/scripts.git    ${SCRIPTS}
      git clone git@github.com:nvasilakis/.emacs.d.git   ${EMACS}
      git clone git@github.com:nvasilakis/dotrc.git      ${SHELL}
      cd ~/.vim
      echo 'updating submodules'
      git submodule update --init
    else
      git clone https://github.com/nvasilakis/immateriia.git ${VIM}
      git clone https://github.com/nvasilakis/scripts.git    ${SCRIPTS}
      git clone https://github.com/nvasilakis/.emacs.d.git   ${EMACS}
      git clone https://github.com/nvasilakis/dotrc.git      ${SHELL}
      cd ~/.vim
      echo 'updating submodules'
      git submodule update --init
    fi
    # cleanup
    rm setup-keys.sh
    cd ~/.dotrc
    linkEm
  fi
}

main
