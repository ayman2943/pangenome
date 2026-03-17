#!/bin/bash
################################################################################
# STEP 3: ROARY PANGENOME ANALYSIS
# Performs pangenome analysis using Roary
################################################################################

set -e  # Exit on error

# Configuration
GFF_DIR="./genomes/annotations"
OUTPUT_DIR="./results/roary"
CPUS=4  # Number of CPU cores to use

# Roary parameters
IDENTITY=95         # Minimum percentage identity for BLAST (default: 95)
EVALUE="1e-5"      # E-value for BLAST (default: 1e-5)
SPLIT_PARA="off"   # Split paralogs (default: off)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================================================"
echo "STEP 3: Roary Pangenome Analysis"
echo "================================================================================"
echo ""

# Check if Roary is installed
if ! command -v roary &> /dev/null; then
    echo -e "${RED}Error: Roary is not installed or not in PATH${NC}"
    echo ""
    echo "To install Roary:"
    echo "  conda create -n roary python=3.8 perl=5.32.1"
    echo "  conda activate roary"
    echo "  conda install -c conda-forge -c bioconda roary"
    echo ""
    echo "Or visit: https://sanger-pathogens.github.io/Roary/"
    exit 1
fi

# Check if GFF directory exists
if [ ! -d "$GFF_DIR" ]; then
    echo -e "${RED}Error: GFF directory not found: $GFF_DIR${NC}"
    echo "Please run './02_annotate_genomes.sh' first"
    exit 1
fi

# Count GFF files
gff_count=$(find "$GFF_DIR" -name "*.gff" | wc -l)

if [ "$gff_count" -eq 0 ]; then
    echo -e "${RED}Error: No GFF files found in $GFF_DIR${NC}"
    echo "Please ensure genome annotations completed successfully"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Configuration:${NC}"
echo "  GFF directory: $GFF_DIR"
echo "  Output directory: $OUTPUT_DIR"
echo "  Total genomes: $gff_count"
echo "  CPUs: $CPUS"
echo "  Identity threshold: $IDENTITY%"
echo "  E-value: $EVALUE"
echo "  Roary version: $(roary --version 2>&1 || echo 'Unknown')"
echo ""

if [ "$gff_count" -lt 3 ]; then
    echo -e "${YELLOW}Warning: Less than 3 genomes detected.${NC}"
    echo "Pangenome analysis works best with at least 3 genomes."
    echo ""
fi

echo -e "${YELLOW}Starting Roary analysis...${NC}"
echo "This may take several minutes to hours depending on the number of genomes."
echo ""

# Run Roary
# -e: Create a multiFASTA alignment of core genes using PRANK
# -n: Fast core gene alignment with MAFFT
# -v: Verbose output
# -p: Number of threads
# -f: Output directory
# -i: Minimum percentage identity for BLASTp
# -e: E-value cutoff for BLAST

roary_output=$(roary \
    -e \
    -n \
    -v \
    -p "$CPUS" \
    -i "$IDENTITY" \
    -cd "$EVALUE" \
    -s "$SPLIT_PARA" \
    -f "$OUTPUT_DIR" \
    "$GFF_DIR"/*/*.gff 2>&1)

echo "$roary_output"

# Check if Roary completed successfully
if [ -f "$OUTPUT_DIR/gene_presence_absence.csv" ]; then
    echo ""
    echo -e "${GREEN}✓ Roary analysis completed successfully${NC}"
    echo ""
    
    # Parse results
    total_genes=$(tail -n +2 "$OUTPUT_DIR/gene_presence_absence.csv" | wc -l)
    core_genes=$(awk -F',' 'NR>1 && $3 == '$gff_count' {count++} END {print count+0}' "$OUTPUT_DIR/gene_presence_absence.csv")
    soft_core=$(awk -F',' 'NR>1 && $3 >= '$gff_count'*0.95 && $3 < '$gff_count' {count++} END {print count+0}' "$OUTPUT_DIR/gene_presence_absence.csv")
    shell=$(awk -F',' 'NR>1 && $3 > '$gff_count'*0.15 && $3 < '$gff_count'*0.95 {count++} END {print count+0}' "$OUTPUT_DIR/gene_presence_absence.csv")
    cloud=$(awk -F',' 'NR>1 && $3 <= '$gff_count'*0.15 {count++} END {print count+0}' "$OUTPUT_DIR/gene_presence_absence.csv")
    
    echo "Pangenome Summary:"
    echo "  Total gene clusters: $total_genes"
    echo "  Core genes (100%): $core_genes"
    echo "  Soft core (95-99%): $soft_core"
    echo "  Shell (15-95%): $shell"
    echo "  Cloud (<15%): $cloud"
    echo ""
    
    echo "Output files:"
    echo "  gene_presence_absence.csv    - Main results table"
    echo "  summary_statistics.txt       - Statistics summary"
    echo "  core_gene_alignment.aln      - Core gene alignment"
    echo "  accessory_binary_genes.fa.newick - Phylogenetic tree"
    echo "  pan_genome_reference.fa      - Pan-genome sequences"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Roary analysis failed${NC}"
    echo "Check the error messages above"
    exit 1
fi

echo "Next step: Run './04_visualize_pangenome.sh' to create visualizations"
echo "================================================================================"
