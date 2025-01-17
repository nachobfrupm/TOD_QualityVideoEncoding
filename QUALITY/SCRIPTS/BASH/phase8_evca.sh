#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
MASTER_VIDEO_FILE=${INPUT_DIR}/master_mp4_file.mp4
MASTER_VIDEO_FILE_WITHOUT_PATH=master_mp4_file.mp4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp.csv
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

# ##########################################################################################################
# STAGE 7 SITI EVCA

# SC: Spatial Complexity
# TC: Temporal Complexitiy

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

if [[ "$FPS_ORIGINAL_VIDEO" == "25" ]]; then
    G_PARAMETER=25
elif [[ "$FPS_ORIGINAL_VIDEO" == "20" ]]; then    
    G_PARAMETER=25
else # ASsume 30
    G_PARAMETER=15
fi

input_evca_mp4_file=$MASTER_VIDEO_FILE
cd ${ROOT_DIR}/ALGORITHMS/EVCA/EVCA
ENV_PATH=${ROOT_DIR}/ALGORITHMS/EVCA/EVCA/evca_env/bin/activate


#INPUT_YUV_FULL_PATH=${INPUT_DIR}/${INPUT_YUV}
echo "Excuting python3 main.py -i $INPUT_YUV -r "${INPUT_WIDTH}x${INPUT_HEIGHT}"  -g ${G_PARAMETER} -f $FPS_ORIGINAL_VIDEO  -c out.csv"
bash --rcfile $ENV_PATH -i -c "python3 main.py -i $INPUT_YUV  -r "${INPUT_WIDTH}x${INPUT_HEIGHT}" -g ${G_PARAMETER}  -f $FPS_ORIGINAL_VIDEO  -c out.csv ; exit 0"
ps -auxwww | grep bash
echo $input_evca_mp4_file
pwd
cat out_EVCA.csv
ls -altr *
ls -altr out_EVCA.csv

cp out_EVCA.csv ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.csv

# Process average
cd ${INPUT_DIR}
echo "$ROOT_DIR/SCRIPTS/PYTHON/average.py ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.csv ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.average.csv"
python3 $ROOT_DIR/SCRIPTS/PYTHON/average.py ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.csv ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.average.csv

SPATIAL_INFO=$(tail -1 ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.average.csv | cut -d "," -f2)
TEMPORAL_INFO=$(tail -1 ${INPUT_DIR}/TMP/${MASTER_VIDEO_FILE_WITHOUT_PATH}.evca.average.csv | cut -d "," -f3)
echo "SPATIAL_INFO : $SPATIAL_INFO"
echo "TEMPORAL_INFO: $TEMPORAL_INFO"
$SCRIPT_DIR/change_csv_at_pos.sh ${input_evca_mp4_file}.csv 9 $SPATIAL_INFO $TEMPORARY_FILE
$SCRIPT_DIR/change_csv_at_pos.sh ${input_evca_mp4_file}.csv 10 $TEMPORAL_INFO $TEMPORARY_FILE

cd $INPUT_DIR
for input_evca_mp4_file in $(ls *.mp4 | grep "_AT_"); do
    # We need YUV files as in STAGE 2
    export INPUT_YUV=${input_evca_mp4_file}.yuv
    echo "ffmpeg -y -i  $input_evca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV"
    ffmpeg -y -i $input_evca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
    cd ${ROOT_DIR}/ALGORITHMS/EVCA/EVCA
    ENV_PATH=/${ROOT_DIR}/ALGORITHMS/EVCA/EVCA/evca_env/bin/activate
    INPUT_YUV_FULL_PATH=${INPUT_DIR}/${INPUT_YUV}
    echo "Excuting python3 main.py -i $INPUT_YUV_FULL_PATH -r "${INPUT_WIDTH}x${INPUT_HEIGHT}"  -g ${G_PARAMETER} -f $FPS_ORIGINAL_VIDEO  -c out.csv"
    bash --rcfile $ENV_PATH -i -c "python3 main.py -i $INPUT_YUV_FULL_PATH  -r "${INPUT_WIDTH}x${INPUT_HEIGHT}"  -g ${G_PARAMETER} -f $FPS_ORIGINAL_VIDEO  -c out.csv ; exit 0"
    cp out_EVCA.csv ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.csv
    # Process average
    cd ${INPUT_DIR}
    python3 $ROOT_DIR/SCRIPTS/PYTHON/average.py ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.csv ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.average.csv
    SPATIAL_INFO=$(tail -1 ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.average.csv | cut -d "," -f2)
    TEMPORAL_INFO=$(tail -1 ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.average.csv | cut -d "," -f3)
    echo "SPATIAL_INFO : $SPATIAL_INFO"
    echo "TEMPORAL_INFO: $TEMPORAL_INFO"
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_evca_mp4_file}.csv 9 $SPATIAL_INFO $TEMPORARY_FILE
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_evca_mp4_file}.csv 10 $TEMPORAL_INFO $TEMPORARY_FILE

    
done
