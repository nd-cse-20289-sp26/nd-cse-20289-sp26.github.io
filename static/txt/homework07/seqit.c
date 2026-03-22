/* seqit.c: Print a sequence of numbers */

#include "list.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>

/* Functions */

void usage(int status) {
    fprintf(stderr, "Usage: seqit LAST\n");
    fprintf(stderr, "       seqit FIRST LAST\n");
    fprintf(stderr, "       seqit FIRST INCREMENT LAST\n");
    exit(status);
}

List *generate_sequence(ssize_t first, ssize_t increment, ssize_t last) {
    // TODO
    return NULL;
}

/* Main Execution */

int main(int argc, char *argv[]) {
    // TODO: Parse command line arguments

    // TODO: Generate sequence

    // TODO: Print out sequence
    return EXIT_SUCCESS;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
