#!/bin/bash

if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <input1.png> <input2.png> <input3.png> <input4.png> <input5.png> <input6.png> <output.png>"
    exit 1
fi

# Assign input and output parameters to variables
input1=$1
input2=$2
input3=$3
input4=$4
input5=$5
input6=$6
output=$7

# Ensure ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required but not installed. Please install it and try again."
    exit 1
fi

# Resize images to 1280x720
convert "$input1" -resize 1280x720\! resized1.png
convert "$input2" -resize 1280x720\! resized2.png
convert "$input3" -resize 1280x720\! resized3.png
convert "$input4" -resize 1280x720\! resized4.png
convert "$input5" -resize 1280x720\! resized5.png
convert "$input6" -resize 1280x720\! resized6.png

# Create two rows of images
convert +append resized1.png resized2.png resized3.png row1.png
convert +append resized4.png resized5.png resized6.png row2.png

# Combine the two rows vertically
convert -append row1.png row2.png "$output"

# Clean up temporary files
#rm resized1.png resized2.png resized3.png resized4.png resized5.png resized6.png row1.png row2.png

echo "Output image created: $output"
