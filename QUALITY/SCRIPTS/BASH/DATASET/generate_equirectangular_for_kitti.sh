#!/bin/bash

# Parameters:
# 1 : input_directory
# 2 : input_dataset_type : supported are ARGO,APOLLO,COMMA2K,KITTI,NUSCENES,GENERIC
# 3 : input_dataset_dir:

INPUT_DIR=$1
INPUT_DATASET_TYPE=$2
INPUT_DATASET_DIR=$3
INPUT_VIDEO_FILE=$INPUT_DIR/input_mp4_file.mp4
TMP_DIR=/tmp

function preprocess_kitti() {
    ## For kitti 1400x1400 we will resize to 1536x1536
    ## ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4

    #INPUT_KITTI_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/KITTI_360/KITTI-360/data_2d_raw/2013_05_28_drive_0000_sync/image_02/data_rgb/
    INPUT_KITTI_DIR=$1        
    OUTPUT_DIR=$2
    cd $INPUT_KITTI_DIR
    ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE

}


cd /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync/image_02/data_rgb/subset
#ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p left_eye.mp4
ffmpeg -y -framerate 10 -pattern_type glob -i '*.png' -crf 17 -c:v libx264 -pix_fmt yuv420p left_eye.mp4
cd /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync/image_03/data_rgb/subset
#ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p right_eye.mp4
ffmpeg -y -framerate 10 -pattern_type glob -i '*.png' -crf 17 -c:v libx264 -pix_fmt yuv420p right_eye.mp4
cd /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync/
#ffmpeg -i image_02/data_rgb/left_eye.mp4  -i image_03/data_rgb/right_eye.mp4 -crf 17 -pix_fmt yuv420p -filter_complex "[v:1][v:0]hstack" -c:a copy $2
ffmpeg -y i image_02/data_rgb/subset/left_eye.mp4   -i image_03/data_rgb/subset/right_eye.mp4 --crf 17 -pix_fmt yuv420p -filter_complex hstack -c:a copy dual.mp4
ffmpeg -y -i dual.mp4 -vf v360=dfisheye:equirect:ih_fov=192:iv_fov=192:yaw=90 equirectangular_192.mp4

