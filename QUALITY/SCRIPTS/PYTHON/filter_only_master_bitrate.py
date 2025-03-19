import csv
import sys

def filter_csv(input_file, output_file, threshold):
    with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        for row in reader:
            try:
                if float(row[0]) >= threshold:
                    writer.writerow(row)
            except ValueError:
                # Writing the header row or any non-numeric first field rows
                writer.writerow(row)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_file> <output_file> <threshold>")
        sys.exit(1)
        
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    threshold = float(sys.argv[3])

    filter_csv(input_file, output_file, threshold)
