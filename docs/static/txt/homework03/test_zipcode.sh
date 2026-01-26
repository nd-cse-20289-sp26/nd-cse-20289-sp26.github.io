#!/bin/sh

# Configuration

SCRIPT=zipcode.sh
WORKSPACE=/tmp/$SCRIPT.$(id -u)
FAILURES=0

# Functions

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && cat $WORKSPACE/test
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $SCRIPT ..."

printf "   %-40s ... " Usage
./$SCRIPT -h 2>&1 | grep -i usage 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " Default
COUNT=$(./$SCRIPT | wc -l)
if [ $COUNT -ne 988 -a $COUNT -ne 696 -a $COUNT -ne 688 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Indiana"
COUNT=$(./$SCRIPT -s Indiana | wc -l)
if [ $COUNT -ne 988 -a $COUNT -ne 696 -a $COUNT -ne 688 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "South Bend, Indiana"
COUNT=$(./$SCRIPT -c "South Bend" -s Indiana | wc -l)
if [ $COUNT -ne 18 -a $COUNT -ne 12 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Indianapolis, Indiana"
COUNT=$(./$SCRIPT -c Indianapolis -s Indiana | wc -l)
if [ $COUNT -ne 50 -a $COUNT -ne 48 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Wisconsin"
COUNT=$(./$SCRIPT -s Wisconsin | wc -l)
if [ $COUNT -ne 732 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Eau Claire, Wisconsin"
COUNT=$(./$SCRIPT -s Wisconsin -c "Eau Claire" | wc -l)
if [ $COUNT -ne 2 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Milwaukee, Wisconsin"
COUNT=$(./$SCRIPT -s Wisconsin -c "Milwaukee" | wc -l)
if [ $COUNT -ne 36 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "California"
COUNT=$(./$SCRIPT -s California | wc -l)
if [ $COUNT -ne 2657 -a $COUNT -ne 1764 -a $COUNT -ne 1743 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Orange, California"
COUNT=$(./$SCRIPT -s California -c Orange | wc -l)
if [ $COUNT -ne 11 -a $COUNT -ne 6 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Los Angeles, California"
COUNT=$(./$SCRIPT -s California -c "Los Angeles" | wc -l)
if [ $COUNT -ne 97 -a $COUNT -ne 71 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "New York"
COUNT=$(./$SCRIPT -s "New York" | wc -l)
if [ $COUNT -ne 2205 -a $COUNT -ne 1745 -a $COUNT -ne 1740 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "Buffalo, New York"
COUNT=$(./$SCRIPT -s "New York" -c "Buffalo" | wc -l)
if [ $COUNT -ne 44 -a $COUNT -ne 43 -a $COUNT -ne 41 ]; then
    error "Failure"
else
    echo "Success"
fi

printf "   %-40s ... " "New York, New York"
COUNT=$(./$SCRIPT -s "New York" -c "New York" | wc -l)
if [ $COUNT -ne 162 -a $COUNT -ne 128 ]; then
    error "Failure"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))
POINTS=$TESTS

echo "  --------------------------------------------------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * $POINTS.0" | bc | awk '{printf "%5.2f\n", $1}') / $POINTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{printf "%5.2f\n", $1}') /  1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
