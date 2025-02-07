#!/bin/bash
export INPUT_DIR=$1
export FIELD_NAME=$2
export EMPTY_VALUE=$3
TMP_DIR=/tmp
TEMPORARY_FILE=$TMP_DIR/tmp.csv
cd ${INPUT_DIR}
for input_mp4_file in $(ls *.mp4)
    do
       LINE_TOP=$(head -1 ${input_mp4_file}.csv)
       LINE_DATA=$(tail -1 ${input_mp4_file}.csv)
       echo "$LINE_TOP,$FIELD_NAME" > $TEMPORARY_FILE
       echo "$LINE_DATA,$EMPTY_VALUE" >> $TEMPORARY_FILE
       cp $TEMPORARY_FILE ${input_mp4_file}.csv
done
