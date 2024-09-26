#!/bin/bash
set -e
export DEBUG=${DEBUG:-''}
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=0

TAP_NAME=${TAP_NAME:-"digitalspacestdio/common"}
TAP_NAME_PREFIX="${TAP_NAME}/"
TAP_SUBDIR=$(echo $TAP_NAME | awk -F/ '{ print $2 }')
ARGS=${@:-$(brew search "${TAP_NAME}" | grep "${TAP_NAME}")}

brew tap "${TAP_NAME}"

cd $(brew tap-info --json "${TAP_NAME}" | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
S3_BUCKET="homebrew";
S3_BASEDIR="ngdev"

function uri_extract_path {
    # extract the protocol
    proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"

    # remove the protocol -- updated
    url=$(echo $1 | sed -e s,$proto,,g)

    # extract the user (if any)
    user="$(echo $url | grep @ | cut -d@ -f1)"

    # extract the host and port -- updated
    hostport=$(echo $url | sed -e s,$user@,,g | cut -d/ -f1)

    # by request host without port
    host="$(echo $hostport | sed -e 's,:.*,,g')"
    # by request - try to extract the port
    port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

    # extract the path (if any)
    path="$(echo $url | grep / | cut -d/ -f2-)"

    echo $path
}

for ARG in $ARGS
do
    FORMULAS=$(brew search "${TAP_NAME}" | grep "${TAP_NAME}" | grep "\($ARG\|$ARG@[0-9]\+\)\$" | sort)
    if [[ -n "$FORMULAS" ]]; then
        for FORMULA in $FORMULAS; do
            echo "Uploading bottles for $PHP_FORMULA ..."
            echo "Checking permissions 's3://$S3_BUCKET' ..."
            s3cmd info "s3://$S3_BUCKET" > /dev/null
            cd ${HOME}/.bottles/${FORMULA//"$TAP_NAME_PREFIX"/}.bottle
            ls | grep ${FORMULA//"$TAP_NAME_PREFIX"/}'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            ls | grep ${FORMULA//"$TAP_NAME_PREFIX"/}'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'

            for jsonfile in ./*.json; do
                jsonfile=$(basename $jsonfile)
                JSON_FORMULA_NAME=$(jq -r '.[].formula.name' "$jsonfile")
                FORMULA_ROOT_URL=$(jq -r '.[].bottle.root_url' "$jsonfile")
                S3_BASE_PATH=$(uri_extract_path "${FORMULA_ROOT_URL}")
                if ! [[ -z $JSON_FORMULA_NAME ]]; then
                    while read tgzName; do
                        if [[ -f "$tgzName" ]]; then
                            echo "Checking is file does not exists 's3://$S3_BASE_PATH/$tgzName' ..."
                            s3cmd info "s3://$S3_BASE_PATH/$tgzName" > /dev/null 2>&1 && {
                                echo "File already exists on remote storage s3://$S3_BASE_PATH/$tgzName"
                                echo "Terminating..."
                                exit 1
                            }
                        fi
                    done < <(jq -r '."'$TAP_NAME'/'$JSON_FORMULA_NAME'".bottle.tags[].filename' "$jsonfile")
                fi
            done

            for jsonfile in ./*.json; do
                jsonfile=$(basename $jsonfile)
                JSON_FORMULA_NAME=$(jq -r '.[].formula.name' "$jsonfile")
                S3_BASE_PATH=$(uri_extract_path $(jq -r '.[].bottle.root_url' "$jsonfile"))

                # If the bucket is absent in the base url we need to add it for s3cmd
                if [[ $S3_BASE_PATH != "${S3_BUCKET}/*" ]]; then
                    S3_BASE_PATH=${S3_BUCKET}/${S3_BASE_PATH}
                fi
                if ! [[ -z $JSON_FORMULA_NAME ]]; then
                    mergedfile=$(jq -r '.["'$TAP_NAME'/'$JSON_FORMULA_NAME'"].formula.name + "-" + ."'$TAP_NAME'/'$JSON_FORMULA_NAME'".formula.pkg_version + ".json"' "$jsonfile" | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
                    while read tgzName; do
                        if [[ -f "$tgzName" ]]; then
                            s3cmd put "$tgzName" "s3://$S3_BASE_PATH/$tgzName"
                        fi
                    done < <(jq -r '."'$TAP_NAME'/'$JSON_FORMULA_NAME'".bottle.tags[].filename' "$jsonfile" | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
                    echo "Checking is file exists 's3://$S3_BASE_PATH/$mergedfile' ..."
                    s3cmd info "s3://$S3_BASE_PATH/$mergedfile" > /dev/null 2>&1 && {
                        s3cmd get "s3://$S3_BASE_PATH/$mergedfile" "$mergedfile".src
                        if [[ "object" != $(cat "$mergedfile".src| jq -r type) ]]; then
                            cp "$jsonfile" "$mergedfile".src
                        fi
                        jq -s  '.[1]."'$TAP_NAME'/'$JSON_FORMULA_NAME'".bottle.tags = .[0]."'$TAP_NAME'/'$JSON_FORMULA_NAME'".bottle.tags * .[1]."'$TAP_NAME'/'$JSON_FORMULA_NAME'".bottle.tags | .[1]' "$mergedfile".src "$jsonfile" > "$mergedfile"
                        s3cmd del "s3://$S3_BASE_PATH/$mergedfile"
                        s3cmd put "$mergedfile" "s3://$S3_BASE_PATH/$mergedfile"
                        brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$mergedfile"
                        rm "$mergedfile" "$mergedfile".src
                    } || {
                        s3cmd put "$jsonfile" "s3://$S3_BASE_PATH/$mergedfile"
                        brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$jsonfile"
                    } || exit 1
                fi

                cd $(brew tap-info --json ${TAP_NAME} | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
                git add .
                git commit -m "bottle ${FORMULA//"$TAP_NAME_PREFIX"/} ${OSTYPE}"
            done
        done
    fi
done
