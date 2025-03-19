import csv
import sys

def overwrite_last_column(input_filename, output_filename, new_text):
    try:
        # Open the input CSV file for reading
        with open(input_filename, mode='r', newline='', encoding='utf-8') as input_file:
            csv_reader = csv.reader(input_file)
            rows = list(csv_reader)

        # Check if there's data beyond the header
        if len(rows) < 2:
            print("The CSV file contains only a header or is empty.")
            return

        header = rows[0]  # Keep the header intact
        data_rows = rows[1:]

        # Modify the last column of each data row
        modified_rows = []
        for row in data_rows:
            if not row:  # Skip empty rows
                modified_rows.append(row)
                continue
            row[-1] = new_text
            modified_rows.append(row)

        # Open the output CSV file for writing
        with open(output_filename, mode='w', newline='', encoding='utf-8') as output_file:
            csv_writer = csv.writer(output_file)
            
            # Write the header first
            csv_writer.writerow(header)
            
            # Write modified data rows
            csv_writer.writerows(modified_rows)

        print(f"Successfully overwritten the last column of the CSV and saved to {output_filename}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_csv> <output_csv> <new_text>")
    else:
        input_csv = sys.argv[1]
        output_csv = sys.argv[2]
        new_text = sys.argv[3]
        overwrite_last_column(input_csv, output_csv, new_text)
