#!/usr/bin/env python3

''' wc.py - print newline, word, and byte counts for stream '''

import io
import sys

# Functions

def usage(exit_status: int=0) -> None:
    ''' Print usage message and exit. '''
    print('''Usage: wc.py [-l | -w | -c]

Print newline, word, and byte counts from standard input.

The options below may be used to select which counts are printed, always in
the following order: newline, word, byte.

    -c      Print byte counts
    -l      Print newline counts
    -w      Print word counts''', file=sys.stderr)
    sys.exit(exit_status)

def count_stream(stream=sys.stdin) -> dict[str, int]:
    ''' Count the newlines, words, and bytes in specified stream.

    >>> count_stream(io.StringIO('Despite all my rage, I am still just a rat in a cage'))
    {'newlines': 1, 'words': 13, 'bytes': 52}
    '''
    pass

def print_counts(counts: dict[str, int], options: list[str]) -> None:
    ''' Print the newline, word, and byte counts.  If none of the options are
    specified, then include all options in output.  Othewrise, only include the
    specified options.

    Note: always output the counts the following order: newlines, words, bytes.

    >>> print_counts({'newlines': 1, 'words': 13, 'bytes': 52}, ['newlines', 'words', 'bytes'])
     1 13 52
    '''
    pass

# Main Execution

def main(arguments=sys.argv[1:], stream=sys.stdin) -> None:
    ''' Print the newline, word, and byte counts from stream.

    This function will parse the command line arguments to select which counts
    to include in the final report.

    >>> main([], io.StringIO('Despite all my rage, I am still just a rat in a cage'))
     1 13 52
    '''
    # Parse command line arguments
    pass

    # Count stream and print counts
    pass

if __name__ == '__main__':
    main()

# vim: set sts=4 sw=4 ts=8 expandtab ft=python:
