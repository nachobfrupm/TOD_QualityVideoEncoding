import cv2
import numpy as np
from skimage.metrics import structural_similarity as ssim
import sys

def calculate_ssim(video_path1, video_path2):
    # Open the videos
    cap1 = cv2.VideoCapture(video_path1)
    cap2 = cv2.VideoCapture(video_path2)

    if not cap1.isOpened() or not cap2.isOpened():
        raise ValueError("Error opening video files")

    total_ssim = 0
    frame_count = 0

    while True:
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()

        if not ret1 or not ret2:
            break

        # Convert frames to grayscale for SSIM calculation
        gray1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)

        # Calculate SSIM
        ssim_value = ssim(gray1, gray2)
        total_ssim += ssim_value
        frame_count += 1

    # Close video captures
    cap1.release()
    cap2.release()

    if frame_count == 0:
        return 0

    # Calculate the average SSIM score
    average_ssim = total_ssim / frame_count
    return average_ssim

# Example usage
video_path1 = sys.argv[1]
video_path2 = sys.argv[2]
average_ssim = calculate_ssim(video_path1, video_path2)
print(f"Average SSIM: {average_ssim:.4f}")
