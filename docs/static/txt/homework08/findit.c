/* findit.c: Search for files in a directory hierarchy */

#include "findit.h"

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/stat.h>
#include <unistd.h>

/* Macros */

#define	streq(a, b) (strcmp(a, b) == 0)

/* Functions */

/**
 * Print usage message and exit with status
 * @param   status      Exit status
 **/
void usage(int status) {
    fprintf(stderr, "Usage: findit PATH [OPTIONS]\n\n");
    fprintf(stderr, "Options:\n\n");
    fprintf(stderr, "   -type [f|d]	File is of type f for regular file or d for directory\n");
    fprintf(stderr, "   -name pattern	Name of file matches shell pattern\n");
    fprintf(stderr, "   -executable	File is executable or directory is searchable by user\n");
    fprintf(stderr, "   -readable	File is readable by user\n");
    fprintf(stderr, "   -writable	File is writable by user\n");
    exit(status);
}

/**
 * Recursively walk specified directory, adding all file system entities to
 * specified files list.
 * @param   root        Directory to walk
 * @param   files       List of files found
 **/
void	find_files(const char *root, List *files) {
    // TODO: Add root to files

    // TODO: Walk directory
    //  - Skip current and parent directory entries
    //  - Form full path to entry
    //  - Recursively walk directories or add entry to files list
}

/**
 * Iteratively filter list of files with each filter in list of filters.
 * @param   files       List of files
 * @param   filters     List of filters
 * @param   options     Pointer to options structure
 **/
void	filter_files(List *files, List *filters, Options *options) {
    // TODO: Apply each filter to list of files
}

/* Main Execution */

int main(int argc, char *argv[]) {
    // TODO: Parse command line arguments */

    // TODO: Find files, filter files, print files
    return EXIT_SUCCESS;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
