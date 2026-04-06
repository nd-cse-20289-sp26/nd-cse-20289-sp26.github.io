CC=             gcc
CFLAGS=         -Wall -g -std=gnu99
TARGETS=        doit

all:            $(TARGETS)

# TODO: Add rule for doit

test:
	        @$(MAKE) -sk test-all

test-all:	test-doit

test-doit:	doit
	curl -sLO https://www3.nd.edu/~pbui/teaching/cse.20289.sp25/static/txt/reading12/doit.test.sh
	chmod +x doit.test.sh
	./doit.test.sh

clean:
	rm -f $(TARGETS)

.SUFFIXES:
