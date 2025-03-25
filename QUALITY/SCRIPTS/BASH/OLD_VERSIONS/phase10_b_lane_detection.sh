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

if [ -d ${INPUT_DIR}/LANE_DETECTION ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/LANE_DETECTION
fi



# ##########################################################################################################
# STAGE 9 COVER
cd ${ROOT_DIR}/ALGORITHMS/YOLOPv2
ENV_PATH=${ROOT_DIR}/ALGORITHMS/YOLOPv2/yolopv2/bin/activate       

ls -altr $ENV_PATH


cd ${INPUT_DIR}
for input_mp4_file in $(ls *.mp4)
    do          
      # python3 lane_detector.py --source /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/MULTI/LEDDARTECH/EXPERIMENT/input_mp4_file.mp4_AT_1000.mp4   --save-txt --project QUALITY --exist-ok
      cd ${ROOT_DIR}/ALGORITHMS/YOLOPv2
      bash --rcfile $ENV_PATH -i  -c "python lane_detector.py --source ${INPUT_DIR}/${input_mp4_file} --save-txt --project QUALITY --exist-ok; exit 0"
done
cd  ${INPUT_DIR}
cp ${ROOT_DIR}/ALGORITHMS/YOLOPv2/QUALITY/exp/master_mp4_file.mp4 ${INPUT_DIR}/LANE_DETECTION
for input_mp4_file in $(ls *.mp4)
    do
       echo $input_mp4_file
       LD_PCT=$(python3 $ROOT_DIR/SCRIPTS/PYTHON/red_similarity.py ${ROOT_DIR}/ALGORITHMS/YOLOPv2/QUALITY/exp/master_mp4_file.mp4  ${ROOT_DIR}/ALGORITHMS/YOLOPv2/QUALITY/exp/$input_mp4_file)
       echo "LC_PCT = $LD_PCT"
       cp ${ROOT_DIR}/ALGORITHMS/YOLOPv2/QUALITY/exp/$input_mp4_file ${INPUT_DIR}/LANE_DETECTION
       $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 24 $LD_PCT $TEMPORARY_FILE
done



