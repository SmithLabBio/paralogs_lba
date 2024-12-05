#!/bin/bash
  
#SBATCH -J trimal                               # Job name 
#SBATCH -o trimal.%j.out                     # File to which stdout will be written
#SBATCH -e trimal.%j.err                     # File to which stderr will be written
#SBATCH -N 1                                    # Ensure that all cores are on one machine
#SBATCH -n 10                                    # Number of cores/cpus
#SBATCH -t 96:00:00                             # Runtime in DD-HH:MM
#SBATCH -p smith                               # Partition shared, serial_requeue, unrestricted, test
#SBATCH --mem=16Gb

# Create variable to hold the directory name (which is the species name) and move inside folder
process_line() {
    echo "Processing: $1"
    # run trimal
    ../programs/trimal/source/trimal -in /mnt/scratch/smithlab/arachnid/alignments/gblocks/$1 -out /mnt/scratch/smithlab/arachnid/alignments/trimAl/trimal_$1
}


# Set the number of threads
num_threads=10
mkdir -p /mnt/scratch/smithlab/arachnid/alignments/trimAl/
# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Run the processing function in the background
    process_line "$line" &

    # Limit the number of background processes
    if [ $(jobs | wc -l) -ge $num_threads ]; then
        wait -n
    fi
done < alignment_names_trimal.txt

# Wait for remaining background processes to finish
wait
