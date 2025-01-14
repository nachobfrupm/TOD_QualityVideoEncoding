#!/bin/bash
export INPUT_DIR=$1
cd $INPUT_DIR
rm *mp4 *csv *yuv *mediainfo
rm -rf TMP/*
mv input_mp4_file.mp4.orig input_mp4_file.mp4