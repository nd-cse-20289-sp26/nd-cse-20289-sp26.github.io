#!/bin/sh

# Globals

URL=https://www.zipcodestogo.com/
STATE="Indiana"

# Functions

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0)

-c      CITY    Which city to search
-s      STATE   Which state to search ($STATE)

If no CITY is specified, then all the zip codes for the STATE are displayed.
EOF
    exit $1
}

zipcode_information() {
    # Fetch zipcode information from URL based on CITY and STATE
}

filter_zipcodes() {
    # Extract zipcodes from zipcode source
}

# Parse Command Line Options

while [ $# -gt 0 ]; do
    case $1 in
        -h) usage 0;;
         *) usage 1;;
    esac
    shift
done

# Filter Pipeline

zipcode_information | filter_zipcodes
