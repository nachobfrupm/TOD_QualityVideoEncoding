#!/bin/bash


## Some warning...
## Not all resolutions are suitable for some tools, specially SI/TI and EVCA

# For Apollo resize was done to 3840x3076
## ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=3840:3076" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4




## For Argodrive a rescaling was required to resize to 2048x1536 using command
## ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=2048:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p newscale.mp4


## For Apollo
## ffmpeg -y -framerate 25 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1920:1080" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p full_hd.mp4


## For COMMA2K (original) 1164x874 ==> 
## Input is HEVC
## Decode to YUV
## ffmpeg -y -i  video.hevc -c:v rawvideo -pixel_format yuv420p video.yuv
## Resize to 1280x960 (YUV)
## ffmpeg -s:v 1164x874 -r 25 -i video.yuv -vf scale=1280:960 -c:v rawvideo -pix_fmt yuv420p video_resized.yuv
## Now produce input for this screen at 8Mbps H264
## ffmpeg -s 1280x960 -framerate 25 -y -i video_resized.yuv -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 8000k -bufsize 10000k source_full_duration.mp4
## Finally - Extract 10 seconds and we are ready ( between 30-40s )
##ffmpeg -ss 30 -to 40 -i source_full_duration.mp4 -c copy -avoid_negative_ts make_zero output.mp4




## For kitti 1400x1400 we will resize to 1536x1536
## ffmpeg -y -framerate 30 -pattern_type glob -i '*.png' -b:v 8000k -vf "scale=1536:1536" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4

## For nuscenes
## ffmpeg -y -framerate 30 -pattern_type glob -i '*.jpg' -b:v 8000k -vf "scale=1536:900" -minrate 8000k -maxrate 8000k -c:v libx264 -pix_fmt yuv420p new_scale.mp4



function text_before_Done ()
{
    
    input_text="$1"
    # Split the input text into two parts using 'Done' as the separator
    # The '##' operator removes the shortest match of the pattern (in this case, "Done") from the start of the second part.
    before_done=${input_text%%, Done*}
    echo $before_done
}

function parse_yolov_output ()
{
    output_yolov_file=$1
    output_csv_file=$2
    grep mp4 ${output_yolov_file}|grep -v img_size|cut -d " " -f3,5-20 > /tmp/yolov7.out.txt
    while IFS= read -r line; do
    # Check if the current line contains the word "Done"  
    # We need to count the following classes
  
        objects_detected=$(text_before_Done "$line")
    
        frame_number=$(echo $objects_detected|cut -d ")" -f1|cut -d "(" -f2|cut -d "/" -f1)
        inference_time_ms=$(echo $line|cut -d "(" -f3|cut -d ")" -f1|cut -d "m" -f1)

        number_of_cars=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*car)')
        if [ -z "$number_of_cars" ]; then
            number_of_cars=0
        fi
        number_of_bicycles=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*bicycle)')
        if [ -z "$number_of_bicycles" ]; then
            number_of_bicycles=0
        fi
        number_of_motorcycles=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*motorcycle)')
        if [ -z "$number_of_motorcycles" ]; then
            number_of_motorcycles=0
        fi
        number_of_buses=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*bus)')
        if [ -z "$number_of_buses" ]; then
            number_of_buses=0
        fi
        number_of_trucks=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*truck)')
        if [ -z "$number_of_trucks" ]; then
            number_of_trucks=0
        fi
        number_of_traffic_lights=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*traffic light)')
        if [ -z "$number_of_traffic_lights" ]; then
            number_of_traffic_lights=0
        fi
        number_of_persons=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*person)')
        if [ -z "$number_of_persons" ]; then
            number_of_persons=0
        fi
        number_of_stop_signs=$(echo "$objects_detected" | grep -oP '(?<=\b)\d+(?=\s*stop signcd)')
        if [ -z "$number_of_stop_signs" ]; then
            number_of_stop_signs=0
        fi
        #echo "========================================================"
        #echo "$objects_detected"
        #echo "$file_bitrate_kbps, $frame_number , $number_of_cars , $number_of_bicycles , $number_of_motorcycles , $number_of_buses , $number_of_trucks , $number_of_traffic_lights , $number_of_persons , $number_of_stop_signs , $inference_time_ms"
        echo "$file_bitrate_kbps, $frame_number , $number_of_cars , $number_of_bicycles , $number_of_motorcycles , $number_of_buses , $number_of_trucks , $number_of_traffic_lights , $number_of_persons , $number_of_stop_signs , $inference_time_ms" >> ${output_csv_file}
        #echo "========================================================"
    
    done < /tmp/yolov7.out.txt

}




