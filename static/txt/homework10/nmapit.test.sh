#!/bin/bash

PROGRAM=nmapit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0

error() {
    echo "$@"
    echo
    case $@ in
	*Valgrind*) cat $WORKSPACE/stderr;;
	*Output*)   cat $WORKSPACE/diff;;
    esac
    echo
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

nmapfr() {
    nmap $@ | grep open | cut -d / -f 1
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing $PROGRAM utility..."

#------------------------------------------------------------------------------

printf "  %-60s ... " "$PROGRAM"
valgrind --leak-check=full ./$PROGRAM > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-h"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! grep -i -q usage $WORKSPACE/stderr; then
    error "Failure (Usage)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p 9000"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! grep -i -q usage $WORKSPACE/stderr; then
    error "Failure (Usage)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p 9000-"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! grep -i -q usage $WORKSPACE/stderr; then
    error "Failure (Usage)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p -9000"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! grep -i -q usage $WORKSPACE/stderr; then
    error "Failure (Usage)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="xavier.h4x0r.space"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -y $WORKSPACE/stdout <(nmapfr -p 1-1023 $ARGUMENTS) > $WORKSPACE/diff; then
    error "Failure (Output)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p 9000-9999 xavier.h4x0r.space"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -y $WORKSPACE/stdout <(nmapfr $ARGUMENTS) > $WORKSPACE/diff; then
    error "Failure (Output)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p 9005-9010 weasel.h4x0r.space"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -eq 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -y $WORKSPACE/stdout <(nmapfr $ARGUMENTS) > $WORKSPACE/diff; then
    error "Failure (Output)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

ARGUMENTS="-p 9895-9900 weasel.h4x0r.space"

printf "  %-60s ... " "$PROGRAM $ARGUMENTS"
valgrind --leak-check=full ./$PROGRAM $ARGUMENTS > $WORKSPACE/stdout 2> $WORKSPACE/stderr
if [ $? -ne 0 ]; then
    error "Failure (Exit Status)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! diff -y $WORKSPACE/stdout <(nmapfr $ARGUMENTS) > $WORKSPACE/diff; then
    error "Failure (Output)"
else
    echo "Success"
fi

#------------------------------------------------------------------------------

TESTS=$(($(grep -c Success $0) - 2))

echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%5.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{ printf "%5.2f\n", $1 }' ) / 1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
