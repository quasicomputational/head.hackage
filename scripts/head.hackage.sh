#!/bin/bash

cat_repo () {
cat <<EOF
repository head.hackage
   url: http://head.hackage.haskell.org/
   secure: True
   root-keys: 07c59cb65787dedfaef5bd5f987ceb5f7e5ebf88b904bbd4c5cbdeb2ff71b740
              2e8555dde16ebd8df076f1a8ef13b8f14c66bad8eafefd7d9e37d0ed711821fb
              8f79fd2389ab2967354407ec852cbe73f2e8635793ac446d09461ffb99527f6e
   key-threshold: 3

EOF
}

# this needs to match the `remote-repo-cache` global config setting
PKGCACHE="${HOME}/.cabal/packages"

# set this to the name or (or full path if not in $PATH) of the GHC HEAD executable
GHC=ghc-head

if [ ! -d "$PKGCACHE" ]; then
  echo "package cache doesn't seem exist; please edit script" >&2
  exit 1
fi

case "X$1" in
  Xupdate)
    CFGFILE=$(mktemp)
    cat_repo > $CFGFILE

    # we need to wipe the cache for head.hackage to workaround issues in hackage-security
    rm -rf "$PKGCACHE/head.hackage/"

    echo "http-transport: plain-http" >> $CFGFILE
    echo "remote-repo-cache: $PKGCACHE" >> $CFGFILE

    cabal --config-file=$CFGFILE update
    ;;

  Xinit)
    if [ -e cabal.project ]; then
      echo "cabal.project file exists already; aborting" >&2
      exit 1
    fi

    echo "creating new cabal.project file"

    cat > cabal.project <<EOF
packages: .

with-compiler: $GHC

EOF

    cat_repo >> cabal.project
    ;;

  Xhelp)
    cat <<EOF
Usage: $0 <command>

Known <commands>

 update   update head.hackage package index

 init     create cabal.project file for GHC HEAD

 help     show help (you're here)

EOF
    ;;

  X)
    echo "no command given; try 'help'" >&2
    exit 1
    ;;

  *)
    echo "unrecognised command '$1'; try 'help'" >&2
    exit 1
    ;;
esac
