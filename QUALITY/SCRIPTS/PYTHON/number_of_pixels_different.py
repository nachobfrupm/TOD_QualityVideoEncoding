import cv2
import numpy as np
import sys

def average_pixel_difference(video_path1, video_path2):
    # Open video files
    cap1 = cv2.VideoCapture(video_path1)
    cap2 = cv2.VideoCapture(video_path2)

    if not cap1.isOpened() or not cap2.isOpened():
        print("Error: Video files could not be opened.")
        return None

    total_differences = 0
    frame_count = 0

    while cap1.isOpened() and cap2.isOpened():
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()

        if not ret1 or not ret2:
            break

        # Resize frames to the same dimensions if they differ
        if frame1.shape != frame2.shape:
            frame2 = cv2.resize(frame2, (frame1.shape[1], frame1.shape[0]))

        # Compute absolute difference between frames
        diff = cv2.absdiff(frame1, frame2)

        # Calculate the number of pixels that are different
        diff_count = np.sum(diff > 0)

        total_differences += diff_count
        frame_count += 1

    cap1.release()
    cap2.release()

    # Calculate average differing pixels per frame
    average_difference = total_differences / frame_count if frame_count != 0 else 0
    return average_difference

video1_path = sys.argv[1]
video2_path = sys.argv[2]

result = average_pixel_difference(video1_path, video2_path)
print(f"Average differing pixels per frame: {result}")


