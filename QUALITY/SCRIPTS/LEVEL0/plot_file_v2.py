import pandas as pd
import matplotlib.pyplot as plt
import sys

# Read the CSV file into a pandas DataFrame


if __name__ == "__main__":
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
    latency = df['INFERENCE_TIME_MS']

    ax = plt.gca()
    ax.grid(visible=True, linestyle='--')
    #ax.grid(True)
    # Create the scatter plot
    plt.plot(bitrate,cars_detected,marker='o', linestyle='-',label="Number of cars")
    plt.plot(bitrate,latency,marker='o', linestyle='-',label="Inference time(ms)")

    # To add and additional column
    # Uncomment for every column
    #plt.scatter(bitrate,buses_detected)
    plt.xlabel('Bitrate')
    plt.ylabel('Average # Cars Detected and Inference Time')
    plt.title(the_title)
    plt.legend()

    # Display the plot
    plt.show()
    output_filename = filename + '.png'
    plt.savefig(output_filename, dpi=320)