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
    echo "COMMA2K"

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
    ffmpeg -s 1280x960 -framerate 25 -y -ss 20 -to 30 -i $TMP_DIR/video_resized.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 8000k -bufsize 10000k $INPUT_VIDEO_FILE
    rm $TMP_DIR/video_resized.yuv
    #ffmpeg -y -ss 20 -to 30 -i $TMP_DIR/source_full_duration.mp4 -c copy -avoid_negative_ts make_zero $INPUT_VIDEO_FILE
    #rm $TMP_DIR/source_full_duration.mp4


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

function copy_300_frames_from_dir_to_dir_kitti()
{
    source_dir=$1
    destination_dir=$2
    start_frame=$3
    end_frame=$4

    if [ -d ${destination_dir} ]; then
        echo "Directory ${destination_dir} already exists, cleaning up"
        /usr/bin/rm ${destination_dir}/*
        #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
    else
        mkdir -p ${destination_dir}
    fi

    # Loop through the range of file names
    for i in $(seq -w $start_frame $end_frame); do
        file_name="${i}.png"
        if [ -f "$source_dir/000000$file_name" ]; then
            cp "$source_dir/000000$file_name" "$destination_dir/"
            echo "Copied $file_name to $destination_dir"
        else
            echo "$file_name does not exist in $source_dir"
        fi
    done
}


function preprocess_kitti_advanced() {
    INPUT_KITTI_DIR=$1            
    START_FRAME=$2
    END_FRAME=$3

    # Example
    # INPUT_KITTI_DIR=/media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync
    # First collect 300 frames from directory
    
    cd $INPUT_KITTI_DIR 
    copy_300_frames_from_dir_to_dir_kitti image_02/data_rgb /tmp/subset_left $START_FRAME $END_FRAME
    copy_300_frames_from_dir_to_dir_kitti image_03/data_rgb /tmp/subset_right $START_FRAME $END_FRAME
    cd /tmp/subset_left
    ffmpeg -y -framerate 10 -pattern_type glob -i '*.png' -crf 17 -c:v libx264 -pix_fmt yuv420p left_eye.mp4
    cd /tmp/subset_right
    ffmpeg -y -framerate 10 -pattern_type glob -i '*.png' -crf 17 -c:v libx264 -pix_fmt yuv420p right_eye.mp4
    cd /tmp
    ffmpeg -y -i /tmp/subset_left/left_eye.mp4   -i /tmp/subset_right/right_eye.mp4 -crf 17 -pix_fmt yuv420p -filter_complex hstack -c:a copy dual.mp4
    ffmpeg -y -i dual.mp4 -vf v360=dfisheye:equirect:ih_fov=192:iv_fov=192:yaw=90 equirectangular_192.mp4
    ffmpeg -y -i equirectangular_192.mp4 -vf "scale=3072:1536" -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE 
    

    
}
function copy_300_frames_from_dir_to_dir_a2d2()
{
    source_dir=$1
    destination_dir=$2
    prefix=$3
    start_frame=$4
    end_frame=$5

    if [ -d ${destination_dir} ]; then
        echo "Directory ${destination_dir} already exists, cleaning up"
        /usr/bin/rm ${destination_dir}/*
        #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
    else
        mkdir -p ${destination_dir}
    fi

    # Loop through the range of file names
    for i in $(seq -w $start_frame $end_frame); do
        file_name="${i}.png"
        if [ -f "$source_dir/${prefix}${file_name}" ]; then
            echo "cp $source_dir/${prefix}${file_name} $destination_dir/"
            cp "$source_dir/${prefix}${file_name}" "$destination_dir/"
            echo "Copied $file_name to $destination_dir"
        else
            # echo "$file_name does not exist in $source_dir"
            echo "cp $source_dir/${prefix}${file_name} $destination_dir/"
        fi
    done
}


function preprocess_a2d2() {
    #INPUT_A2D2_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/A2D2/FULL/camera_lidar/20180810_150607/camera/cam_front_center
    INPUT_A2D2_DIR=$1
    OUTPUT_DIR=$2
    cd $INPUT_A2D2_DIR
    pwd
    #echo "ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k  -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE"
    #ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k  -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
    echo "ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE"
    ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
}

function preprocess_leddartech() {
    #INPUT_LEDDARTECH_DIR=/media/xruser/1TB_KIOXIA/DATASETS/LEDDARTECH/20200706_162218_part21_4368_7230/subset
    INPUT_LEDDARTECH_DIR=$1
    OUTPUT_DIR=$2
    cd $INPUT_LEDDARTECH_DIR
    ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -b:v 8000k  -vf "scale=1536:1080" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
}



function preprocess_nuscenes() {
    ## For nuscenes
    ## ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4
    #INPUT_NUSCENES_DIR=/home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
    echo "Preprocess NUSCENES"
    INPUT_NUSCENES_DIR=$1 
    START_TIME_SECS=$2
    END_TIME_SECS=$3
    
    cd $INPUT_NUSCENES_DIR
    pwd
    #echo " ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE"
    #ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $INPUT_VIDEO_FILE
    # Just cut 30 seconds from FULL.mp4 
    # Example of this processing 
    # cd /media/xruser/be69d5a6-c48b-4291-9417-11ba851d3979/DATASETS/NUSCENES/TRAIN05/sweeps/CAM_FRONT
    # fmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p ../../FULL.mp4
    ffmpeg -ss $START_TIME_SECS -to $END_TIME_SECS -i FULL.mp4 -c copy -avoid_negative_ts make_zero $INPUT_VIDEO_FILE
}


if [ "$INPUT_DATASET_TYPE" = "GENERIC" ]; then
    # MP4 with no preprocessing needs
    # Just extract mediainfo
    # mediainfo $INPUT_VIDEO_FILE >${INPUT_VIDEO_FILE}.mediainfo
    echo "Generic Type - Doing Nothing"
elif [ "$INPUT_DATASET_TYPE" = "A2D2" ]; then
    PREFIX=$4
    # 20190401145936_camera_frontcenter_00
    START_FRAME=$5
    END_FRAME=$6
    copy_300_frames_from_dir_to_dir_a2d2 $INPUT_DATASET_DIR $INPUT_DATASET_DIR/subset $PREFIX $START_FRAME $END_FRAME
    preprocess_a2d2 $INPUT_DATASET_DIR/subset $INPUT_DIR
elif [ "$INPUT_DATASET_TYPE" = "ARGO" ]; then
    preprocess_argodrive $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "APOLLO" ]; then
    preprocess_apollo $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "COMMA2K" ]; then
    preprocess_comma2k $INPUT_DATASET_DIR $INPUT_DIR

elif [ "$INPUT_DATASET_TYPE" = "KITTI" ]; then
    preprocess_kitti $INPUT_DATASET_DIR $INPUT_DIR
elif [ "$INPUT_DATASET_TYPE" = "KITTI_ADVANCED" ]; then
    START_FRAME=$4
    END_FRAME=$5
    preprocess_kitti_advanced $INPUT_DATASET_DIR $START_FRAME $END_FRAME
elif [ "$INPUT_DATASET_TYPE" = "NUSCENES" ]; then
    START_TIME_SECS=$4
    END_TIME_SECS=$5
    preprocess_nuscenes $INPUT_DATASET_DIR $START_TIME_SECS $END_TIME_SECS

elif [ "$INPUT_DATASET_TYPE" = "LEDDARTECH" ]; then
    preprocess_leddartech $INPUT_DATASET_DIR $INPUT_DIR
fi
mediainfo $INPUT_VIDEO_FILE >${INPUT_VIDEO_FILE}.mediainfo
echo "=================================================================================================="
echo $INPUT_VIDEO_FILE
ls -altr $INPUT_VIDEO_FILE
echo "=================================================================================================="
