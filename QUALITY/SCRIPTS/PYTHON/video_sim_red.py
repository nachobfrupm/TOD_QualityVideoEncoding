import cv2
import numpy as np
import sys

def compare_videos_red_channel(video_path1, video_path2):
    # Open the videos
    cap1 = cv2.VideoCapture(video_path1)
    cap2 = cv2.VideoCapture(video_path2)
    
    if not cap1.isOpened() or not cap2.isOpened():
        raise ValueError("Error opening video files")

    total_similarities = 0
    frame_count = 0

    while True:
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()

        if not ret1 or not ret2:
            break

        # Resize frames
        frame1 = cv2.resize(frame1, (640, 480))
        frame2 = cv2.resize(frame2, (640, 480))
        
        # Extract the red channel
        red1 = frame1[:, :, 2]
        red2 = frame2[:, :, 2]

        # Calculate histograms for the red channel
        hist1 = cv2.calcHist([red1], [0], None, [256], [0, 256])
        hist2 = cv2.calcHist([red2], [0], None, [256], [0, 256])

        # Normalize histograms
        hist1 = cv2.normalize(hist1, hist1).flatten()
        hist2 = cv2.normalize(hist2, hist2).flatten()

        # Calculate similarity for the red channel
        similarity = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
        total_similarities += similarity
        frame_count += 1

    # Close video captures
    cap1.release()
    cap2.release()

    if frame_count == 0:
        return 0

    # Calculate average similarity score and scale to 0-100
    average_similarity = total_similarities / frame_count
    similarity_score = average_similarity * 100

    return max(0, min(100, similarity_score))

# Example usage
video_path1 = sys.argv[1]
video_path2 = sys.argv[2]
similarity = compare_videos_red_channel(video_path1, video_path2)
print(f"Video similarity based on red channel: {similarity:.2f}")
