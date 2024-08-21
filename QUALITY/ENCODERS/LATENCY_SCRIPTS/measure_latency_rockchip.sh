export GST_DEBUG="*v4l2*:7,*aml*:7,*base*:7"
export GST_DEBUG_FILE="/tmp/latency.txt"
# Place your command here
gst-launch-1.0 v4l2src device=/dev/video60 io-mode=mmap num-buffers=300 ! image/jpeg,width=1920,height=1080,framerate=30/1 ! mppjpegdec ! mpph264enc qp-min=10 qp-max=51 bps-min=2000000 bps-max=2000000 gop=
30 header-mode=1 ! h264parse ! fakesink   
# Place your command here
magic_word="baseparse"
first_line=true
for entry in $(grep $magic_word /tmp/latency.txt |egrep "gst_base_parse_prepare_frame|gst_base_parse_frame_free" |cut -d " " -f1|cut -d ":" -f3)
 do
        #echo $entry
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

