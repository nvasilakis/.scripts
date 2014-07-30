#!/bin/bash

## TODO: Determine presence of libraries needed
## - zlib-devel

## User-configurable variables

GHC_VERSION=7.6.3
CABAL_VERSION=1.18.0.2

GHC_INSTALL_DIR=$HOME/ghc

DEFAULT_CABAL_LIBS="happy alex"

## End user-configurable variables

set -eux

CABAL_INSTALL_DIR=$HOME/.cabal

FAIL="NO"
check_dir_no_exist () {
    if [ -d "$1" ]
    then
        echo "$1 already exists"
        echo "Please remove $1 before trying again"
        FAIL="FAIL"
    fi
}

finalize_check () {
    if [ "$FAIL" = "FAIL" ]
    then
        exit 1
    fi
}

# check_dir_no_exist "$GHC_INSTALL_DIR"
check_dir_no_exist "$CABAL_INSTALL_DIR"
finalize_check

#ghc
GHC_EXT=tar.bz2
GHC_NO_EXT=ghc-${GHC_VERSION}
GHC_WITH_EXT=${GHC_NO_EXT}-x86_64-unknown-linux.${GHC_EXT}
GHC_URL=http://www.haskell.org/ghc/dist/${GHC_VERSION}/${GHC_WITH_EXT}

# cabal-install
CABAL_EXT=tar.gz
CABAL_NO_EXT=cabal-install-${CABAL_VERSION}
CABAL_WITH_EXT=${CABAL_NO_EXT}.${CABAL_EXT}
CABAL_URL=http://www.haskell.org/cabal/release/cabal-install-${CABAL_VERSION}/${CABAL_WITH_EXT}

# make a temporary directory to work in
TMP_DIR=`mktemp -d`

pushd $TMP_DIR &> /dev/null

## download GHC, unpack, install
wget "$GHC_URL"
tar xjf $GHC_WITH_EXT
pushd $GHC_NO_EXT &> /dev/null
./configure --prefix=$GHC_INSTALL_DIR
make install
popd &> /dev/null

## download cabal, unpack, install
wget "$CABAL_URL"
tar xzf $CABAL_WITH_EXT
pushd $CABAL_NO_EXT &> /dev/null
chmod 700 bootstrap.sh

PATH_ADD=$GHC_INSTALL_DIR/bin:$CABAL_INSTALL_DIR/bin
export PATH=$PATH_ADD:$PATH
echo "Make sure to update your PATH to include ${PATH_ADD}"
./bootstrap.sh --user
popd &> /dev/null

# update cabal, install base packages
cabal update
cabal install ${DEFAULT_CABAL_LIBS}

popd &> /dev/null

## remove temporary directory (but only if we succeed)
rm -rf $TMP_DIR
