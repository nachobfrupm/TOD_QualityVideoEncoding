import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
from tabulate import tabulate

def plot_correlation_matrix(csv_file_path,title):
    # Read CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)

    # Calculate the correlation matrix
    corr_matrix = df.corr()

    # Save the correlation matrix to a CSV file
    corr_csv_filename = 'correlation_matrix.csv'
    corr_matrix.to_csv(corr_csv_filename)

    # Plot the correlation matrix
    plt.figure(figsize=(10, 8))
    sns.heatmap(corr_matrix, annot=True, fmt=".2f", cmap='coolwarm', cbar_kws={'label': 'Correlation Coefficient'})
    plt.title(title)

    # Save the plot as an image file
    output_filename = 'correlation.png'
    plt.savefig(output_filename, dpi=320)
    
    # Pretty print specific rows from the correlation matrix
    rows_to_print = corr_matrix.loc[['LD_PCT', 'CARS_PCT']]
    print("\nPretty Printed Table:")
    print(tabulate(rows_to_print, headers='keys', tablefmt='pretty', floatfmt=".2f"))

# Example usage
plot_correlation_matrix(sys.argv[1],sys.argv[2])
