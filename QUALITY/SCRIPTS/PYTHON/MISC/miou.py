import cv2
import numpy as np
import sys

def calculate_iou(pred_mask, true_mask):
    intersection = np.logical_and(pred_mask, true_mask).sum()
    union = np.logical_or(pred_mask, true_mask).sum()
    iou = intersection / union if union != 0 else 1.0
    return iou

def calculate_miou(video1_path, video2_path):
    cap1 = cv2.VideoCapture(video1_path)
    cap2 = cv2.VideoCapture(video2_path)
    
    miou_sum = 0
    frame_count = 0
    
    while True:
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()
        
        if not ret1 or not ret2:
            break
        
        # Assuming binary masks: pixel values are 0 or 255.
        binary_frame1 = cv2.threshold(frame1, 127, 255, cv2.THRESH_BINARY)[1]
        binary_frame2 = cv2.threshold(frame2, 127, 255, cv2.THRESH_BINARY)[1]

        # Convert frames to Boolean numpy arrays for logical operations
        pred_mask = binary_frame1.astype(bool)
        true_mask = binary_frame2.astype(bool)
        
        iou = calculate_iou(pred_mask, true_mask)
        miou_sum += iou
        frame_count += 1

    cap1.release()
    cap2.release()
    
    miou = miou_sum / frame_count if frame_count != 0 else 0
    return miou

# Replace 'video1.mp4' and 'video2.mp4' with your video file paths
video1_path = sys.argv[1]
video2_path = sys.argv[2]
miou = calculate_miou(video1_path, video2_path)
print(f'Mean Intersection over Union (mIoU): {miou:.4f}')
