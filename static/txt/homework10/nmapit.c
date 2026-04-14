/* nmapit.c: Simple network port scanner */

#include "socket.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <netdb.h>
#include <signal.h>

#ifndef GNU_SOURCE
typedef void (*sighandler_t)(int);
#endif

/* Functions */

/**
 * Display usage message and exit.
 * @param   status      Exit status
 **/
void    usage(int status) {
    fprintf(stderr, "Usage: nmapit [-p START-END] HOST\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -p START-END    Specifies the range of port numbers to scan\n");
    exit(status);
}

/**
 * Handle alarm signal.
 * @param   signum      Signal number
 **/
void sigalrm_handler(int signum) {
    // TODO: Cancel current alarm
}

/**
 * Parse port range string into start and end port integers.
 * @param   range       Port range string (ie. START-END)
 * @param   start       Pointer to starting port integer
 * @param   end         Pointer to ending port integer
 * @return  true if parsing both start and end were successful, otherwise false
 **/
bool parse_ports(char *range, int *start, int *end) {
    // TODO: Parse starting port

    // TODO: Parse ending port
    return false;
}

/**
 * Scan ports at specified host from starting and ending port numbers
 * (inclusive).
 * @param   host        Host to scan
 * @param   start       Starting port number
 * @param   end         Ending port number
 * @return  true if any port is found, otherwise false
 **/
bool scan_ports(const char* host, int start, int end) {
    // TODO: Register signal handler for alarm

    // TODO: For each port, set alarm, attempt to dial host and port
    return false;
}

/* Main Execution */

int main(int argc, char *argv[]) {
    // TODO: Parse command-line arguments

    // TODO: Scan ports
    return EXIT_FAILURE;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
