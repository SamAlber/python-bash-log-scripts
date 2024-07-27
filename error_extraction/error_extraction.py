#!/usr/bin/env python3

"""
SAMUEL ALBERSHTEIN - ERROR TEXT EXTRACTION

This script prompts the user for a file path and extracts the lines with an error.
+ Path check 
"""

import os 
import re


def count_error_lines(path):

    error_pattern = re.compile(r'^.*ERROR') # Simplified version of error_pattern = re.compile(r'\d{1,2}-\d{1,2}-\d{4} \d{2}:\d{2}:\d{2}\.\d{3}\s+ERROR\b')

    count = 0 
    with open(path, 'r') as file:
        for line in file:
            if error_pattern.search(line):
                count += 1
    return count


while True: # Iterating endlessly until we decide to stop by pressing q and break

    path = input("Please enter the path to the log file (q for quit): ") # Don't forget to add the extension of file if needed (.txt)

    if path.lower() == 'q': 
        break 

    if os.path.exists(path): # Will help us see if there are errors or permission problems with the path 
        try: 
            error_count = count_error_lines(path)
            print(f"This log contains: {error_count} ERROR lines")
        except Exception as e: # Will catch any error and show it for us for analysis 
            print(f"{e}")
    else:
        print("Wrong path, please try again") 
