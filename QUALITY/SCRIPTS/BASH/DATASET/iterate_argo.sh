#!/bin/bash
cd /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGO
for i in $(seq -w 1 50)
do
  cd /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGO/SEQUENCE_${i}
  cp  /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/DONE_SEQUENCES/SEQUENCE_${i}/sequence_${i}.mp4.orig input_mp4_file.mp4
  cd /home/xruser/TOD/TESIS/QUALITY2.0/SCRIPTS/BASH
  pwd
  echo "./all_phases.sh /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGO/SEQUENCE_${i}"
  ./all_phases.sh /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGO/SEQUENCE_${i}
done
