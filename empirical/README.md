# Step 1: Download protein, CDS, and gff files. 
See Table S1 for details.

# Step 2: Create cds for Tachypleus gigas using gffread.
gffread -g /mnt/scratch/smithlab/arachnid/cds/tgiga/01_Tgigas_genome_assembly.fasta -x /mnt/scratch/smithlab/arachnid/cds/tgiga/cds_from_genomic.fna /mnt/scratch/smithlab/arachnid/cds/tgiga/02_Tgigas_annotation.gff3

# Step 3: Use isofilter to get the longest isoforms
sbatch bash_scripts/isofilter.sh

# Step 4: Move data
mv cds/ /mnt/scratch/smithlab/arachnid/

# Step 5: Rename longest isoform files
bash bash_scripts/rename_isoforms.sh

# Step 6: Combine Sequences
find /mnt/scratch/smithlab/arachnid/cds/ -type f -name *-isoforms.fa -exec cat {} \; > /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-peptides.fa

# Step 7: Make blast database
makeblastdb -in /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-peptides.fa -dbtype prot -out /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-blastdb

# Step 8: Run blast
blastp -db /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-blastdb -query  /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-peptides.fa -outfmt 7 -seg yes -num_threads 24 > /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-blast-output.txt

# Step 9: Filter blast results by e-val
grep -v "#" /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-blast-output.txt | awk '{if($11 <= 1e-3){print}}' > /mnt/scratch/smithlab/arachnid/data/chelicerate-19spec-blast-output-1e-3.txt

# Step 10: FastOrtho
sbatch bash_scripts/fastortho.sh

# Step 11: Summarize FastOrtho
python python_scripts/summarize_fastortho.py

# Step 12: Get Genes
python python_scripts/get_orth_MLS.py

# Step 13: Align data
sbatch bash_scripts/mafft_parallel.sh

# Step 14: GBlocks
sbatch bash_scripts/gblocks.sh

# Step 15: Organize
mkdir /mnt/scratch/smithlab/arachnid/alignments/mafft
mv /mnt/scratch/smithlab/arachnid/alignments/gblocks/ /mnt/scratch/smithlab/arachnid/alignments/gblocks_info/
mkdir /mnt/scratch/smithlab/arachnid/alignments/gblocks
mv /mnt/scratch/smithlab/arachnid/alignments/*.htm /mnt/scratch/smithlab/arachnid/alignments/gblocks_info/
mv /mnt/scratch/smithlab/arachnid/alignments/*-gb /mnt/scratch/smithlab/arachnid/alignments/gblocks/
mv /mnt/scratch/smithlab/arachnid/alignments/*.fa /mnt/scratch/smithlab/arachnid/alignments/mafft/

# Step 16: TrimAl
sbatch bash_scripts/trimal.sh

# Step 17: Filter alignments
python python_scripts/filteralignments.py 300
## These filtered alignments are available in data/filtered_g300.tar.gz

# Step 18: Run MPBoot on alignments
sbatch bash_scripts/mpboot_300.sh

# Step 19: Organize MPBoot Trees
mkdir /mnt/scratch/smithlab/arachnid/mpboot_300
mv /mnt/scratch/smithlab/arachnid/alignments/filtered_g300/*.treefile /mnt/scratch/smithlab/arachnid/mpboot_300/
mv /mnt/scratch/smithlab/arachnid/alignments/filtered_g300/*.mpboot /mnt/scratch/smithlab/arachnid/mpboot_300/
mv /mnt/scratch/smithlab/arachnid/alignments/filtered_g300/*.parstree /mnt/scratch/smithlab/arachnid/mpboot_300/
mv /mnt/scratch/smithlab/arachnid/alignments/filtered_g300/*.log /mnt/scratch/smithlab/arachnid/mpboot_300/
mkdir /mnt/scratch/smithlab/arachnid/mpboot_300/treefiles
mv /mnt/scratch/smithlab/arachnid/mpboot_300/*.treefile /mnt/scratch/smithlab/arachnid/mpboot_300/treefiles/
mkdir /mnt/scratch/smithlab/arachnid/mpboot_300/other
mv /mnt/scratch/smithlab/arachnid/mpboot_300/* /mnt/scratch/smithlab/arachnid/mpboot_300/other/
mv /mnt/scratch/smithlab/arachnid/mpboot_300/other/treefiles /mnt/scratch/smithlab/arachnid/mpboot_300/
## These trees are available in data/mpboot_300.tar.gz

# Step 20: Run IQTree on alignments
sbatch bash_scripts/iqtree_300.sh
## These trees are available in data/iqtree_300.tar.gz

# Step 21: Create ASTRAL Input (MP)
cat /mnt/scratch/smithlab/arachnid/mpboot_300/treefiles/*.treefile > astral_input_300/all_genes.treefile
python python_scripts/get_all.py astral_input_300/all_genes.treefile astral_input_300/astral_allparalogs.treefile
python python_scripts/get_sco.py astral_input_300/all_genes.treefile astral_input_300/astral_sco.treefile
python python_scripts/get_cscordups.py astral_input_300/all_genes.treefile astral_input_300/astral_cscordups.treefile
## These datasets are available in data/astral_input_mpboot.tar.gz

# Step 22: Create ASTRAL Input (ML)
cat iqtree_300/*.treefile > astral_input_ml_300/all_genes.treefile
python python_scripts/get_all.py astral_input_ml_300/all_genes.treefile astral_input_ml_300/astral_allparalogs.treefile
python python_scripts/get_sco.py astral_input_ml_300/all_genes.treefile astral_input_ml_300/astral_sco.treefile
python python_scripts/get_cscordups.py astral_input_ml_300/all_genes.treefile astral_input_ml_300/astral_cscordups.treefile
## These datasets are available in data/astral_input_iqtree.tar.gz

# Step 23: ASTRAL (MP)
mkdir astral_output_300
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_300/astral_sco.treefile -u 2 > astral_output_300/astral_sco_tree1.treefile
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_300/astral_allparalogs.treefile -u 2 > astral_output_300/astral_allparalogs_tree1.treefile 
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_300/astral_cscordups.treefile -u 2 > astral_output_300/astral_cscordups_tree1.treefile 
## These results are available in results/astral_output_mp

# Step 24: ASTRAL (ML) 
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_ml_300/astral_sco.treefile -u 2 > astral_output_ml_300/astral_sco_tree1.treefile
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_ml_300/astral_allparalogs.treefile -u 2 > astral_output_ml_300/astral_allparalogs_tree1.treefile 
programs/ASTER-Linux/bin/astral -C -c astral_scoring_t1.tre -i astral_input_ml_300/astral_cscordups.treefile -u 2 > astral_output_ml_300/astral_cscordups_tree1.treefile 
## These results are available in results/astral_output_iqtree

# Step 25: CIs using bootstrap
sbatch bash_scripts/confidenceintervals_mp_sc.pbs
sbatch bash_scripts/confidenceintervals_mp_all.pbs
sbatch bash_scripts/confidenceintervals_mp_cscordups.pbs
sbatch bash_scripts/confidenceintervals_ml_sc.pbs
sbatch bash_scripts/confidenceintervals_ml_all.pbs
sbatch bash_scripts/confidenceintervals_ml_cscordups.pbs
python python_scripts/summarize_ci.py