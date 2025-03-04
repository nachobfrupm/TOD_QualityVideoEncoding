INSTALLATION INSTRUCIONS for YOLOPV2
=========================================
cd ..
git clone https://github.com/CAIC-AD/YOLOPv2.git
cd YOLOPV2
# Create VirtualEnv
python3 -m venv yolopv2
source yolopv2/bin/activate
pip3 install numpy
pip3 install pandas
pip3 install tensorflow
pip3 install tf_keras
pip3 install argparse
pip3 install time
pip3 install pathlib
pip3 install torch
pip3 install opencv-python
pip3 install torch
pip3 install torchvision

# Get weights file
 wget https://github.com/CAIC-AD/YOLOPv2/releases/download/V0.0.1/yolopv2.pt
 python3 demo.py 
 mkdir -p data/weights/
 mv yolopv2.pt data/weights/

# Use lane_detector.py instead of demo.py


