

for dir in $(find /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/MULTI/A2D2_CITIES/Gaimersheim -type d|grep -v MP4|grep SEQ|grep -v TMP)
do
    echo $dir
    ./patch_add_lane_detection_to_existing_results.sh $dir
done