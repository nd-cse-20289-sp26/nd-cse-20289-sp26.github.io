#!/bin/bash

PROGRAM=timeit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0

export PATH=$WORKSPACE:$PATH

# Functions

error() {
    echo "$@"
    echo
    case "$@" in
        *Elapsed*)
        echo
        cat $WORKSPACE/test.diff
        echo
        cat $WORKSPACE/test.stdout
        ;;
        *Output*|*Valgrind*)
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

test_valgrind() {
    [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -eq 0 ]
}

test_elapsed() {
    ttime="$(awk '/Time Elapsed:/ {print $3}' $WORKSPACE/test.stdout)"
    if ! echo "$ttime" | grep -q -P "$1"; then
    	echo "Wrong elapsed time: $ttime != $1" >> $WORKSPACE/test.diff
    	return 1
    else
    	return 0
    fi
}

make_troll() {
    cat > $WORKSPACE/TROLL <<TROLL
#!/bin/sh

nope() {
    echo "Nope"
}

trap nope INT TERM EXIT
while true; do
    sleep 1
done
TROLL
    chmod +x $WORKSPACE/TROLL
}

grep_all() {
    for pattern in $1; do
    	if ! grep -q -E "$pattern" $2; then
    	    echo "Missing $pattern in $2" >> $WORKSPACE/test
    	    return 1;
    	fi
    done
    return 0;
}

SYSCALLS="fork exec[vl]p (wait|waitpid) (signal|sigaction) (nanosleep|sleep|alarm) clock_gettime WIFEXITED WEXITSTATUS WTERMSIG"

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Testing

echo "Testing $PROGRAM..."

printf "  %-60s ... " "system calls"
if ! grep_all "$SYSCALLS" $PROGRAM.c; then
    error "Failure"
else
    echo "Success"
fi

printf "  %-60s ... " "usage (-h)"
PATTERNS="usage"
valgrind --leak-check=full ./$PROGRAM -h > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-60s ... " "usage (no arguments)"
PATTERNS="usage"
valgrind --leak-check=full ./$PROGRAM > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 1 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-60s ... " "usage (-v, no command)"
PATTERNS="usage Timeout Verbose"
valgrind --leak-check=full ./$PROGRAM -v > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 1 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-60s ... " "usage (-t 5 -v, no command)"
PATTERNS="usage Timeout Verbose"
valgrind --leak-check=full ./$PROGRAM -t 5 -v > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 1 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

ARGUMENTS="sleep"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 1 ]; then
    error "Failure (Exit Status)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

ARGUMENTS="sleep 1"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 1.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-v sleep 1"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 1.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-t 5 -v sleep 1"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 1.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="sleep 5"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 5.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-v sleep 5"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 5.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-t 1 sleep 5"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 15 ]; then
    error "Failure (Exit Status)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 1.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-t 1 -v sleep 5"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit Killing"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 15 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 1.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

ARGUMENTS="-v find /etc -type f"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 1 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 0.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

make_troll
ARGUMENTS="-t 5 -v $WORKSPACE/TROLL"
PATTERNS="Timeout Verbose Registering handlers Grabbing start time Sleeping Executing Waiting exit Killing"
printf "  %-60s ... " "$ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 9 ]; then
    error "Failure (Exit Status)"
elif ! grep_all "$PATTERNS" $WORKSPACE/test.stderr; then
    error "Failure (Output)"
elif ! test_valgrind; then
    error "Failure (Valgrind)"
elif ! test_elapsed 5.\\d; then
    error "Failure (Elapsed)"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))

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
