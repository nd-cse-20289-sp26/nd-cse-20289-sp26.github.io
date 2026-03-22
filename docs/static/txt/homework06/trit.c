/* trit.c: translation utility */

#include "str.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Constants */

enum {
    LOWER   = 1<<1,
    UPPER   = 0,    // TODO: Modify
    TITLE   = 0,    // TODO: Modify
    STRIP   = 0,    // TODO: Modify
    DELETE  = 0,    // TODO: Modify
};

/* Functions */

void usage(int status) {
    fprintf(stderr, "Usage: trit SET1 SET2\n\n");
    fprintf(stderr, "Post Translation filters:\n\n");
    fprintf(stderr, "   -l      Convert to lowercase\n");
    fprintf(stderr, "   -u      Convert to uppercase\n");
    fprintf(stderr, "   -t      Convert to titlecase\n");
    fprintf(stderr, "   -s      Strip trailing whitespace\n");
    fprintf(stderr, "   -d      Delete letters in SET1\n");
    exit(status);
}

void translate_stream(FILE *stream, const char *set1, const char *set2, int flags) {
    // TODO
}

/* Main Execution */

int main(int argc, char *argv[]) {
    // TODO: Parse command line arguments

    // TODO: Translate standard input
    return EXIT_SUCCESS;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */

