#!/bin/bash
INPUT_DIR=$1
ROOT_DIR=/media/xruser/REMOTEDRIVING/TOD/TESIS/QUALITY2.0


## With existing csv plot file and individual yolov7 files create a new csv file
## Then regnerate all plot files
## BITRATE,FRAME,CARS,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOP_SIGNS,INFERENCE_TIME_MS
##                    ------------------------------------------------------------------->


conf="0.7"
img_size="640"
cd $INPUT_DIR
for input_mp4_file in $(ls *mp4)
do            
            cp ${input_mp4_file}.csv ${input_mp4_file}.csv.backup
            echo ${input_mp4_file}
            echo "Executing : tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d \",\" -f4"
            BICYCLES=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f4)
            MOTORCYCLES=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f5)
            BUSES=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f6)
            TRUCKS=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f7)
            TRAFFIC_LIGHTS=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f8)
            PERSONS=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f9)
            STOP_SIGNS=$(tail -1 TMP/${input_mp4_file}_${conf}_${img_size}_yolov7_average.csv | cut  -d "," -f10)
            echo "BICYCLES: $BICYCLES"
            echo "MOTORCYCLES: $MOTORCYCLES"
            echo "BUSES : $BUSES"
            echo "TRUCKS : $TRUCKS"
            echo "TRAFFIC_LIGHTS: $TRAFFIC_LIGHTS"
            echo "PERSONS: $PERSONS"
            echo "STOP_SIGNS: $STOP_SIGNS"

            sed -i '$ s/$/'",${BICYCLES}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${MOTORCYCLES}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${BUSES}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${TRUCKS}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${TRAFFIC_LIGHTS}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${PERSONS}"'/' ${input_mp4_file}.csv
            sed -i '$ s/$/'",${STOP_SIGNS}"'/' ${input_mp4_file}.csv
            

done

# ##########################################################################################################
# STAGE 10 - PLOTTING GRAPHS

# Combine CSVs
if ($STAGE_10)
then
cd ${INPUT_DIR}
#head -1 source_mp4_file.mp4.csv > file_for_plot.csv
echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS" > file_for_plot.csv

for input_mp4_file in $(ls ${INPUT_DIR}/*mp4)
    do
       echo $input_mp4_file 
       tail -1 ${input_mp4_file}.csv >> file_for_plot.csv
done

# ITERATE THROUG ALL THE NEW FIELDS ADDED
NEW_YOLOV_FIELDS="SI TI BICYCLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS"
for new_field in $NEW_YOLOV_FIELDS
do
# ADD PCT_COLUMN TO ALL NEW FIELDS
    echo "============="
    echo "$new_field"
    echo "============="
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/add_column.py file_for_plot.csv file_for_plot_1.csv $new_field
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/add_column.py file_for_plot_1.csv file_for_plot_2.csv $new_field
    python3 $ROOT_DIR/SCRIPTS/LEVEL0/add_column.py file_for_plot_2.csv file_for_plot_3.csv $new_field
    mv file_for_plot.csv file_for_plot_no_pcts.csv 
    mv file_for_plot_3.csv file_for_plot.csv
done



# GENERATE SEVERAL PLOTS
#ALL_FIELDS="BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS"
ALL_FIELDS="BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS,COVER_SSC,COVER_TSC,COVER_ASC,COVER_FSC,BICYCLES,MOTORCYCLES,BUSES,TRUCKS,TRAFFIC_LIGHTS,PERSONS,STOPS_SIGNS"
#SELECTED_FIELDS="VMAF PSNR SI TI P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS INFERENCE_TIME_MS"
SELECTED_FIELDS="BITRATE VMAF PSNR SI TI SI_PCT TI_PCT P1204_3_MOS VCA_E VCA_H EVCA_SC EVCA_TC CARS CARS_PCT INFERENCE_TIME_MS COVER_SSC COVER_TSC COVER_ASC COVER_FSC BYCICLES MOTORCYCLES BUSES TRUCKS TRAFFIC_LIGHTS PERSONS STOPS_SIGNS BYCICLES_PCT MOTORCYCLES_PCT BUSES_PCT TRUCKS_PCT TRAFFIC_LIGHTS_PCT PERSONS_PCT STOPS_SIGNS_PCT"
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
