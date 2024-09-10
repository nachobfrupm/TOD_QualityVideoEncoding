import pandas as pd
import sys

def merge_csv_files(file1, file2, output_file):
    # Read the CSV files
    df1 = pd.read_csv(file1)
    df2 = pd.read_csv(file2)

    # Check if both files have the same number of rows
    if df1.shape[0] != df2.shape[0]:
        raise ValueError("The two files do not have the same number of rows.")

    # Merge the dataframes by columns (axis=1)
    merged_df = pd.concat([df1, df2], axis=1)

    # Save the merged dataframe to a new CSV file
    merged_df.to_csv(output_file, index=False)

# Example usage
file1 = sys.argv[1]
file2 = sys.argv[2]
output_file = sys.argv[3]

merge_csv_files(file1, file2, output_file)

