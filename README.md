

# TOD Video Quality and AI Detection Metrics 
A set of scripts to execute objective video quality metrics measurements combined with object detection extraction on remote driving videos.
Based on shell and python scripts 

# Table of contents  
1. [Introduction](#introduction)  
2. [Initial Preparation](#preparation) <br/>
   2.1. [Cloning the repository](#cloning) <br/>
   2.2. [Input Dataset Preparation](#inputdataset) <br/>
   2.3. [Processed Dataset](#processed) <br/>
3. [External Tools Setup](#setup_ext)  
    3.1. [VMAF](#vmaf_setup)  
    3.2. [PSNR](#psnr_setup)   
    3.3. [ITU-P.1204.3](#itup12043)   
    3.4. [VCA](#VCA)   
    3.5. [EVCA](#EVCA)  
    3.6. [COVER](#COVER)   
    3.7. [YOLOV7](#YOLOV7)   
    3.8. [YOLOPV2](#YOLOPV2)   
    3.9. [PYTHON LIBRARIES](#PYTHONLIBS)   
   
4. [Execution and Data Collection](#execution)  
5. [Description of Additional Scripts](#description)  
6. [Assoociated Paper](#paper)
7. [Results for Selected Datasets](#results)


<a name="introduction"></a>
## 1. Introduction
Traditional video quality metrics like VMAF, PSNR, and SI-TI evaluate media quality, whereas newer metrics such as ITU-P.1204.3, VCA, and EVCA have broadened the evaluation of visual complexity. In emerging areas like Tele-Operated Driving, video quality is critical for remote applications, which encounter challenges due to the complexities of testing. In the realm of self-driving technology, video quality influences CNNs used for object detection, with research investigating how bitrate affects detection performance through the use of large datasets. <br/>
A new dataset with video quality and object detection metrics at different bitrates is available in this repository.<br/>
All the required scripts to execute this exercise from scratch as well as the instructions to setup the required tools is available here.<br/>
![image](https://github.com/user-attachments/assets/4a4cca45-d741-4c07-ac79-9876da2b5d12)

<a name="preparation"></a>
## 2. Input Dataset Preparation
<a name="cloning"></a>
### 2.1. Cloning the Repository
   ~~~shell
      git clone TOD_QualityVideoEncoding
      cd TOD_QualityVideoEncoding/QUALITY
      chmod -R 755 *      
   ~~~
<a name="inputdataset"></a>
### 2.2. Input DataSet Preparation
Preparation of your MP4 origin file is a task that it is not automated in this environment.  
However, some convenient scripts have been developed to do this in the source autonomous driving dataset used: A2D2,Argoverse2,Comma2K,Kitti360,NuScenes and Leddartech 

   ~~~shell
# Example for COMMA2K
#./phase1_prepare_video.sh $INPUT_DIR COMMA2K "/media/xruser/REMOTEDRIVING/TOD/TESIS/DATASETS/comma2k19/Chunk_1/b0c9d2329ad1606b|2018-08-01--21-13-49/6"
# Example for NUSCENES
#./phase1_prepare_video.sh $INPUT_DIR NUSCENES /home/xruser/TOD/TESIS/QUALITY2.0/INPUT/NUSCENES/SOURCE
# For Leddartech
#./phase1_prepare_video.sh $INPUT_DIR LEDDARTECH /media/xruser/1TB_KIOXIA/DATASETS/LEDDARTECH/20200706_162218_part21_4368_7230/subset60
# For kitti 360 equirectangular
#./phase1_prepare_video.sh $INPUT_DIR KITTI_ADVANCED /media/xruser/1TB_KIOXIA/DATASETS/KITTI_360_FULL/KITTI-360/data_2d_raw/2013_05_28_drive_0010_sync
# ARGO
#./phase1_prepare_video.sh $INPUT_DIR $DATASET_TYPE $DATASET_PARAM_01
#./phase1_prepare_video.sh $INPUT_DIR A2D2  /media/xruser/be69d5a6-c48b-4291-9417-11ba851d3979/DATASETS/A2D2/camera_lidar/20190401_145936/camera/cam_front_center 20190401145936_camera_frontcenter_00000 5800 6100
   ~~~

In case you have your own MP4 as source you need to have it encoded at 8Mbps
   ~~~shell
#Example 
#Create the directory in which you place your MP4 input file at 8Mbps 
mkdir /home/user/data/MyIndividualSequence/
cp <preprocess_directory> /home/user/data/MyIndividualSequence/themasterfile.mp4
   ~~~

<a name="processed"></a>
### 2.3. Processed Dataset

[Dataset Generated](https://drive.google.com/file/d/1a64lggH5tr3VoyneoscMniWaqw_nvH1Y/view?usp=sharing)  



<a name="setup_ext"></a>
## 3. External Tools Setup
<a name="vmaf_setup"></a>
### 3.1.VMAF 
Please read Readme.MD file under ALGORITHMS/VMAF folder in this repository

<a name="psnr_setup"></a>
### 3.2.PSNR 
PSNR is part of modern versions of ffmpeg  
A way to obtain the PSNR value of one video compared to other is the following one
PSNR_VALUE=$(ffmpeg -i ${FIRST_MP4_FILE} -i ${SECOND_MP4_FILE} -lavfi psnr=stats_file=${TMP_PSNR_FILE} -f null - 2>&1 |grep Parsed|cut -d ":" -f5|cut -d " " -f1|tail -1) 

<a name="itup12043"></a>
### 3.3.ITU-P.1204.3
Please read Readme.MD file under ALGORITHMS/bitstream_mode3_p1204_3 folder in this repository

<a name="VCA"></a>
### 3.4.VCA  
Please read Readme.MD file under ALGORITHMS/VCA folder in this repository

<a name="EVCA"></a>
### 3.5.EVCA  
Please read Readme.MD file under ALGORITHMS/EVCA folder in this repository

<a name="COVER"></a>
### 3.6.COVER 
Please read Readme.MD file under ALGORITHMS/COVER folder in this repository

<a name="YOLOV7"></a>
### 3.7.YOLOV7 
Please read Readme.MD file under ALGORITHMS/YOLOV7 folder in this repository

<a name="YOLOPV2"></a>
### 3.8.YOLOPV2 
Please read Readme.MD file under ALGORITHMS/YOLOPV2 folder in this repository

<a name="PYTHONLIBS"></a>
### 3.9.PYTHON LIBRARIES 
The tools described above will run in their own virtualenvironment and the instruction to install the required packages can be found either in the README.MD file under them or in the original tool 

from tabulate import tabulate
import csv
import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import pyarrow.feather as feather
import seaborn as sns
import sys



<a name="execution"></a>
## 4. Execution and Data Collection
   ~~~shell
      cd TOD_QualityVideoEncoding/QUALITY/SCRIPTS/BASH
      #Following the example started in 2.2
      ./all_phases.sh /home/user/data/MyIndividualSequence
      chmod -R 755 *      
   ~~~

<a name="description"></a>
## 5. Description of Additional Scripts

<a name="paper"></a>
## 6. Associated Paper

<a name="results"></a>
## 7.Results for Selected Datasets
Correlation Matrix of Video Quality Metrics and Object Detection for 216 sequences encoded at 11 bitrates

![6_correlation_matrix](https://github.com/user-attachments/assets/22faa34c-f6eb-476a-9852-5f4d5f937ed1)

SI-TI Scatter Plot of all sequences
![all_si_ti](https://github.com/user-attachments/assets/dcf6b836-ad44-4f11-bed0-41cef83f04f3)

Rendered Scatter plots of all magnitudes against bitrate
![BUSES_PCT](https://github.com/user-attachments/assets/87b9963d-91c6-40d5-a3d5-43f4ed15bf34) ![CARS_PCT](https://github.com/user-attachments/assets/9492cc95-2fc4-4e81-aeed-2a3cf1ed983d) 
![MOTORCYCLES_PCT](https://github.com/user-attachments/assets/b70775e1-139c-4032-aaff-e50ac1b98c92)




## License  



