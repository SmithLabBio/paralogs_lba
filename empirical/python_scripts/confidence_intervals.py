import argparse
import os
import shutil
import numpy as np
import sys
import dendropy
import pandas as pd

def bootstrap(input_file, num_reps, output_directory):
    
    with open(input_file, 'r') as f:
        lines = f.readlines()

    total_lines = len(lines)

    for i in range(num_reps):
        bs_lines = np.random.choice(lines, size=total_lines, replace=True)
        outfilename = os.path.join(output_directory, f"bsrep_{i}.tre")
        with open(outfilename, 'w') as f:
            for line in bs_lines:
                f.write(line)

def run_astral(output_directory, num_reps, astral):

    q1_list = []
    q2_list = []
    q3_list = []

    for i in range(num_reps):

        infilename = os.path.join(output_directory, f"bsrep_{i}.tre")

        tempoutfile = os.path.join(output_directory, f"astral_results.tre")

        os.system(f"{astral} -C -c astral_scoring_t1.tre -i {infilename} -u 2 > {tempoutfile}")

        scored_tree = dendropy.Tree.get(path=tempoutfile, schema="newick", rooting='force-rooted')
        node_D = scored_tree.find_node_with_taxon_label("dmela")
        scored_tree.reroot_at_edge(node_D.edge, update_bipartitions=True)
        string = scored_tree.as_string(schema="newick")
        info = string.split("cscor")[1]
        q1_str = info.split("q1=")[1].split(";")[0]
        q2_str = info.split("q2=")[1].split(";")[0]
        q3_str = info.split("q3=")[1].split("]")[0]

        for node in scored_tree.postorder_node_iter():
            if len(node.child_nodes()) != 0 and node is not None:
                try:
                    children = [x.taxon.label for x in node.child_nodes()]
                    if "cscor" in children and "cscul" in children:
                        print(node)
                        q1 = node.label.split("q1=")[1].split(";")[0]
                        q2 = node.label.split("q2=")[1].split(";")[0]
                        q3 = node.label.split("q3=")[1].split("]")[0]
                except:
                    pass
        
        try:
            q1_match = q1==q1_str
            q2_match = q2==q2_str
            q3_match = q3==q3_str
            print(q1, q1_str)
            if not q1_match and q2_match and q3_match:
                sys.exit('There is an issue here')
            
            del q1, q2, q3

        except:
            pass

        q1_list.append(q1_str)
        q2_list.append(q2_str)
        q3_list.append(q3_str)
        del q1_str, q2_str, q3_str

    results = pd.DataFrame({'Q1': q1_list, 'Q2': q2_list, 'Q3': q3_list})

    return(results)

def calculate_confidence_intervals(input_trees, output_directory, num_reps, astral, force=False):
    # Check if output directory exists
    if os.path.exists(output_directory):
        if force:
            print(f"Output directory '{output_directory}' already exists. Deleting...")
            shutil.rmtree(output_directory)  # Delete directory and its contents
        else:
            raise FileExistsError(f"Output directory '{output_directory}' already exists. Use --force to overwrite.")

    # Create the output directory
    os.makedirs(output_directory, exist_ok=True)

    # Your logic to calculate confidence intervals
    print(f"Calculating confidence intervals for input trees from: {input_trees}")
    print(f"Output directory: {output_directory}")

    # From the original input file, create a user specified number of additional file samplign lines with replacement
    bootstrap(input_trees, num_reps, output_directory)

    # run ASTRAL 
    results = run_astral(output_directory, num_reps, astral)

    # write results to file
    output_file = f"{output_directory}_bootstrappingresults.csv"
    results.to_csv(output_file)

    # remove directory 
    shutil.rmtree(output_directory)  # Delete directory and its contents


if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description='Calculate confidence intervals for supports.')
    parser.add_argument('-i', '--input', type=str, required=True, help='Path to the input file')
    parser.add_argument('-o', '--output', type=str, help='Path to output directory')
    parser.add_argument('--force', action='store_true', help='Force overwrite if output directory exists (default: False)')
    parser.add_argument('-b', '--bs_reps', type=int, help='Number of bootstrap replicates')
    parser.add_argument('-a', '--astral', type=str, help='Path to ASTRAL')

    # Parse command-line arguments
    args = parser.parse_args()

    # Call your function with parsed arguments
    calculate_confidence_intervals(input_trees = args.input, output_directory=args.output, num_reps=args.bs_reps, force=args.force, astral=args.astral)
