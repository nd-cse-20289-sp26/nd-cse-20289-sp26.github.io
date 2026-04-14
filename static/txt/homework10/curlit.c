/* curlit.c: Simple HTTP client*/

#include "socket.h"

#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <netdb.h>

/* Constants */

#define HOST_DELIMITER  "://"
#define PATH_DELIMITER  '/'
#define PORT_DELIMITER  ':'
#define BILLION         (1000000000.0)
#define MEGABYTES       (1<<20)

/* Macros */

#define streq(a, b) (strcmp(a, b) == 0)

/* Structures */

typedef struct {
    char host[NI_MAXHOST];
    char port[NI_MAXSERV];
    char path[PATH_MAX];
} URL;

/* Functions */

/**
 * Display usage message and exit.
 * @param   status      Exit status.
 **/
void    usage(int status) {
    fprintf(stderr, "Usage: curlit [-h] URL\n");
    exit(status);
}

/**
 * Parse URL string into URL structure.
 * @param   s       URL string
 * @param   url     Pointer to URL structure
 **/
void    parse_url(const char *s, URL *url) {
    // TODO: Copy data to local buffer

    // TODO: Skip scheme to host

    // TODO: Split host:port from path

    // TODO: Split host and port

    // TODO: Copy components to URL
}

/**
 * Fetch contents of URL and print to standard out.
 *
 * Print elapsed time and bandwidth to standard error.
 * @param   s       URL string
 * @param   url     Pointer to URL structure
 * @return  true if client is able to read all of the content (or if the
 * content length is unset), otherwise false
 **/
bool    fetch_url(URL *url) {
    // TODO: Grab start time

    // TODO: Connect to remote host and port

    // TODO: Send request to server

    // TODO: Read status response from server

    // TODO: Read response headers from server

    // TODO: Read response body from server

    // TODO: Grab end time

    // TODO: Output metrics

    return false;
}

/* Main Execution */

int     main(int argc, char *argv[]) {
    // TODO: Parse command line options

    // TODO: Parse URL

    // TODO: Fetch URL

    return EXIT_FAILURE;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
