#!/bin/bash


export INPUT_FILE=$1
START_TIME="00:01:35"
END_TIME="00:01:45"
#END_TIME="00:07:15"

ffmpeg -y -ss $START_TIME -to $END_TIME -i $INPUT_FILE -c copy ${INPUT_FILE}_CUT.mp4
siti-tools ${INPUT_FILE}_CUT.mp4 --color-range full >${INPUT_FILE}_CUT.mp4.json
SPATIAL_INFO=$(cat ${INPUT_FILE}_CUT.mp4.json | jq '.si | add/length')
TEMPORAL_INFO=$(cat ${INPUT_FILE}_CUT.mp4.json | jq '.ti | add/length')
echo "${INPUT_FILE} ; $SPATIAL_INFO ; $TEMPORAL_INFO"

