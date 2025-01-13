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
# STAGE 4 PSNR CALCULATION
cd $INPUT_DIR
PSNR_VALUE=""
for input_psnr_mp4_file in $(ls *mp4 | grep _AT); do
    TMP_PSNR_FILE=${INPUT_DIR}/TMP/psnr_${input_psnr_mp4_file}.psnr.txt
    echo "${TMP_PSNR_FILE}"
    FIRST_MP4_FILE=$MASTER_VIDEO_FILE
    SECOND_MP4_FILE=${input_psnr_mp4_file}
    PSNR_VALUE=$(ffmpeg -i ${FIRST_MP4_FILE} -i ${SECOND_MP4_FILE} -lavfi psnr=stats_file=${TMP_PSNR_FILE} -f null - 2>&1 | grep Parsed | cut -d ":" -f5 | cut -d " " -f1 | tail -1)
    echo "PSNR - VALUE IS : $PSNR_VALUE"    
        $SCRIPT_DIR/change_csv_at_pos.sh ${input_psnr_mp4_file}.csv 3 $PSNR_VALUE $TEMPORARY_FILE
done
