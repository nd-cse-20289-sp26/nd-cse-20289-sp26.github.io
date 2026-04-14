#!/bin/bash

PROGRAM=ncat
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0
POINTS=1.00

export PATH=/usr/sbin:$PATH

error() {
    echo "$@"
    echo
    case "$@" in
    	*Client*)
        echo Missing Client Output: $PATTERN
        echo
        ;;
        *Server*)
        echo Missing Server Output: $MESSAGE
        echo
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

grep_all() {
    for pattern in $1; do
    	if ! grep -q -E "$pattern" $2; then
    	    echo "Missing $pattern in $2" >> $WORKSPACE/test
    	    return 1;
    	fi
    done
    return 0;
}

nc_server() {
    PORT=""
    while [ -z "$PORT" ]; do
	PORT=$(shuf -i9000-9999 -n 1)
	if grep -q $PORT <(ss -tln | grep -Po '9\d{3}'); then
	    PORT=""
	fi
    done

    { nc -l -p $PORT > $WORKSPACE/test.server || 
      nc -l $PORT > $WORKSPACE/test.server; } &
    SPID=$!
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Checking reading13 $PROGRAM ..."

printf "  %-40s ... " "$PROGRAM (syscalls)"
PATTERNS="socket getaddrinfo connect close"
if ! grep_all "$PATTERNS" $PROGRAM.c; then
    error "Failure"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM (usage)"
PATTERN="usage"
valgrind --leak-check=full ./$PROGRAM > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -eq 0 ] || ! grep -q "$PATTERN" $WORKSPACE/test.stderr; then
    error "Failure"
elif [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM (fakehost 9999)"
MESSAGE=$(sha1sum <<<$(whoami) | awk '{print $1}')
PATTERN="(Name or service not known|Temporary failure|name resolution)"
valgrind --leak-check=full ./$PROGRAM fakehost 9999 <<<$MESSAGE > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif ! grep -Eq "$PATTERN" $WORKSPACE/test.stderr; then
    error "Failure (Client Output)"
elif [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM (localhost 0)"
MESSAGE=$(sha1sum <<<$(whoami) | awk '{print $1}')
PATTERN="(Connection refused|Cannot assign requested address)"
valgrind --leak-check=full ./$PROGRAM localhost 0 <<<$MESSAGE > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif ! grep -Eq "$PATTERN" $WORKSPACE/test.stderr; then
    error "Failure (Client Output)"
elif [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

nc_server
printf "  %-40s ... " "$PROGRAM (localhost $PORT)"
MESSAGE=$(sha1sum <<<$(whoami) | awk '{print $1}')
PATTERN="Connected"
valgrind --leak-check=full ./$PROGRAM localhost $PORT <<<$MESSAGE > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep -Eq "$PATTERN" $WORKSPACE/test.stdout; then
    error "Failure (Client Output)"
fi

wait $SPID

if ! grep -q "$MESSAGE" $WORKSPACE/test.server; then
    error "Failure (Server Output)"
elif [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf "  %-40s ... " "$PROGRAM (weasel.h4x0r.space 9910)"
MESSAGE="$(whoami) $(date +%s)"
PATTERN="Connected"
valgrind --leak-check=full ./$PROGRAM weasel.h4x0r.space 9910 <<<$MESSAGE > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif ! grep -Eq "$PATTERN" $WORKSPACE/test.stdout; then
    error "Failure (Client Output)"
elif ! curl -s http://weasel.h4x0r.space:9911 | grep -q "$MESSAGE"; then
    error "Failure (Server Output)"
elif [ $(awk '/ERROR SUMMARY:/ {errors += $4} END{print errors}' $WORKSPACE/test.stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

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
