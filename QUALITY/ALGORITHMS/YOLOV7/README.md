INSTALLATION INSTRUCTIONS
======================================
   ~~~shell
#Clone official YOLOV7 directory
git clone https://github.com/WongKinYiu/yolov7

#Create virtual environent to get all dependencies locally
python3 -m venv yolov7
source yolov7/bin/activate

#install pip3 requirements as per the requirements.txt
#check everything goes fine by executing

python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source yourmp4file.mp4

#It is important that YOLOV7 is undef ROOT DIRECTORY OF THIS INSTALLATION
cd ..
ln -s ALGORITHMS/YOLOV7 YOLOV7
   ~~~




