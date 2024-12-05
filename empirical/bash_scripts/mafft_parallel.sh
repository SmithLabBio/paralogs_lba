#!/bin/bash
#SBATCH -J mafft
#SBATCH -p smith
#SBATCH --output=mafft_parallel_%A_%a.out
#SBATCH --error=mafft_parallel_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=100:00:00
#SBATCH --mem=2G

# Define the input and output directories
INPUT_DIR="/mnt/scratch/smithlab/arachnid/seq/cds"
OUTPUT_DIR="/mnt/scratch/smithlab/arachnid/alignments"

# Loop over each file in the input directory
for infile in "$INPUT_DIR"/*; do
    outfile="${OUTPUT_DIR}/$(basename "$infile")"
    if [ ! -s "$outfile" ]; then
        mafft --localpair --maxiterate 5000 --thread 24 --reorder "$infile" > "$outfile"
    fi
done