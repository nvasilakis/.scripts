#!/bin/bash

SYSTEM="$(uname)"
VIM=~/.vim/
SCRIPTS=~/scripts/
EMACS=~/.emacs.d/
SHELL=~/.dotrc/
FILES=".bashrc .conkyrc .hgrc .irbrc .vimrc .zshrc .pythonrc .emacs";
FILES="${FILES} .screenrc .pentadactylrc  .gitconfig .Xdefaults .ss";
FILES="${FILES} .ocamlinit";
BAK=".rc_backups"
GIT_EXEC=$(which git > /dev/null && echo '0' || echo '1')
WGET_EXEC=$(which wget > /dev/null && echo '0' || echo '1')
CURL_EXEC=$(which curl > /dev/null && echo '0' || echo '1')
# Packages to install -- git is the absolute minimum
MIN="git"
MID="zsh screen htop"
MAX="autoconf libncurses5-dev"
ABS_MIN="https://github.com/nvasilakis/dotrc/archive/master.zip"
PKG_MGR=""
OVER_HTTP="False";
FULL_INSTALL="True";

usage () {
  cat <<EOF
  Setup environment first time.

    ./${0} [-c]

    will download and setup environment from github
    * -c: cleans up existing setup
    * -h: shows this message
EOF
}

isInstalled () {
  [ -x "$(which $1)" ]
}

#cleanup everything
clean () {
 rm -rf ${VIM}
 rm -rf ${SCRIPTS}
 rm -rf ${EMACS}
 rm -rf ${SHELL}
 for f in $FILES; do
   touch "~/${f}" && rm "~/${f}"
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

fetch () {
  if [[ $WGET_EXEC == '0' ]]; then
    wget $1
  elif [[ $CURL_EXEC == '0' ]]; then
    curl -LOk $1
  else
    echo 'You have neither curl nor wget, what else can we do than abort?'
    exit -1
  fi
}

# Check which argument we have
while getopts "ch" opt; do
  case $opt in
    c) 
      clean
      exit 0;
      ;;
    h) 
      usage;
      exit 0;
      ;;
    :)
      out "Need extra argument for ${OPTARG}. -h brings up help."
      exit 1;
      ;;
  esac
done

# TODO: If OS X set up brew, install patched screen

echo -n "Default is git over ssh -- prefer http?[y/N]"
read pls < /dev/tty
if [[ $pls == 'y' || $pls == 'Y' ]]; then
  OVER_HTTP="True";
fi

echo -n "Do you want full install? (e.g., vim, git, zsh, screen, updates) [Y/n]"
read pls < /dev/tty
if [[ $pls == 'n' || $pls == 'N' ]]; then
  FULL_INSTALL="False";
fi

check () {
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

getConfig () {
  echo "Trying to generate and setup keys"
  fetch https://raw.github.com/nvasilakis/scripts/master/setup-keys.sh
  chmod +x setup-keys.sh
  ./setup-keys.sh
  if [[ $OVER_HTTP == "False" ]]; then # if success
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
  cd ..
  rm setup-keys.sh
  cd ~/.dotrc
  linkEm
}

## Set up package managers and everything
## Currently tested with debian-based and os x
presetup() {
  if [[ `uname` == 'Linux' ]]; then
    if isInstalled apt-get ; then 
      sudo apt-get update 
      if [[ $FULL_INSTALL == 'True' ]]; then
       sudo apt-get upgrade
      fi
      PKG_MGR="apt-get install -y ";
    elif isInstalled yum ; then 
      PKG_MGR="yum install";
    elif isInstalled pacman ; then 
      PKG_MGR="pacman install"
    elif isInstalled emerge ; then 
      PKG_MGR="emerge install"
    elif isInstalled zypp ; then 
      PKG_MGR="zypp install"
    fi
    PKGS="$MIN $MID"
    sudo $PKG_MGR $PKGS
  elif [[ `uname` == 'Darwin' ]]; then
    echo -n "Current hostname is $(hostname) -- please suggest one (empty for no change)"
    read newhostname < /dev/tty
    # TODO right check
    if [[ $newhostname == "" ]]; then
      echo "No change then!"
      sleep 1
    else
      sudo scutil --set HostName $newhostname
    fi
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if isInstalled apt-get ; then 
      PKG_MGR="brew install";
    fi
    PKGS="$MIN $MID automake"
    brew install $PKGS
    git clone https://github.com/FreedomBen/screen-for-OSX.git &&
    cd screen-for-OSX &&
    ./install.sh &&
    cd .. &&
    sudo cp /usr/local/bin/screen /usr/bin/screen &&
    rm -rf screen-for-OSX
  fi
}

setup () {
  presetup
  # Most probably OSX, and if true, will use curl
  if [[ $PKG_MGR == "" ]]; then
    echo 'Could not find package manager,' 
    echo '..proceeding just with configuration fetch (min)'
    if [[ $GIT_EXEC == '1' ]]; then
      echo 'Could not even find git -- proceeding with the absolute minimum!'
      fetch $ABS_MIN;
      linkEm
    else
      getConfig
    fi
  else
    getConfig
  fi
}

setup
