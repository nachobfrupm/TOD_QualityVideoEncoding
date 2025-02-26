#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR=$1
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0
cd $INPUT_DIR
SUFFIX=$(basename $INPUT_DIR)
TMP_DIR=/tmp/TMPLOT_${SUFFIX}
if [ -d ${TMP_DIR} ]; then
    echo "Directory ${TMP_DIR} already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${TMP_DIR}
fi
rm $TMP_DIR/*png 
cp $INPUT_DIR/*png $TMP_DIR
# Remove some figures
rm $TMP_DIR/BUSES.png $TMP_DIR/CARS.png $TMP_DIR/EVCA_SC.png
rm $TMP_DIR/EVCA_TC.png $TMP_DIR/MOTORCYCLES.png $TMP_DIR/PERSONS.png
rm $TMP_DIR/SI.png $TMP_DIR/TI.png $TMP_DIR/TRAFFIC_LIGHTS.png 
rm $TMP_DIR/TRUCKS.png $TMP_DIR/VCA_E.png $TMP_DIR/VCA_H.png 
rm $TMP_DIR/STOPS_SIGNS.png $TMP_DIR/STOPS_SIGNS_PCT.png
gwenview -f $TMP_DIR