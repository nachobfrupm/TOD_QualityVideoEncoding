export GST_DEBUG="*v4l2*:7,*aml*:7,*base*:7"
export GST_DEBUG_FILE="/tmp/latency.txt"
# Place your command here
gst-launch-1.0 v4l2src device=/dev/video0 io-mode=mmap num-buffers=300 ! image/jpeg,width=1920,height=1080,framerate=30/1 ! jpegdec ! nvvidconv ! nvv4l2h264enc  maxperf-enable=1  iframeinterval=30 bitrate=2000000  insert-sps-pps=1 ! h264parse ! fakesink
# Place your command here
magic_word="gst"
first_line=false
for entry in $(grep $magic_word /tmp/latency.txt |egrep "Handling frame|next_ts" |cut -d " " -f1|cut -d ":" -f3)
 do
        #echo $entry
        if $first_line
                then
                        last_entry=$entry
                        first_line=false
                else
                        delta=$(echo "$entry - $last_entry"|bc -l)
                        #printf '%.6f\n' $delta
                        echo "0$delta"
                        first_line=true
        fi
 done

