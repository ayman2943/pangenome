# Bacterial Pangenome Analysis Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)

Automated pipeline for bacterial pangenome analysis from genome download through visualization. Integrates PATRIC database access, Prokka annotation, Roary pangenome analysis, and custom visualization tools.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Detailed Usage](#detailed-usage)
- [Directory Structure](#directory-structure)
- [Output Files](#output-files)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Citation](#citation)
- [License](#license)

## 🔬 Overview

This pipeline automates the complete workflow for bacterial pangenome analysis:

1. **Genome Download** - Fetch genomes from PATRIC database via accession list
2. **Annotation** - Annotate genomes with Prokka
3. **Pangenome Analysis** - Identify core and accessory genes with Roary
4. **Visualization** - Generate publication-quality plots

Perfect for comparative genomics studies of bacterial species.

## ✨ Features

- ✅ **Fully Automated** - 4 simple commands for complete analysis
- ✅ **PATRIC Integration** - Direct genome download from database
- ✅ **Batch Processing** - Handle hundreds of genomes
- ✅ **Error Recovery** - Skip completed steps, resume from failures
- ✅ **Publication Plots** - High-quality visualizations ready for papers
- ✅ **Customizable** - Adjust parameters for your specific needs
- ✅ **Progress Tracking** - Clear status updates and counters
- ✅ **Cross-Platform** - Works on Linux, macOS, and WSL

## 📦 Prerequisites

### Required Software

1. **Bash** (version 4.0+)
   - Linux/macOS: Built-in
   - Windows: WSL or Git Bash

2. **Prokka** (genome annotation)
   ```bash
   conda install -c conda-forge -c bioconda prokka
   ```

3. **Roary** (pangenome analysis)
   ```bash
   conda create -n roary python=3.8 perl=5.32.1
   conda activate roary
   conda install -c conda-forge -c bioconda roary
   ```

4. **Python 3.8+** with packages:
   ```bash
   pip install matplotlib seaborn pandas numpy biopython
   ```

5. **curl** (for downloads)
   - Usually pre-installed on most systems

### Input Requirements

**Accession List CSV** - Create `data/accession_list.csv`:

```csv
Genome ID,Genome Name
1313.7001,Streptococcus pneumoniae strain ABC
1313.7002,Streptococcus pneumoniae strain XYZ
1313.7003,Streptococcus pneumoniae strain 123
```

- Column 1: PATRIC Genome ID
- Column 2: Descriptive genome name
- Get genome IDs from [PATRIC](https://www.patricbrc.org/)

## 🚀 Installation

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/pangenome-analysis-pipeline.git
cd pangenome-analysis-pipeline
```

### 2. Install Dependencies

```bash
# Create conda environment for Roary
conda create -n pangenome python=3.8 perl=5.32.1
conda activate pangenome

# Install tools
conda install -c conda-forge -c bioconda prokka roary

# Install Python packages
pip install matplotlib seaborn pandas numpy biopython
```

### 3. Make Scripts Executable

```bash
chmod +x *.sh
```

### 4. Prepare Accession List

Create `data/accession_list.csv` with your genome IDs (see format above).

## 🎯 Quick Start

Run the complete pipeline with 4 commands:

```bash
# Step 1: Download genomes from PATRIC
./01_download_genomes.sh

# Step 2: Annotate genomes with Prokka
./02_annotate_genomes.sh

# Step 3: Run Roary pangenome analysis
./03_run_roary.sh

# Step 4: Generate visualizations
./04_visualize_pangenome.sh
```

Or run all at once:

```bash
./run_all.sh
```

Results will be in `results/` directory!

## 📖 Detailed Usage

### Step 1: Download Genomes

**What it does:** Downloads genome assemblies from PATRIC database using your accession list.

```bash
./01_download_genomes.sh
```

**Input:**
- `data/accession_list.csv` - List of genome IDs and names

**Output:**
- `genomes/downloaded/*.fasta` - Downloaded genome assemblies

**Example output:**
```
================================================================================
STEP 1: Downloading Genomes from PATRIC Database
================================================================================

Configuration:
  Input file: ./data/accession_list.csv
  Output directory: ./genomes/downloaded
  Total genomes to download: 25

[1/25] Processing: Escherichia coli strain K12
  Genome ID: 511145.12
  Downloading...
  ✓ Downloaded successfully (4.6M)

[2/25] Processing: Escherichia coli strain O157:H7
  Genome ID: 155864.11
  Downloading...
  ✓ Downloaded successfully (5.2M)

...

Summary:
  Total genomes: 25
  Downloaded: 25
  Skipped (already exist): 0
  Failed: 0
```

**Notes:**
- Downloads are skipped if files already exist
- Failed downloads are reported (check genome IDs)
- Genome names are sanitized for filesystem compatibility

---

### Step 2: Annotate Genomes

**What it does:** Annotates all downloaded genomes using Prokka to identify genes, proteins, and features.

```bash
./02_annotate_genomes.sh
```

**Input:**
- `genomes/downloaded/*.fasta` - Genome assemblies

**Output:**
- `genomes/annotations/<genome>/*.gff` - Gene annotations (required for Roary)
- `genomes/annotations/<genome>/*.faa` - Protein sequences
- `genomes/annotations/<genome>/*.ffn` - Gene sequences
- `genomes/annotations/<genome>/*.gbk` - GenBank format files

**Parameters to adjust:**
```bash
CPUS=4  # Number of CPUs per annotation job
```

**Example output:**
```
================================================================================
STEP 2: Genome Annotation with Prokka
================================================================================

Configuration:
  Total genomes to annotate: 25
  CPUs per job: 4
  Prokka version: 1.14.6

═══════════════════════════════════════════════════════════
[1/25] Annotating: Escherichia_coli_K12
═══════════════════════════════════════════════════════════
Running Prokka...
✓ Annotation completed successfully
  Genes annotated: 4,321

...

Summary:
  Total genomes: 25
  Annotated: 25
  Skipped (already done): 0
  Failed: 0
```

**Runtime:** ~5-15 minutes per genome (depends on genome size and CPUs)

---

### Step 3: Run Roary Pangenome Analysis

**What it does:** Identifies core genes (present in all genomes) and accessory genes (variable presence).

```bash
./03_run_roary.sh
```

**Input:**
- `genomes/annotations/*/*.gff` - Gene annotations

**Output:**
- `results/roary/gene_presence_absence.csv` - Main pangenome matrix
- `results/roary/accessory_binary_genes.fa.newick` - Phylogenetic tree
- `results/roary/core_gene_alignment.aln` - Core gene alignment
- `results/roary/summary_statistics.txt` - Statistics

**Parameters to adjust:**
```bash
CPUS=4          # Number of CPU cores
IDENTITY=95     # Minimum identity for clustering (%)
EVALUE="1e-5"   # E-value threshold for BLAST
```

**Example output:**
```
================================================================================
STEP 3: Roary Pangenome Analysis
================================================================================

Configuration:
  Total genomes: 25
  CPUs: 4
  Identity threshold: 95%

Starting Roary analysis...

✓ Roary analysis completed successfully

Pangenome Summary:
  Total gene clusters: 8,542
  Core genes (100%): 3,245
  Soft core (95-99%): 421
  Shell (15-95%): 2,156
  Cloud (<15%): 2,720

Output files:
  gene_presence_absence.csv    - Main results table
  summary_statistics.txt       - Statistics summary
  core_gene_alignment.aln      - Core gene alignment
  accessory_binary_genes.fa.newick - Phylogenetic tree
```

**Runtime:** 30 minutes to several hours (depends on genome count)

---

### Step 4: Visualize Pangenome

**What it does:** Creates publication-quality plots from Roary results.

```bash
./04_visualize_pangenome.sh
```

**Input:**
- `results/roary/gene_presence_absence.csv` - Pangenome matrix
- `results/roary/accessory_binary_genes.fa.newick` - Tree

**Output:**
- `results/plots/pangenome_frequency.png` - Gene frequency distribution
- `results/plots/pangenome_matrix.png` - Presence/absence heatmap with tree

**Parameters to adjust:**
```bash
FORMAT="png"              # Options: png, pdf, svg, tiff
LABELS="true"            # Show genome labels on tree
SPECIAL_GENOME="Ref123"  # Highlight a specific genome (optional)
```

**Example output:**
```
================================================================================
STEP 4: Pangenome Visualization
================================================================================

✓ All Python dependencies found

Generating plots...

✓ Plots generated successfully

Generated files:
  ✓ pangenome_frequency.png (245K)
  ✓ pangenome_matrix.png (1.8M)

Plot descriptions:
  pangenome_frequency.png  - Histogram of gene frequency
  pangenome_matrix.png     - Presence/absence matrix with phylogeny
```

**Runtime:** 1-5 minutes

---

## 📁 Directory Structure

```
pangenome-analysis-pipeline/
├── 01_download_genomes.sh        # Step 1: Download from PATRIC
├── 02_annotate_genomes.sh        # Step 2: Prokka annotation
├── 03_run_roary.sh               # Step 3: Roary analysis
├── 04_visualize_pangenome.sh     # Step 4: Create plots
├── run_all.sh                     # Master script (all steps)
├── README.md                      # This file
├── LICENSE                        # MIT License
├── QUICKSTART.md                  # Quick setup guide
├── .gitignore                     # Git ignore rules
├── scripts/                       # Analysis scripts
│   └── roary_plots.py            # Visualization script
├── data/                          # Input data
│   └── accession_list.csv        # Genome accession list
├── genomes/                       # Genome data
│   ├── downloaded/               # Downloaded FASTA files
│   └── annotations/              # Prokka outputs
└── results/                       # Analysis results
    ├── roary/                    # Roary outputs
    │   ├── gene_presence_absence.csv
    │   ├── accessory_binary_genes.fa.newick
    │   ├── core_gene_alignment.aln
    │   └── summary_statistics.txt
    └── plots/                    # Visualizations
        ├── pangenome_frequency.png
        └── pangenome_matrix.png
```

## 📊 Output Files

### Main Results

| File | Description |
|------|-------------|
| `gene_presence_absence.csv` | Binary matrix of gene presence/absence |
| `accessory_binary_genes.fa.newick` | Phylogenetic tree based on accessory genes |
| `summary_statistics.txt` | Pangenome statistics |
| `core_gene_alignment.aln` | Alignment of core genes |
| `pan_genome_reference.fa` | Representative sequences for all gene clusters |

### Visualizations

| File | Description |
|------|-------------|
| `pangenome_frequency.png` | Histogram showing gene frequency distribution |
| `pangenome_matrix.png` | Heatmap of gene presence/absence with phylogeny |

### Per-Genome Annotations

Each genome gets:
- `.gff` - Gene annotations (GFF3 format)
- `.faa` - Protein amino acid sequences
- `.ffn` - Gene nucleotide sequences
- `.gbk` - GenBank format annotation
- `.txt` - Annotation summary statistics

## ⚙️ Customization

### Adjust Roary Parameters

Edit `03_run_roary.sh`:

```bash
IDENTITY=95        # Identity threshold (90-100%)
EVALUE="1e-5"      # BLAST E-value
CPUS=8             # More CPUs for faster analysis
```

### Highlight Specific Genome

Edit `04_visualize_pangenome.sh`:

```bash
SPECIAL_GENOME="Reference_Strain"  # Will be bold, italic, and red
```

### Change Plot Format

Edit `04_visualize_pangenome.sh`:

```bash
FORMAT="pdf"       # For publication-quality vector graphics
# or
FORMAT="svg"       # For web/editing
```

### Prokka Annotation Options

Edit `02_annotate_genomes.sh`:

```bash
prokka \
    --kingdom Bacteria \
    --genus Streptococcus \
    --species pneumoniae \
    --strain K12 \
    ...
```

## 🔧 Troubleshooting

### Common Issues

**1. "Prokka not found"**

```bash
# Solution: Install Prokka
conda install -c conda-forge -c bioconda prokka

# Verify installation
prokka --version
```

**2. "Roary not found"**

```bash
# Solution: Create Roary environment
conda create -n roary python=3.8 perl=5.32.1
conda activate roary
conda install -c conda-forge -c bioconda roary
```

**3. "No genomes downloaded"**

- Check genome IDs in accession_list.csv
- Verify internet connection
- Check PATRIC database is accessible
- Ensure CSV format is correct (Genome ID,Genome Name)

**4. "Python module not found"**

```bash
# Solution: Install required packages
pip install matplotlib seaborn pandas numpy biopython
```

**5. "Roary failed - not enough genomes"**

- Roary requires at least 2 genomes (works best with 3+)
- Check that all annotations completed successfully
- Verify .gff files exist in annotations directory

**6. "Plot generation failed"**

- Ensure all Python packages are installed
- Check that Roary completed successfully
- Verify tree and matrix files exist
- Try running plot script manually for detailed errors

### Memory Issues

For large datasets (100+ genomes):

```bash
# Reduce memory usage in Roary
# Edit 03_run_roary.sh and remove -e flag (disables core alignment)

roary \
    -n \
    -v \
    -p $CPUS \
    -f "$OUTPUT_DIR" \
    "$GFF_DIR"/*/*.gff
```

## 📚 Understanding Results

### Pangenome Categories

- **Core genes (100%)**: Present in ALL genomes
  - Essential for species
  - Housekeeping functions

- **Soft core (95-99%)**: Present in most genomes
  - Nearly universal functions

- **Shell (15-95%)**: Present in some genomes
  - Niche adaptations

- **Cloud (<15%)**: Rare genes
  - Strain-specific
  - Recently acquired

### Interpreting Plots

**Pangenome Frequency Plot:**
- X-axis: Number of genomes containing the gene
- Y-axis: Number of genes
- Shows distribution of core vs. accessory genes

**Pangenome Matrix:**
- Rows: Gene clusters
- Columns: Genomes (ordered by phylogeny)
- Blue: Gene present
- White: Gene absent
- Tree shows evolutionary relationships

## 📖 Citation

If you use this pipeline in your research, please cite:

```bibtex
@software{pangenome_pipeline_2025,
  author = {Ayman Bin Abdul Mannan},
  title = {Bacterial Pangenome Analysis Pipeline},
  year = {2025},
  url = {https://github.com/ayman2943/pangenome-analysis-pipeline},
  version = {1.0.0}
}
```

And cite the tools used:

**Prokka:**
```bibtex
@article{seemann2014prokka,
  title={Prokka: rapid prokaryotic genome annotation},
  author={Seemann, Torsten},
  journal={Bioinformatics},
  volume={30},
  number={14},
  pages={2068--2069},
  year={2014}
}
```

**Roary:**
```bibtex
@article{page2015roary,
  title={Roary: rapid large-scale prokaryote pan genome analysis},
  author={Page, Andrew J and Cummins, Carla A and Hunt, Martin and Wong, Vanessa K and Reuter, Sandra and Holden, Matthew TG and Fookes, Maria and Falush, Daniel and Keane, Jacqueline A and Parkhill, Julian},
  journal={Bioinformatics},
  volume={31},
  number={22},
  pages={3691--3693},
  year={2015}
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



## 🙏 Acknowledgments

- PATRIC team for the bacterial genome database
- Torsten Seemann for Prokka
- Andrew Page et al. for Roary
- Marco Galardini for the original roary_plots.py

## 📞 Contact

- GitHub Issues: [https://github.com/yourusername/pangenome-analysis-pipeline/issues](https://github.com/yourusername/pangenome-analysis-pipeline/issues)
- Email: aymanbin2943@gmail.com

---

**Last Updated:** March 2025
