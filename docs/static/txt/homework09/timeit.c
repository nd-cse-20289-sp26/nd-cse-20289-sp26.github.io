/* timeit.c: Run command with a time limit */

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <fcntl.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <unistd.h>

/* Macros */

#define	streq(a, b) (strcmp(a, b) == 0)
#define strchomp(s) (s)[strlen(s) - 1] = 0
#define debug(M, ...) \
    if (Verbose) { \
        fprintf(stderr, "%s:%d:%s: " M, __FILE__, __LINE__, __func__, ##__VA_ARGS__); \
    }

#define BILLION 1000000000.0

/* Globals */

int  Timeout  = 10;
bool Verbose  = false;
int  ChildPid = 0;

/* Functions */

/**
 * Display usage message and exit.
 * @param   status      Exit status.
 **/
void	usage(int status) {
    fprintf(stderr, "Usage: timeit [options] command...\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -t SECONDS  Timeout duration before killing command (default is %d)\n", Timeout);
    fprintf(stderr, "    -v          Display verbose debugging output\n");
    exit(status);
}

/**
 * Parse command line options.
 * @param   argc        Number of command line arguments.
 * @param   argv        Array of command line argument strings.
 * @return  Array of strings representing command to execute (must be freed).
 **/
char ** parse_options(int argc, char **argv) {
    // TODO: Iterate through command line arguments to determine Timeout and
    // Verbose flags

    debug("Timeout = %d\n", Timeout);
    debug("Verbose = %d\n", Verbose);

    // TODO: Copy remaining arguments into new array of strings

    if (Verbose) {
        // TODO: Print out new array of strings (to stderr)
        debug("Command =");
    }

    return NULL;
}

/**
 * Handle signal.
 * @param   signum      Signal number.
 **/
void    handle_signal(int signum) {
    // TODO: Kill child process gracefully, then forcefully
    debug("Killing child %d...\n", ChildPid);
}

/* Main Execution */

int	main(int argc, char *argv[]) {
    // TODO: Parse command line options

    // TODO: Register alarm handler and save start time
    debug("Registering handlers...\n");

    debug("Grabbing start time...\n");

    // TODO: Fork child process:
    
    //  1. Child executes command parsed from command line
    debug("Executing child...\n");

    //  2. Parent sets alarm based on Timeout and waits for child
    debug("Sleeping for %d seconds...\n", Timeout);
    debug("Waiting for child %d...\n", 0);

    // TODO: Print out child's exit status or termination signal
    debug("Child exit status: %d\n", 0);

    // TODO: Print elapsed time
    debug("Grabbing end time...\n");
    printf("Time Elapsed: %0.1lf\n", 0);

    // TODO: Cleanup
    return EXIT_FAILURE;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
