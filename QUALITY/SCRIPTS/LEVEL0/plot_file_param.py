import pandas as pd
import matplotlib.pyplot as plt
import sys

# Read the CSV file into a pandas DataFrame
# echo "BITRATE,VMAF,PSNR,SI,TI,P1204_3_MOS,VCA_E,VCA_H,EVCA_SC,EVCA_TC,CARS,INFERENCE_TIME_MS" > ${input_mp4_file}.csv


if __name__ == "__main__":
    print(f"Arguments count: {len(sys.argv)}")
    for i, arg in enumerate(sys.argv):
        print(f"Argument {i:>6}: {arg}")

    filename = sys.argv[1]
    the_title = sys.argv[2]
    the_parameter = sys.argv[3]
    read_df = pd.read_csv(filename, sep =',' )
    df = read_df.sort_values(by=[the_parameter], ascending=False)
    df.head()
    # Extract the "EncoderLatency" and "VMAF" columns
    bitrate = df['BITRATE']
    the_parameter_value = df[the_parameter]
    
    

    ax = plt.gca()
    ax.grid(visible=True, linestyle='--')
    #ax.grid(True)
    # Create the scatter plot
    plt.plot(bitrate,the_parameter_value,marker='o', linestyle='-',label=the_parameter)
    

    # To add and additional column
    # Uncomment for every column
    #plt.scatter(bitrate,buses_detected)
    plt.xlabel('Bitrate')
    plt.ylabel(the_parameter)
    plt.title(the_title)
    plt.legend()

    # Display the plot
    #plt.show()
    #output_filename = filename + '.png'
    output_filename = the_parameter + '.png'
    plt.savefig(output_filename, dpi=320)