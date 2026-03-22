#!/bin/bash

WORKSPACE=/tmp/trit.$(id -u)
FAILURES=0

input() {
    cat <<EOF

 
Through the woods
 Blank Space
Out of Style
I need a hero
 You Got A Friend in Me!!! 
Hello, World!
EOF
}

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

export LD_LIBRARY_PATH=$LD_LIBRRARY_PATH:.

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing trit utility..."

printf "  %-40s ... " "trit -h"
if ! ./trit.static -h |& grep -q -i usage; then
    error "Failure (Usage)"
else
    valgrind --leak-check=full ./trit.dynamic -h &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit"
input | ./trit.static | diff -y - <(input) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit aeio 4310"
input | ./trit.static aeio 4310 | diff -y - <(input | tr aeio 4310) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic aeio 4310 &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit blue gold"
input | ./trit.static blue gold | diff -y - <(input | tr blue gold) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic blue gold &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -l aeio 4310"
input | ./trit.static -l aeio 4310 | diff -y - <(input | tr aeio 4310 | tr A-Z a-z) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -l aeio 4310 &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -u blue gold"
input | ./trit.static -u blue gold | diff -y - <(input | tr blue gold | tr a-z A-Z) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -u blue gold &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -t"
input | ./trit.static -t | diff -y - <(input | python3 -c 'import sys;[print(line[:-1].title()) for line in sys.stdin]') &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -t &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi

printf "  %-40s ... " "trit -s swift snake"
input | ./trit.static -s swift snake | diff -y - <(input | tr swift snake | sed -E 's/[ \t\r\n]+$//') &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -s swift snake &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -d aeio"
input | ./trit.static -d aeio | diff -y - <(input | tr -d aeio) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -d aeio &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -l -u aeio 4310"
input | ./trit.static -l -u aeio 4310 | diff -y - <(input | tr aeio 4310 | tr a-z A-Z) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -l -u aeio 4310 &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -l -s aeio 4310"
input | ./trit.static -l -s aeio 4310 | diff -y - <(input | tr aeio 4310 | tr A-Z a-z | sed -E 's/[ \t\r\n]+$//') &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -l -s aeio 4310 &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -l -d gdbye"
input | ./trit.static -l -d gdbye | diff -y - <(input | tr -d gdbye | tr A-Z a-z) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -l -d gdbye &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -s -t aeio 4310"
input | ./trit.static -s -t aeio 4310 | diff -y - <(input | tr aeio 4310 | python3 -c 'import sys;[print(line.rstrip().title()) for line in sys.stdin]') &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -s -t aeio 4310 &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


printf "  %-40s ... " "trit -u -d antm"
input | ./trit.static -u -d antm | diff -y - <(input | tr -d antm | tr a-z A-Z) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    input | valgrind --leak-check=full ./trit.dynamic -u -d antm &> $WORKSPACE/test
    if [ $? -ne 0 ]; then
	error "Failure (Exit Status)"
    elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
fi


TESTS=$(($(grep -c Success $0) - 2))

echo "  --------------------"
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES)" | bc | awk '{printf "%0.2f\n", $1}') / $TESTS.00"
echo "   Grade $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0" | bc | awk '{printf "%0.2f\n", $1}')  / 1.00"
printf "  Status "
if [ $FAILURES -gt 0 ]; then
    echo "Failure"
else
    echo "Success"
fi
echo
