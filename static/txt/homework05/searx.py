#!/usr/bin/env python3

''' searx.py - SearX from the command line '''

import sys

import requests

# Constants

URL     = 'https://searx.ndlug.org/search'
LIMIT   = 5
ORDERBY = 'score'

# Functions

def usage(exit_status: int=0) -> None:
    ''' Print usage message and exit. '''
    print(f'''Usage: searx.py [-u URL -n LIMIT -o ORDERBY] QUERY

Fetch SearX results for QUERY and print them out.

    -u URL      Use URL as the SearX instance (default is: {URL})
    -n LIMIT    Only display up to LIMIT results (default is: {LIMIT})
    -o ORDERBY  Sort the search results by ORDERBY (default is: {ORDERBY})

If ORDERBY is score, the results are shown in descending order.  Otherwise,
results are shown in ascending order.''', file=sys.stderr)
    sys.exit(exit_status)

def searx_query(query: str, url: str=URL) -> list[dict]:
    ''' Returns lists of results for query from SearX.

    >>> searx_query('Python', 'https://yld.me/ipfM') # doctest: +ELLIPSIS
    [{'url': 'https://www.python.org/', 'title': 'Welcome to Python.org', ...}]
    '''
    pass

def print_results(results: list[dict], limit: int=LIMIT, orderby: str=ORDERBY) -> None:
    ''' Print results of SearX query.

    >>> print_results(searx_query('Python', 'https://yld.me/ipfM')) # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
        1.  Welcome to Python.org [...]
            https://www.python.org/
    ...
    '''
    pass

# Main Execution

def main(arguments=sys.argv[1:]) -> None:
    ''' Searches SearX and print results.

    >>> main('-u https://yld.me/ipfM Python'.split()) # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
        1.  Welcome to Python.org [...]
            https://www.python.org/
    ...
    '''
    pass

if __name__ == '__main__':
    main()

# vim: set sts=4 sw=4 ts=8 expandtab ft=python:
