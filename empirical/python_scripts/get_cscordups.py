import os
import ete3
import numpy as np
import sys

input_file = sys.argv[1]
output_filename = sys.argv[2]
all_species = []

output_file = open(output_filename,'w')

with open(input_file, 'r') as f:

    for line in f.readlines():

        t = ete3.Tree(line.strip())

        taxa = t.get_leaf_names()

        taxa = [x.split("_")[0] for x in taxa]

        set_taxa = set(taxa)

        write = False

        for node in t.traverse("postorder"):
            taxa_node = node.get_leaf_names()
            spec_node = [x.split("_")[0] for x in taxa_node]
            spec_node_set = set(spec_node)
            if len(spec_node_set) == 1 and len(taxa_node) > 1 and spec_node[0] == 'cscor':
                write=True

        if write == True:    
            for leaf in t.iter_leaves():
                leaf.name = leaf.name.split('_')[0]
            all_species.extend(taxa)
            output_file.write(t.write())
            output_file.write("\n")
 

output_file.close()

set_all_species = set(all_species)
print(set_all_species)