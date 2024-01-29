#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

FORMULAS=${@:-$(brew search digitalspacestdio/php | grep 'php[7-9]\{1\}[0-9]\{1\}$' | awk -F'/' '{ print $3 }' | sort)}

for formula in $FORMULAS; do
    echo "---> Starting $formula"
    ./_php-bottles-make.sh $formula && {
        if [[ -z $NO_UPLOAD ]];  then
            ./_php-bottles-upload.sh $formula || echo "Failed to upload bottles for $formula"
        fi
    } || echo "Failed to build bottles for $formula"
    echo "---> Finished $formula"
done