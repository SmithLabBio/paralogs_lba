"""Python script to filter alignments:
1. Remove any individuals with > 50% gaps.
2. Remove any alignments with < 4 individuals.
3. Write output to output folder.
"""
# On carbonate, use anaconda environment deeplearning, as it has dendropy already installed.
from Bio import AlignIO
import os
from sys import argv

length = int(argv[1])

input_folder = '/mnt/scratch/smithlab/arachnid/alignments/trimAl/'
output_folder = f'/mnt/scratch/smithlab/arachnid/alignments/filtered_g{length}/'

os.system('mkdir -p %s' % output_folder)

alignments = os.listdir(input_folder)

for alignment in alignments:

    charmatrix = AlignIO.read(open(os.path.join(input_folder, alignment)), 'fasta')

    # check overall sequence length
    if len(charmatrix[0]) >= length:
        newcharmatrix = AlignIO.MultipleSeqAlignment(records=[])
        for record in charmatrix:
            seq_length = len(record.seq)
            nogaps = record.seq.replace('-','')
            nogap_length = len(nogaps)
            if nogap_length >= 0.5*seq_length:
                newcharmatrix.append(record)
        if len(newcharmatrix) >= 4:
            AlignIO.write(newcharmatrix, os.path.join(output_folder, alignment), format="fasta")
