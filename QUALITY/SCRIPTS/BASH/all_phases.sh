#!/bin/bash
export INPUT_DIR=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
background_scripts=("phase4_psnr.sh" "phase5_p1204.sh phase6_siti_classic_single.sh")
pids=()

cd $SCRIPT_DIR 
# Example for KITTI
#./phase1_prepare_video.sh $INPUT_DIR KITTI /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/KITTI_360/KITTI-360/data_2d_raw/2013_05_28_drive_0000_sync/image_02/data_rgb/
# Example for ARGO
./phase1_prepare_video.sh $INPUT_DIR ARGO /home/xruser/TOD/TESIS/DATASETS/ARGODRIVE/sensor/train/08734a1b-0289-3aa3-a6ba-8c7121521e26
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

cd $SCRIPT_DIR
./phase12_plot_files.sh $INPUT_DIR





