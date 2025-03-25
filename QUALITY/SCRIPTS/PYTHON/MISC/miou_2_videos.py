import cv2
import numpy as np
import sys

def calculate_iou(imageA, imageB):
    # Convert images to binary using thresholding
    _, threshA = cv2.threshold(cv2.cvtColor(imageA, cv2.COLOR_BGR2GRAY), 127, 255, cv2.THRESH_BINARY)
    _, threshB = cv2.threshold(cv2.cvtColor(imageB, cv2.COLOR_BGR2GRAY), 127, 255, cv2.THRESH_BINARY)

    # Calculate intersection and union
    intersection = np.logical_and(threshA, threshB).sum()
    union = np.logical_or(threshA, threshB).sum()

    # Compute IoU
    iou = intersection / union if union != 0 else 0
    return iou

def mean_iou(video_path1, video_path2):
    cap1 = cv2.VideoCapture(video_path1)
    cap2 = cv2.VideoCapture(video_path2)

    if not cap1.isOpened() or not cap2.isOpened():
        print("Error: Video files could not be opened.")
        return None

    iou_sum = 0
    count = 0

    while cap1.isOpened() and cap2.isOpened():
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()

        if not ret1 or not ret2:
            break

        iou = calculate_iou(frame1, frame2)
        print(iou)
        iou_sum += iou
        count += 1

    cap1.release()
    cap2.release()

    mean_iou = iou_sum / count if count != 0 else 0
    return mean_iou

video1_path = 'video1.mp4'
video2_path = 'video2.mp4'

result = mean_iou(sys.argv[1], sys.argv[2])
print(f"Mean IoU: {result}")

