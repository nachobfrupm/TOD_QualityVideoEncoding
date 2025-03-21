

# TOD Video Quality and AI Detection Metrics 
A set of scripts to execute objective video quality metrics measurements combined with object detection extraction on remote driving videos.
Based on shell and python scripts 

# Table of contents  
1. [Introduction](#introduction)  
2. [Initial Preparation](#preparation) <br/>
   2.1. [Cloning the repository](#cloning) <br/>
   2.2. [Input Dataset Preparation](#inputdataset) <br/>
   2.3. [Environment variables configuration](#envvariables) <br/>
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





Create the directory in which you place your MP4 input file at 8Mbps
For example
mkdir /home/user/data/MyIndividualSequence/
cp <preprocess_directory> /home/user/data/MyIndividualSequence/themasterfile.mp4

<a name="inputdataset"></a>
### 2.3. Environment Variables Configuration




<a name="setup_ext"></a>
## 3. External Tools Setup
<a name="vmaf_setup"></a>
### 3.1.VMAF 
Please read Readme.MD file under ALGORITHMS/VMAF folder in this repository

<a name="psnr_setup"></a>
### 3.2.PSNR 
Please read Readme.MD file under ALGORITHMS/PSNR folder in this repository

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
### 3.7.YOLOPV2 
Please read Readme.MD file under ALGORITHMS/YOLOPV2 folder in this repository



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




## License  
[MIT](https://choosealicense.com/licenses/mit/)  

## Usage/Examples  
~~~javascript  
  import Component from 'my-project'

  console.log("Hello World")
~~~  

## Screenshots  
![App Screenshot](https://lanecdr.org/wp-content/uploads/2019/08/placeholder.png)  
