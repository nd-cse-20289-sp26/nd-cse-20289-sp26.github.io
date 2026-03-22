#!/bin/bash

WORKSPACE=/tmp/str_rev.$(id -u)
FAILURES=0
POINTS=1

error() {
    echo "$@"
    echo
    case "$@" in
	*Output*)   cat $WORKSPACE/diff;;
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

test_str_rev() {
    INPUT="$1"
    OUTPUT="$2"

    printf "  %-40s ... " "str_rev $INPUT"
    valgrind --leak-check=full ./str_rev $INPUT > $WORKSPACE/stdout 2> $WORKSPACE/stderr
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif ! diff -y $WORKSPACE/stdout <(printf "$OUTPUT") > $WORKSPACE/diff; then
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

echo "Checking reading07 str_rev ..."

test_str_rev "" ""
test_str_rev "runescape" "epacsenur\n"
test_str_rev "old school" "dlo\nloohcs\n"

TESTS=$(($(grep -c test_str_rev $0) - 2))
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
