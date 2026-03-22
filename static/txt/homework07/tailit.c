/* tailit.c: Output the last part of files */

#include "list.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Functions */

void usage(int status) {
    fprintf(stderr, "Usage: tailit [-n NUMBER]\n\n");
    fprintf(stderr, "    -n NUMBER  Output the last NUMBER of lines (default is 10)\n");
    exit(status);
}

List *tail_stream(FILE *stream, size_t limit) {
    // TODO
    return NULL;
}

/* Main Execution */

int main(int argc, char *argv[]) {
    // TODO: Parse command line arguments

    // TODO: Construct tail of stream

    // TODO: Print out tail
    return EXIT_SUCCESS;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
