/* moveit.c: Interactive Move Command */

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <fcntl.h>
#include <sys/wait.h>
#include <unistd.h>

/* Macros */

#define streq(a, b) (strcmp(a, b) == 0)
#define strchomp(s) (s)[strlen(s) - 1] = 0

/* Functions */

/**
 * Display usage message and exit.
 * @param   status      Exit status.
 **/
void    usage(int status) {
    fprintf(stderr, "Usage: moveit files...\n");
    exit(status);
}

/**
 * Save list of file paths to temporary file.
 * @param   files       Array of path strings.
 * @param   n           Number of path strings.
 * @return  Newly allocated path to temporary file (must be freed).
 **/
char *  save_files(char **files, size_t n) {
    // TODO: Create temporary file

    // TODO: Open temporary file for writing

    // TODO: Write paths to temporary file

    return NULL;
}

/**
 * Run $EDITOR on specified path.
 * @param   path        Path to file to edit.
 * @return  Whether or not the $EDITOR process terminatesd successfully.
 **/
bool    edit_files(const char *path) {
    // TODO: Get EDITOR from environment (default to vim if not found)

    // TODO: Fork process
    //  1. Child: execute editor on path
    //  2. Parent: wait for child

    // TODO: Return exit status of child process

    return false;
}

/**
 * Rename files as specified in contents of path.
 * @param   files       Array of old path names.
 * @param   n           Number of old path names.
 * @param   path        Path to file with new names.
 * @return  Whether or not all rename operations were successful.
 **/
bool    move_files(char **files, size_t n, const char *path) {
    // TODO: Open temporary file at path for reading

    // TODO: Rename each file in array according to new name in temporary file
    // (if the names do not match)

    return false;
}

/* Main Execution */

int     main(int argc, char *argv[]) {
    // TODO: Parse command line options

    // TODO: Save files

    // TODO: Edit files

    // TODO: Move files

    // TODO: Cleanup temporary file

    return EXIT_FAILURE;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
