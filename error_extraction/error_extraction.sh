#!/bin/bash

# SAMUEL ALBERSHTEIN - ERROR TEXT EXTRACTION
# This script prompts the user for a file path and extracts the lines with an error.
# + Path check

count_error_lines() {
    local path="$1"
    grep -c '^.*ERROR' "$path" # Counts the number of lines in a file that match a specified pattern.
}

while true; do
    read -p "Please enter the path to the log file (q for quit): " path

    if [[ "$path" == "q" || "$path" == "Q" ]]; then
        break
    fi

    if [[ -f "$path" ]]; then # Checks if the path exists and is specifically a regular file.
        error_count=$(count_error_lines "$path")
        echo "This log contains: $error_count ERROR lines"
    else
        echo "Wrong path, please try again"
    fi
done
