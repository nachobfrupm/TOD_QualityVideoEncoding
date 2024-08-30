import pandas as pd
import matplotlib.pyplot as plt
import sys

# Read the CSV file into a pandas DataFrame


if __name__ == "__main__":sequence07_straight_high_speed_90km_700_preset_5_rc_mode_4.ts.mp4_0.42_1920.single_average.csv
    print(f"Arguments count: {len(sys.argv)}")
    for i, arg in enumerate(sys.argv):
        print(f"Argument {i:>6}: {arg}")

    filename = sys.argv[1]
    the_title = sys.argv[2]
    read_df = pd.read_csv(filename, sep =',' )
    df = read_df.sort_values(by=['BITRATE'], ascending=False)
    df.head()
    # Extract the "EncoderLatency" and "VMAF" columns
    bitrate = df['BITRATE']
    cars_detected = df['CARS']
    

    ax = plt.gca()
    ax.grid(visible=True, linestyle='--')
    #ax.grid(True)
    # Create the scatter plot
    plt.scatter(bitrate,cars_detected)
    # To add and additional column
    # Uncomment for every column
    #plt.scatter(bitrate,buses_detected)
    plt.xlabel('Bitrate')
    plt.ylabel('Average # Cars Detected')
    plt.title(the_title)

    # Display the plot
    #plt.show()
    output_filename = filename + '.png'
    plt.savefig(output_filename, dpi=320)