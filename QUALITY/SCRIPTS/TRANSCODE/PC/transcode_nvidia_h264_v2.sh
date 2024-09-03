# Read input.json
# 
 gst-launch-1.0 filesrc location=$1 ! video/mpegts ! tsdemux ! video/x-h264 ! h264parse disable-passthrough=true ! avdec_h264 \
 ! videoconvert   ! videorate  ! video/x-raw , framerate=4/1  ! nvh264enc bitrate=$2   \
 ! 'video/x-h264, stream-format=(string)byte-stream' !  mpegtsmux ! filesink location=/home/xruser/transcoded.ts
