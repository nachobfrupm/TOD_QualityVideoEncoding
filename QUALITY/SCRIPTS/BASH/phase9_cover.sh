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
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

# ##########################################################################################################
# STAGE 9 COVER
cd ${ROOT_DIR}/ALGORITHMS/COVER/COVER
ENV_PATH=${ROOT_DIR}/ALGORITHMS/COVER/cover/bin/activate        
bash --rcfile $ENV_PATH -i  -c "python evaluate_a_set_of_videos.py -i  ${INPUT_DIR} --output  ${INPUT_DIR}/cover.csv ; exit 0"                                                             

cd $INPUT_DIR
for input_mp4_file in $(ls *.mp4)
    do
      dos2unix ${input_mp4_file}.csv
      data_cover=$(grep ${input_mp4_file} cover.csv|head -1 |cut -d "," -f2-5)
      echo "${input_mp4_file}.csv $data_cover"
      COVER_SSC=$(echo $data_cover|cut -d "," -f1)      
      COVER_TSC=$(echo $data_cover|cut -d "," -f2)      
      COVER_ASC=$(echo $data_cover|cut -d "," -f3)      
      COVER_FSC=$(echo $data_cover|cut -d "," -f4)      
      $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 11 $COVER_SSC $TEMPORARY_FILE
      $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 12 $COVER_TSC $TEMPORARY_FILE
      $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 13 $COVER_ASC $TEMPORARY_FILE
      $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 14 $COVER_FSC $TEMPORARY_FILE
      
    
done

