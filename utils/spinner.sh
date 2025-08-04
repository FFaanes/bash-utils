#!/bin/bash

source ./colors.sh

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local i=0

    # Loop while the process is running
    while kill -0 "$pid" 2>/dev/null; do
        blue "\r[%c] Running..." "${spinstr:i++%${#spinstr}:1}"
        sleep $delay
    done
}

# Function to run a command silently with a spinner and clean output
run_with_spinner() {
    local cmd="$1"

    # Run the command in the background, suppressing all output
    (eval "$cmd" > /dev/null 2>&1) &
    local cmd_pid=$!

    spinner $cmd_pid     # Start spinner
    wait $cmd_pid        # Wait for the command to finish
    local exit_code=$?   # Capture the exit code

    # Clear the spinner line and print result
    if [ $exit_code -eq 0 ]; then
        check "\rSuccess!"
    else
        error "\rFailed!"
    fi
}

# Example usage
run_with_spinner "sleep 5"  # Replace with your actual command"
