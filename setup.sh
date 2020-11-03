#!/bin/bash

# TODO: Need to create a minimal setup-git/rc script for downloading configuration and setting up files on a machine without root privileges.

SYSTEM="$(uname)"
REPOS=".dotrc .vim .emacs.d .scripts";
RC=".bashrc .conkyrc .hgrc .irbrc .vimrc .zshrc .pythonrc .screenrc .emacs";
RC="${RC} .ocamlinit .pentadactylrc  .gitconfig .Xdefaults .ss";
BAK=".rc_backups"
GIT_EXEC=$(which git > /dev/null && echo '0' || echo '1')
WGET_EXEC=$(which wget > /dev/null && echo '0' || echo '1')
CURL_EXEC=$(which curl > /dev/null && echo '0' || echo '1')
# Packages to install -- git is the absolute minimum
SW="git zsh screen htop autoconf libncurses5-dev"


ABS_MIN="https://github.com/nvasilakis/dotrc/archive/master.zip"
PKG_MGR=""
PROTOCOL="${PROTOCOL:-git}"; # can override with HTTP
FULL_INSTALL="True";

usage() {
  cat <<EOF
  Setup environment first time.

    ./${0} [-c]

    will download and setup environment from github
    * -c: cleans up existing setup
    * -h: shows this message
EOF
}

isInstalled() {
  [ -x "$(which $1)" ]
}

#cleanup everything
clean() {
  for d in $REPOS; do
    rm -rf $d
  done

  for f in $RC; do
    echo removing $f
    rm ~/${f}
  done

  # Restore from backup 
  cp ~/$BAK/*/.*rc  ~/
}

# Keep a backup of .*rc, in case we need to rollback
backup() {
  dt=$(date "+%Y.%m.%d.%H.%M.%S")
  echo "Backing up .*rc files in $BAK/$dt"
  mkdir -p ~/$BAK/$dt
  cp ~/.*rc ~/$BAK/$dt/
  echo "Backup complete"
}

fetch() {
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

#echo -n "Default is git over ssh -- prefer http?[y/N]"
#read pls < /dev/tty
#if [[ $pls == 'y' || $pls == 'Y' ]]; then
#  PROTOCOL="True";
#fi

#echo -n "Do you want full install? (e.g., vim, git, zsh, screen, updates) [Y/n]"
#read pls < /dev/tty
#if [[ $pls == 'n' || $pls == 'N' ]]; then
#  FULL_INSTALL="False";
#fi

check() {
  sudo apt-get install "$1" || echo "Install $1";
}

check_install() {
  for prog; do
    #echo "Install ${prog}"
    command -v "${prog}" >/dev/null 2>&1 || { icheck "${prog}"; }
  done
}

gen_key() {
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa -C $(whoami)@$(uname -n)

  desc="$(date +%D)"
  user="nvasilakis"
  # Cannot quote because shell won't expand `~`!
  path=~/.ssh/id_rsa.pub
  title="$(whoami) $(uname -n) ($desc)"
  key_data="$(cat "$path")"
  curl -u "${user:=$USER}" \
    --data "{\"title\":\"$title\",\"key\":\"$key_data\"}" \
    https://api.github.com/user/keys
    # ssh-add ~/.ssh/id_rsa
}

config() {
  if [[ $PROTOCOL == "git" ]]; then
    gen_key
    for d in $REPOS; do
      git clone git@github.com:nvasilakis/$d.git $d
    done
  else
    for d in $REPOS; do
      git clone https://github.com/nvasilakis/$d.git $d
    done
  fi
	cd ~/.vim
	git submodule update --init
  for i in $RC; do
    rm -rf ~/$i
    ln -s ~/.dotrc/$i ~/$i
  done

  if [[ `uname` == 'Linux' ]]; then
    sudo apt install unzip
    git clone git@github.com:chrishantha/install-java.git
    cd install-java
    wget http://nikos.vasilak.is/sw/jdk-8u251-linux-x64.tar.gz
    cat <(echo 'y') <(echo 'n') | sudo ./install-java.sh -f ./jdk-8u251-linux-x64.tar.gz 
    cd ..
    rm -rf install-java
  else
    echo install JDK8: http://nikos.vasilak.is/sw/jdk-8u251-macosx-x64.dmg
  fi
}

osxhostname() {
  if [ grep -c "^$(hostname)$" -eq 1 ]; then
    echo -n "Current hostname is $(hostname) -- please suggest one (empty for no change)"
    read newhostname < /dev/tty
    # TODO right check
    if [[ $newhostname == "" ]]; then
      echo "No change then!"
    else
      sudo scutil --set HostName $newhostname
    fi
  fi
}

## Set up package managers and everything
## Currently tested with debian-based and os x
presetup() {
  if [[ `uname` == 'Linux' ]]; then
    if isInstalled apt-get ; then 
      sudo apt-get update 
      sudo apt-get upgrade
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
    sudo $PKG_MGR $PKGS
  elif [[ `uname` == 'Darwin' ]]; then
    osxhostname
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if isInstalled apt-get ; then 
      PKG_MGR="brew install";
    fi
    PKGS="$MIN $MID automake"
    brew install $PKGS
    git clone git://git.savannah.gnu.org/screen.git
    cd screen/src
    mkdir -p /opt/etc
    mv etc/etcscreenrc /opt/etc/screenrc
    ./autogen.sh
    ./configure --prefix=/opt/Cellar/screen/3.6.0  --enable-colors256 --with-sys-screenrc=/opt/etc/screenrc
    make
    make install
    brew link screen
    rm -rf screen
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
