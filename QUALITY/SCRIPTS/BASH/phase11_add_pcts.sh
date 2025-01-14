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
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0






if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi

cd ${INPUT_DIR}
#head -1 source_mp4_file.mp4.csv > file_for_plot.csv
echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC,INFERENCE_TIME_MS,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS" > file_for_plot.csv
#echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS" > file_for_plot.csv

for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
    do
       echo $input_mp4_file 
       tail -1 ${input_mp4_file}.csv >> file_for_plot.csv
done

# ITERATE THROUG ALL THE NEW FIELDS ADDED THAT WE WANT TO ADD PCT INFO
PCT_FIELDS="SI TI BICYCLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS"
for new_field in $PCT_FIELDS
do
# ADD PCT_COLUMN TO ALL NEW FIELDS
    echo "============="
    echo "$new_field"
    echo "============="
    python3 $ROOT_DIR/SCRIPTS/PYTHON/add_pct_column.py file_for_plot.csv file_for_plot_1.csv $new_field

    python3 $ROOT_DIR/SCRIPTS/PYTHON/add_pct_column.py file_for_plot_1.csv file_for_plot_2.csv $new_field
    python3 $ROOT_DIR/SCRIPTS/PYTHON/add_pct_column.py file_for_plot_2.csv file_for_plot_3.csv $new_field

    mv file_for_plot.csv file_for_plot_no_pcts.csv
    mv file_for_plot_3.csv file_for_plot.csv
done
