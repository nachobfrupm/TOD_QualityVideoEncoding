#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <filename> <position> <new_value> <temporary_filename>"
    exit 1
fi

# Get the script arguments
filename="$1"
position="$2"
new_value="$3"
temporary_filename="$4"

# Validate that the position is a positive integer
if ! [[ "$position" =~ ^[0-9]+$ ]] || [ "$position" -le 0 ]; then
    echo "Error: Position must be a positive integer."
    exit 1
fi

# Read the content, process it, and save to the output file
{
    # Read and output header
    IFS= read -r header_line
    echo "$header_line"
    
    # Process all lines but the last
    while IFS= read -r line; do
        last_line="$line"
    done
    
    # Modify last line
    modified_line=$(awk -F, -v pos="$position" -v value="$new_value" '{
        if (NF >= pos) {
            $pos = value
            print
        } else {
            print "Error: Last line has fewer than " pos " fields." > "/dev/stderr"
            print
        }
    }' OFS=, <<< "$last_line")
    
    # Output modified last line
    echo "$modified_line"
} < "$filename" > "$temporary_filename"
mv $temporary_filename $filename



