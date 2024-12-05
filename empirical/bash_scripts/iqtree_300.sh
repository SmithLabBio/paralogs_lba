#!/bin/bash
  
#SBATCH -J iqtree                               # Job name 
#SBATCH -o iqtree.%j.out                     # File to which stdout will be written
#SBATCH -e iqtree.%j.err                     # File to which stderr will be written
#SBATCH -N 1                                    # Ensure that all cores are on one machine
#SBATCH -n 24                                    # Number of cores/cpus
#SBATCH -t 96:00:00                             # Runtime in DD-HH:MM
#SBATCH -p smith                               # Partition shared, serial_requeue, unrestricted, test
#SBATCH --mem=4Gb

# Create variable to hold the directory name (which is the species name) and move inside folder
process_line() {
    echo "Processing: $1"
    # Add your processing logic here

    # to run iqtree
    ../programs/iqtree-2.3.2-Linux-intel/bin/iqtree2 -s /mnt/scratch/smithlab/arachnid/alignments/filtered_g300/$1 --prefix iqtree_300/$1_
}


# Set the number of threads
num_threads=24

# Read the file line by line
mkdir -p iqtree_300
while IFS= read -r line || [ -n "$line" ]; do
    # Run the processing function in the background
    process_line "$line" &

    # Limit the number of background processes
    if [ $(jobs | wc -l) -ge $num_threads ]; then
        wait -n
    fi
done < alignments_mpboot_300.txt

# Wait for remaining background processes to finish
wait