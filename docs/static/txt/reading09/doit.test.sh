#!/bin/bash

PROGRAM=doit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FAILURES=$((FAILURES + 1))
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

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Checking reading10 $PROGRAM ..."

printf "  %-40s ... " "$PROGRAM (syscalls)"
if ! grep -q fork $PROGRAM.c || ! grep -q exec $PROGRAM.c || ! grep -q wait $PROGRAM.c; then
    error "Failure (Missing Syscalls)"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM (usage)"
if ! ./$PROGRAM |& grep -q -i usage; then
    error "Failure (Output)"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM true"
valgrind --leak-check=full ./$PROGRAM true > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Status)"
elif [ "$(awk '/ERROR SUMMARY/ {errors += $4} END {print errors}' $WORKSPACE/test.stderr)" -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

ARGUMENTS="false"
printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -eq 0 ]; then
    error "Failure (Status)"
elif [ "$(awk '/ERROR SUMMARY/ {errors += $4} END {print errors}' $WORKSPACE/test.stderr)" -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

ARGUMENTS="NOPE"
printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -eq 0 ]; then
    error "Failure (Status)"
elif [ "$(awk '/ERROR SUMMARY/ {errors += $4} END {print errors}' $WORKSPACE/test.stderr)" -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

ARGUMENTS="/bin/ls"
printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Status)"
elif [ "$(awk '/ERROR SUMMARY/ {errors += $4} END {print errors}' $WORKSPACE/test.stderr)" -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -W 80 -y $WORKSPACE/test.stdout <($ARGUMENTS) &> $WORKSPACE/test.diff; then
    error "Failure (Output)"
else
    echo "Success"
fi
rm -f $WORKSPACE/test.diff

ARGUMENTS="echo execution of all things"
printf "  %-40s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM "$ARGUMENTS" > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Status)"
elif [ "$(awk '/ERROR SUMMARY/ {errors += $4} END {print errors}' $WORKSPACE/test.stderr)" -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -W 80 -y $WORKSPACE/test.stdout <($ARGUMENTS) &> $WORKSPACE/test.diff; then
    error "Failure (Output)"
else
    echo "Success"
fi
rm -f $WORKSPACE/test.diff

TESTS=$(($(grep -c Success $0) - 2))

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
