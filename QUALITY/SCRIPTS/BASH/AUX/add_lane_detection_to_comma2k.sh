

for dir in $(find /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/MULTI/COMMA2K -type d|grep -v MP4|grep -v TMP|grep SEQUENCE_)
do
    echo $dir
    ./patch_add_lane_detection_to_existing_results.sh $dir
done
