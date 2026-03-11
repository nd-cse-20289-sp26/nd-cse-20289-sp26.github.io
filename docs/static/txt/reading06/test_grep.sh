#!/bin/bash

TOOL=grep
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

test_grep() {
    ARGS=$1
    FILE=$2
    EXITCODE=$3

    printf "  %-40s ... " "$TOOL $ARGS $FILE"
    valgrind --leak-check=full ./$TOOL $ARGS < $FILE > $WORKSPACE/stdout 2> $WORKSPACE/stderr
    if [ $? -ne $EXITCODE ]; then
	error "Failure (Exit Status)"
    elif ! diff -y $WORKSPACE/stdout <(grep $ARGS < $FILE) > $WORKSPACE/test; then
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

echo "Checking reading06 grep ..."

printf "  %-40s ... " "grep"
if ! ./grep |& grep -q -i usage; then
    error "Failure"
else
    echo "Success"
fi

printf "  %-40s ... " "grep -h "
if ! ./grep -h |& grep -q -i usage; then
    error "Failure"
else
    echo "Success"
fi

test_grep "root" "/etc/passwd" 0
test_grep "login" "/etc/passwd" 0
test_grep "asdf" "/etc/passwd" 1

TESTS=$(($(grep -c test_grep $0)))
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
