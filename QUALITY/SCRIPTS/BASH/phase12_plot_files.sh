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
LIST_OF_COLUMNS_TO_BE_REMOVED="SI,TI,INFERENCE_TIME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS,BICYCLES_PCT,MOTORCYCLES_PCT,BUSES_PCT,TRUCKS_PCT,TRAFFIC_LIGHTS_PCT,PERSONS_PCT,STOPS_SIGNS_PCT,INFERENCE_TIME_MS,BITRATE"
#LIST_OF_COLUMNS_TO_BE_REMOVED="INFERENCE_TIME_MS,BITRATE"

cd ${INPUT_DIR}

SELECTED_FIELDS="BITRATE VMAF PSNR SI TI SI_PCT TI_PCT P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS CARS_PCT INFERENCE_TIME_MS COVER_SSC COVER_TSC COVER_ASC COVER_FSC BYCICLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS LD_PCT BYCICLES_PCT MOTORCYCLES_PCT BUSES_PCT TRUCKS_PCT TRAFFIC_LIGHTS_PCT PERSONS_PCT STOPS_SIGNS_PCT"
for field in $SELECTED_FIELDS
do
    echo 'python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}'
    python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}
done

## PLOT CORRELATION MATRIX
cd ${INPUT_DIR}

python3 $ROOT_DIR/SCRIPTS/PYTHON/remove_columns.py "${INPUT_DIR}/file_for_plot.csv" ${INPUT_DIR}/file_for_correlation_plot.csv $LIST_OF_COLUMNS_TO_BE_REMOVED
#python3 $ROOT_DIR/SCRIPTS/PYTHON/remove_empty_columns.py "${INPUT_DIR}/file_for_plot.csv" ${INPUT_DIR}/file_for_correlation_plot_temp.csv 
#python3 $ROOT_DIR/SCRIPTS/PYTHON/remove_columns.py "${INPUT_DIR}/file_for_correlation_plot_temp.csv" ${INPUT_DIR}/file_for_correlation_plot.csv $LIST_OF_COLUMNS_TO_BE_REMOVED
python3 $ROOT_DIR/SCRIPTS/PYTHON/correlation.py ${INPUT_DIR}/file_for_correlation_plot.csv 