# This script starts from a given source directory and performs the following actions
#  Requirement - The directory contains either a single video file in MP4 format or aprox 300 sequential image files either in jpg or png format
#  0.If it is a directory containing images, generates an initial video file
#  1.Reencodes the file with H.264 at a list of bitrates and mesaure encoding latency
#  2.Performs VMAF measurement for the different bitrates
#  3.Performs PSNR measurement for the different bitrates
#  4.Measures SI/TI Information loss for the different bitrates
#  5.Measures Bitstream information for every bitrate
#  6.Measures VCA information for every bitrate
#  7.Measures EVCA information for every bitrate
#  8.Measures YOLOV7 detection ratio for every bitrate alongside inference latency
#  9.Generates the following graphs:
#    9.a.YOLOV7 average detection per bitrate - scatter plot
#    9.b.PSNR and VMAF per bitrate
#    9.c.SI per bitrate
#    9.d.TI per bitrate
#    9.e.Bitstream energy related data per bitrate
#    9.f.VCA and EVCA data per bitrate



# DIRECTORY WHERE ALL SCRIPTS, BINARIES AND REPOSITORIES ARE
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0
#STAGE_0=true
STAGE_0=false
#STAGE_1=true
STAGE_1=false
#STAGE_2=true
STAGE_2=false
#STAGE_3=true
STAGE_3=false
#STAGE_4=true
STAGE_4=false
#STAGE_5=true
STAGE_5=false
#STAGE_6=true
STAGE_6=false
#STAGE_7=true
STAGE_7=false

# YOLOV7
#STAGE_8=true
STAGE_8=false

# COVER METRIC
STAGE_9=true
#STAGE_9=false
EXECUTE_SITI=true

# PLOTTING
STAGE_10=true
#STAGE_10=false


confs=("0.7")
img_sizes=("640")



# Parameters:
# 1 : input_directory
# 2 : input_format, etiher mp4,jpg or png
# 3 : yolov7 installation directory ( assumes virtualenv exists with same name )

INPUT_DIR=$1
INPUT_FORMAT=$2

# ##########################################################################################################
# STAGE 0

