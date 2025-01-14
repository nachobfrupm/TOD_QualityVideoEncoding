#!/bin/bash

# Parameters:
# 1 : input directory in whicc MP4 files are
# There should be at least one file called
# master_mp4_file.mp4 (8Mbps bitrate)
# And the encoded replicas of this at different bitrates
export INPUT_DIR=$1
MASTER_VIDEO_FILE=${INPUT_DIR}/master_mp4_file.mp4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp.csv
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0

if [ -d ${INPUT_DIR}/TMP ]; then
    echo "Directory ${INPUT_DIR}/TMP already exists!"
    #/usr/bin/rm -rf ${INPUT_DIR}/TMP/*
else
    mkdir -p ${INPUT_DIR}/TMP
fi


function text_before_Done ()
{
    
    input_text="$1"
    # Split the input text into two parts using 'Done' as the separator
    # The '##' operator removes the shortest match of the pattern (in this case, "Done") from the start of the second part.
    before_done=${input_text%%, Done*}
    echo $before_done
}

function parse_yolov_output() {
    output_yolov_file=$1
    output_csv_file=$2
    file_bitrate_kbps=$3

    grep mp4 ${output_yolov_file} | grep -v img_size | cut -d " " -f3,5-20 >/tmp/yolov7.out.txt
    while IFS= read -r line; do
        # Check if the current line contains the word "Done"
        # We need to count the following classes

        objects_detected=$(text_before_Done "$line")

        frame_number=$(echo $objects_detected | cut -d ")" -f1 | cut -d "(" -f2 | cut -d "/" -f1)
        inference_time_ms=$(echo $line | cut -d "(" -f3 | cut -d ")" -f1 | cut -d "m" -f1)

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
        echo "$file_bitrate_kbps, $frame_number , $number_of_cars , $number_of_bicycles , $number_of_motorcycles , $number_of_buses , $number_of_trucks , $number_of_traffic_lights , $number_of_persons , $number_of_stop_signs , $inference_time_ms" >>${output_csv_file}
        #echo "========================================================"

    done </tmp/yolov7.out.txt

}

# ##########################################################################################################
# STAGE 10 YOLOV7 DETECTION

conf="0.7"
img_size="640"
for input_mp4_file in $(ls ${INPUT_DIR}/*mp4); do
    echo "$conf"
    echo "======================================================================================================================================"
    echo "Executing line : python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt"
    echo "======================================================================================================================================"
    echo ""

    cd ${ROOT_DIR}/YOLOV7/yolov7
    ENV_PATH=/${ROOT_DIR}/YOLOV7/yolov7/yolov7/bin/activate

    file_bitrate_kbps=$(ffprobe -i $input_mp4_file 2>&1 | grep bitrate | cut -d ":" -f 6 | cut -d " " -f2)

    bash --rcfile $ENV_PATH -i -c "python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt; exit 0"
    # Appends the result of this single yolov execution for a given bitrate(mp4 dependent),conf and img_size value into ${input_mp4_file}.csv
    cd ${INPUT_DIR}
    echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" >${input_mp4_file}_${conf}_${img_size}_yolov7.csv
    parse_yolov_output ${input_mp4_file}_${conf}_${img_size}.txt ${input_mp4_file}_${conf}_${img_size}_yolov7.csv $file_bitrate_kbps

    # And calculate average for this single combination
    echo "Executing line: python3 $ROOT_DIR/SCRIPTS/LEVEL0/average.py  ${input_mp4_file}_${conf}_${img_size}_yolov7.csv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv "
    python3 $ROOT_DIR/SCRIPTS/PYTHON/average.py ${input_mp4_file}_${conf}_${img_size}_yolov7.csv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv
    dos2unix ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv
    # Extract average figures from YOLOV7 Execution for every object
    CAR_NUMBER=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f3)
    BICYCLES=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f4)
    MOTORCYCLES=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f5)
    BUSES=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f6)
    TRUCKS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f7)
    TRAFFIC_LIGHTS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f8)
    PERSONS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f9)
    STOP_SIGNS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f10)
    INFERENCE_TIME_MS=$(tail -1 ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut -d "," -f11)
    echo "$INFERENCE_TIME_MS"
    INFERENCE_TIME_MS=$(echo $INFERENCE_TIME_MS)
    #INFERENCE_TIME_MS="2.1222"
    echo "=============================================================================================================
    echo "$CAR_NUMBER,$BICYCLES,$MOTORCYCLES,$BUSES,$TRUCKS,$TRAFFIC_LIGHTS,$PERSONS,$STOP_SIGNS,$INFERENCE_TIME_MS"
    echo "=============================================================================================================

    # Inject the previous figures in our csv...


    #sed -i '$ s/$/'"${INFERENCE_TIME_MS}"'/' ${input_mp4_file}.csv
    #$SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 15 $INFERENCE_TIME_MS $TEMPORARY_FILE

    #sed -i '$ s/$/'"${CAR_NUMBER},"'/' ${input_mp4_file}.csv    
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 16 $CAR_NUMBER $TEMPORARY_FILE
    
    
    #sed -i '$ s/$/'",${BICYCLES}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 17 $BICYCLES $TEMPORARY_FILE
    
    #sed -i '$ s/$/'",${MOTORCYCLES}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 18 $MOTORCYCLES $TEMPORARY_FILE
    
    #sed -i '$ s/$/'",${BUSES}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 19 $BUSES $TEMPORARY_FILE

    #sed -i '$ s/$/'",${TRUCKS}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 20 $TRUCKS $TEMPORARY_FILE
    
    #sed -i '$ s/$/'",${TRAFFIC_LIGHTS}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 21 $TRAFFIC_LIGHTS $TEMPORARY_FILE

    #sed -i '$ s/$/'",${PERSONS}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 22 $PERSONS $TEMPORARY_FILE
        
    #sed -i '$ s/$/'",${STOP_SIGNS}"'/' ${input_mp4_file}.csv
    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 23 $STOP_SIGNS $TEMPORARY_FILE

    $SCRIPT_DIR/change_csv_at_pos.sh ${input_mp4_file}.csv 15 $INFERENCE_TIME_MS $TEMPORARY_FILE

    echo "YOLOV7: $CAR_NUMBER , $INFERENCE_TIME"
    
    mv ${input_mp4_file}_${conf}_${img_size}.txt ${INPUT_DIR}/TMP 
    mv ${input_mp4_file}_${conf}_${img_size}_yolov7.csv ${INPUT_DIR}/TMP 
    mv ${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv ${INPUT_DIR}/TMP 
    
done
