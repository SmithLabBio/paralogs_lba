#!/bin/bash
  
#SBATCH -J gblocks                               # Job name 
#SBATCH -o gblocks.%j.out                     # File to which stdout will be written
#SBATCH -e gblocks.%j.err                     # File to which stderr will be written
#SBATCH -N 1                                    # Ensure that all cores are on one machine
#SBATCH -n 1                                    # Number of cores/cpus
#SBATCH -t 96:00:00                             # Runtime in DD-HH:MM
#SBATCH -p smith                               # Partition shared, serial_requeue, unrestricted, test
#SBATCH --mem=16Gb

# Create variable to hold the directory name (which is the species name) and move inside folder
process_line() {
    echo "Processing: $1"
    # run gblocks
    ../programs/Gblocks_0.91b/Gblocks /mnt/scratch/smithlab/arachnid/alignments/$1 -t=p > /mnt/scratch/smithlab/arachnid/alignments/gblocks/gblocks_$1
}


# Set the number of threads
num_threads=1
mkdir -p /mnt/scratch/smithlab/arachnid/alignments/gblocks/
# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Run the processing function in the background
    process_line "$line" &

    # Limit the number of background processes
    if [ $(jobs | wc -l) -ge $num_threads ]; then
        wait -n
    fi
done < alignment_names.txt

# Wait for remaining background processes to finish
wait
