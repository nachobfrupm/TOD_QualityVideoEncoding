

for dir in $(find /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/MULTI/ARGO_SEQUENCES/ -type d|grep -v TMP|grep -v MP4|grep -v NOK|grep SEQUENCE_)
do
    echo $dir
    ./patch_add_lane_detection_to_existing_results.sh $dir
done
