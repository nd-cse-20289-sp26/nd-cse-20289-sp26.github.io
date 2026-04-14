#!/bin/bash

PROGRAM=curlit
WORKSPACE=/tmp/$PROGRAM.$(id -u)
FAILURES=0
POINTS=4.50

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

check_contents() {
    python3 <<EOF
import hashlib
import sys

def cksum(p):
    return hashlib.sha1(open(p, 'rb').read()).hexdigest()

curlpy_hash = cksum('$WORKSPACE/stdout.curlpy')
curlit_hash = cksum('$WORKSPACE/stdout.curlit')

sys.exit(0 if curlpy_hash == curlit_hash else 1)
EOF
}

compute_metrics() {
    rm -f "$WORKSPACE/stdout.curlpy"
    python3 <<EOF
import os
import requests
import time

def curl(url):
    start_time  = time.time()
    url         = 'http://' + url if not url.startswith('http://') else url
    path        = "$WORKSPACE/stdout.curlpy"

    with open(path, 'wb') as fs:
        try:
            response = requests.get(url, allow_redirects=False)
        except requests.exceptions.RequestException:
            return (0, 0.00000001)

        fs.write(response.content)

    return (len(response.content), time.time() - start_time)

bytes, time_elapsed = curl("$URL")
bandwidth           = bytes / (1<<20) / time_elapsed
print(f'TIME_ELAPSED_MIN={max(time_elapsed * 0.05, 0.01):0.2f}')
print(f'TIME_ELAPSED_MAX={max(time_elapsed * 5.00, 0.50):0.2f}')
print(f'BANDWIDTH_MIN={bandwidth * 0.05:0.2f}')
print(f'BANDWIDTH_MAX={bandwidth * 5.00:0.2f}')
EOF
}

check_metrics() {
    python3 > $WORKSPACE/test <<EOF
import re
import sys

bandwidth    = None
time_elapsed = None
for line in open('$WORKSPACE/stderr.curlit'):
    match = re.findall(r'Bandwidth:\s+([0-9\\.]+) MB/s', line)
    if match:
        bandwidth = float(match[0])
    elif line.startswith('Time Elapsed'):
        time_elapsed = float(line.split()[2])

if bandwidth is not None and time_elapsed is not None \\
   and ($BANDWIDTH_MIN <= bandwidth <= $BANDWIDTH_MAX) \\
   and ($TIME_ELAPSED_MIN <= time_elapsed <= $TIME_ELAPSED_MAX):
    sys.exit(0)
else:
    for line in open('$WORKSPACE/stderr.curlit'):
        print(line.rstrip())
    print()
    print(f'Expected Time Elapsed: $TIME_ELAPSED_MIN - $TIME_ELAPSED_MAX')
    print(f'Returned Time Elapsed: {time_elapsed}')
    print(f'Expected Bandwidth   : $BANDWIDTH_MIN - $BANDWIDTH_MAX')
    print(f'Returned Bandwidth   : {bandwidth}')
    sys.exit(1)
EOF
}

check_valgrind() {
    [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/stderr.curlit) -eq 0 ]
}

# Tests -----------------------------------------------------------------------

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing $PROGRAM ..."

if [ ! -x $PROGRAM ]; then
    echo "Failure: $PROGRAM is not executable!"
    exit 1
fi

# Usage -----------------------------------------------------------------------

printf "  %-60s ... " "$PROGRAM"
./$PROGRAM &> $WORKSPACE/test
if [ $? -eq 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

printf "  %-60s ... " "$PROGRAM -h"
./$PROGRAM -h &> $WORKSPACE/test
if [ $? -ne 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

printf "  %-60s ... " "$PROGRAM -?"
./$PROGRAM -? &> $WORKSPACE/test
if [ $? -eq 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

rm -f $WORKSPACE/test

# http://fake.host -----------------------------------------------------------

URL=http://fake.host
eval $(compute_metrics)

printf "  %-60s ... " "$PROGRAM $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# http://example.com -----------------------------------------------------------

URL=http://example.com
eval $(compute_metrics)

printf "  %-60s ... " "$PROGRAM $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# http://nd.edu ---------------------------------------------------------------

URL=http://nd.edu
eval $(compute_metrics)
BANDWIDTH_MIN=0

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# h4x0r.space -----------------------------------------------------------------

URL=h4x0r.space
eval $(compute_metrics)
BANDWIDTH_MIN=0
BANDWIDTH_MAX=0.1

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# h4x0r.space:9898/mind.txt --------------------------------------------------

URL=h4x0r.space:9898/mind.txt
eval $(compute_metrics)
BANDWIDTH_MIN=0

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# h4x0r.space:9898/txt/walden.txt ----------------------------------------------

URL=h4x0r.space:9898/txt/walden.txt
eval $(compute_metrics)

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# h4x0r.space:9898/txt/gatsby.txt ---------------------------------------------

URL=h4x0r.space:9898/txt/gatsby.txt
HAMMERS=1
eval $(compute_metrics)

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# http://h4x0r.space:9898/txt/warandpeace.txt ---------------------------------

URL=http://h4x0r.space:9898/txt/warandpeace.txt
eval $(compute_metrics)

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.curlit $WORKSPACE/stdout.curlpy
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# http://h4x0r.space:9898/img/appa.png ----------------------------------------

URL=http://h4x0r.space:9898/img/appa.png
eval $(compute_metrics)

printf "  %-60s ... " "curlit $URL"
valgrind --leak-check=full ./$PROGRAM $URL > $WORKSPACE/stdout.curlit 2> $WORKSPACE/stderr.curlit
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_valgrind; then
    error "Failure (Valgrind)"
    tail $WORKSPACE/stderr.curlit
else
    echo "Success"
fi

sleep 1

# Summary ---------------------------------------------------------------------

TESTS=$(($(grep -c Success $0) - 2))

echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%5.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{ printf "%5.2f\n", $1 }' ) /  1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
