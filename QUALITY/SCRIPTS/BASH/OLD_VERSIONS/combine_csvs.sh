#!/bin/bash

# Define the output file
output="combined.csv"

# Get the list of CSV files
files=("$@")

# Check if there are files to process
if [ ${#files[@]} -eq 0 ]; then
  echo "No CSV files provided."
  exit 1
fi

# Initialize a variable to control header inclusion
header_included=false

# Process each CSV file
for file in "${files[@]}"; do
  if [ "$header_included" = false ]; then
    # Include the header from the first file
    cat "$file" > "$output"
    header_included=true
  else
    # Skip the header in subsequent files and append the content
    tail -n +2 "$file" >> "$output"
  fi
done

echo "All files have been combined into $output."

