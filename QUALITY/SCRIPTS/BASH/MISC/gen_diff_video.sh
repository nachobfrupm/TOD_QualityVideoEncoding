ffmpeg -i $1  -i $2  -filter_complex "[0][1]blend=c0_mode=difference[y];[0]lutyuv=y=val:u=128:v=128[uv];[y][uv]mergeplanes=0x001112:yuv420p[v]" -map "[v]" $3
