#!/bin/bash
export INPUT_DIR=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
background_scripts=("phase4_psnr.sh" "phase5_p1204.sh")
pids=()

cd $SCRIPT_DIR 
./phase1_prepare_video.sh $INPUT_DIR NUSCENES /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
cd $SCRIPT_DIR 
./phase2_transcode_qualitites.sh $INPUT_DIR 
cd $SCRIPT_DIR 
./phase3_vmaf.sh $INPUT_DIR 
cd $SCRIPT_DIR 
./phase4_psnr.sh $INPUT_DIR &
  pids+=($!)
cd $SCRIPT_DIR 
./phase5_p1204.sh $INPUT_DIR &
  pids+=($!)
cd $SCRIPT_DIR 
./phase6_siti_classic_parallel.sh $INPUT_DIR
cd $SCRIPT_DIR 
./phase7_vca.sh $INPUT_DIR
cd $SCRIPT_DIR 
./phase8_evca.sh $INPUT_DIR
cd $SCRIPT_DIR 
./phase9_cover.sh $INPUT_DIR
cd $SCRIPT_DIR 
./phase10_yolov7.sh $INPUT_DIR

for pid in "${pids[@]}"; do
  wait $pid
done

cd $SCRIPT_DIR
./phase11_add_pcts.sh $INPUT_DIR





