import pandas as pd
import sys


def round_csv_decimal_values(input_file, output_file, decimal_places=2):
    # Read the CSV file without using the index
    df = pd.read_csv(input_file, index_col=False)

    # Apply rounding to numeric values only
    df = df.applymap(lambda x: round(x, decimal_places) if isinstance(x, (int, float)) else x)

    # Write the updated DataFrame to a new CSV file without the index
    df.columns = df.columns.str.replace("Unnamed: 0", "", regex=False)
    df.to_csv(output_file, index=False)


round_csv_decimal_values(sys.argv[1], sys.argv[2])



