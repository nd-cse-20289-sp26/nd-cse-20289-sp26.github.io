/* socket.c: TCP Socket Functions */

#include "socket.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

/**
 * Create socket connection to specified host and port.
 * @param   host        Host string to connect to.
 * @param   port        Port string to connect to.
 * @return  Socket file stream of connection if successful, otherwise NULL.
 **/
FILE *socket_dial(const char *host, const char *port) {
    // TODO: Lookup server address information

    // TODO: For each server entry, allocate socket and try to connect

	// TODO: Allocate socket

	// TODO: Connect to host

    // TODO: Release allocate address information

    // TODO: Open file stream from socket file descriptor

    return NULL;
}

/* vim: set expandtab sts=4 sw=4 ts=8 ft=c: */
