


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
STAGE_2=false
STAGE_3=false
STAGE_4=false
STAGE_5=false
STAGE_6=true





# Parameters:
# 1 : input_directory
# 2 : input_format, etiher mp4,jpg or png
# 3 : yolov7 installation directory ( assumes virtualenv exists with same name )

INPUT_DIR=$1
INPUT_FORMAT=$2

# ##########################################################################################################
# STAGE 0

if [ "$INPUT_FORMAT" = "png" ]
then
    # Step 0 Generate video file
    ${ROOT_DIR}/ENCODE/SCRIPTS/generate_mp4_from_pngs.sh $INPUT_DIR ${INPUT_DIR}/source_mp4_file.mp4
    INPUT_VIDEO_FILE=$INPUT_DIR/source_mp4_file.mp4
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
elif [["$INPUT_FORMAT" == "jpg"]]
then
    ${ROOT_DIR}/ENCODE/SCRIPTS/generate_mp4_from_jpgs.sh $INPUT_DIR ${INPUT_DIR}/source_mp4_file.mp4
    INPUT_VIDEO_FILE=$INPUT_DIR $INPUT_DIR/source_mp4_file.mp4
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
else
    INPUT_VIDEO_FILE=$(ls ${INPUT_DIR}*.mp4)
    mediainfo $INPUT_VIDEO_FILE > ${INPUT_VIDEO_FILE}.mediainfo
fi
echo "=================================================================================================="
echo $INPUT_VIDEO_FILE
ls -altr $INPUT_VIDEO_FILE
echo "=================================================================================================="
# ##########################################################################################################


# ##########################################################################################################
# STAGE 1 BITRATE TRANSCODING

echo ""
${ROOT_DIR}/ENCODE/SCRIPTS/transcode_bitrates.sh $INPUT_VIDEO_FILE
echo "=================================================================================================="
ls -altr ${INPUT_DIR}/*mp4
echo "=================================================================================================="
# ##########################################################################################################

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

    for input_vmaf_mp4_file in $(ls *mp4|grep _AT)
        do    
        TMP_VMAF_FILE=${INPUT_DIR}/TMP/${input_vmaf_mp4_file}.json
        # Generate YUV for every one
        OUTPUT_YUV=${input_vmaf_mp4_file}.mp4.yuv
        ffmpeg -y -i  $input_vmaf_mp4_file -c:v rawvideo -pixel_format yuv420p $OUTPUT_YUV    
        ${ROOT_DIR}/BIN/vmaf --reference $INPUT_YUV  --distorted $OUTPUT_YUV --width $INPUT_WIDTH --height $INPUT_HEIGHT --pixel_format 420 --bitdepth 8 --output ${TMP_VMAF_FILE} --json 
        VMAF_VALUE=$(grep mean  ${TMP_VMAF_FILE}|grep -v harmonic|tail -1|cut -d ":" -f2|cut -d "," -f1|cut -d " " -f2)
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
    for input_psnr_mp4_file in $(ls *mp4|grep _AT)
        do    
            TMP_PSNR_FILE=${INPUT_DIR}/TMP/psnr_${input_psnr_mp4_file}.txt
            echo "${TMP_PSNR_FILE}"
            FIRST_MP4_FILE=source_mp4_file.mp4
            SECOND_MP4_FILE=${input_psnr_mp4_file}
            PSNR_VALUE=$(ffmpeg -i ${FIRST_MP4_FILE}  -i ${SECOND_MP4_FILE}  -lavfi psnr=stats_file=${TMP_PSNR_FILE} -f null - 2>&1 |grep Parsed|cut -d ":" -f5|cut -d " " -f1)
            echo "PSNR - VALUE IS : $PSNR_VALUE"
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
            siti-tools $input_siti_mp4_file --color-range full > $TMP_JSON_FILE
            SPATIAL_INFO=$(cat $TMP_JSON_FILE|jq '.si | add/length')
            TEMPORAL_INFO=$(cat $TMP_JSON_FILE|jq '.ti | add/length')
            echo "${input_siti_mp4_fille} ; $SPATIAL_INFO ; $TEMPORAL_INFO"
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
            per_squence_mos=$(grep per_sequence ${INPUT_DIR}/TMP/${the_base_name}.json|cut -d ":" -f2)
            echo "======================"
            echo $per_squence_mos        
            echo "======================"                
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
    $ROOT_DIR/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps 30 --complexity-csv TMP/source_mp4_file.mp4.vca.csv
    # at this point we need to calculate Spatial Complexity (E) and Temporal complexity in Average from the csv file
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/source_mp4_file.mp4.vca.csv TMP/source_mp4_file.mp4.vca.average.csv
    E_Value=$(tail -1  TMP/source_mp4_file.mp4.vca.average.csv|cut -d "," -f2)
    h_Value=$(tail -1  TMP/source_mp4_file.mp4.vca.average.csv|cut -d "," -f3)
    echo "E: $E_Value"
    echo "h: $h_Value"
    for input_vca_mp4_file in $(ls *.mp4|grep "_AT_")
        do
        # We need YUV files as in STAGE 2
        INPUT_YUV=${input_vca_mp4_file}.mp4.yuv
        ffmpeg -y -i  $input_vca_mp4_file -c:v rawvideo -pixel_format yuv420p $INPUT_YUV    
        $ROOT_DIR/ALGORITHMS/VCA/VCA/source/apps/vca/vca --input ${INPUT_YUV} --input-res ${INPUT_WIDTH}x${INPUT_HEIGHT} --input-fps 30 --complexity-csv TMP/${input_vca_mp4_file}.vca.csv
        python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py TMP/${input_vca_mp4_file}.vca.csv TMP/${input_vca_mp4_file}.vca.average.csv
        E_Value=$(tail -1  TMP/${input_vca_mp4_file}.vca.average.csv|cut -d "," -f2)
        h_Value=$(tail -1  TMP/${input_vca_mp4_file}.vca.average.csv|cut -d "," -f3)
        echo "E: $E_Value"
        echo "h: $h_Value"  
        done
fi
# ##########################################################################################################

