#!/usr/bin/env python3

''' cut.py - remove sections from each line of stream '''

import io
import sys

# Functions

def usage(exit_status: int=0) -> None:
    ''' Print usage message and exit. '''
    print('''Usage: cut -d DELIMITER -f FIELDS

Print selected parts of lines from stream to standard output.

    -d DELIMITER    Use DELIM instead of TAB for field delimiter
    -f FIELDS       Select only these fields''', file=sys.stderr)
    sys.exit(exit_status)

def strs_to_ints(strings: list[str]) -> list[int]:
    ''' Convert all strings in list to integers.

    >>> strs_to_ints(['2', '4'])
    [2, 4]
    '''
    pass

def cut_line(line: str, delimiter: str='\t', fields: list[int]=[]) -> list[str]:
    ''' Return selected fields from line separated by delimiter.

    >>> cut_line('Harder, Better, Faster, Stronger', ',', [2, 4])
    [' Better', ' Stronger']
    '''
    pass

def cut_stream(stream=sys.stdin, delimiter: str='\t', fields: list[int]=[]) -> None:
    ''' Print selected parts of lines from stream to standard output.

    >>> cut_stream(io.StringIO('Harder, Better, Faster, Stronger'), ',', [2, 4])
     Better, Stronger
    '''
    pass

# Main Execution

def main(arguments=sys.argv[1:], stream=sys.stdin) -> None:
    ''' Print selected parts of lines from stream to standard output.

    This function will parse the command line arguments to determine the
    delimiter and which fields to select from each line.

    >>> main('-d , -f 2,4'.split(), io.StringIO('Harder, Better, Faster, Stronger'))
     Better, Stronger
    '''
    # Parse command line arguments
    pass

    # Cut stream with delimiter and fields
    pass

if __name__ == '__main__':
    main()

# vim: set sts=4 sw=4 ts=8 expandtab ft=python:
