#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
if [[ -z $1 ]]; then
    echo "Usage $0 <FORMULA_NAME>"
    exit 1;
fi
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
brew tap digitalspacestdio/common
cd $(brew tap-info --json digitalspacestdio/common | jq -r '.[].path')
git stash
git pull

FORMULAS=$(brew search digitalspacestdio/common | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)
echo "==> Next formulas found:"
echo "$FORMULAS"
sleep 5
for FORMULA in $FORMULAS; do
    echo "==> Ceating bottles for $FORMULA ..."
    rm -rf ${HOME}/.bottles/$FORMULA.bottle
    mkdir -p ${HOME}/.bottles/$FORMULA.bottle
    cd ${HOME}/.bottles/$FORMULA.bottle

    echo "==> Installing dependencies for $FORMULA ..."

    brew deps --direct $FORMULA | grep $FORMULA | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf '--no-run-if-empty'; fi;) -I{} bash -c 'brew uninstall -f --ignore-dependencies {} || /usr/bin/true'

    if brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$" > /dev/null; then
        if brew deps $(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$") | grep -v $FORMULA > /dev/null; then
            brew install --quiet $(brew deps $(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$") | grep -v $FORMULA)
        fi
    fi

    echo "==> Building bottles for $FORMULA ..."
    brew install --quiet --build-bottle $FORMULA 2>&1
    brew bottle --skip-relocation --no-rebuild --root-url 'https://f003.backblazeb2.com/file/homebrew-bottles/'$FORMULA --json $FORMULA
    ls | grep $FORMULA'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
    ls | grep $FORMULA'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
    cd $(brew tap-info --json digitalspacestdio/common | jq -r '.[].path')
done