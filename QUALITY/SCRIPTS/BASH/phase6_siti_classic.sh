#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
MASTER_VIDEO_FILE=${INPUT_DIR}/master_mp4_file.mp4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp.csv

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

# ##########################################################################################################
# STAGE 5 SI/TI Information

cd $INPUT_DIR
for input_siti_mp4_file in $(ls *mp4); do
    TMP_JSON_FILE=${INPUT_DIR}/TMP/${input_siti_mp4_file}_siti_out.json
    siti-tools $input_siti_mp4_file --color-range full >$TMP_JSON_FILE    
    SPATIAL_INFO=$(cat $TMP_JSON_FILE | jq '.si | add/length')
    TEMPORAL_INFO=$(cat $TMP_JSON_FILE | jq '.ti | add/length')
    echo "${input_siti_mp4_fille} ; $SPATIAL_INFO ; $TEMPORAL_INFO"
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_siti_mp4_file}.csv 4 $SPATIAL_INFO $TEMPORARY_FILE    
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_siti_mp4_file}.csv 5 $TEMPORAL_INFO $TEMPORARY_FILE        
done
