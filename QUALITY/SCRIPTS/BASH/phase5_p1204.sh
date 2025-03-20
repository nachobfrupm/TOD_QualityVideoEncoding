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
TEMPORARY_FILE=$TMP_DIR/tmp_p1204.csv
ROOT_DIR=$SCRIPT_DIR/../..


if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

# ##########################################################################################################
# STAGE 5 bitstream_mode3_p1204_3 Information


if ($STAGE_5)
then
    cd $ROOT_DIR/ALGORITHMS/bitstream_mode3_p1204_3
    poetry install
    for input_bitstream_mp4_file in $(ls ${INPUT_DIR}/*mp4)
        do
            poetry run p1204_3 --result_folder ${INPUT_DIR}/TMP --tmp ${INPUT_DIR}/TMP $input_bitstream_mp4_file
            the_base_name=$(basename $input_bitstream_mp4_file .mp4)
            cp ${INPUT_DIR}/TMP/${the_base_name}.json ${INPUT_DIR}/TMP/${the_base_name}.p1204.json
            per_squence_mos=$(grep per_sequence ${INPUT_DIR}/TMP/${the_base_name}.json|cut -d ":" -f2|cut -d "," -f1)
            echo "======================"
            echo $per_squence_mos        
            echo "======================"                
            $SCRIPT_DIR/change_csv_at_pos.sh ${input_bitstream_mp4_file}.csv 6 $per_squence_mos $TEMPORARY_FILE
        done                        
fi

# ##########################################################################################################
