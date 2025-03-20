#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
export INPUT_FILE=$2
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp_${INPUT_FILE}.csv
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=$SCRIPT_DIR/../..


cd $INPUT_DIR
TMP_JSON_FILE=${INPUT_DIR}/TMP/${INPUT_FILE}_siti_out.json
siti-tools $INPUT_FILE --color-range full >$TMP_JSON_FILE    
SPATIAL_INFO=$(cat $TMP_JSON_FILE | jq '.si | add/length')
TEMPORAL_INFO=$(cat $TMP_JSON_FILE | jq '.ti | add/length')
echo "${INPUT_FILE} ; $SPATIAL_INFO ; $TEMPORAL_INFO"
$SCRIPT_DIR/change_csv_at_pos.sh ${INPUT_FILE}.csv 4 $SPATIAL_INFO $TEMPORARY_FILE    
$SCRIPT_DIR/change_csv_at_pos.sh ${INPUT_FILE}.csv 5 $TEMPORAL_INFO $TEMPORARY_FILE        

