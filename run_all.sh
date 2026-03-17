#!/bin/bash
################################################################################
# MASTER RUN SCRIPT
# Executes the complete pangenome analysis pipeline
################################################################################

set -e  # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║            BACTERIAL PANGENOME ANALYSIS - MASTER PIPELINE                ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Function to run a step
run_step() {
    local step_num=$1
    local step_name=$2
    local script=$3
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}STEP $step_num: $step_name${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ ! -f "$script" ]; then
        echo -e "${RED}Error: Script not found: $script${NC}"
        exit 1
    fi
    
    if ! bash "$script"; then
        echo ""
        echo -e "${RED}✗ Step $step_num failed!${NC}"
        echo "Check the error messages above for details"
        echo ""
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}✓ Step $step_num completed successfully${NC}"
}

# Check if scripts exist and make executable
for script in 01_download_genomes.sh 02_annotate_genomes.sh 03_run_roary.sh 04_visualize_pangenome.sh; do
    if [ ! -f "$script" ]; then
        echo -e "${RED}Error: Required script not found: $script${NC}"
        exit 1
    fi
    if [ ! -x "$script" ]; then
        echo -e "${YELLOW}Making $script executable...${NC}"
        chmod +x "$script"
    fi
done

# Check for accession list
if [ ! -f "data/accession_list.csv" ]; then
    echo -e "${RED}Error: Accession list not found: data/accession_list.csv${NC}"
    echo ""
    echo "Please create a CSV file with the following format:"
    echo "  Genome ID,Genome Name"
    echo "  12345.67,Escherichia coli strain ABC"
    echo "  12345.68,Escherichia coli strain XYZ"
    echo ""
    exit 1
fi

# Record start time
start_time=$(date +%s)

# Run pipeline
run_step 1 "Download Genomes from PATRIC" "./01_download_genomes.sh"
run_step 2 "Annotate Genomes with Prokka" "./02_annotate_genomes.sh"
run_step 3 "Run Roary Pangenome Analysis" "./03_run_roary.sh"
run_step 4 "Generate Visualizations" "./04_visualize_pangenome.sh"

# Calculate elapsed time
end_time=$(date +%s)
elapsed=$((end_time - start_time))
hours=$((elapsed / 3600))
minutes=$(( (elapsed % 3600) / 60 ))
seconds=$((elapsed % 60))

# Final summary
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo -e "║${GREEN}                 PANGENOME ANALYSIS COMPLETED SUCCESSFULLY!               ${NC}║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total execution time: ${hours}h ${minutes}m ${seconds}s"
echo ""
echo "Results are available in:"
echo "  📁 genomes/downloaded/    - Downloaded genome assemblies"
echo "  📁 genomes/annotations/   - Prokka annotations"
echo "  📁 results/roary/         - Roary pangenome analysis"
echo "  📁 results/plots/         - Visualization plots"
echo ""
echo "Key output files:"
echo "  📊 results/roary/gene_presence_absence.csv"
echo "  🌳 results/roary/accessory_binary_genes.fa.newick"
echo "  📈 results/plots/pangenome_frequency.png"
echo "  🔲 results/plots/pangenome_matrix.png"
echo ""
echo "Next steps:"
echo "  1. Open plots in results/plots/"
echo "  2. Analyze gene_presence_absence.csv"
echo "  3. Use core gene alignment for phylogenetic analysis"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
