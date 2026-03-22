#!/bin/bash

PROGRAM=seqit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0
POINTS=2

error() {
    echo "$@"
    echo
    case "$@" in
        *Output*)
        printf "%-40s%-40s\n" "PROGRAM OUTPUT" "EXPECTED OUTPUT"
        cat $WORKSPACE/test.diff
        ;;
        *Valgrind*)
        echo
        cat $WORKSPACE/test.stderr
        ;;
    esac
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

test_seqit() {
    ARGUMENTS="$1"
    EXITSTATUS=$2
    printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
    valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
    if [ $? -ne $EXITSTATUS ]; then
	error "Failure (Status)"
    elif ! seq $ARGUMENTS 2> /dev/null | diff -W 80 -y $WORKSPACE/test.stdout - > $WORKSPACE/test.diff; then
	error "Failure (Output)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test.stderr) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
    rm -f $WORKSPACE/test.diff
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing $PROGRAM ..."

test_seqit "1" 0
test_seqit "10" 0
test_seqit "100" 0
test_seqit "1 100" 0
test_seqit "1 2 100" 0
test_seqit "100 -3 1" 0
test_seqit "1 2 3 4" 1

TESTS=$(($(grep -c test_seqit $0) - 2))

echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%0.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{ printf "%0.2f\n", $1 }' ) / 1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
