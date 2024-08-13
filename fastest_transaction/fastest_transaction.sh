#!/bin/bash

# SAMUEL ALBERSHTEIN - FASTEST TRANSACTION IN ms EXTRACTION
# This script prompts the user for a file path and extracts the fastest executed transaction
# + Path check

# Function to parse the log file and extract the transaction timings
parse_log() {

    declare -A transactions

    while IFS= read -r line; do

        if [[ $line =~ ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}).*?transaction\ ([0-9]+)\ (begun) ]]; then
            timestamp="${BASH_REMATCH[1]}"
            transaction_id="${BASH_REMATCH[2]}"
            transactions[$transaction_id,begun]=$timestamp

        elif [[ $line =~ ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}).*?transaction\ (done),\ id=([0-9]+) ]]; then
            timestamp="${BASH_REMATCH[1]}"
            transaction_id="${BASH_REMATCH[3]}"
            transactions[$transaction_id,done]=$timestamp

        fi
    done < "$1" # As is without calling it as local path=$1 

    echo "${!transactions[@]}" > /dev/null 2>&1 # suppress output and error output. This echo displays nothing 
    fastest_transaction=""
    min_time=999999999 # Big number so any successful calculated duration will be lower than this 

    for transaction_id in $(printf "%s\n" "${!transactions[@]}" | cut -d, -f1 | sort -u); do

        if [[ -n "${transactions[$transaction_id,begun]}" && -n "${transactions[$transaction_id,done]}" ]]; then

            start_time=$(date -u -d "${transactions[$transaction_id,begun]}" +"%s%3N")
            end_time=$(date -u -d "${transactions[$transaction_id,done]}" +"%s%3N")
            duration=$(( end_time - start_time ))

            if (( duration < min_time )); then
                min_time=$duration
                fastest_transaction=$transaction_id 
            fi
        fi
    done

    echo $fastest_transaction
}

while true; do
    read -p "Please enter the path to the log file (q for quit): " path

    if [[ "$path" == "q" ]]; then
        break
    fi

    if [[ -f "$path" ]]; then
        fastest_id=$(parse_log "$path")
        if [[ -n "$fastest_id" ]]; then
            echo "The fastest transaction is: $fastest_id"
        else
            echo "No complete transactions found."
        fi
    else
        echo "Wrong path, please try again."
    fi
done
