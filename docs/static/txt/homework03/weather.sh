#!/bin/sh

# Globals

URL="https://forecast.weather.gov/zipcity.php"
ZIPCODE=46556
FORECAST=0
CELSIUS=0

# Functions

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) [zipcode]

-c    Use Celsius degrees instead of Fahrenheit for temperature
-f    Display forecast text after the temperature

If zipcode is not provided, then it defaults to $ZIPCODE.
EOF
    exit $1
}

weather_information() {
    # Fetch weather information from URL based on ZIPCODE
}

temperature() {
    # Extract temperature information from weather source
    weather_information | ...
}

forecast() {
    # Extract forecast information from weather source
    weather_information | ...
}

# Parse Command Line Options

while [ $# -gt 0 ]; do
    case $1 in
        -h) usage 0;;
    esac
    shift
done

# Display Information

echo "Temperature: $(temperature) degrees"
