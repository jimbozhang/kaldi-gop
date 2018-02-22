#!/bin/bash

# set color test
COLOR_OFF="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# based on https://github.com/lemire/SIMDCompressionAndIntersection/blob/master/tools/clang-format.sh
STYLE="$(which clang-format-6.0) -style Google"
if [ $? -ne 0 ]; then
    echo "$RED clang-format not installed. Unable to check source file format policy.$COLOR_OFF" >&2
    exit 1
fi

BASE=$(git rev-parse --show-toplevel)

ALLFILES=$(git ls-tree --full-tree --name-only -r HEAD src | grep -e ".*\.\(c\|h\|cc\|cpp\|hh\)\$")
for FILE in $ALLFILES; do
    $STYLE $BASE/$FILE > tmp
    cmp $BASE/$FILE tmp
    if [ $? -ne 0 ]; then
        echo -e "Formated $RED$FILE.$COLOR_OFF" >&2
        mv tmp $BASE/$FILE
    else
        rm tmp
    fi
done

exit 0
