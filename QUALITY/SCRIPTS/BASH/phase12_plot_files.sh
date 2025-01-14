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


cd ${INPUT_DIR}

SELECTED_FIELDS="BITRATE VMAF PSNR SI TI SI_PCT TI_PCT P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS CARS_PCT INFERENCE_TIME_MS COVER_SSC COVER_TSC COVER_ASC COVER_FSC BYCICLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS BYCICLES_PCT MOTORCYCLES_PCT BUSES_PCT TRUCKS_PCT TRAFFIC_LIGHTS_PCT PERSONS_PCT STOPS_SIGNS_PCT"
for field in $SELECTED_FIELDS
do
    echo 'python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}'
    python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}
done
