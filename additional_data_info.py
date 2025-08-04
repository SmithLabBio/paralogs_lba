"""This script will take as input a results file and an associated tree file.
It will then extract additional data: the number of copies and the presence of pseudoorthologs.
It will output a new results file including these additional columns."""

import argparse
import pandas as pd
import ete3
import os
import sys

def parse_arguments():
    parser = argparse.ArgumentParser(description="Extract additional data from results and tree files.")
    parser.add_argument("-r", "--results", type=str, help="Path to the results file (CSV format).")
    parser.add_argument("-t", "--tree", type=str, help="Path to the tree file (Newick format).")
    parser.add_argument("-o", "--output", type=str, help="Path to save the updated results file.")
    return parser.parse_args()

def getinfo(args):

    # open the results file
    results = pd.read_csv(args.results)

    # open the tree file
    trees = open(args.tree, "r").readlines()

    # create lists to store new values
    pseudoortholog_list = []
    num_duplications_list = []

    # iterate over each row in the results dataframe
    for index, row in results.iterrows():

        # get the tree with the same index
        tree = ete3.Tree(trees[index].strip())

        # count number of copies
        copies = [x.split('_')[-2] for x in tree.get_leaf_names()]
        num_duplications = len(set(copies)) - 1
        species = [x.split("_")[0] for x in tree.get_leaf_names()]
        num_species = len(set(species))

        # check for pseudoorthologs
        if num_duplications > 0 and row['sco']=="True":
            pseudoortholog = True
        else:
            pseudoortholog = False

        num_duplications_list.append(num_duplications)
        pseudoortholog_list.append(pseudoortholog)
    results['num_duplications'] = num_duplications_list
    results['pseudoortholog'] = pseudoortholog_list
    
    results.to_csv(args.output, index=False)


def main():

    args = parse_arguments()

    getinfo(args)

if __name__ == "__main__":
    main()