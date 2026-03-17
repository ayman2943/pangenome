#!/bin/bash
################################################################################
# STEP 1: DOWNLOAD GENOMES FROM PATRIC
# Downloads bacterial genomes from PATRIC database using accession list
################################################################################

set -e  # Exit on error

# Configuration
INPUT_FILE="./data/accession_list.csv"
OUTPUT_DIR="./genomes/downloaded"
TEMP_FILE="./data/genome_data.tmp"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================================================"
echo "STEP 1: Downloading Genomes from PATRIC Database"
echo "================================================================================"
echo ""

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Accession list not found: $INPUT_FILE${NC}"
    echo ""
    echo "Please create an accession list CSV file with the following format:"
    echo "  Genome ID,Genome Name"
    echo "  12345.67,Escherichia coli strain ABC"
    echo "  12345.68,Escherichia coli strain XYZ"
    echo ""
    echo "Expected location: $INPUT_FILE"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$TEMP_FILE")"

# Count total genomes
total_genomes=$(awk -F',' 'NR>1 {print}' "$INPUT_FILE" | wc -l)

echo -e "${GREEN}Configuration:${NC}"
echo "  Input file: $INPUT_FILE"
echo "  Output directory: $OUTPUT_DIR"
echo "  Total genomes to download: $total_genomes"
echo ""

if [ "$total_genomes" -eq 0 ]; then
    echo -e "${RED}Error: No genomes found in accession list${NC}"
    echo "Make sure your CSV has at least one data row (plus header)"
    exit 1
fi

# Extract Genome ID and Genome Name columns (skip header)
awk -F',' 'NR>1 {print $1 "," $2}' "$INPUT_FILE" > "$TEMP_FILE"

# Function to sanitize genome name for filesystem
sanitize_name() {
    echo "$1" | sed -e 's/[ :()/-]/_/g' -e 's/__*/_/g' -e 's/_$//'
}

# Counters
count=0
downloaded=0
skipped=0
failed=0

echo -e "${YELLOW}Starting downloads...${NC}"
echo ""

# Process each genome
while IFS=',' read -r genome_id genome_name; do
    count=$((count + 1))
    
    echo "[$count/$total_genomes] Processing: $genome_name"
    echo "  Genome ID: $genome_id"
    
    # Sanitize name for filename
    sanitized_name=$(sanitize_name "$genome_name")
    output_file="${OUTPUT_DIR}/${sanitized_name}.fasta"
    
    # Check if already downloaded
    if [ -f "$output_file" ]; then
        echo -e "  ${YELLOW}⊙ Already exists. Skipping.${NC}"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi

    # Download FASTA from PATRIC
    echo "  Downloading..."
    if curl -s -H "accept: application/dna+fasta" -o "$output_file" \
        "https://www.patricbrc.org/api/genome_sequence/?eq(genome_id,${genome_id})&http_accept=application/dna+fasta"; then
        
        # Check if download was successful (file not empty)
        if [ -s "$output_file" ]; then
            file_size=$(du -h "$output_file" | cut -f1)
            echo -e "  ${GREEN}✓ Downloaded successfully (${file_size})${NC}"
            downloaded=$((downloaded + 1))
        else
            echo -e "  ${RED}✗ Download failed (empty file)${NC}"
            rm -f "$output_file"
            failed=$((failed + 1))
        fi
    else
        echo -e "  ${RED}✗ Download failed (connection error)${NC}"
        rm -f "$output_file"
        failed=$((failed + 1))
    fi
    
    echo ""
done < "$TEMP_FILE"

# Cleanup
rm -f "$TEMP_FILE"

# Summary
echo "================================================================================"
echo -e "${GREEN}Download Complete${NC}"
echo "================================================================================"
echo ""
echo "Summary:"
echo "  Total genomes: $total_genomes"
echo -e "  ${GREEN}Downloaded: $downloaded${NC}"
echo -e "  ${YELLOW}Skipped (already exist): $skipped${NC}"
if [ "$failed" -gt 0 ]; then
    echo -e "  ${RED}Failed: $failed${NC}"
fi
echo ""
echo "Output location: $OUTPUT_DIR/"
echo ""

if [ "$failed" -gt 0 ]; then
    echo -e "${YELLOW}Note: Some downloads failed. Check the genome IDs in your accession list.${NC}"
    echo ""
fi

echo "Next step: Run './02_annotate_genomes.sh' to annotate downloaded genomes"
echo "================================================================================"
