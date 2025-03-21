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

# Create two rows of images
convert +append "$input1" "$input2" "$input3" row1.png
convert +append "$input4" "$input5" "$input6" row2.png

# Combine the two rows vertically
convert -append row1.png row2.png "$output"

# Clean up temporary files
rm row1.png row2.png

echo "Output image created: $output"
