# Quick Start Guide

Get your pangenome analysis running in 10 minutes!

## Prerequisites Checklist

- [ ] Bash shell
- [ ] Prokka installed
- [ ] Roary installed
- [ ] Python 3.8+ with matplotlib, seaborn, pandas, numpy, biopython
- [ ] Internet connection (for genome downloads)

## Step-by-Step Setup

### 1. Clone and Setup (2 minutes)

```bash
# Clone repository
git clone https://github.com/yourusername/pangenome-analysis-pipeline.git
cd pangenome-analysis-pipeline

# Make scripts executable
chmod +x *.sh
```

### 2. Install Dependencies (5 minutes)

```bash
# Create conda environment
conda create -n pangenome python=3.8 perl=5.32.1
conda activate pangenome

# Install bioinformatics tools
conda install -c conda-forge -c bioconda prokka roary

# Install Python packages
pip install matplotlib seaborn pandas numpy biopython
```

### 3. Prepare Your Accession List (2 minutes)

Create `data/accession_list.csv`:

```csv
Genome ID,Genome Name
511145.12,Escherichia coli K12
585056.4,Escherichia coli UMN026
362663.7,Escherichia coli 536
```

**Where to get genome IDs:**
1. Go to [PATRIC](https://www.patricbrc.org/)
2. Search for your species
3. Find "Genome ID" in the results
4. Copy Genome ID and Name to your CSV

### 4. Run Analysis (1 minute to start)

```bash
# Option A: Run all steps automatically
./run_all.sh

# Option B: Run step-by-step
./01_download_genomes.sh
./02_annotate_genomes.sh
./03_run_roary.sh
./04_visualize_pangenome.sh
```

## Expected Timeline

| Step | Time (10 genomes) | Output |
|------|------------------|---------|
| 1. Download | 2-5 min | FASTA files |
| 2. Annotation | 30-60 min | GFF files |
| 3. Roary | 30-60 min | Pangenome matrix |
| 4. Visualization | 1-2 min | Plots |

*Times scale with genome count and system resources*

## Verify Success

After completion, check:

```bash
# View results
ls results/roary/
ls results/plots/

# Open plots
open results/plots/pangenome_matrix.png
```

You should see:
- ✓ Gene presence/absence matrix
- ✓ Pangenome frequency histogram
- ✓ Phylogenetic tree

## Example with Test Data

Use the included example:

```bash
# Copy example to active data
cp data/accession_list_example.csv data/accession_list.csv

# Run pipeline
./run_all.sh
```

This will download and analyze 5 *E. coli* genomes (takes ~1-2 hours total).

## Common First-Time Issues

### Issue: "Prokka not found"
```bash
# Solution:
conda install -c conda-forge -c bioconda prokka
prokka --version  # Verify
```

### Issue: "Roary not found"
```bash
# Solution:
conda create -n roary python=3.8 perl=5.32.1
conda activate roary
conda install -c conda-forge -c bioconda roary
```

### Issue: "Python module not found"
```bash
# Solution:
pip install matplotlib seaborn pandas numpy biopython
```

### Issue: "No genomes downloaded"
```bash
# Check internet connection
ping www.patricbrc.org

# Verify CSV format
head data/accession_list.csv

# Check genome IDs are correct on PATRIC website
```

## Customization

### Download More/Fewer Genomes

Edit `data/accession_list.csv` - add or remove rows.

### Use Faster Settings

Edit `03_run_roary.sh`:
```bash
CPUS=8  # Use more CPUs
```

### Change Plot Format

Edit `04_visualize_pangenome.sh`:
```bash
FORMAT="pdf"  # For publication
```

## Understanding Results

### Key Files

```
results/
├── roary/
│   ├── gene_presence_absence.csv     ← Main results
│   └── accessory_binary_genes.fa.newick  ← Tree
└── plots/
    ├── pangenome_frequency.png       ← Gene distribution
    └── pangenome_matrix.png          ← Visual pangenome
```

### Interpreting Pangenome

Open `results/roary/summary_statistics.txt`:

```
Core genes (100%): 3,500   ← In ALL genomes
Soft core (95-99%): 400    ← In most genomes
Shell (15-95%): 2,000      ← In some genomes
Cloud (<15%): 2,500        ← Rare genes
```

**What this means:**
- Large core = conserved species
- Large cloud = diverse strains
- Shell genes = niche adaptations

## Get Help

- 📖 Full guide: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/pangenome-analysis-pipeline/issues)
- 📧 Email: your.email@example.com

## Success!

If you see this at the end:

```
╔══════════════════════════════════════════════════════════════════╗
║     PANGENOME ANALYSIS COMPLETED SUCCESSFULLY!                   ║
╚══════════════════════════════════════════════════════════════════╝

Total execution time: 1h 23m 45s
```

🎉 **Congratulations! Your pangenome analysis is complete!**

Next steps:
1. Open plots to visualize your pangenome
2. Analyze core vs. accessory genes
3. Use results for publication

---

**Need more help?** See the full [README.md](README.md) for detailed documentation!
