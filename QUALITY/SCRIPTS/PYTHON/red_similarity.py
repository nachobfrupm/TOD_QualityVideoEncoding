import cv2
import numpy as np
import sys
def calculate_red_pixel_similarity(video_path1, video_path2):
    # Open the videos
    cap1 = cv2.VideoCapture(video_path1)
    cap2 = cv2.VideoCapture(video_path2)
    
    if not cap1.isOpened() or not cap2.isOpened():
        raise ValueError("Error opening video files")

    total_similarity = 0
    frame_count = 0

    while True:
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()

        if not ret1 or not ret2:
            break

        # Resize frames to ensure they are the same size (if necessary)
        # frame1 = cv2.resize(frame1, (640, 480))
        # frame2 = cv2.resize(frame2, (640, 480))

        # Identify pure red pixels in the first video
        pure_red1 = (frame1[:, :, 0] == 0) & (frame1[:, :, 1] == 0) & (frame1[:, :, 2] > 0)

        # Identify corresponding pixels in the second video
        pure_red2 = (frame2[:, :, 0] == 0) & (frame2[:, :, 1] == 0) & (frame2[:, :, 2] > 0)

        # Count the number of pure red pixels in the first video and matching pixels in the second video
        count_red1 = np.sum(pure_red1)
        count_matching_red = np.sum(pure_red1 & pure_red2)

        if count_red1 > 0:
            similarity = (count_matching_red / count_red1) * 100  # Similarity as a percentage
        else:
            similarity = 0  # No pure red pixels in the first video

        total_similarity += similarity
        frame_count += 1

    # Close video captures
    cap1.release()
    cap2.release()

    if frame_count == 0:
        return 0

    # Calculate average similarity score across all frames
    average_similarity = total_similarity / frame_count
    return average_similarity

# Example usage
video_path1 = sys.argv[1]
video_path2 = sys.argv[2]
similarity_score = calculate_red_pixel_similarity(video_path1, video_path2)
print(f"{similarity_score:.2f}")
