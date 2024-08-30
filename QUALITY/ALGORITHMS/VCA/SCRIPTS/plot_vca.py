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
    #BITRATE,POC,E,h,epsilon,L,avgU,energyU,avgV,energyV,entropy,entropyDiff, entropyEpsilon,entropyU,entropyV,edgeDensity
    # Extract the "BITRATE" and "E" columns
    bitrate = df['BITRATE']
    energy = df['E']
    #h_value = df['h']
    
    #epsilon = df['epsilon']
    #L_value = df['L']
    #avgU = df['avgU']
    #energyU = df['energyU']



    

    ax = plt.gca()
    ax.grid(visible=True, linestyle='--')
    ax.grid(True)
    # Create the scatter plot
    plt.scatter(bitrate,energy)
    #plt.scatter(bitrate,h_value)
    #plt.scatter(bitrate,epsilon)
    #plt.scatter(bitrate,L_value)
    #plt.scatter(bitrate,avgU)
    #plt.scatter(bitrate,energyU)
    # To add and additional column
    # Uncomment for every column
    #plt.scatter(bitrate,buses_detected)
    plt.xlabel('Bitrate')
    plt.ylabel('Energy')
    plt.title(the_title)

    # Display the plot
    plt.show()
    output_filename = filename + '.png'
    plt.savefig(output_filename, dpi=320)