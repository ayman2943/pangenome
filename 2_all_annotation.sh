#!/bin/bash

# Output directory for Prokka annotations
ANNOTATION_DIR="./annotations"
mkdir -p "${ANNOTATION_DIR}"

# Loop through each assembly file (contigs.fasta)
for fasta_file in ./assembly/*.fasta
do
    # Get the base name of the file
    base=$(basename "${fasta_file}" .fasta)

    # Run Prokka annotation
    prokka \
        --outdir "${ANNOTATION_DIR}/${base}" \
        --prefix "${base}" \
        "${fasta_file}"

    echo "Annotation for ${base} completed."
done
