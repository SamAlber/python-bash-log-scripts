#!/bin/bash

# SAMUEL ALBERSHTEIN - FIRST LINE TEXT EXTRACTION
# This script prompts the user for a file path and extracts the first line of the file.
# I also added a path check to analyze annoying errors :)

get_first_line() {
    local path="$1"
    read -r first_line < "$path" # Could have used head -n 1 "$path" instead of read and echo 
    echo "$first_line"
}

while true; do
    read -p "Please enter the path to the log file (q for quit): " path

    if [[ "$path" == "q" || "$path" == "Q" ]]; then
        break
    fi

    if [[ -e "$path" ]]; then # Check if the path plainly exists regardless of what type of file it is (regular file, directory, symbolic link, etc.).) UNLIKE -f in the ERROR count script. 
        if [[ -r "$path" ]]; then # Check if the file is readable
            first_line=$(get_first_line "$path")
            echo "This path exists"
            echo "The first line of the log is: $first_line"
        else
            echo "The file is not readable"
        fi
    else
        echo "Wrong path, please try again"
    fi
done
