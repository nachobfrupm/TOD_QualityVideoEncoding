#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
VMAF_BINARY_FULL_PATH=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/BIN/vmaf
MASTER_VIDEO_FILE=${INPUT_DIR}/master_mp4_file.mp4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp.csv
ROOT_DIR=$SCRIPT_DIR/../..
VMAF_BINARY_FULL_PATH=$ROOT_DIR/BIN/vmaf


# ##########################################################################################################
# STAGE 3 VMAF CALCULATION

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi


echo "${INPUT_DIR}/TMP"
ls ${INPUT_DIR}/TMP
# Iterate over new created file
cd $INPUT_DIR
# Generate YUV from mater file
INPUT_YUV=${INPUT_DIR}/master_mp4_file.mp4.yuv
ffmpeg -y -i ${INPUT_DIR}/master_mp4_file.mp4 -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
# Gather width and height of the input video
INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 $MASTER_VIDEO_FILE)
INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 $MASTER_VIDEO_FILE)
VMAF_VALUE="100"
#sed -i '$ s/$/'"${VMAF_VALUE},"'/' "${MASTER_VIDEO_FILE}.csv"
echo "$SCRIPT_DIR/change_csv_at_pos.sh ${MASTER_VIDEO_FILE}.csv 2 $VMAF_VALUE $TMP_DIR/tmp.csv"
$SCRIPT_DIR/change_csv_at_pos.sh ${MASTER_VIDEO_FILE}.csv 2 $VMAF_VALUE $TEMPORARY_FILE


for input_vmaf_mp4_file in $(ls *mp4 | grep _AT); do
    TMP_VMAF_FILE=${INPUT_DIR}/TMP/${input_vmaf_mp4_file}.vmaf.json
    # Generate YUV for every one
    OUTPUT_YUV=${input_vmaf_mp4_file}.mp4.yuv
    ffmpeg -y -i $input_vmaf_mp4_file -c:v rawvideo -pixel_format yuv420p $OUTPUT_YUV
    echo "${ROOT_DIR}/BIN/vmaf --reference $INPUT_YUV  --distorted $OUTPUT_YUV --width $INPUT_WIDTH --height $INPUT_HEIGHT --pixel_format 420 --bitdepth 8 --output ${TMP_VMAF_FILE} --json"
    $VMAF_BINARY_FULL_PATH --reference $INPUT_YUV --distorted $OUTPUT_YUV --width $INPUT_WIDTH --height $INPUT_HEIGHT --pixel_format 420 --bitdepth 8 --output ${TMP_VMAF_FILE} --json
    VMAF_VALUE=$(grep mean ${TMP_VMAF_FILE} | grep -v harmonic | tail -1 | cut -d ":" -f2 | cut -d "," -f1 | cut -d " " -f2)
    #sed -i '$ s/$/'"${VMAF_VALUE},"'/' ${input_vmaf_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_vmaf_mp4_file}.csv 2 $VMAF_VALUE $TEMPORARY_FILE    
    echo $VMAF_VALUE
    /usr/bin/rm $OUTPUT_YUV
done
#/usr/bin/rm $INPUT_YUV
