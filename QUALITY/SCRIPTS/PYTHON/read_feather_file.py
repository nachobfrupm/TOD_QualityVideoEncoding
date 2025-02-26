import pyarrow.feather as feather
import sys
def print_feather_info(file_path):
    # Read the Feather file into an Arrow table
    table = feather.read_table(file_path)
    
    # Print schema information
    print("Schema:")
    print(table.schema)
    
    # Print the number of rows and columns
    print("\nNumber of rows:", table.num_rows)
    print("Number of columns:", table.num_columns)
    
    # Print a preview of the data
    print("\nData Preview:")
    print(table.to_pandas().head())  # Converts to a DataFrame for a readable preview

# Replace 'your_file.feather' with the path to your Feather file
print_feather_info(sys.argv[1])


