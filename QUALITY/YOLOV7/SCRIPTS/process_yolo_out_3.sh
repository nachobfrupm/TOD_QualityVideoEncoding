# process_yolo_out.sh
# Reads several versions of a video file endoded at different bitrates
# Runs YOLOV7 to detect objects related to driving a car
# Computes the average number of objects detected per frame for every video input
# Get the actual bitrate of the video using ffprobe
# Plots the YOLOV7 degradation due to reencoding video
# V3.0 with combinations of conf and img_size in yolov

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



input_dir=$1
#confs=("0.25" "0.30" "0.35" "0.42" "0.50")
#img_sizes=("640" "1280" "1920")
confs=("0.25" "0.30")
img_sizes=("640" "1280")

for input_mp4_file in $(ls ${input_dir}/*mp4)
do    
    echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" > ${input_mp4_file}.csv
    #Bitrate extraction
    file_bitrate_kbps=$(ffprobe -i $input_mp4_file 2>&1 |grep bitrate|cut -d ":" -f 6|cut -d " " -f2)
    #Iterate through some confidence thresholds and image sizes


    for conf in "${confs[@]}"; do
        for img_size in "${img_sizes[@]}"; do
            echo "$conf"
            echo "======================================================================================================================================"   
            echo "Executing line : python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt"
            echo "======================================================================================================================================"   
            echo ""
            python3 detect.py --weights yolov7.pt --conf $conf --img-size $img_size --source $input_mp4_file > ${input_mp4_file}_${conf}_${img_size}.txt            
            
            # Appends the result of this single yolov execution for a given bitrate(mp4 dependent),conf and img_size value into ${input_mp4_file}.csv
            parse_yolov_output ${input_mp4_file}_${conf}_${img_size}.txt ${input_mp4_file}.csv
            # Should we have also individuals csv files for fixed confs and img_sizes (??)
            # This file requires header
            echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" > ${input_mp4_file}_${conf}_${img_size}.csv
            parse_yolov_output ${input_mp4_file}_${conf}_${img_size}.txt ${input_mp4_file}_${conf}_${img_size}.csv                        
            # And calculate average for this single combination
            python3 average.py ${input_mp4_file}_${conf}_${img_size}.csv  ${input_mp4_file}_${conf}_${img_size}.single_average.csv 
        done
    done        
done

# Generate combined_average for same confidence and img_size

for conf in "${confs[@]}"; do
    for img_size in "${img_sizes[@]}"; do
        echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" > ${input_dir}/combined_average_${conf}_${img_size}.csv
        #sequence07_straight_high_speed_90km_900_preset_5_rc_mode_4.ts.mp4_0.25_640.single_average.csv
        for file in $(ls ${input_dir}/*.mp4_${conf}_${img_size}.single_average.csv) ;do 
            echo $file
            tail -1 $file >> ${input_dir}/combined_average_${conf}_${img_size}.csv
        done
    done
done



# Generate plot file
for conf in "${confs[@]}"; do
    for img_size in "${img_sizes[@]}"; do
        python3 plot_file.py  ${input_dir}/combined_average_${conf}_${img_size}.csv "YOLOV7 Degradation wtih Confidence ${conf} and Image Size ${img_size}"
    done
done


