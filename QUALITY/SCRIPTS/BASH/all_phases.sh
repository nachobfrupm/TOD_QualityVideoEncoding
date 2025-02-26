#!/bin/bash
export INPUT_DIR=$1
export DATASET_TYPE=$2
export DATASET_PARAM_01=$3
export DATASET_PARAM_02=$4
export DATASET_PARAM_03=$5
export DATASET_PARAM_04=$6

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
background_scripts=("phase4_psnr.sh" "phase5_p1204.sh phase6_siti_classic_single.sh")
pids=()

cd $SCRIPT_DIR 

# Example for ARGO


# Example for KITTI
#./phase1_prepare_video.sh $INPUT_DIR KITTI /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/KITTI_360/KITTI-360/data_2d_raw/2013_05_28_drive_0000_sync/image_02/data_rgb/
# Example for APOLLO
#./phase1_prepare_video.sh $INPUT_DIR APOLLO /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/APOLLOSCAPE/3d_car_instance_sample/3d_car_instance_sample/images
# Example for COMMA2K
#./phase1_prepare_video.sh $INPUT_DIR COMMA2K "/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/comma2k19/Chunk_1/b0c9d2329ad1606b|2018-08-01--21-13-49/6"
# Example for NUSCENES
#./phase1_prepare_video.sh $INPUT_DIR NUSCENES /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
# Example for GENERIC
#./phase1_prepare_video.sh $INPUT_DIR A2D2 /media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/A2D2/FULL/camera_lidar/20180810_150607/camera/cam_front_center/tmp
# For Leddartech
#./phase1_prepare_video.sh $INPUT_DIR LEDDARTECH /media/xruser/1TB_KIOXIA/DATASETS/LEDDARTECH/20200706_162218_part21_4368_7230/subset60
# For kitti 360 equirectangular
# echo "Hi"
#./phase1_prepare_video.sh $INPUT_DIR KITTI_ADVANCED /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync
# ARGO
#./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE $DATASET_PARAM_01
#./phase1_prepare_video.sh $INPUT_DIR A2D2  /media/xruser/be69d5a6-c48b-4291-9417-11ba851d3979/DATASETS/A2D2/camera_lidar/20190401_145936/camera/cam_front_center 20190401145936_camera_frontcenter_00000 5800 6100
#./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE  $DATASET_PARAM_01 $DATASET_PARAM_02 $DATASET_PARAM_03 $DATASET_PARAM_04

#./phase1_prepare_video.sh $INPUT_DIR GENERIC 


./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE $DATASET_PARAM_01 $DATASET_PARAM_02 $DATASET_PARAM_03 $DATASET_PARAM_04


cd $SCRIPT_DIR 
./phase2_transcode_qualitites.sh $INPUT_DIR 
#./phase2_transcode_qualitites_low_latency_01.sh $INPUT_DIR 
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

./phase10_b_lane_detection.sh $INPUT_DIR
cd $SCRIPT_DIR
./phase11_add_pcts.sh $INPUT_DIR

cd $SCRIPT_DIR
./phase12_plot_files.sh $INPUT_DIR



cd $SCRIPT_DIR
./phase14_cleanup_and_show_final.sh $INPUT_DIR





