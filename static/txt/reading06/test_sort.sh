#!/bin/bash

TOOL=sort
WORKSPACE=/tmp/$TOOL.$(id -u)
FAILURES=0

error() {
    echo "$@"
    echo
    case "$@" in
	*Output*)   cat $WORKSPACE/test;;
	*Valgrind*) cat $WORKSPACE/stderr;;
    esac
    echo
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

test_sort() {
    FIRST=$1
    LAST=$2
    EXITCODE=$3

    printf "  %-40s ... " "$TOOL $FIRST $LAST"
    shuf -i $FIRST-$LAST | valgrind --leak-check=full ./$TOOL > $WORKSPACE/stdout 2> $WORKSPACE/stderr
    if [ $? -ne $EXITCODE ]; then
	error "Failure (Exit Status)"
    elif ! diff -y $WORKSPACE/stdout <(seq $FIRST $LAST) > $WORKSPACE/test; then
	error "Failure (Output)"
    elif [ "$(awk '/ERROR SUMMARY/ {print $4}' $WORKSPACE/stderr)" -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Checking reading06 sort ..."

test_sort 1 1 0
test_sort 1 10 0
test_sort 1 100 0
test_sort 1 1000 0

TESTS=$(($(grep -c test_sort $0) - 2))
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
