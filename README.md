

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
7. [Results for Selected Datasets](#results)
8. [License](#license)



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
Please read Readme.MD file under [ALGORITHMS/VMAF](QUALITY/ALGORITHMS/VMAF/README.md) folder in this repository



<a name="psnr_setup"></a>
### 3.2.PSNR 
PSNR is part of modern versions of ffmpeg  
A way to check that PSNR plugin is part of ffmpeg can be trying to execute it as per the following instructions

   ~~~shell
export FIRST_MP4_FILE=your_master_mp4.mp4
export SECOND_MP4_FILE=your_transcoded_mp4.mp4
export TMP_PSNR_FILE=/tmp/psnr.txt
PSNR_VALUE=$(ffmpeg -i ${FIRST_MP4_FILE} -i ${SECOND_MP4_FILE} -lavfi psnr=stats_file=${TMP_PSNR_FILE} -f null - 2>&1 |grep Parsed|cut -d ":" -f5|cut -d " " -f1|tail -1) 
echo $PSNR_VALUE 
   ~~~


<a name="itup12043"></a>
### 3.3.ITU-P.1204.3
Please read Readme.MD file under [ALGORITHMS/bitstream_mode3_p1204_3](QUALITY/ALGORITHMS/bitstream_mode3_p1204_3/README.md) folder in this repository

<a name="VCA"></a>
### 3.4.VCA  
Please read Readme.MD file under [ALGORITHMS/VCA](QUALITY/ALGORITHMS/VCA/README.md) folder in this repository


<a name="EVCA"></a>
### 3.5.EVCA  
Please read Readme.MD file under [ALGORITHMS/EVCA](QUALITY/ALGORITHMS/EVCA/README.md) folder in this repository

<a name="COVER"></a>
### 3.6.COVER 
Please read Readme.MD file under [ALGORITHMS/COVER](QUALITY/ALGORITHMS/COVER/README.md) folder in this repository

<a name="YOLOV7"></a>
### 3.7.YOLOV7 
Please read Readme.MD file under [ALGORITHMS/YOLOV7](QUALITY/ALGORITHMS/YOLOV7/README.md) folder in this repository

<a name="YOLOPV2"></a>
### 3.8.YOLOPV2 
Please read Readme.MD file under [ALGORITHMS/YOLOPv2](QUALITY/ALGORITHMS/YOLOPv2/README.md) folder in this repository

<a name="PYTHONLIBS"></a>
### 3.9.PYTHON LIBRARIES 
The tools described above will run in their own virtualenvironment.
For the rest of common python scripts the following packages will be required
<br />
tabulate csv cv2 matplotlib numpy pandas pyarrow.feather seaborn sys



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
Additional bash scripts are placed in 5 different directories under SCRIPTS/BASH directory
AUX: Scripts used to execute incrementally some steps when migrating versions. Please do not execute them. They might cause incosistencies. 
DATASET: Scripts specific to given datasets. They are used to automate extractioon of master video from input datasets. 
EXPERIMENTAL: Not stable scripts used for future evolutions of the framework  
MISC: Miscellaneous scripts, not critical for the main flow  
<br />


<a name="results"></a>
## 6.Results for Selected Datasets
All CSV files at every level can be found in this repository under the DATASET directory  
<br />
Correlation Matrix of Video Quality Metrics and Object Detection for 216 sequences encoded at 11 bitrates

![6_correlation_matrix](https://github.com/user-attachments/assets/22faa34c-f6eb-476a-9852-5f4d5f937ed1)

SI-TI Scatter Plot of all sequences
![all_si_ti](https://github.com/user-attachments/assets/dcf6b836-ad44-4f11-bed0-41cef83f04f3)


Rendered Scatter plots of all magnitudes against bitrate  

Object Detection Metrics for all datasets and bitrates ( LD_PCT means Lane Detection Degradation (0-1) )

<p float="left">
  <img src="https://github.com/user-attachments/assets/87b9963d-91c6-40d5-a3d5-43f4ed15bf34" width="320" />
  <img src="https://github.com/user-attachments/assets/9492cc95-2fc4-4e81-aeed-2a3cf1ed983d" width="320" /> 
  <img src="https://github.com/user-attachments/assets/b70775e1-139c-4032-aaff-e50ac1b98c92" width="320" />
</p>

<p float="left">
  <img src="https://github.com/user-attachments/assets/21d48d95-9d7b-49ef-b9ed-4a8823ebede0" width="320" />
  <img src="https://github.com/user-attachments/assets/86af8d1a-0f84-4860-9a3b-d20bbc0a4609" width="320" /> 
  <img src="https://github.com/user-attachments/assets/589b8f9f-f862-4cb7-911f-e1a8c6d81100" width="320" />
</p>


Video Quality Metrics for all datasets and bitrates ( _PCT prefix indicates degradation compared to master quality )

<p float="left">
  <img src="https://github.com/user-attachments/assets/742c4a9f-7f81-4309-ac33-484cf798dd6a" width="320" />
  <img src="https://github.com/user-attachments/assets/69f872fc-53d9-4a9b-bef8-4658d9089006" width="320" /> 
  <img src="https://github.com/user-attachments/assets/449ed2a9-8dcd-4cdd-85b3-396d068a828d" width="320" />
  
</p>

<p float="left">
  <img src="https://github.com/user-attachments/assets/b6fde0f1-7bf9-4d39-a34c-e2e471c7d4a9" width="320" />
  <img src="https://github.com/user-attachments/assets/629b9515-9ae5-4b70-85f5-b08f592c503b" width="320" /> 
  <img src="https://github.com/user-attachments/assets/6496cd8c-fcde-49e6-9a0a-aecdcf6696b9" width="320" />
</p>


<p float="left">
  <img src="https://github.com/user-attachments/assets/db953cfc-1d9a-486c-945d-325dc3efc839" width="320" />
  <img src="https://github.com/user-attachments/assets/8dd1bbf3-a220-4583-b41b-d05a14678e29" width="320" /> 
  <img src="https://github.com/user-attachments/assets/9f7bb37e-389a-4a7e-a157-b56089b2aec7" width="320" />
</p>


<p float="left">
  <img src="https://github.com/user-attachments/assets/1b3d826d-7839-4ad0-a107-dcab15759319" width="320" />
  <img src="https://github.com/user-attachments/assets/8ff0272f-523a-46da-b406-9d778bd1092f" width="320" /> 
  <img src="https://github.com/user-attachments/assets/858982f4-53da-440f-a2d4-7096f55e7964" width="320" />
</p>



<a name="license"></a>

## 7.License

Please see file  [License.MD](LICENSE.md)

