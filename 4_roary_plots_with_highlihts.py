#!/usr/bin/env python


# change ax1 and uts colspan



__author__ = "Marco Galardini"
__version__ = '0.1.0'

def get_options():
    import argparse

    description = "Create plots from roary outputs"
    parser = argparse.ArgumentParser(description=description, prog='roary_plots.py')

    parser.add_argument('tree', action='store',
                        help='Newick Tree file', default='accessory_binary_genes.fa.newick')
    parser.add_argument('spreadsheet', action='store',
                        help='Roary gene presence/absence spreadsheet', default='gene_presence_absence.csv')

    parser.add_argument('--labels', action='store_true',
                        default=False,
                        help='Add node labels to the tree (up to 10 chars)')
    parser.add_argument('--format',
                        choices=('png', 'tiff', 'pdf', 'svg'),
                        default='png',
                        help='Output format [Default: png]')
    parser.add_argument('-N', '--skipped_columns', action='store',
                        type=int,
                        default=14,
                        help='First N columns of Roary\'s output to exclude [Default: 14]')
    parser.add_argument('--special_genome', action='store',
                        help='Genome name to be both italic and bold')

    parser.add_argument('--version', action='version',
                        version='%(prog)s ' + __version__)

    return parser.parse_args()


if __name__ == "__main__":
    options = get_options()

    import matplotlib
    matplotlib.use('Agg')  # Use Agg backend for non-interactive plotting

    import matplotlib.pyplot as plt
    import seaborn as sns
    sns.set_style('white')

    import os
    import pandas as pd
    import numpy as np
    from Bio import Phylo

    # Disable LaTeX rendering
    matplotlib.rcParams['text.usetex'] = False

    t = Phylo.read(options.tree, 'newick')

    # Debugging: Print out the terminal names
    print("Terminal names in the tree:")
    for term in t.get_terminals():
        print(term.name)

    # Max distance to create better plots
    mdist = max([t.distance(t.root, x) for x in t.get_terminals()])

    # Load roary
    roary = pd.read_csv(options.spreadsheet, low_memory=False)
    # Set index (group name)
    roary.set_index('Gene', inplace=True)
    # Drop the other info columns
    roary.drop(list(roary.columns[:options.skipped_columns - 1]), axis=1, inplace=True)

    # Replace ".{2,100}" with 1 and NaN with 0
    roary.replace('.{2,100}', 1, regex=True, inplace=True)
    roary.replace(np.nan, 0, regex=True, inplace=True)

    # Sort the matrix by the sum of strains presence
    idx = roary.sum(axis=1).sort_values(ascending=False).index
    roary_sorted = roary.loc[idx]

    # Pangenome frequency plot
    plt.figure(figsize=(7, 5))
    plt.hist(roary.sum(axis=1), roary.shape[1],
             histtype="stepfilled", alpha=.7)
    plt.xlabel('No. of genomes')
    plt.ylabel('No. of genes')
    sns.despine(left=True, bottom=True)
    plt.savefig('pangenome_frequency.%s' % options.format, dpi=300)
    plt.clf()

    # Debugging: Print column names in roary_sorted for debugging
    print("Column names in roary_sorted:")
    print(roary_sorted.columns)

    # Sort the matrix according to tip labels in the tree
    terminal_names = [x.name for x in t.get_terminals()]
    print("Terminal names from t.get_terminals():")
    print(terminal_names)

    # Ensure matching of terminal names to avoid missing strains
    terminal_names = [x for x in terminal_names if x in roary_sorted.columns]

    # Sort the matrix accordingly
    roary_sorted = roary_sorted[terminal_names]

    # Plot presence/absence matrix against the tree
    with sns.axes_style('whitegrid'):
        fig = plt.figure(figsize=(24, 12))  # Increased figure width for more space

        # Adjusted positions for the tree (left) and matrix (right)
        ax1 = plt.subplot2grid((1, 100), (0, 30),
                               colspan=70)  # Matrix starts further to the right (30) and takes 70% of the space
        a = ax1.matshow(roary_sorted.T, cmap=plt.cm.Blues,
                        vmin=0, vmax=1,
                        aspect='auto',
                        interpolation='none')
        ax1.set_yticks([])
        ax1.set_xticks([])
        ax1.axis('off')

        ax = plt.subplot2grid((1, 100), (0, 0), colspan=23, facecolor='white')  # Tree takes 20% of the space
        fig.subplots_adjust(wspace=0, hspace=0)
        ax1.set_title('Roary matrix\n(%d gene clusters)' % roary.shape[0])

        # Draw the tree
        Phylo.draw(t, axes=ax,
                   show_confidence=False,
                   xticks=([],), yticks=([],),
                   ylabel=('',), xlabel=('',),
                   xlim=(-mdist * 0.1, mdist + mdist * 0.45 - mdist * roary.shape[1] * 0.001),
                   axis=('off',),
                   title=('Tree\n(%d strains)' % roary.shape[1],),
                   do_show=False)
        
        # Apply custom formatting for labels
        for terminal in t.get_terminals():
            if terminal.name:
                label = ax.texts[t.get_terminals().index(terminal)]
                if options.special_genome and terminal.name == options.special_genome:
                    label.set_fontweight('bold')
                    label.set_fontstyle('italic')
                    label.set_color('red')  # Set the color of the special genome to red
                else:
                    label.set_fontstyle('italic')
                
        plt.savefig('pangenome_matrix.%s' % options.format, dpi=300)
        plt.clf()
