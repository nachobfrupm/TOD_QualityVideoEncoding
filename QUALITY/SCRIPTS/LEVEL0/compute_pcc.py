import pandas as pd
from scipy.stats import pearsonr
import sys

def compute_pearson_correlation(csv_file, column1, column2):
    # Load the CSV file into a DataFrame
    df = pd.read_csv(csv_file)

    # Check if the specified columns exist in the DataFrame
    if column1 not in df.columns or column2 not in df.columns:
        print(f"Error: Columns '{column1}' and/or '{column2}' not found in the CSV file.")
        return

    # Drop rows where either column1 or column2 has NaN values
    df = df[[column1, column2]].dropna()

    # Extract the two columns as series
    col1_data = df[column1]
    col2_data = df[column2]

    # Calculate the Pearson Correlation Coefficient
    correlation, _ = pearsonr(col1_data, col2_data)

    # Output the result
    print(f"The Pearson Correlation Coefficient between '{column1}' and '{column2}' is: {correlation:.4f}")

if __name__ == "__main__":
    # Expecting the script to be run with three additional arguments
    if len(sys.argv) != 4:
        print("Usage: python script.py <csv_file> <column1> <column2>")
    else:
        csv_file = sys.argv[1]
        column1 = sys.argv[2]
        column2 = sys.argv[3]
        compute_pearson_correlation(csv_file, column1, column2)

