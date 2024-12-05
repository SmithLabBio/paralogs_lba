#!/bin/bash
#SBATCH -J fastortho
#SBATCH -p smith
#SBATCH -o fastortho_%j.txt
#SBATCH -e fastortho_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=100:00:00

configfile="input_files/fastortho_opts.txt"

i=2
sed -i "s/--project_name chelicerate_fastortho_i[0-9]/--project_name chelicerate_fastortho_i$i/g" $configfile
sed -i "s/chelicerate-fastortho-i[0-9].out/chelicerate-fastortho-i$i.out/g" $configfile
sed -i "s/--inflation [0-9]/--inflation $i/g" $configfile
time -p /mnt/home/ms4438/arachnid/programs/FastOrtho/src/FastOrtho --option_file $configfile --mcl_path /mnt/home/ms4438/local/bin/mcl

i=3
sed -i "s/--project_name chelicerate_fastortho_i[0-9]/--project_name chelicerate_fastortho_i$i/g" $configfile
sed -i "s/chelicerate-fastortho-i[0-9].out/chelicerate-fastortho-i$i.out/g" $configfile
sed -i "s/--inflation [0-9]/--inflation $i/g" $configfile
time -p /mnt/home/ms4438/arachnid/programs/FastOrtho/src/FastOrtho --option_file $configfile --mcl_path /mnt/home/ms4438/local/bin/mcl

i=4
sed -i "s/--project_name chelicerate_fastortho_i[0-9]/--project_name chelicerate_fastortho_i$i/g" $configfile
sed -i "s/chelicerate-fastortho-i[0-9].out/chelicerate-fastortho-i$i.out/g" $configfile
sed -i "s/--inflation [0-9]/--inflation $i/g" $configfile
time -p /mnt/home/ms4438/arachnid/programs/FastOrtho/src/FastOrtho --option_file $configfile --mcl_path /mnt/home/ms4438/local/bin/mcl

i=5
sed -i "s/--project_name chelicerate_fastortho_i[0-9]/--project_name chelicerate_fastortho_i$i/g" $configfile
sed -i "s/chelicerate-fastortho-i[0-9].out/chelicerate-fastortho-i$i.out/g" $configfile
sed -i "s/--inflation [0-9]/--inflation $i/g" $configfile
time -p /mnt/home/ms4438/arachnid/programs/FastOrtho/src/FastOrtho --option_file $configfile --mcl_path /mnt/home/ms4438/local/bin/mcl

i=6
sed -i "s/--project_name chelicerate_fastortho_i[0-9]/--project_name chelicerate_fastortho_i$i/g" $configfile
sed -i "s/chelicerate-fastortho-i[0-9].out/chelicerate-fastortho-i$i.out/g" $configfile
sed -i "s/--inflation [0-9]/--inflation $i/g" $configfile
time -p /mnt/home/ms4438/arachnid/programs/FastOrtho/src/FastOrtho --option_file $configfile --mcl_path /mnt/home/ms4438/local/bin/mcl

