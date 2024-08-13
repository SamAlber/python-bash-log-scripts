#!/bin/bash

# SAMUEL ALBERSHTEIN - AVERAGE TRANSACTION IN ms CALCULATION
# This script prompts the user for a file path and calculates the average transaction time
# + Path check

parse_log() {

    local file_path="$1" # Calling the received path as file_path for usage 
    declare -A transactions # Creating a dicrionary called transactions 

    while IFS= read -r line; do
        if [[ $line =~ ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}).*transaction\ ([0-9]+)\ begun ]]; then
    
            timestamp_str="${BASH_REMATCH[1]}"
            transaction_id="${BASH_REMATCH[2]}"
            timestamp=$(date -d "$timestamp_str" +%s%3N)
            transactions["$transaction_id,begun"]="$timestamp" # Creates a new key-value entry in the dictionary 
        
        elif [[ $line =~ ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}).*transaction\ done,\ id=([0-9]+) ]]; then
    
            timestamp_str="${BASH_REMATCH[1]}"
            transaction_id="${BASH_REMATCH[2]}"
            timestamp=$(date -d "$timestamp_str" +%s%3N) # 'date' Received the date passed from timestamp_str (because of -d) and formats it to seconds and ms from the begining of the UNIX era to timestamp_str for further comparisons and calculations
            transactions["$transaction_id,done"]="$timestamp" # Creates a new key-value entry in the dictionary 
        
        fi
    done < "$file_path" # While starts from here with passing the file for the first iteration and further 

    echo "$(declare -p transactions)" # Will output : declare -A transactions='( )' the dictionary 
}



calculate_transaction_times() {

    eval "$1" # Will perform the following from what we received from echo "$(declare -p transactions)" and that's the parsed dictionary with all the key-values 
              # For example if declare -p transactions = declare -A transactions='([123,begun]="1624395296789" [123,done]="1624395312345")' We aka imported what we did in the previous step 

    declare -A transaction_times # Declaring another dictionary 

    for key in "${!transactions[@]}"; do # Iterates over all of the keys and not it's values, because of the ! , {} braces for just putting the values between " "
        if [[ $key =~ ([0-9]+),begun ]]; then
            transaction_id="${BASH_REMATCH[1]}"
            if [[ -n "${transactions[$transaction_id,done]}" ]]; then # -n checks if a value for a specific key exists 
                start_time="${transactions[$key]}"
                end_time="${transactions[$transaction_id,done]}"
                duration=$((end_time - start_time))

                transaction_times["$transaction_id"]="$duration"
            fi
        fi
    done

    echo "$(declare -p transaction_times)" # Outputs the finished form of decration -A transaction_times dictionary with it's key-values for another function to use 
}



calculate_average_transaction_time() {

    eval "$1"
    total_time=0
    count=0

    for duration in "${transaction_times[@]}"; do
        total_time=$((total_time + duration))
        count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
        average_time=$((total_time / count))
    else
        average_time=0
    fi

    echo "$average_time"
}



while true; do
    read -p "Please enter the path to the log file (q for quit): " path

    if [[ "$path" == "q" || "$path" == "Q" ]]; then
        break
    fi

    if [[ -e "$path" ]]; then

        if [[ -r "$path" ]]; then
    
            transactions_str=$(parse_log "$path")
            transaction_times_str=$(calculate_transaction_times "$transactions_str")
            average_time=$(calculate_average_transaction_time "$transaction_times_str")

            echo "The average transaction time is: $average_time ms"
        else
            echo "The file is not readable"
        fi
    else
        echo "Wrong path, please try again"
    fi
done
