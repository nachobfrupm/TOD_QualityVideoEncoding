import cv2
import numpy as np
import sys

def compare_videos_pure_red(video_path1, video_path2):
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
        
        # Identify pure red pixels
        pure_red1 = np.logical_and(frame1[:, :, 0] == 0, 
                                   np.logical_and(frame1[:, :, 1] == 0, frame1[:, :, 2] > 0))
        pure_red2 = np.logical_and(frame2[:, :, 0] == 0,
                                   np.logical_and(frame2[:, :, 1] == 0, frame2[:, :, 2] > 0))

        # Calculate the number of matching pure red pixels
        matching_pure_red = np.sum(pure_red1 == pure_red2)
        total_pixels = np.sum(pure_red1 | pure_red2)  # Total pure red pixels in both frames

        if total_pixels > 0:
            # Calculate similarity score as the proportion of matching pure red pixels
            similarity = matching_pure_red / total_pixels
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
similarity = compare_videos_pure_red(video_path1, video_path2)
print(f"Video similarity based on pure red pixels: {similarity:.2f}")
