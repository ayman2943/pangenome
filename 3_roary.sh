#!/bin/bash

# Check if the correct number of arguments is provided
# if [ "$#" -lt 2 ]; then
#     echo "Usage: $0 <gff_directory> <output_directory>"
#     exit 1
# fi
conda create -n roary python=3.8 perl=5.32.1
conda activate roary
conda install -c roary roary

# Input directory containing .gff files
GFF_DIR=genomes

# Output directory for Roary results
OUTPUT_DIR=roary_output

# Number of CPU cores to use
CORES=4  # Adjust according to your machine's capability

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Activate the environment if you're using conda (optional)
# source activate roary_env

# Run Roary
roary -e -n -v -p $CORES --mafft -f "$OUTPUT_DIR" "$GFF_DIR"/*.gff

# -e: Create a multiFASTA alignment of core genes using PRANK
# -n: Run fast core gene alignment using MAFFT
# -v: Verbose output
# -p: Number of threads to use
# -f: Output directory

echo "Roary analysis completed. Results are stored in $OUTPUT_DIR."
