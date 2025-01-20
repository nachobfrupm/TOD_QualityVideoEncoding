#!/bin/bash
export INPUT_DIR=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
background_scripts=("phase4_psnr.sh" "phase5_p1204.sh phase6_siti_classic_single.sh")
pids=()

cd $SCRIPT_DIR 
# Example for KITTI
#./phase1_prepare_video.sh $INPUT_DIR KITTI /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/KITTI_360/KITTI-360/data_2d_raw/2013_05_28_drive_0000_sync/image_02/data_rgb/
# Example for APOLLO
#./phase1_prepare_video.sh $INPUT_DIR APOLLO /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/APOLLOSCAPE/3d_car_instance_sample/3d_car_instance_sample/images
# Example for COMMA2K
#./phase1_prepare_video.sh $INPUT_DIR COMMA2K "/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/comma2k19/Chunk_1/b0c9d2329ad1606b|2018-08-01--21-13-49/6"
# Example for NUSCENES
#./phase1_prepare_video.sh $INPUT_DIR NUSCENES /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
# Example for GENERIC
./phase1_prepare_video.sh $INPUT_DIR GENERIC 

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

cd $SCRIPT_DIR
./phase14_cleanup_and_show_final.sh $INPUT_DIR





