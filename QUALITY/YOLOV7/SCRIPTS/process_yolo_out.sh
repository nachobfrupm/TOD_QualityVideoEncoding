

function text_before_Done ()
{
    
    input_text="$1"
    # Split the input text into two parts using 'Done' as the separator
    # The '##' operator removes the shortest match of the pattern (in this case, "Done") from the start of the second part.
    before_done=${input_text%%, Done*}
    echo $before_done
}
input_mp4_file=$1
file_bitrate_kbps=$(ffprobe -i $input_mp4_file 2>&1 |grep bitrate|cut -d ":" -f 6|cut -d " " -f2)
python detect.py --weights yolov7.pt --conf 0.50 --img-size 640 --source $input_mp4_file > ${input_mp4_file}.txt
grep mp4 ${input_mp4_file}.txt|grep -v img_size|cut -d " " -f3,5-20 > /tmp/yolov7.out.txt


#Count number of every class , and output to csv file



echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS"
echo "BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS" > ${input_mp4_file}.csv

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
    echo "$file_bitrate_kbps, $frame_number , $number_of_cars , $number_of_bicycles , $number_of_motorcycles , $number_of_buses , $number_of_trucks , $number_of_traffic_lights , $number_of_persons , $number_of_stop_signs , $inference_time_ms"
    echo "$file_bitrate_kbps, $frame_number , $number_of_cars , $number_of_bicycles , $number_of_motorcycles , $number_of_buses , $number_of_trucks , $number_of_traffic_lights , $number_of_persons , $number_of_stop_signs , $inference_time_ms" >> ${input_mp4_file}.csv
    #echo "========================================================"
    
done < "/tmp/yolov7.out.txt"

# Calculate Average 
python3 average.py ${input_mp4_file}.csv ${input_mp4_file}.average.csv
cat ${input_mp4_file}.average.csv







