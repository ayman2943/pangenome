#!/bin/bash

input_file="accession_list.csv"
output_dir="genome_downloaded"

# Create output dAirectory if it doesn't exist
mkdir -p "$output_dir"

# Extract Genome ID and Genome Name columns (skip header)
awk -F',' 'NR>1 {print $1 "," $2}' "$input_file" > genome_data.tmp

# Function to sanitize genome name
sanitize_name() {
    echo "$1" | sed -e 's/[ :()/-]/_/g' -e 's/__*/_/g' -e 's/_$//'
}

while IFS=',' read -r genome_id genome_name; do
    echo "Processing: $genome_name (Genome ID: $genome_id)"
    
    sanitized_name=$(sanitize_name "$genome_name")
    output_file="${output_dir}/${sanitized_name}.fasta"  # Modified path
    
    # Check if file exists in 2nd_time folder
    if [ -f "$output_file" ]; then
        echo "$output_file already exists. Skipping download."
        echo "-----------------------------"
        continue
    fi

    # Download FASTA
    echo "Downloading to: $output_file"
    curl -s -H "accept: application/dna+fasta" -o "$output_file" \
    "https://www.patricbrc.org/api/genome_sequence/?eq(genome_id,${genome_id})&http_accept=application/dna+fasta"

    # Check download success
    if [ -s "$output_file" ]; then
        echo "Successfully downloaded: $output_file"
    else
        echo "Failed to download: $genome_name"
        rm -f "$output_file"
    fi
    
    echo "-----------------------------"
done < genome_data.tmp

rm -f genome_data.tmp
