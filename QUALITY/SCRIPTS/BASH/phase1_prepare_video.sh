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

function preprocess_argodrive() {

    #INPUT_ARGO_DIR=/home/xruser/TOD/TESIS/DATASETS/ARGODRIVE/sensor/train/
    #OUTPUT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/SEQUENCES
    INPUT_ARGO_DIR=$1
    OUTPUT_DIR=$2
    cd ${INPUT_ARGO_DIR}/sensors/cameras/ring_front_center/
    ffmpeg -y -framerate 20 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=2048:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
}

function preprocess_apollo() {

    ## This dataset is captured between 2016 and 2017 in China
    ## The pictures are taken every 125 ms aprox
    ## In the sample we have 2 front cameras
    ## URL : https://apolloscape.auto/

    # INPUT_APOLLO_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/APOLLOSCAPE/3d_car_instance_sample/3d_car_instance_sample/images
    INPUT_APOLLO_DIR=$1
    OUTPUT_DIR=$2
    cd $INPUT_APOLLO_DIR
    ffmpeg -y -framerate 25 -pattern_type glob -i '*Camera_6.jpg' -b:v 8000k -vf "scale=1920:1080" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE

}

function preprocess_comma2k() {
    #INPUT_COMMA_DIR="/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/comma2k19/Chunk_1/b0c9d2329ad1606b|2018-08-01--21-13-49/6"    
    INPUT_COMMA_DIR=$1    
    OUTPUT_DIR=$2
    cd $INPUT_COMMA_DIR

    ## For COMMA2K (original) 1164x874 ==>
    ## Input is HEVC
    ## Decode to YUV
    ## ffmpeg -y -i  video.hevc -c:v rawvideo -pixel_format yuv420p video.yuv
    ## Resize to 1280x960 (YUV)
    ## ffmpeg -s:v 1164x874 -r 25 -i video.yuv -vf scale=1280:960 -c:v rawvideo -pix_fmt yuv420p video_resized.yuv
    ## Now produce input for this screen at 8Mbps H264
    ## ffmpeg -s 1280x960 -framerate 25 -y -i video_resized.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 8000k -bufsize 10000k source_full_duration.mp4
    ## Finally - Extract 10 seconds and we are ready ( between 30-40s )
    ##ffmpeg -ss 30 -to 40 -i source_full_duration.mp4 -c copy -avoid_negative_ts make_zero output.mp4}
    ffmpeg -y -i  video.hevc -c:v rawvideo -pixel_format yuv420p $TMP_DIR/video.yuv
    ffmpeg -s:v 1164x874 -r 25 -i $TMP_DIR/video.yuv -vf scale=1280:960 -c:v rawvideo -pix_fmt yuv420p $TMP_DIR/video_resized.yuv
    rm $TMP_DIR/video.yuv
    ffmpeg -s 1280x960 -framerate 25 -y -i $TMP_DIR/video_resized.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 8000k -bufsize 10000k $TMP_DIR/source_full_duration.mp4
    rm $TMP_DIR/video_resized.yuv
    ffmpeg -y -ss 30 -to 40 -i $TMP_DIR/source_full_duration.mp4 -c copy -avoid_negative_ts make_zero $INPUT_VIDEO_FILE
    rm $TMP_DIR/source_full_duration.mp4


}

function preprocess_kitti() {
    ## For kitti 1400x1400 we will resize to 1536x1536
    ## ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4

    #INPUT_KITTI_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/KITTI_360/KITTI-360/data_2d_raw/2013_05_28_drive_0000_sync/image_02/data_rgb/
    INPUT_KITTI_DIR=$1        
    OUTPUT_DIR=$2
    cd $INPUT_KITTI_DIR
    ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE

}

function preprocess_nuscenes() {
    ## For nuscenes
    ## ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4
    #INPUT_NUSCENES_DIR=/home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
    INPUT_NUSCENES_DIR=$1    
    OUTPUT_DIR=$2
    cd $INPUT_NUSCENES_DIR
    ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
}


if [ "$INPUT_DATASET_TYPE" = "GENERIC" ]; then
    # MP4 with no preprocessing needs
    # Just extract mediainfo
    # mediainfo $INPUT_VIDEO_FILE >${INPUT_VIDEO_FILE}.mediainfo
    echo "Generic Type - Doing Nothing"

elif [ "$INPUT_DATASET_TYPE" = "ARGO" ]; then
    preprocess_argodrive $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "APOLLO" ]; then
    preprocess_apollo $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "COMMA2K" ]; then
    preprocess_comma2k $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "KITTI" ]; then
    preprocess_kitti $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "NUSCENES" ]; then
    preprocess_nuscenes $INPUT_DATASET_DIR $INPUT_DIR

fi
mediainfo $INPUT_VIDEO_FILE >${INPUT_VIDEO_FILE}.mediainfo
echo "=================================================================================================="
echo $INPUT_VIDEO_FILE
ls -altr $INPUT_VIDEO_FILE
echo "=================================================================================================="
