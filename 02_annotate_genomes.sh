#!/bin/bash
################################################################################
# STEP 2: ANNOTATE GENOMES WITH PROKKA
# Annotates bacterial genomes using Prokka
################################################################################

set -e  # Exit on error

# Configuration
INPUT_DIR="./genomes/downloaded"
OUTPUT_DIR="./genomes/annotations"
CPUS=4  # Number of CPUs to use per annotation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================================================"
echo "STEP 2: Genome Annotation with Prokka"
echo "================================================================================"
echo ""

# Check if Prokka is installed
if ! command -v prokka &> /dev/null; then
    echo -e "${RED}Error: Prokka is not installed or not in PATH${NC}"
    echo ""
    echo "To install Prokka:"
    echo "  conda install -c conda-forge -c bioconda prokka"
    echo ""
    echo "Or visit: https://github.com/tseemann/prokka"
    exit 1
fi

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo -e "${RED}Error: Input directory not found: $INPUT_DIR${NC}"
    echo "Please run './01_download_genomes.sh' first"
    exit 1
fi

# Count FASTA files
fasta_count=$(find "$INPUT_DIR" -name "*.fasta" -o -name "*.fa" -o -name "*.fna" | wc -l)

if [ "$fasta_count" -eq 0 ]; then
    echo -e "${RED}Error: No FASTA files found in $INPUT_DIR${NC}"
    echo "Please ensure genomes were downloaded successfully"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Configuration:${NC}"
echo "  Input directory: $INPUT_DIR"
echo "  Output directory: $OUTPUT_DIR"
echo "  Total genomes to annotate: $fasta_count"
echo "  CPUs per job: $CPUS"
echo "  Prokka version: $(prokka --version 2>&1 | head -n 1)"
echo ""

# Counters
count=0
annotated=0
skipped=0
failed=0

echo -e "${YELLOW}Starting annotations...${NC}"
echo ""

# Process each FASTA file
for fasta_file in "$INPUT_DIR"/*.{fasta,fa,fna} 2>/dev/null; do
    # Skip if glob didn't match
    [ -e "$fasta_file" ] || continue
    
    count=$((count + 1))
    
    # Get base name without extension
    base=$(basename "$fasta_file")
    base="${base%.fasta}"
    base="${base%.fa}"
    base="${base%.fna}"
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[$count/$fasta_count] Annotating: $base${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    # Check if already annotated (check for .gff file)
    if [ -f "${OUTPUT_DIR}/${base}/${base}.gff" ]; then
        echo -e "${YELLOW}⊙ Already annotated. Skipping.${NC}"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    # Run Prokka annotation
    echo "Running Prokka..."
    
    if prokka \
        --outdir "${OUTPUT_DIR}/${base}" \
        --prefix "${base}" \
        --cpus "$CPUS" \
        --quiet \
        "${fasta_file}"; then
        
        # Check if GFF was created
        if [ -f "${OUTPUT_DIR}/${base}/${base}.gff" ]; then
            echo -e "${GREEN}✓ Annotation completed successfully${NC}"
            annotated=$((annotated + 1))
            
            # Show summary
            gene_count=$(grep -c "CDS" "${OUTPUT_DIR}/${base}/${base}.gff" || echo "0")
            echo "  Genes annotated: $gene_count"
        else
            echo -e "${RED}✗ Annotation failed (no GFF file created)${NC}"
            failed=$((failed + 1))
        fi
    else
        echo -e "${RED}✗ Prokka failed${NC}"
        failed=$((failed + 1))
    fi
    
    echo ""
done

# Summary
echo "================================================================================"
echo -e "${GREEN}Annotation Complete${NC}"
echo "================================================================================"
echo ""
echo "Summary:"
echo "  Total genomes: $fasta_count"
echo -e "  ${GREEN}Annotated: $annotated${NC}"
echo -e "  ${YELLOW}Skipped (already done): $skipped${NC}"
if [ "$failed" -gt 0 ]; then
    echo -e "  ${RED}Failed: $failed${NC}"
fi
echo ""
echo "Output location: $OUTPUT_DIR/"
echo ""
echo "Key output files per genome:"
echo "  - .gff    : Gene annotations (required for Roary)"
echo "  - .faa    : Protein sequences"
echo "  - .ffn    : Gene sequences"
echo "  - .gbk    : GenBank format"
echo "  - .txt    : Annotation statistics"
echo ""

if [ "$failed" -gt 0 ]; then
    echo -e "${YELLOW}Note: Some annotations failed. Check the logs above.${NC}"
    echo ""
fi

echo "Next step: Run './03_run_roary.sh' to perform pangenome analysis"
echo "================================================================================"
