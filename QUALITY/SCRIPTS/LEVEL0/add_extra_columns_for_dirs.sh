
#!/bin/bash
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0
for dir in $(find /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/DONE_SEQUENCES -type d -name 'SEQUENCE_*')
do 
echo $dir
${ROOT_DIR}/SCRIPTS/LEVEL0/add_extra_yolov_columns.sh $dir
done

