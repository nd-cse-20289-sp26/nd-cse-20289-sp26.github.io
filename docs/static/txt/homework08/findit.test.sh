#!/bin/bash

WORKSPACE=/tmp/findit.$(id -u)
FAILURES=0
POINTS=4.00

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

test_findit() {
    FINDIT_PATH="$1"
    FINDIT_ARGS="$2"
    printf "  %-60s ... " "findit $FINDIT_PATH $FINDIT_ARGS"
    valgrind --leak-check=full ./findit $FINDIT_PATH $FINDIT_ARGS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test.stderr) -ne 0 ]; then
	error "Failure (Valgrind)"
    elif ! diff -W 80 -y <(sort $WORKSPACE/test.stdout) <(find $FINDIT_PATH $FINDIT_ARGS 2> /dev/null | sort) &> $WORKSPACE/test.diff; then
	error "Failure (Output)"
    else
	echo "Success"
    fi
}


export LD_LIBRARY_PATH=$LD_LIBRRARY_PATH:.

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing findit ..."

test_findit "" ""

test_findit "/etc" ""
test_findit "/etc" "-type f"
test_findit "/etc" "-type d"
test_findit "/etc" "-name '*.conf'"
test_findit "/etc" "-readable"
test_findit "/etc" "-writable"
test_findit "/etc" "-executable"
test_findit "/etc" "-type d -name '*.d'"
test_findit "/etc" "-type d -name '*.d' -executable"

test_findit "." "-name '*.c'"
test_findit "." "-writable"
test_findit "." "-type f -name '*.unit' -executable"

TESTS=$(($(grep -c test_findit $0) - 2))

echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%0.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{ printf "%5.2f\n", $1 }' ) /  1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
