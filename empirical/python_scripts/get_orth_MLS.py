"""This script takes as input a fastortho output file. It will create a dictionary from the cds and protein files mapping proteins to cds. Then, it will use this to find orthologs and create fasta files."""
import os
from Bio import SeqIO
import sys

inflation_param = "3"

species = ["abrue", "bmori", "crotu", "cscor", "cscul", "dmela", "hlong", "iscap", "lhesp", "lpoly", "lrecl", "mocci", "nclav", "ptepi", "smimo", "sscab", "tgiga", "turti", "vdest"]

cds_dir = "/mnt/scratch/smithlab/arachnid/cds/"

ortholog_file = "/mnt/scratch/smithlab/arachnid/fastortho/chelicerate-fastortho-i" + inflation_param + ".out"
print(ortholog_file)

outdir = "/mnt/scratch/smithlab/arachnid/seq/"

sequence_dictionary = {}

for spec in species:

    #print(f"Processing species: {spec}.\n")

    pep_file = os.path.join(cds_dir, spec, "protein_isoform", spec + "-longest-isoforms.fa")

    cds_file = [ f for f in os.listdir(os.path.join(cds_dir, spec)) if any(s in f for s in ["cds", "CDS"]) ][0]
    cds_file = os.path.join(cds_dir, spec, cds_file)

    # gunzip if file ends with .gz
    if cds_file.endswith('.gz'):
        os.system(f"gunzip {cds_file}")
        cds_file = cds_file.strip(".gz")
    
    # cds to dict
    sequence_data = None
    with open(cds_file, 'r') as f:
        for line in f.readlines():
            if '>' in line:
                if not sequence_data is None:
                    sequence_dictionary[prot_id] = [sequence_data, spec, full_id]
                if spec == "crotu":
                    full_id = line
                    prot_id = line.split()[0].split('>')[1]
                    sequence_data = ''
                elif spec  == "cscor" or spec == "sscab":
                    full_id = line
                    prot_id = line.split()
                    try:
                        prot_id = [x for x in prot_id if "protein_id" in x][0].strip("[]").split("=")[1]
                        sequence_data = ''
                    except:
                        sequence_data = None
                elif spec == "lhesp" or spec == "lrecl" or spec == "tgiga":
                    full_id = line
                    temp_prot_id = line.split('>')[1].strip().strip('-CDS').strip('-RA')
                    prot_id = f"{temp_prot_id}-PA"
                    sequence_data = ''
                else:
                    full_id = line
                    prot_id = line.split()
                    prot_id = [x for x in prot_id if "protein_id" in x][0].strip("[]").split("=")[1]
                    sequence_data = ''
            elif not sequence_data is None:
                sequence_data+=line.strip()
        sequence_dictionary[prot_id] = [sequence_data, spec, full_id]

    # prot to dict
    sequence_data = None
    with open(pep_file, 'r') as f:
        for line in f.readlines():
            if '>' in line:
                if not sequence_data is None:
                    sequence_dictionary[prot_id].append(sequence_data)
                prot_id = line.split()[0].split('>')[1]
                sequence_data = ''
            else:
                sequence_data+=line.strip()

# process fastortho file
with open(ortholog_file, 'r') as f:
    
    for line in f.readlines():


        # check for number of taxa
        num_taxa = int(line.split(':')[0].split(',')[1].strip(" taxa)"))

        # continue if >=4
        if num_taxa >=4:

            # get orthid and start dict
            orthid = line.split(":")[0].split()[0]
            this_dict_cds = {}
            this_dict_prot = {}
            
            isoforms = line.split(':')[1].split()
            
            for isoform in isoforms:

                # get protid and specid
                protid = isoform.split('(')[0]
                specid = isoform.split("(")[1].split('-')[0]

                # get data
                this_dict_cds[f"{specid}_{protid}"] = sequence_dictionary[protid][0]
                this_dict_prot[f"{specid}_{protid}"] = sequence_dictionary[protid][-1]

        # write to file
        os.system(f"mkdir -p {os.path.join(outdir, 'cds')}")
        os.system(f"mkdir -p {os.path.join(outdir, 'prot')}")
        orthofilepath_cds = os.path.join(outdir, 'cds', f"{orthid}.fa")
        orthofilepath_prot = os.path.join(outdir, 'prot', f"{orthid}.fa")
        with open(orthofilepath_cds, 'w') as f:
            for key,value in this_dict_cds.items():
                f.write(f">{key}\n")
                f.write(f"{value}\n")
        with open(orthofilepath_prot, 'w') as f:
            for key,value in this_dict_prot.items():
                f.write(f">{key}\n")
                f.write(f"{value}\n")
        


