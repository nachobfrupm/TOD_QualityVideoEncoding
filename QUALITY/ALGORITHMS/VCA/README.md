INSTALLATION INSTRUCTIONS
========================================================================
Please replace the name of the YUV file in the example below with and actual name of an existing file

   ~~~shell
git clone https://github.com/cd-athena/VCA.git  
sudo apt install -y git nasm ffmpeg cmake build-essential  
cmake .  
cmake --build . -j  
cd source  
cd apps  
cd vca  
./vca --help  
./vca --input /home/xruser/TOD/TESIS/QUALITY/INPUT/Sequence01_Stopped.ts.yuv --input-res 1920x1080 --input-fps 30 --complexity-csv out.csv 
   ~~~
