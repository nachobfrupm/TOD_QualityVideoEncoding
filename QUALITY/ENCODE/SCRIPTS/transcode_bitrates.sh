#Trasncode to different bitrates
#! /usr/bin/bash
export INPUT_FILE=$1

#BIT_RATES="6000 5000 4000 3000 2000 1500 1000 800 600 500"
BIT_RATES="3500 1000"
#BIT_RATES="1000"

PRESET=0   # LOW LATENCY HQ
RC_MODE=0  # CBR
echo "--"

# First create yuv file to start from it
ffmpeg -y -i  $INPUT_FILE -c:v rawvideo -pixel_format yuv420p ${INPUT_FILE}.yuv
INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 $INPUT_FILE)
INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 $INPUT_FILE)
FPS_ORIGINAL_VIDEO=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 ${INPUT_FILE}|cut -d "/" -f1 )
    

for BIT_RATE in $BIT_RATES
    do
    echo $BIT_RATE


    #gst-launch-1.0 filesrc location=${INPUT_FILE}.yuv !  videoparse width=${INPUT_WIDTH} height=${INPUT_HEIGHT} format=i420 framerate=30/1  ! \
    #nvh264enc max-bitrate=${BIT_RATE} bitrate=${BIT_RATE} preset=${PRESET} rc-mode=${RC_MODE} ! 'video/x-h264, stream-format=(string)byte-stream' !  mpegtsmux ! \
    #filesink location=${INPUT_FILE}_${BIT_RATE}.ts
        
    #ffmpeg -y -i ${INPUT_FILE}_${BIT_RATE}.ts -c:v copy ${INPUT_FILE}_AT_${BIT_RATE}.mp4
    #/usr/bin/rm ${INPUT_FILE}_${BIT_RATE}.ts
    ffmpeg -s ${INPUT_WIDTH}x${INPUT_HEIGHT} -framerate $FPS_ORIGINAL_VIDEO -y -i ${INPUT_FILE}.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -b:v ${BIT_RATE}k -bufsize 10000k ${INPUT_FILE}_AT_${BIT_RATE}.mp4

done
