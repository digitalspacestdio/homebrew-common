#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

FORMULAS=$(brew search digitalspacestdio/common | grep "$1\|$1@.\+" | awk -F'/' '{ print $3 }' | sort)

for FORMULA in $FORMULAS; do
    echo "---> Starting $FORMULA"
    ./_common-bottles-make.sh $FORMULA && {
        if [[ -z $NO_UPLOAD ]];  then
            ./_common-bottles-upload.sh $FORMULA || echo "Failed to upload bottles for $FORMULA"
        fi
    } || echo "Failed to build bottles for $FORMULA"
    echo "---> Finished $FORMULA"
done