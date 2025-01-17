import pandas as pd
import sys
import csv




# Read the CSV file into a DataFrame
df = pd.read_csv(sys.argv[1])
print(df)


column_name = sys.argv[3]
column_name_pct = column_name+"_PCT"

# Calculate the maximum value in the NUMBERS_OF_CARS column
max_value = df[column_name].max()

# Calculate the percentage and add it as a new column
df[column_name_pct] = (df[column_name] / max_value) * 100

# Save the updated DataFrame back to a CSV file (optional)
df.to_csv(sys.argv[2], index=False)
    


# Display the updated DataFrame (optional)
print(df)


