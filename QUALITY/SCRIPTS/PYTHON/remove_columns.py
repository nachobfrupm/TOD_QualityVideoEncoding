import pandas as pd
import sys

def remove_columns(input_csv, output_csv, columns_to_remove):
    # Read the input CSV file into a DataFrame
    df = pd.read_csv(input_csv)
    
    # Split the input columns by comma and remove leading/trailing whitespace
    columns_to_remove_list = [col.strip() for col in columns_to_remove.split(',')]
    
    # Drop the specified columns
    df.drop(columns=columns_to_remove_list, inplace=True, errors='ignore')
    
    # Write the modified DataFrame to a new CSV file
    df.to_csv(output_csv, index=False)
    
    print(f"Columns removed successfully. Output saved to: {output_csv}")

# Example usage:
#input_csv_file = 'input.csv'  # Path to your input CSV file
#output_csv_file = 'output.csv'  # Path where you want the output CSV to be saved
#columns_to_remove = input("Enter the column names to remove (comma-separated): ")

remove_columns(sys.argv[1], sys.argv[2], sys.argv[3])
