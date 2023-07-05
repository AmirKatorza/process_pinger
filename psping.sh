#!/bin/bash

# Default values
COUNT=-1
TIMEOUT=1
USERNAME=""
EXENAME=""

# Function to display script usage
usage() {
    echo "Usage: psping [-c COUNT] [-t TIMEOUT] [-u USERNAME] EXENAME"
    echo "  -c: Limit amount of pings, e.g. -c 3. Default is infinite"
    echo "  -t: Define alternative timeout in seconds, e.g. -t 5. Default is 1 sec"
    echo "  -u: define user to check process for. Default is ANY user."
    echo "  EXENAME: Name of the executable to ping"
    exit 1
}

# Process command-line arguments
while getopts "c:t:u:" opt; do
    case $opt in
        c)
            if [[ $OPTARG =~ ^[1-9]\d*$ ]]; then
                COUNT=$OPTARG
            else
                usage
            fi
            ;;
        t)
            if [[ $OPTARG =~ ^[1-9]\d*$ ]]; then
                TIMEOUT=$OPTARG
            else
                usage
            fi          
            ;;
        u)
            if [[ -n $OPTARG && id "$OPTARG" &>/dev/null ]]; then
                USERNAME=$OPTARG
            else
                usage
            fi
            ;;
        *)
            usage
            ;;
    esac
done

# Shift the processed options
shift $((OPTIND-1))

# Check if EXENAME is provided
if [ $# -eq 0 ]; then
    usage
fi

EXENAME=$1

# Function to count and echo live processes
function count_processes() {
    local process_count=0
    if [ -z "$USERNAME" ]; then
        process_count=$(pgrep -c -x "$EXENAME")
    else
        process_count=$(pgrep -c -x -u "$USERNAME" "$EXENAME")
    fi
    echo "$EXENAME: $process_count instance(s)..."
}

# Function to echo opening message
function openin_message() {
    if [ -z "$USERNAME" ]; then 
        echo "Pinging '$EXENAME' for any user"
    else
        echo "Pinging '$EXENAME' for user '$USERNAME'"
    fi
}

# Print opening message
openin_message

# Start pinging
if [ $COUNT -eq -1 ]; then
    while true; do
        count_processes
        sleep "$TIMEOUT"
    done
else
    for ((i=0; i<COUNT; i++)); do
        count_processes
        sleep "$TIMEOUT"
    done
fi
