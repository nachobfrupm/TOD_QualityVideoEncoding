ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf scale=2048:1536 -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p newscale.mp4
