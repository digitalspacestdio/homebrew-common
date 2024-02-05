#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
if [[ -z $1 ]]; then
    exit 1;
fi
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
brew tap digitalspacestdio/common
brew tap digitalspacestdio/common
cd $(brew tap-info --json digitalspacestdio/common | jq -r '.[].path')
git stash
git pull

FORMULAS=$(brew search digitalspacestdio/common | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)
for FORMULA in $FORMULAS; do
    echo "Uploading bottle for $FORMULA ..."
    s3cmd info "s3://homebrew-bottles" > /dev/null
    cd ${HOME}/.bottles/$FORMULA.bottle
    ls | grep $FORMULA'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
    ls | grep $FORMULA'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
    for jsonfile in ./*.json; do
        jsonfile=$(basename $jsonfile)
        JSON_FORMULA_NAME=$(jq -r '.[].formula.name' "$jsonfile")
        if ! [[ -z $JSON_FORMULA_NAME ]]; then
            mergedfile=$(jq -r '.["digitalspacestdio/common/'$JSON_FORMULA_NAME'"].formula.name + "-" + ."digitalspacestdio/common/'$JSON_FORMULA_NAME'".formula.pkg_version + ".json"' "$jsonfile")
            while read tgzName; do
                if [[ -f "$tgzName" ]]; then
                    s3cmd info "s3://homebrew-bottles/$FORMULA/$tgzName" >/dev/null && {
                        s3cmd del "s3://homebrew-bottles/$FORMULA/$tgzName"
                    } || /usr/bin/true
                    s3cmd put "$tgzName" "s3://homebrew-bottles/$FORMULA/$tgzName"
                fi
            done < <(jq -r '."digitalspacestdio/common/'$JSON_FORMULA_NAME'".bottle.tags[].filename' "$jsonfile")
            s3cmd info "s3://homebrew-bottles/$FORMULA/$mergedfile" >/dev/null && {
                s3cmd get "s3://homebrew-bottles/$FORMULA/$mergedfile" "$mergedfile".src
                if [[ "object" != $(cat "$mergedfile".src| jq -r type) ]]; then
                    cp "$jsonfile" "$mergedfile".src
                fi
                jq -s  '.[1]."digitalspacestdio/common/'$JSON_FORMULA_NAME'".bottle.tags = .[0]."digitalspacestdio/common/'$JSON_FORMULA_NAME'".bottle.tags * .[1]."digitalspacestdio/common/'$JSON_FORMULA_NAME'".bottle.tags | .[1]' "$mergedfile".src "$jsonfile" > "$mergedfile"
                s3cmd del "s3://homebrew-bottles/$FORMULA/$mergedfile"
                s3cmd put "$mergedfile" "s3://homebrew-bottles/$FORMULA/$mergedfile"
                brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$mergedfile"
                rm "$mergedfile" "$mergedfile".src
            } || {
                s3cmd put "$jsonfile" "s3://homebrew-bottles/$FORMULA/$mergedfile"
                brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$jsonfile"
            } || exit 1
        fi
    done
done
cd $(brew tap-info --json digitalspacestdio/common | jq -r '.[].path')
git add .
git commit -m "bottles update"
git pull --rebase
git push
cd -
