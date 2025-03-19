import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

# Load the CSV data into a Pandas DataFrame
df = pd.read_csv('combined.csv')
dataset_name = sys.argv[1]

# Set up the plot
plt.figure(figsize=(10, 8))

# Use a colormap to assign different colors to points from different files
unique_filenames = df['filename'].unique()
colors = plt.cm.rainbow(np.linspace(0, 1, len(unique_filenames)))

# Plot each file's data separately to have different colors
for color, filename in zip(colors, unique_filenames):
    subset = df[df['filename'] == filename]
    plt.scatter(subset['SI'], subset['TI'], color=color, label=filename, linewidths=10, alpha=0.7, s=250,  marker='x')

# Add labels and title
plt.title(dataset_name, fontsize=16)
plt.xlabel('SI', fontsize=16)
plt.ylabel('TI', fontsize=16)
plt.grid(True)

plt.tick_params(axis='both', labelsize=14)
# Place the legend on the right side of the plot
#plt.legend(title='Filename', loc='center left', bbox_to_anchor=(1, 0.5), fontsize=10, title_fontsize=12)

# Display the plot
plt.tight_layout()
# Uncomment below to display interactively
# plt.show()
plt.savefig("scatter_si_ti.png", dpi=320)
