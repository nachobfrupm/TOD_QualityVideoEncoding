export GST_DEBUG="*v4l2*:7,*aml*:7,*base*:7"
export GST_DEBUG_FILE="/tmp/latency.txt"
# Place your command here
gst-launch-1.0 v4l2src device=/dev/video0 io-mode=mmap num-buffers=300 ! image/jpeg,width=1920,height=1080,framerate=30/1 ! jpegdec ! amlvenc bitrate=2000 ! h265parse ! fakesink
# Place your command here
magic_word="amlvenc"

first_line=true
for entry in $(grep $magic_word /tmp/latency.txt |grep -v caps|grep -v propo|grep -v set_late |cut -d " " -f1|cut -d ":" -f3)
 do
        if $first_line
                then
                        last_entry=$entry
                        first_line=false
                else
                        delta=$(echo "$entry - $last_entry"|bc -l)
                        printf '%.6f\n' $delta
                        first_line=true
        fi
 done

