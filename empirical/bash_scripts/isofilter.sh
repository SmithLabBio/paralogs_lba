#!/bin/bash
#SBATCH -J isofilter
#SBATCH -p smith
#SBATCH -o isofilter_%j.txt
#SBATCH -e isofilter_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00

spec_dirs=(abrue bmori crotu cscor cscul dmela hlong iscap lhesp lpoly lrecl mocci nclav ptepi smimo sscab tgiga turti vdest)
for dir in "${spec_dirs[@]}"; do
    echo ""
    echo "Processing $dir..."
    if [ ! -e "cds/$dir/protein.faa" ]; then
        echo "File does not in $dir"
        files=$(find "cds/$dir" -type f \( -name *prot* -o -name *pep* \) )
        echo $files
        mv $files cds/$dir/protein.faa
    fi
    gfffile=$(find "cds/$dir" -type f \( -name *.gff3 -o -name *.gff -o -name *.gff3.gz \) )
    python ./programs/isofilter-gff/isofilter_gff.py -a $gfffile -s cds/$dir/protein.faa -o ./cds/$dir/protein_isoform --prot
done