#!/bin/bash
################################################################################
# STEP 4: VISUALIZE PANGENOME RESULTS
# Creates publication-quality plots from Roary outputs
################################################################################

set -e  # Exit on error

# Configuration
ROARY_DIR="./results/roary"
OUTPUT_DIR="./results/plots"
PLOT_SCRIPT="./scripts/roary_plots.py"

# Input files
TREE_FILE="$ROARY_DIR/accessory_binary_genes.fa.newick"
MATRIX_FILE="$ROARY_DIR/gene_presence_absence.csv"

# Plot parameters
FORMAT="png"        # Options: png, pdf, svg, tiff
LABELS="true"       # Show labels on tree: true/false
SPECIAL_GENOME=""   # Optional: highlight a specific genome (e.g., "Reference_strain")

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================================================"
echo "STEP 4: Pangenome Visualization"
echo "================================================================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}Error: Python is not installed${NC}"
    exit 1
fi

PYTHON_CMD=$(command -v python3 || command -v python)

# Check required Python packages
echo "Checking Python dependencies..."
for package in matplotlib seaborn pandas numpy biopython; do
    if ! $PYTHON_CMD -c "import ${package}" 2>/dev/null; then
        echo -e "${RED}Error: Python package '$package' is not installed${NC}"
        echo ""
        echo "Install required packages:"
        echo "  pip install matplotlib seaborn pandas numpy biopython"
        echo ""
        echo "Or using conda:"
        echo "  conda install matplotlib seaborn pandas numpy biopython"
        exit 1
    fi
done
echo -e "${GREEN}✓ All Python dependencies found${NC}"
echo ""

# Check if Roary results exist
if [ ! -f "$TREE_FILE" ]; then
    echo -e "${RED}Error: Tree file not found: $TREE_FILE${NC}"
    echo "Please run './03_run_roary.sh' first"
    exit 1
fi

if [ ! -f "$MATRIX_FILE" ]; then
    echo -e "${RED}Error: Gene matrix not found: $MATRIX_FILE${NC}"
    echo "Please run './03_run_roary.sh' first"
    exit 1
fi

# Check if plot script exists
if [ ! -f "$PLOT_SCRIPT" ]; then
    echo -e "${RED}Error: Plot script not found: $PLOT_SCRIPT${NC}"
    echo "Expected location: $PLOT_SCRIPT"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Configuration:${NC}"
echo "  Roary directory: $ROARY_DIR"
echo "  Output directory: $OUTPUT_DIR"
echo "  Tree file: $(basename "$TREE_FILE")"
echo "  Matrix file: $(basename "$MATRIX_FILE")"
echo "  Output format: $FORMAT"
echo "  Show labels: $LABELS"
if [ -n "$SPECIAL_GENOME" ]; then
    echo "  Highlighted genome: $SPECIAL_GENOME"
fi
echo ""

echo -e "${YELLOW}Generating plots...${NC}"
echo ""

# Change to output directory
cd "$OUTPUT_DIR"

# Build command
CMD="$PYTHON_CMD ../../$PLOT_SCRIPT ../../$TREE_FILE ../../$MATRIX_FILE --format $FORMAT"

if [ "$LABELS" = "true" ]; then
    CMD="$CMD --labels"
fi

if [ -n "$SPECIAL_GENOME" ]; then
    CMD="$CMD --special_genome '$SPECIAL_GENOME'"
fi

# Run plotting script
echo "Running: roary_plots.py"
if eval $CMD; then
    echo ""
    echo -e "${GREEN}✓ Plots generated successfully${NC}"
    echo ""
    
    # List generated files
    echo "Generated files:"
    for file in pangenome_frequency.$FORMAT pangenome_matrix.$FORMAT; do
        if [ -f "$file" ]; then
            file_size=$(du -h "$file" | cut -f1)
            echo "  ✓ $file ($file_size)"
        fi
    done
else
    echo ""
    echo -e "${RED}✗ Plot generation failed${NC}"
    exit 1
fi

cd - > /dev/null

echo ""
echo "Plot descriptions:"
echo "  pangenome_frequency.$FORMAT  - Histogram of gene frequency"
echo "  pangenome_matrix.$FORMAT     - Presence/absence matrix with phylogeny"
echo ""
echo "Output location: $OUTPUT_DIR/"
echo ""
echo "================================================================================"
echo -e "${GREEN}PANGENOME ANALYSIS COMPLETE!${NC}"
echo "================================================================================"
echo ""
echo "All results are available in:"
echo "  - Roary results: $ROARY_DIR/"
echo "  - Visualizations: $OUTPUT_DIR/"
echo ""
echo "Key files:"
echo "  📊 gene_presence_absence.csv - Main pangenome matrix"
echo "  🌳 accessory_binary_genes.fa.newick - Phylogenetic tree"
echo "  📈 pangenome_frequency.$FORMAT - Gene distribution plot"
echo "  🔲 pangenome_matrix.$FORMAT - Visual pangenome matrix"
echo ""
echo "================================================================================"
