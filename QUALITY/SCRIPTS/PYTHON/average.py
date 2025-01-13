import csv
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, mode='r') as csvfile:
    csvreader = csv.reader(csvfile)
    header = next(csvreader)  # Read the header

    # Initialize lists to hold column sums and counts
    sums = [0] * len(header)
    counts = [0] * len(header)

    # Process each row in the CSV file
    for row in csvreader:
        for i, value in enumerate(row):
            if value:  # Check if value is not empty
                try:
                    num_value = float(value)
                    sums[i] += num_value
                    counts[i] += 1
                except ValueError:
                    print(f"Warning: Non-numeric data '{value}' encountered in column {i+1}.")

averages = []
for i in range(len(sums)):
    if counts[i] > 0:
        averages.append(round(sums[i] / counts[i], 6))  # Calculate and round the average
    else:
        averages.append(0)  # Handle potential divide by zero case

# Write the results to the output CSV file
with open(output_file, mode='w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(header)  # Write the header
    csvwriter.writerow(averages)  # Write the averages

print(f"Averages calculatedd and written to {output_file}")
