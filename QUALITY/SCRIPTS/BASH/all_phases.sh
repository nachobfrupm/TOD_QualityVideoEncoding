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




# Example for COMMA2K
#./phase1_prepare_video.sh $INPUT_DIR COMMA2K "/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/comma2k19/Chunk_1/b0c9d2329ad1606b|2018-08-01--21-13-49/6"
# Example for NUSCENES
#./phase1_prepare_video.sh $INPUT_DIR NUSCENES /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
# For Leddartech
#./phase1_prepare_video.sh $INPUT_DIR LEDDARTECH /media/xruser/1TB_KIOXIA/DATASETS/LEDDARTECH/20200706_162218_part21_4368_7230/subset60
# For kitti 360 equirectangular
#./phase1_prepare_video.sh $INPUT_DIR KITTI_ADVANCED /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync
# ARGO
#./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE $DATASET_PARAM_01
#./phase1_prepare_video.sh $INPUT_DIR A2D2  /media/xruser/be69d5a6-c48b-4291-9417-11ba851d3979/DATASETS/A2D2/camera_lidar/20190401_145936/camera/cam_front_center 20190401145936_camera_frontcenter_00000 5800 6100

# I M P O R T A N T ! ! !

# Asumption there is single mp4 file in INPUT_DIR Encoded at 8Mbps 
# PHASE 1 is very customized and you should be able to develop your own scripts
# Please see examples above to check how to deal with A2D2,Argoverse,COMMA2k,KITTI360,NUSECENES AND LEDDARTECH

# Should you need to generate the master file uncomment the following line and pass the appropriate parameters from outside as per the examples above
# e.g. ./all_phases.sh /home/user/QualityVideoEncoding/QUALITY/INPUT_DIR A2D2 /media/xruser/be69d5a6-c48b-4291-9417-11ba851d3979/DATASETS/A2D2/camera_lidar/20190401_145936/camera/cam_front_center 20190401145936_camera_frontcenter_00000 5800 6100
#./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE  $DATASET_PARAM_01 $DATASET_PARAM_02 $DATASET_PARAM_03 $DATASET_PARAM_04

# I M P O R T A N T ! ! !


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

cd $INPUT_DIR
pwd
cp MP4/* .

cd $SCRIPT_DIR
#./add_new_empty_field_to_mp4_csvs.sh $INPUT_DIR LD_PCT 0.0
./phase10_b_v2_lane_detection.sh $INPUT_DIR
./phase11_add_pcts_V2.sh $INPUT_DIR
./phase12_plot_files_V2.sh $INPUT_DIR
cd $SCRIPT_DIR
./phase14_cleanup_and_show_final.sh $INPUT_DIR
exit 0


### Old code
./phase10_b_lane_detection.sh $INPUT_DIR
cd $SCRIPT_DIR
./phase11_add_pcts.sh $INPUT_DIR

cd $SCRIPT_DIR
./phase12_plot_files.sh $INPUT_DIR



cd $SCRIPT_DIR
./phase14_cleanup_and_show_final.sh $INPUT_DIR





