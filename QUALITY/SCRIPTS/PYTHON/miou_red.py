import cv2
import numpy as np
import sys

def calculate_iou(pred_mask, true_mask):
    intersection = np.logical_and(pred_mask, true_mask).sum()
    union = np.logical_or(pred_mask, true_mask).sum()    
    #print("=====================")
    #print(intersection)
    #print(union)
    iou = intersection / union if union != 0 else 1.0
    return iou

def get_red_mask(frame):
    # Extract the red channel
    blue_channel = frame[:,:,0]
    green_channel = frame[:,:,1]
    red_channel  = frame[:,:,2]  # OpenCV uses BGR format
    # Create binary mask where red channel is greater than a threshold (e.g., 100)
    red_mask = ( red_channel > 100 ) & ( green_channel == 0 ) & ( blue_channel == 0)
    #red_mask = ( red_channel > 0 )
    #print(np.sum(red_mask))
    return red_mask

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
        
        # Get red masks for each frame
        pred_mask = get_red_mask(frame1)
        true_mask = get_red_mask(frame2)
        
        #iou = calculate_iou(pred_mask, true_mask)
        iou = calculate_iou(true_mask, pred_mask)
        #iou = calculate_iou(frame1,frame2)
        #print(iou)
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
print(f'{miou:.4f}')
