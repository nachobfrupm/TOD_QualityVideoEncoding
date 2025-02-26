#!/bin/bash

# Parameters:
# 1 : input file to be transcoded
# 2 : input_dataset_type : supported are ARGO,APOLLO,COMMA2K,KITTI,NUSCENES,GENERIC

export INPUT_DIR=$1
INPUT_VIDEO_FILE=$INPUT_DIR/input_mp4_file.mp4
MASTER_VIDEO_FILE=${INPUT_DIR}/master_mp4_file.mp4




function transcode_bitrates () {

INPUT_FILE=$1
INPUT_DIR=$2

BIT_RATES="6000 5000 4000 3000 2000 1500 1000 800 600 500"
#BIT_RATES="3500 1000"
#BIT_RATES="1000"

PRESET=0   # LOW LATENCY HQ
RC_MODE=0  # CBR
echo "--"

# First create yuv file to start from it
ffmpeg -y -i $INPUT_FILE -c:v rawvideo -pixel_format yuv420p ${INPUT_FILE}.yuv
INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 $INPUT_FILE)
INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 $INPUT_FILE)

#UNIFORM FRAME RATE CALCULATION - USE IT EVERYWHERE
FPS_ORIGINAL_VIDEO=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 ${INPUT_FILE}|bc -l)
echo $FPS_ORIGINAL_VIDEO
FPS_ORIGINAL_VIDEO=$(echo "scale=0; if ($FPS_ORIGINAL_VIDEO > ((d=$FPS_ORIGINAL_VIDEO)/1)) d/1+1 else d/1" | bc)
#UNIFORM FRAME RATE CALCULATION - USE IT EVERYWHERE
echo $FPS_ORIGINAL_VIDEO
## First encode "master" at 8Mbps
BIT_RATE=8000
echo "========================================================================================="
echo "ffmpeg -s ${INPUT_WIDTH}x${INPUT_HEIGHT} -framerate $FPS_ORIGINAL_VIDEO  -y -i ${INPUT_FILE}.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -g 30 -bf 0-b:v ${BIT_RATE}k -bufsize 500k $MASTER_VIDEO_FILE"
echo "========================================================================================="

ffmpeg -s ${INPUT_WIDTH}x${INPUT_HEIGHT} -framerate $FPS_ORIGINAL_VIDEO  -y -i ${INPUT_FILE}.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -g 30 -bf 0 -b:v ${BIT_RATE}k -bufsize 500k $MASTER_VIDEO_FILE

for BIT_RATE in $BIT_RATES
    do
    echo $BIT_RATE


    #gst-launch-1.0 filesrc location=${INPUT_FILE}.yuv !  videoparse width=${INPUT_WIDTH} height=${INPUT_HEIGHT} format=i420 framerate=30/1  ! \
    #nvh264enc max-bitrate=${BIT_RATE} bitrate=${BIT_RATE} preset=${PRESET} rc-mode=${RC_MODE} ! 'video/x-h264, stream-format=(string)byte-stream' !  mpegtsmux ! \
    #filesink location=${INPUT_FILE}_${BIT_RATE}.ts
        
    #ffmpeg -y -i ${INPUT_FILE}_${BIT_RATE}.ts -c:v copy ${INPUT_FILE}_AT_${BIT_RATE}.mp4
    #/usr/bin/rm ${INPUT_FILE}_${BIT_RATE}.ts
    ffmpeg -s ${INPUT_WIDTH}x${INPUT_HEIGHT} -framerate $FPS_ORIGINAL_VIDEO  -y -i ${INPUT_FILE}.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -g 30 -bf 0 -b:v ${BIT_RATE}k -bufsize 500k ${INPUT_FILE}_AT_${BIT_RATE}.mp4 > ${INPUT_FILE}_AT_${BIT_RATE}.mp4.stats 2>&1 

done
echo "/usr/bin/rm $INPUT_FILE"
mv $INPUT_FILE ${INPUT_FILE}.orig
}


# ##########################################################################################################
# STAGE 2 BITRATE TRANSCODING
echo ""
transcode_bitrates $INPUT_VIDEO_FILE $INPUT_DIR
echo "=================================================================================================="
ls -altr ${INPUT_DIR}/*mp4
# Initialize CSV Headers
for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
do    
    #echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS" > ${input_mp4_file}.csv
    echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC,INFERENCE_TIME_MS,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS.LD_PCT" > ${input_mp4_file}.csv
    file_bitrate_kbps=$(ffprobe -i $input_mp4_file 2>&1 |grep bitrate|cut -d ":" -f 6|cut -d " " -f2)
    echo "${file_bitrate_kbps},,,,,,,,,,,,,,,,,,,,,,,">> ${input_mp4_file}.csv
                              
                              
done
echo "=================================================================================================="
# ##########################################################################################################
