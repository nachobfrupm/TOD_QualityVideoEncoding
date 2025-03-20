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
ROOT_DIR=$SCRIPT_DIR/../..

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

# ##########################################################################################################
# STAGE 6 VCA
cd $INPUT_DIR
# Generate YUV from source file
export INPUT_YUV=${MASTER_VIDEO_FILE}.yuv
ffmpeg -y -i $MASTER_VIDEO_FILE -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
# Gather width and height of the input video
export INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 $MASTER_VIDEO_FILE)
export INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 $MASTER_VIDEO_FILE)
#V1.1
FPS_ORIGINAL_VIDEO=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 $MASTER_VIDEO_FILE | bc -l)
echo $FPS_ORIGINAL_VIDEO
FPS_ORIGINAL_VIDEO=$(echo "scale=0; if ($FPS_ORIGINAL_VIDEO > ((d=$FPS_ORIGINAL_VIDEO)/1)) d/1+1 else d/1" | bc)
#V1.1

${ROOT_DIR}/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps $FPS_ORIGINAL_VIDEO --complexity-csv ${INPUT_DIR}/TMP/source_mp4_file.mp4.vca.csv
# at this point we need to calculate Spatial Complexity (E) and Temporal complexity in Average from the csv file
python3 $ROOT_DIR/SCRIPTS/PYTHON/average.py TMP/source_mp4_file.mp4.vca.csv ${INPUT_DIR}/TMP/source_mp4_file.mp4.vca.average.csv
E_Value=$(tail -1 ${INPUT_DIR}/TMP/source_mp4_file.mp4.vca.average.csv | cut -d "," -f2)
h_Value=$(tail -1 ${INPUT_DIR}/TMP/source_mp4_file.mp4.vca.average.csv | cut -d "," -f3)
echo "E: $E_Value"
echo "h: $h_Value"
echo "$SCRIPT_DIR/change_csv_at_pos.sh ${MASTER_VIDEO_FILE}.csv 6 $E_Value $TEMPORARY_FILE"
$SCRIPT_DIR/change_csv_at_pos.sh ${MASTER_VIDEO_FILE}.csv 7 $E_Value $TEMPORARY_FILE
$SCRIPT_DIR/change_csv_at_pos.sh ${MASTER_VIDEO_FILE}.csv 8 $h_Value $TEMPORARY_FILE



# Cleanup YUV
/usr/bin/rm ${INPUT_YUV}
for input_vca_mp4_file in $(ls *.mp4 | grep "_AT_"); do
    # We need YUV files as in STAGE 2
    INPUT_YUV=${input_vca_mp4_file}.mp4.yuv
    ffmpeg -y -i $input_vca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
    ${ROOT_DIR}/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps $FPS_ORIGINAL_VIDEO --complexity-csv ${INPUT_DIR}/TMP/${input_vca_mp4_file}.vca.csv
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/${input_vca_mp4_file}.vca.csv ${INPUT_DIR}/TMP/${input_vca_mp4_file}.vca.average.csv
    E_Value=$(tail -1 TMP/${input_vca_mp4_file}.vca.average.csv | cut -d "," -f2)
    h_Value=$(tail -1 TMP/${input_vca_mp4_file}.vca.average.csv | cut -d "," -f3)
    echo "E: $E_Value"
    echo "h: $h_Value"
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_vca_mp4_file}.csv 7 $E_Value $TEMPORARY_FILE
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_vca_mp4_file}.csv 8 $h_Value $TEMPORARY_FILE
    # Cleanup YUVmaster_mp4_file.mp4.csv
    /usr/bin/rm ${INPUT_YUV}
done
