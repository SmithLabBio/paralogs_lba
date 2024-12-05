import os
import ete3
import numpy as np
import sys

input_file = sys.argv[1]
output_filename = sys.argv[2]


output_file = open(output_filename,'w')

with open(input_file, 'r') as f:

    for line in f.readlines():

        t = ete3.Tree(line.strip())

        for leaf in t.iter_leaves():
            leaf.name = leaf.name.split('_')[0]
    
        output_file.write(t.write())
        output_file.write("\n")
        

output_file.close()
