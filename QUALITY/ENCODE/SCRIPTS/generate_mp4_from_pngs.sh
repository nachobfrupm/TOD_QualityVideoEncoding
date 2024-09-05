current_pwd=$PWD
cd $1
#ffmpeg -y -framerate 30 -pattern_type glob -i '*.png'   -c:v libx264 -pix_fmt yuv420p $2
ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p $2

cd $current_pwd