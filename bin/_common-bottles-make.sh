#!/bin/bash
set -e
export DEBUG=${DEBUG:-''}
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null

TAP_NAME=${TAP_NAME:-"digitalspacestdio/common"}
TAP_NAME_PREFIX="${TAP_NAME}/"
TAP_SUBDIR=$(echo $TAP_NAME | awk -F/ '{ print $2 }')
BASE_ROOT_URL="https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/${TAP_SUBDIR}"

brew install md5sha1sum jq s3cmd
brew tap "${TAP_NAME}"

ARGS=${@:-$(brew search "${TAP_NAME}" | grep "${TAP_NAME}")}
REBUILD=${REBUILD:-''}

export FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$ARGS" | md5sum | awk '{ print $1 }')}
export HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-$(brew --prefix)}
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=0

if [[ -n $REBUILD ]] || ! [[ -f "/tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp" ]]; then
    echo -n '' > /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
fi

for ARG in $ARGS
do
    FORMULAS=$(brew search "${TAP_NAME}" | grep "${TAP_NAME}" | grep "\($ARG\|$ARG@[0-9]\+\)\$" | sort)
    if [[ -n "$FORMULAS" ]]; then
        for FORMULA in $FORMULAS; do
            if [[ "true" != $(brew info --json=v1 ${FORMULA} | jq '.[0].deprecated') ]]; then
                find "${HOMEBREW_PREFIX}/etc" -maxdepth 1 -name "${FORMULA//"$TAP_NAME_PREFIX"/}*" -exec rm -v -rf {} \; || true
                if [[ -n $REBUILD ]]; then
                    brew list | grep '^'${FORMULA//"$TAP_NAME_PREFIX"/}'$' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'brew uninstall --force --ignore-dependencies {} --verbose || true'
                    brew deps --full --direct $FORMULA | grep "${TAP_NAME}" | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'brew uninstall --force --ignore-dependencies {} --verbose || true'
                    rm -rf ${HOME}/.bottles/$FORMULA.bottle
                fi
                for DEP in $(brew deps --full --direct $FORMULA | grep "${TAP_NAME}"); do
                    if ! grep -q "$DEP$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp; then
                        echo -n -e "\033[33m==> Building dependency bottle \033[0m"
                        echo -e "$DEP \033[33mfor\033[0m $FORMULA"
                        REBUILD='' $0 $DEP
                    fi
                done
            fi
        done
    fi
    
    for FORMULA in $FORMULAS; do
        if [[ "true" != $(brew info --json=v1 ${FORMULA} | jq '.[0].deprecated') ]]; then
            if ! [[ -d ${HOME}/.bottles/${FORMULA//"$TAP_NAME_PREFIX"/}.bottle ]] || ! grep -q "$FORMULA$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp; then
                echo -e "\033[33m==> Creating bottle for $FORMULA ...\033[0m"
                rm -rf ${HOME}/.bottles/${FORMULA//"$TAP_NAME_PREFIX"/}.bottle
                mkdir -p ${HOME}/.bottles/${FORMULA//"$TAP_NAME_PREFIX"/}.bottle
                cd ${HOME}/.bottles/${FORMULA//"$TAP_NAME_PREFIX"/}.bottle

                if brew deps --full --direct $FORMULA | grep -q $FORMULA | grep -v $FORMULA"$" > /dev/null; then
                    DEPS=$(brew deps --full --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$")
                    echo -e "\033[33m==> Installing dependencies ($DEPS) for $FORMULA ..."
                    echo -e "\033[0m"
                    for DEP in $DEPS; do
                        if echo $DEP | grep "${TAP_NAME}"; then
                            brew install -s --quiet $DEP
                        else
                            brew install --quiet $DEP
                        fi
                    done
                    
                fi

                echo "==> Building bottles for $FORMULA ..."
                [[ "true" == $(brew info --json=v1 $FORMULA | jq '.[0].installed[0].built_as_bottle') ]] || {
                    echo "==> Removing previously installed formula $FORMULA ..."
                    brew list | grep '^'${FORMULA//"$TAP_NAME_PREFIX"/}'$' && xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'brew uninstall --ignore-dependencies {} || true'
                }

                brew install --quiet --build-bottle $FORMULA 2>&1
                brew bottle --skip-relocation --no-rebuild --root-url ${BASE_ROOT_URL}/${FORMULA//"$TAP_NAME_PREFIX"/} --json $FORMULA
                ls | grep ${FORMULA//"$TAP_NAME_PREFIX"/}'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
                ls | grep ${FORMULA//"$TAP_NAME_PREFIX"/}'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
                cd $(brew tap-info --json "${TAP_NAME}" | jq -r '.[].path')

                ${DIR}/_common-bottles-upload.sh ${FORMULA//"$TAP_NAME_PREFIX"/}

                echo $FORMULA >> /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
            else
                echo -e "\033[33m==> Already created bottle for $FORMULA ...\033[0m"
            fi
        fi
    done
done

