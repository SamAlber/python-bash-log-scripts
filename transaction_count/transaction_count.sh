#!/bin/bash

# SAMUEL ALBERSHTEIN - TRANSACTION COUNT EXTRACTION
# This script prompts the user for a file path and extracts the number of transactions (we will count the completed ones)
# + Path check

count_end_transactions() {
    local path="$1"
    local count_start=0
    local count_end=0

    local transaction_start_pattern="transaction [0-9]\+ begun"
    local transaction_end_pattern="transaction done, id=[0-9]\+"

    while IFS= read -r line; do # IFS is none so the string will be taken as a whole and put within the line variable 
        if [[ $line =~ $transaction_start_pattern ]]; then # =~ for REGEX equation match 
            ((count_start++))
        fi

        if [[ $line =~ $transaction_end_pattern ]]; then
            ((count_end++))
        fi
    done < "$path" # We start the while by passing path for 'read' to read the next line and test it within the 2 if's (while starts from this and continues with this loop)

    local transactions_count=$((count_start < count_end ? count_start : count_end)) # Double (( )) for math operations and checking if count_start is lower than count_end 

    echo "$transactions_count" # STDOUT for count_end_transactions output 
}

while true; do
    read -p "Please enter the path to the log file (q for quit): " path

    if [[ "$path" == "q" || "$path" == "Q" ]]; then
        break
    fi

    if [[ -e "$path" ]]; then # Checks if the path exists 
        if [[ -r "$path" ]]; then # Checks if the file is readable 
            transactions_count=$(count_end_transactions "$path") # $() Makes the function run and it's stdout is assigned to transactions_count 
            echo "This log contains: $transactions_count Completed transactions"
        else
            echo "The file is not readable"
        fi
    else
        echo "Wrong path, please try again"
    fi
done
