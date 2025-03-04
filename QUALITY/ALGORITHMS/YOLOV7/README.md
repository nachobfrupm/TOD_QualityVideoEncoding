INSTALLATION INSTRUCTIONS
======================================
# Clone official YOLOV7 directory
git clone https://github.com/WongKinYiu/yolov7

# Create virtual environent to get all dependencies locally
python3 -m venv yolov7
source yolov7/bin/activate

#install pip3 requirements as per the requirements.txt


python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt

It is important that YOLOV7 is undef ROOT DIRECTORY OF THIS INSTALLATION
e.g.
cd ..
ln -s ALGORITHMS/YOLOV7 YOLOV7




