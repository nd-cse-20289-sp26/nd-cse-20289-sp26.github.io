#!/bin/bash

SCRIPT=exists.py
WORKSPACE=/tmp/$SCRIPT.$(id -u)
FAILURES=0

error() {
    echo "$@"
    echo
    [ -r $WORKSPACE/test ] && cat $WORKSPACE/test
    echo
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

exists_sh() {
    for argument in $@; do
        if [ -e "$argument" ]; then
            echo "$argument exists!"
        else
            echo "$argument does not exist!"
        fi
    done
}

test_exists() {
    ARGS=$1
    EXITCODE=$2

    printf "  %-40s ... " "exists.py $ARGS"
    ./$SCRIPT $ARGS > $WORKSPACE/stdout
    if [ $? -ne $EXITCODE ]; then
	error "Failure (Exit Status)"
    elif ! diff -y $WORKSPACE/stdout <(exists_sh $ARGS) > $WORKSPACE/test; then
	error "Failure (Output)"
    else
        echo "Success"
    fi
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Checking reading04 $SCRIPT ..."

test_exists "" 0
test_exists "*" 0
test_exists "* ASDF" 1
test_exists "ASDF * FDSA" 1
test_exists "/lib/*" 0

TESTS=$(($(grep -c test_exists $0) - 2))
echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%0.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * 1.0" | bc | awk '{printf "%0.2f\n", $1}') / 1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
