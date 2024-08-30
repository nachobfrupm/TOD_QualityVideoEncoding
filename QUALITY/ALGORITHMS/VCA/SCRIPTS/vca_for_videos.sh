# input_dir should contain both YUV RAW files and MP4 files
# encoded H264 files are in MP4 container format

input_dir=$1
for file in $(ls ${input_dir}/*.mp4)
do
    VCA/source/apps/vca/vca --input ${file}.yuv --input-res 1920x1080 --input-fps 30 --complexity-csv ${file}.yuv.csv
    python3 SCRIPTS/average.py $file.yuv.csv ${file}.yuv.average.csv
    # Check bitrate
    file_bitrate_kbps=$(ffprobe -i $file 2>&1 |grep bitrate|cut -d ":" -f 6|cut -d " " -f2)
    last_line_csv=$(tail -1 ${file}.yuv.average.csv)
    new_line_csv_2="$file_bitrate_kbps,$last_line_csv"
    bitrate_header="BITRATE"
    top_line_csv=$(head -1 ${file}.yuv.average.csv)
    new_line_csv_1="$bitrate_header,$top_line_csv"
    echo $new_line_csv_1 
    echo $new_line_csv_2        
    echo $new_line_csv_1 > ${file}.yuv.average.toplot.csv
    echo $new_line_csv_2 >> ${file}.yuv.average.toplot.csv
    echo $new_line_csv_1 > ${input_dir}/full_vca_plot.csv
done
#Generate final plot csv file
head -1 
for file in $(ls ${input_dir}/*.mp4)
    do
      tail -1 ${file}.yuv.average.toplot.csv >> ${input_dir}/full_vca_plot.csv
done
cat ${input_dir}/full_vca_plot.csv
echo "Executing plotting script : python3 SCRIPTS/plot_vca.py ${input_dir}/full_vca_plot.csv /"VCA METRICS/""
python3 SCRIPTS/plot_vca.py ${input_dir}/full_vca_plot.csv "VCA METRICS"

