import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys

def plot_correlation_matrix(csv_file_path):
    # Read CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)

    # Calculate the correlation matrix
    corr_matrix = df.corr()

    # Plot the correlation matrix
    plt.figure(figsize=(10, 8))
    sns.heatmap(corr_matrix, annot=True, fmt=".2f", cmap='coolwarm', cbar_kws={'label': 'Correlation Coefficient'})
    plt.title('Correlation Matrix')
    #plt.show()
    output_filename = 'correlation.png'
    plt.savefig(output_filename, dpi=320)

# Example usage
plot_correlation_matrix(sys.argv[1])

