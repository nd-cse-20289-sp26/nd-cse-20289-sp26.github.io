#!/bin/bash

PROGRAM=tailit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0

input() {
    cat /etc/passwd
}

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

test_tailit() {
    ARGUMENTS="$1"
    EXITSTATUS=$2

    printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
    input | valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
    if [ $? -ne $EXITSTATUS ]; then
	error "Failure (Status)"
    elif ! input | tail $ARGUMENTS 2> /dev/null | diff -W 80 -y $WORKSPACE/test.stdout - > $WORKSPACE/test.diff; then
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


test_tailit "-h" "0"
test_tailit "-p" "1"
test_tailit "" "0"
test_tailit "-n 1" "0"
test_tailit "-n 5" "0"
test_tailit "-n 10" "0"
test_tailit "-n 25" "0"
test_tailit "-n 100" "0"


TESTS=$(($(grep -c test_tailit $0) - 2))

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
