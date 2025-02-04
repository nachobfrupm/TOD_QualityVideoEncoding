#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR=$1
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0
cd $INPUT_DIR
echo "Regular Plot Files"
$SCRIPT_DIR/combine_csvs_with_filename.sh $(find . -type f -name file_for_plot.csv)
mv combined.csv file_for_plot.csv
echo "Regular Plot Files - DONE"
echo ""
echo "Correlation Plot Files"
$SCRIPT_DIR/combine_csvs_with_filename.sh $(find . -type f -name file_for_correlation_plot.csv)
mv combined.csv file_for_correlation_plot.csv
echo "Correlation Plot Files - DONE"
echo ""
echo "Plotting scatter files vs Bitrate"
SELECTED_FIELDS="BITRATE VMAF PSNR SI TI SI_PCT TI_PCT P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS CARS_PCT INFERENCE_TIME_MS COVER_SSC COVER_TSC COVER_ASC COVER_FSC BYCICLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS BYCICLES_PCT MOTORCYCLES_PCT BUSES_PCT TRUCKS_PCT TRAFFIC_LIGHTS_PCT PERSONS_PCT STOPS_SIGNS_PCT"
for field in $SELECTED_FIELDS
do
    echo 'python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}'
    python3 $ROOT_DIR/SCRIPTS/PYTHON/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}
done
echo "Plotting scatter files vs Bitrate - DONE"
echo ""
echo "Plotting correlation file"
python3 $ROOT_DIR/SCRIPTS/PYTHON/correlation.py ${INPUT_DIR}/file_for_correlation_plot.csv 
echo "Plotting correlation file - DONE"


