

for dir in $(find /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/MULTI/NUSCENES -type d|grep SEQUENCE_|grep -v TMP|grep -v MP4)
do
    echo $dir
    ./patch_add_lane_detection_to_existing_results.sh $dir
done
