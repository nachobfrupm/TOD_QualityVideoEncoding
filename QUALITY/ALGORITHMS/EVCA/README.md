INSTALLATION INSTRUCTIONS
===========================================
git clone https://github.com/cd-athena/EVCA.git  
cd EVCA  
virtualenv evca_env  
source evca_env/bin/activate  
pip3 install -r requirements.txt   
python3 main.py -i /home/xruser/TOD/TESIS/QUALITY/INPUT/Sequence01_Stopped.ts.yuv -r "1920x1080"  -f 30  -c out.csv   
more out_EVCA.csv  
 

 

B,SC,TC,TC2  
0.23845656,27.495571,0.0,0.0  
0.23851644,27.445293,1.2258109,0.0  
0.23854317,27.429728,0.6554951,1.2817523  
0.23855048,27.425056,0.3538983,0.71165496  
0.23854844,27.420073,0.2893036,0.45371702  
0.2385512,27.41787,0.253606,0.36869803  
0.23855487,27.419832,0.19784369,0.3060141  
0.23855919,27.429909,0.46489403,0.52517295  
0.23854886,27.493132,1.3591077,1.4495256  
0.23856153,27.533354,1.3437229,1.8932958