if ($STAGE_0)
then
if [ "$INPUT_FORMAT" = "png" ]
then
    # Step 0 Generate video file
    ${ROOT_DIR}/ENCODE/SCRIPTS/generate_mp4_from_pngs.sh $INPUT_DIR ${INPUT_DIR}/input_mp4_file.mp4
    INPUT_VIDEO_FILE=$INPUT_DIR/input_mp4_file.mp4
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
elif [ "$INPUT_FORMAT" = "jpg" ]
then
    ${ROOT_DIR}/ENCODE/SCRIPTS/generate_mp4_from_jpgs.sh $INPUT_DIR ${INPUT_DIR}/input_mp4_file.mp4
    INPUT_VIDEO_FILE=$INPUT_DIR/input_mp4_file.mp4
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
else
    INPUT_VIDEO_FILE=$(ls ${INPUT_DIR}/*.mp4)
    #mv $INPUT_VIDEO_FILE ${INPUT_DIR}/source_mp4_file.mp4
    #INPUT_VIDEO_FILE=$INPUT_DIR/source_mp4_file.mp4
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
fi
echo "=================================================================================================="
echo $INPUT_VIDEO_FILE
ls -altr $INPUT_VIDEO_FILE
echo "=================================================================================================="
fi
# ##########################################################################################################



# ##########################################################################################################
# STAGE 1 BITRATE TRANSCODING
if ($STAGE_1)
then            
echo ""
${ROOT_DIR}/ENCODE/SCRIPTS/transcode_bitrates.sh $INPUT_VIDEO_FILE $INPUT_DIR
echo "=================================================================================================="
ls -altr ${INPUT_DIR}/*mp4
# Initialize CSV Headers
for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
do    
    #echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS" > ${input_mp4_file}.csv
    echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC" > ${input_mp4_file}.csv
    file_bitrate_kbps=$(ffprobe -i $input_mp4_file 2>&1 |grep bitrate|cut -d ":" -f 6|cut -d " " -f2)
    echo "${file_bitrate_kbps},">> ${input_mp4_file}.csv
done
echo "=================================================================================================="
# ##########################################################################################################
fi





# ##########################################################################################################
# STAGE 2 VMAF CALCULATION

if [ -d ${INPUT_DIR}/TMP ]
then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p  ${INPUT_DIR}/TMP    
fi


if ($STAGE_2)
then
    echo "Stage 2 : ON"
    echo "${INPUT_DIR}/TMP"
    ls ${INPUT_DIR}/TMP
    # Iterate over new created file
    cd $INPUT_DIR
    # Generate YUV from source file
    INPUT_YUV=source_mp4_file.mp4.yuv
    ffmpeg -y -i  source_mp4_file.mp4 -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
    # Gather width and height of the input video
    INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    VMAF_VALUE=""
    sed -i '$ s/$/'"${VMAF_VALUE},"'/' "source_mp4_file.mp4.csv"    
    for input_vmaf_mp4_file in $(ls *mp4|grep _AT)
        do    
        TMP_VMAF_FILE=${INPUT_DIR}/TMP/${input_vmaf_mp4_file}.json
        # Generate YUV for every one
        OUTPUT_YUV=${input_vmaf_mp4_file}.mp4.yuv
        ffmpeg -y -i  $input_vmaf_mp4_file -c:v rawvideo -pixel_format yuv420p $OUTPUT_YUV    
        ${ROOT_DIR}/BIN/vmaf --reference $INPUT_YUV  --distorted $OUTPUT_YUV --width $INPUT_WIDTH --height $INPUT_HEIGHT --pixel_format 420 --bitdepth 8 --output ${TMP_VMAF_FILE} --json 
        VMAF_VALUE=$(grep mean  ${TMP_VMAF_FILE}|grep -v harmonic|tail -1|cut -d ":" -f2|cut -d "," -f1|cut -d " " -f2)
        sed -i '$ s/$/'"${VMAF_VALUE},"'/' ${input_vmaf_mp4_file}.csv
        echo $VMAF_VALUE                        
        /usr/bin/rm $OUTPUT_YUV 
    done
    /usr/bin/rm $INPUT_YUV
else
echo "Stage 2 : OFF"
fi


# ##########################################################################################################

# ##########################################################################################################
# STAGE 3 PSNR CALCULATION
if ($STAGE_3)
then
    cd $INPUT_DIR
    PSNR_VALUE=""
    sed -i '$ s/$/'"${PSNR_VALUE},"'/' source_mp4_file.mp4.csv
    for input_psnr_mp4_file in $(ls *mp4|grep _AT)
        do    
            TMP_PSNR_FILE=${INPUT_DIR}/TMP/psnr_${input_psnr_mp4_file}.txt
            echo "${TMP_PSNR_FILE}"
            FIRST_MP4_FILE=source_mp4_file.mp4
            SECOND_MP4_FILE=${input_psnr_mp4_file}
            PSNR_VALUE=$(ffmpeg -i ${FIRST_MP4_FILE}  -i ${SECOND_MP4_FILE}  -lavfi psnr=stats_file=${TMP_PSNR_FILE} -f null - 2>&1 |grep Parsed|cut -d ":" -f5|cut -d " " -f1|tail -1)
            echo "PSNR - VALUE IS : $PSNR_VALUE"
            sed -i '$ s/$/'"${PSNR_VALUE},"'/' ${input_psnr_mp4_file}.csv
    done
fi

# ##########################################################################################################

# ##########################################################################################################
# STAGE 4 SI/TI Information
if ($STAGE_4)
then
    cd $INPUT_DIR
    for input_siti_mp4_file in $(ls *mp4)
        do
            TMP_JSON_FILE=${INPUT_DIR}/TMP/${input_siti_mp4_file}_${BIT_RATE}_siti_out.json
            if ($EXECUTE_SITI)
                then
                siti-tools $input_siti_mp4_file --color-range full > $TMP_JSON_FILE
            fi
            SPATIAL_INFO=$(cat $TMP_JSON_FILE|jq '.si | add/length')
            TEMPORAL_INFO=$(cat $TMP_JSON_FILE|jq '.ti | add/length')
            echo "${input_siti_mp4_fille} ; $SPATIAL_INFO ; $TEMPORAL_INFO"
            sed -i '$ s/$/'"${SPATIAL_INFO},"'/' ${input_siti_mp4_file}.csv
            sed -i '$ s/$/'"${TEMPORAL_INFO},"'/' ${input_siti_mp4_file}.csv

        done                        
fi

# ##########################################################################################################


# ##########################################################################################################
# STAGE 5 bitstream_mode3_p1204_3 Information

if ($STAGE_5)
then
    cd $ROOT_DIR/ALGORITHMS/bitstream_mode3_p1204_3
    poetry install

    for input_bitstream_mp4_file in $(ls ${INPUT_DIR}/*mp4)
        do
            poetry run p1204_3 --result_folder ${INPUT_DIR}/TMP --tmp ${INPUT_DIR}/TMP $input_bitstream_mp4_file
            the_base_name=$(basename $input_bitstream_mp4_file .mp4)                        
            per_squence_mos=$(grep per_sequence ${INPUT_DIR}/TMP/${the_base_name}.json|cut -d ":" -f2|cut -d "," -f1)
            echo "======================"
            echo $per_squence_mos        
            echo "======================"                
            sed -i '$ s/$/'"${per_squence_mos},"'/' ${input_bitstream_mp4_file}.csv
        done                        
fi

# ##########################################################################################################


# ##########################################################################################################
# STAGE 6 VCA

if ($STAGE_6)
then
    cd $INPUT_DIR
    # Generate YUV from source file
    INPUT_YUV=source_mp4_file.mp4.yuv
    ffmpeg -y -i  source_mp4_file.mp4 -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
    # Gather width and height of the input video
    INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    FPS_ORIGINAL_VIDEO=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4|cut -d "/" -f1)
    ${ROOT_DIR}/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps $FPS_ORIGINAL_VIDEO --complexity-csv TMP/source_mp4_file.mp4.vca.csv
    # at this point we need to calculate Spatial Complexity (E) and Temporal complexity in Average from the csv file
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/source_mp4_file.mp4.vca.csv TMP/source_mp4_file.mp4.vca.average.csv
    E_Value=$(tail -1  TMP/source_mp4_file.mp4.vca.average.csv|cut -d "," -f2)
    h_Value=$(tail -1  TMP/source_mp4_file.mp4.vca.average.csv|cut -d "," -f3)
    echo "E: $E_Value"
    echo "h: $h_Value"
    sed -i '$ s/$/'"${E_Value},"'/' source_mp4_file.mp4.csv
    sed -i '$ s/$/'"${h_Value},"'/' source_mp4_file.mp4.csv
    # Cleanup YUV
    /usr/bin/rm ${INPUT_YUV}
    for input_vca_mp4_file in $(ls *.mp4|grep "_AT_")
        do
        # We need YUV files as in STAGE 2
        INPUT_YUV=${input_vca_mp4_file}.mp4.yuv
        ffmpeg -y -i  $input_vca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV    
        ${ROOT_DIR}/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps $FPS_ORIGINAL_VIDEO --complexity-csv TMP/${input_vca_mp4_file}.vca.csv
        python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/${input_vca_mp4_file}.vca.csv TMP/${input_vca_mp4_file}.vca.average.csv
        E_Value=$(tail -1  TMP/${input_vca_mp4_file}.vca.average.csv|cut -d "," -f2)
        h_Value=$(tail -1  TMP/${input_vca_mp4_file}.vca.average.csv|cut -d "," -f3)
        echo "E: $E_Value"
        echo "h: $h_Value"  
        sed -i '$ s/$/'"${E_Value},"'/' ${input_vca_mp4_file}.csv
        sed -i '$ s/$/'"${h_Value},"'/' ${input_vca_mp4_file}.csv
        # Cleanup YUV
        /usr/bin/rm ${INPUT_YUV}
        done
fi


# ##########################################################################################################

# ##########################################################################################################
# STAGE 7 EVCA
# In this we need to use virtualenv. Let's see how can we do it ( we will also need for YOLOV7 )
  
# SC: Spatial Complexity
# TC: Temporal Complexitiy 
if ($STAGE_7)
then
    cd $INPUT_DIR
    # Generate YUV from source file
    export INPUT_YUV=source_mp4_file.mp4.yuv
    ffmpeg -y -i  source_mp4_file.mp4 -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
    # Gather width and height of the input video
    export INPUT_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    export INPUT_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4)
    FPS_ORIGINAL_VIDEO=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 source_mp4_file.mp4|cut -d "/" -f1)

    if [[ "$FPS_ORIGINAL_VIDEO" == "25" ]] 
    then
    G_PARAMETER=25
    else # ASsume 30
    G_PARAMETER=15
    fi

    cd ${ROOT_DIR}/ALGORITHMS/EVCA/EVCA
    ENV_PATH=/home/xruser/TOD/TESIS/QUALITY2.0/ALGORITHMS/EVCA/EVCA/evca_env/bin/activate
    INPUT_YUV_FULL_PATH=${INPUT_DIR}/${INPUT_YUV}
    bash --rcfile $ENV_PATH -i  -c "python3 main.py -i $INPUT_YUV_FULL_PATH -r "${INPUT_WIDTH}x${INPUT_HEIGHT}" -g ${G_PARAMETER}  -f $FPS_ORIGINAL_VIDEO  -c out.csv ; exit 0"   
   
    ps -auxwww|grep bash    
    cp out_EVCA.csv ${INPUT_DIR}/TMP/source_mp4_file.mp4.evca.csv
    # Process average
    cd ${INPUT_DIR}
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/source_mp4_file.mp4.evca.csv TMP/source_mp4_file.mp4.evca.average.csv
    SC_value=$(tail -1 TMP/source_mp4_file.mp4.evca.average.csv|cut -d "," -f2)
    TC_value=$(tail -1 TMP/source_mp4_file.mp4.evca.average.csv|cut -d "," -f3)
    echo "SC: $SC_value"
    echo "TC: $TC_value"
    sed -i '$ s/$/'"${SC_value},"'/' source_mp4_file.mp4.csv
    sed -i '$ s/$/'"${TC_value},"'/' source_mp4_file.mp4.csv

    cd $INPUT_DIR
    for input_evca_mp4_file in $(ls *.mp4|grep "_AT_")
        do
        # We need YUV files as in STAGE 2
        export INPUT_YUV=${input_evca_mp4_file}.yuv
        echo "ffmpeg -y -i  $input_evca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV"
        ffmpeg -y -i  $input_evca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV
        echo "after 1"
        cd ${ROOT_DIR}/ALGORITHMS/EVCA/EVCA
        echo "after 2"
        ENV_PATH=/${ROOT_DIR}/ALGORITHMS/EVCA/EVCA/evca_env/bin/activate
        echo "after 3"
        INPUT_YUV_FULL_PATH=${INPUT_DIR}/${INPUT_YUV}
        echo "after 4"
        echo "Excuting python3 main.py -i $INPUT_YUV_FULL_PATH -r "${INPUT_WIDTH}x${INPUT_HEIGHT}"  -g ${G_PARAMETER} -f $FPS_ORIGINAL_VIDEO  -c out.csv"
        bash --rcfile $ENV_PATH -i  -c "python3 main.py -i $INPUT_YUV_FULL_PATH -r "${INPUT_WIDTH}x${INPUT_HEIGHT}"  -g ${G_PARAMETER} -f $FPS_ORIGINAL_VIDEO  -c out.csv ; exit 0"     
        echo "after 5"
        cp out_EVCA.csv ${INPUT_DIR}/TMP/${input_evca_mp4_file}.evca.csv
        echo "after 6"        
        # Process average
        cd ${INPUT_DIR}
        python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/${input_evca_mp4_file}.evca.csv  TMP/${input_evca_mp4_file}.evca.average.csv
        SC_value=$(tail -1 TMP/${input_evca_mp4_file}.evca.average.csv|cut -d "," -f2)
        TC_value=$(tail -1 TMP/${input_evca_mp4_file}.evca.average.csv|cut -d "," -f3)
        echo "SC: $SC_value"
        echo "TC: $TC_value"
        sed -i '$ s/$/'"${SC_value},"'/' ${input_evca_mp4_file}.csv
        sed -i '$ s/$/'"${TC_value},"'/' ${input_evca_mp4_file}.csv
    done
fi



                


# ##########################################################################################################

# ##########################################################################################################
# STAGE 9 YOLOV7 DETECTION
if ($STAGE_8)
then
conf="0.7"
img_size="640"
for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
do    
            echo "$conf"
            echo "======================================================================================================================================"   
            echo "Executing line : python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt"
            echo "======================================================================================================================================"   
            echo ""
            cd ${ROOT_DIR}/YOLOV7/yolov7
            ENV_PATH=/${ROOT_DIR}/YOLOV7/yolov7/yolov7/bin/activate        
            
            bash --rcfile $ENV_PATH -i  -c "python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt; exit 0"                             
            # Appends the result of this single yolov execution for a given bitrate(mp4 dependent),conf and img_size value into ${input_mp4_file}.csv
            cd ${INPUT_DIR}
            echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" > ${input_mp4_file}_${conf}_${img_size}_yolov7.csv            
            parse_yolov_output ${input_mp4_file}_${conf}_${img_size}.txt ${input_mp4_file}_${conf}_${img_size}_yolov7.csv            
            
            # And calculate average for this single combination
            echo "Executing line: python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py  ${input_mp4_file}_${conf}_${img_size}_yolov7.csv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv "
            python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py  ${input_mp4_file}_${conf}_${img_size}_yolov7.csv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv            
            CAR_NUMBER=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f3)
            INFERENCE_TIME_MS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f11)
            sed -i '$ s/$/'"${CAR_NUMBER},"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'"${INFERENCE_TIME_MS}"'/' ${input_mp4_file}.csv
            echo "YOLOV7: $CAR_NUMBER , $INFERENCE_TIME"
            mv ${input_mp4_file}_${conf}_${img_size}.txt TMP
            mv ${input_mp4_file}_${conf}_${img_size}_yolov7.csv TMP
            mv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv TMP

done


fi


# ##########################################################################################################
# STAGE 9 COVER
if ($STAGE_9)
then
    cd ${ROOT_DIR}/ALGORITHMS/COVER/COVER
    ENV_PATH=${ROOT_DIR}/ALGORITHMS/COVER/cover/bin/activate        
    bash --rcfile $ENV_PATH -i  -c "python evaluate_a_set_of_videos.py -i  ${INPUT_DIR} --output  ${INPUT_DIR}/cover.csv ; exit 0"                                                             
    # This is not working
    # python3 ${ROOT_DIR}/SCRIPTS/LEVEL0/merge_csvs.py ${INPUT_DIR}/file_for_plot.csv ${INPUT_DIR}/cover.csv ${INPUT_DIR}/full_plot_with_cover.csv
fi
cd $INPUT_DIR
for input_mp4_file in $(ls *.mp4)
    do
      dos2unix ${input_mp4_file}.csv
      data_cover=$(grep ${input_mp4_file} cover.csv|head -1 |cut -d "," -f2-5)
      echo "${input_mp4_file}.csv $data_cover"
      sed -i '$ s/$/'",${data_cover}"'/' ${input_mp4_file}.csv
    
done
## Iterate thru all the lines in file_for_plot.csv and append the correct information



# ##########################################################################################################
# STAGE 10 - PLOTTING GRAPHS

# Combine CSVs
if ($STAGE_10)
then
cd ${INPUT_DIR}
#head -1 source_mp4_file.mp4.csv > file_for_plot.csv
echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC" > file_for_plot.csv

for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
    do
       echo $input_mp4_file 
       tail -1 ${input_mp4_file}.csv >> file_for_plot.csv
done

# GENERATE SEVERAL PLOTS
#ALL_FIELDS="BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS"
ALL_FIELDS="BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC"
#SELECTED_FIELDS="VMAF PSNR SI TI P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS INFERENCE_TIME_MS"
SELECTED_FIELDS="BITRATE VMAF PSNR SI TI P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS INFERENCE_TIME_MS COVER_SSC COVER_TSC COVER_ASC COVER_FSC"
for field in $SELECTED_FIELDS
do
    echo 'python3 $ROOT_DIR/SCRIPTS/LEVEL0/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}'
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/plot_file_param.py ${INPUT_DIR}/file_for_plot.csv "${field} vs Encoded Bitrate" ${field}
done

#python3 ../../SCRIPTS/LEVEL0/plot_file_param.py file_for_plot.csv "TITLE" "CARS"
#python3 $ROOT_DIR/SCRIPTS/LEVEL0/plot_file_v2.py  ${INPUT_DIR}/file_for_plot.csv "YOLOV7 Degradation wtih Confidence ${conf} and Image Size ${img_size}"
# ##########################################################################################################

# STAGE 11 CLEANUP
fi
/usr/bin/rm $INPUT_DIR/*.yuv
