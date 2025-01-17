import pandas as pd
import sys



def remove_empty_or_zero_columns(input_csv, output_csv):
    # Read the input CSV file into a DataFrame
    df = pd.read_csv(input_csv)
    
    # Define a function to check if a series is either all NaN/empty or all zero
    def is_empty_or_zero(series):
        return all(series.isna()) or all(series.eq(0))
    
    # Identify columns to be removed where all values are NaN or zero
    columns_to_remove = [col for col in df.columns if is_empty_or_zero(df[col])]
    
    # Drop these columns
    df.drop(columns=columns_to_remove, inplace=True)
    
    # Write the modified DataFrame to a new CSV file
    df.to_csv(output_csv, index=False)
    
    print(f"Columns {columns_to_remove} removed successfully. Output saved to: {output_csv}")

# Example usage:




remove_empty_or_zero_columns(sys.argv[1], sys.argv[2])
