#!/usr/bin/env python3

import os
import socket
import ssl

# Constants

HOST = 'chat.ndlug.org'
PORT = 6697
NICK = f'ircle-{os.environ["USER"]}'

# Functions

def ircle():
    # Connect to IRC server
    ssl_context = ssl.create_default_context()
    tcp_socket  = socket.create_connection((HOST, PORT))
    ssl_socket  = ssl_context.wrap_socket(tcp_socket, server_hostname=HOST)
    ssl_stream  = ssl_socket.makefile('rw')

    # Identify ourselves
    ssl_stream.write(f'USER {NICK} 0 * :{NICK}\r\n')
    ssl_stream.write(f'NICK {NICK}\r\n')
    ssl_stream.flush()

    # Join #bots channel
    ssl_stream.write(f'JOIN #bots\r\n')
    ssl_stream.flush()

    # Write message to channel
    ssl_stream.write(f"PRIVMSG #bots :I've fallen and I can't get up!\r\n")
    ssl_stream.flush()

    # Read and display
    while True:
        message = ssl_stream.readline().strip()
        print(message)

# Main Execution

def main():
    ircle()

if __name__ == '__main__':
    main()
