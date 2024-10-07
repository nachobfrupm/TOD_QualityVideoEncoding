#!/bin/bash
INPUT_ARGO_DIR=/home/xruser/TOD/TESIS/DATASETS/ARGODRIVE/sensor/train/
OUTPUT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/SEQUENCES
cd ${INPUT_ARGO_DIR}
for directory in $(ls)
do 
      cd ${directory}/sensors/cameras/ring_front_center/
      ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=2048:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p ${OUTPUT_DIR}/${directory}.mp4
      cd ${INPUT_ARGO_DIR}
done
cd ${OUTPUT_DIR}
ls -altr *mp4
# Now create a normal directory structure


# Set the initial counter
counter=1

# Loop through all files in the current directory
for file in $(ls *mp4); do
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
