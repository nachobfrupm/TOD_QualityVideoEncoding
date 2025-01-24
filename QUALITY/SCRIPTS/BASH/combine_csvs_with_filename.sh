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
  # Get the filename without the path
  filename=$(dirname "$file")
  
  if [ "$header_included" = false ]; then
    # Include the header from the first file along with a new column for filename
    awk -v fname="$filename" -F',' 'BEGIN {OFS=","} {if(NR==1) print $0,"filename"; else print $0,fname}' "$file" > "$output"
    header_included=true
  else
    # Skip the header in subsequent files, append content and add filename column
    awk -v fname="$filename" -F',' 'BEGIN {OFS=","} {if(NR>1) print $0,fname}' "$file" >> "$output"
  fi
done

echo "All files have been combined into $output with an extra filename column."

