#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $INPUT_DIR
pwd
cp MP4/* .

cd $SCRIPT_DIR
./add_new_empty_field_to_mp4_csvs.sh $INPUT_DIR LD_PCT 0.0
./phase10_b_lane_detection.sh $INPUT_DIR
./phase11_add_pcts.sh $INPUT_DIR
./phase12_plot_files.sh $INPUT_DIR
cd $SCRIPT_DIR
./phase14_cleanup_and_show_final.sh $INPUT_DIR

