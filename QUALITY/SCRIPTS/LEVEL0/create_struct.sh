#!/bin/bash

# Now create a normal directory structure


# Set the initial counter
counter=1

# Loop through all files in the current directory
for file in $(ls *.mp4); do
  # Skip if it's a directory
  if [[ -d "$file" ]]; then
    continue
  fi

  # Format the counter as a two-digit number
  formatted_counter=$(printf "%02d" $counter)

  # Create the new file name
  new_filename="sequence_${formatted_counter}.mp4"

  # Create the directory name
  new_dirname="SEQUENCE_${formatted_counter}"

  # Rename the file
  mv "$file" "$new_filename"

  # Create a new directory
  mkdir "$new_dirname"

  # Move the renamed file into the new directory
  mv "$new_filename" "$new_dirname"

  # Increment the counter
  ((counter++))
done

