for direc in $(ls /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/SEQUENCES/|grep -v _01|grep -v _02|grep -v _03|grep -v _04)
do 
echo $direc
echo "./generate_it_all.sh /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/SEQUENCES/${direc} mp4"
./generate_it_all.sh /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/INPUT/ARGODRIVE/SEQUENCES/${direc} mp4

cd /media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0/SCRIPTS/LEVEL0
done
