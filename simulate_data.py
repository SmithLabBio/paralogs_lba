"""This script will simulate data under a user-defined species tree using simphy.
Usage: python3 simulator_v1a.py paramfile.txt
NOTE: THERE CANNOT BE UNDERSCORES IN YOUR TAXON NAMES
NOTE: AT PRESENT WILL ONLY WORK WITH UP TO 9999 replicates. """

import os
import ete3
import numpy as np
import itertools
import subprocess
import sys
import dendropy

import configparser # process_params

class ConfigParser:
    """Process the parameter file provided by the user."""

    def __init__(self, configfile):
        self.configfile = configfile

    def parse_config(self):

        """
        Parse a configuration file and return a dictionary containing the parsed values.

        Parameters:
            configfile (str): Path to the configuration file.

        Returns:
            dict: A dictionary containing the parsed configuration values.

        Raises:
            KeyError: If a required key is missing in the configuration file.
            ValueError: If there is an issue with parsing or converting the configuration values.
        """

        config = configparser.ConfigParser(inline_comment_prefixes="#")
        config.read(self.configfile)
        config_dict = {}

        # empty lists for grid
        grid_items = []
        grid_names = []

        # Parse Program paths
        try:
            config_dict["simphy"] = config["Programs"]["simphy"]
            config_dict["seqgen"] = config["Programs"]["seqgen"]
            config_dict["iqtree"] = config["Programs"]["iqtree"]
            config_dict["mpboot"] = config["Programs"]["mpboot"]
            config_dict["astral"] = config["Programs"]["astral"]
        
        except KeyError as e:
            raise KeyError(f"Error in program config: Missing key for program in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in program config: {e}")

        # Parse general info
        try:
            config_dict["subreps"] = int(config["General"]["subreps"])
            config_dict["output directory"] = config["General"]["output directory"]
            config_dict["output prefix"] = config["General"]["output prefix"]
            if 'Grid' in config["General"]["replicates"]:
                parameters = int(config["General"]["replicates"].split("Grid(")[1].split(",")[0])
                choices = int(config["General"]["replicates"].split("Grid(")[1].split(",")[1].strip().strip(")"))
                config_dict["replicates"] = choices ** parameters
                config_dict["choices"] = choices
                config_dict["scheme"] = 'Grid'
            else:
                config_dict["replicates"] = int(config["General"]["replicates"])
                config_dict["scheme"] = 'Regular'

        except KeyError as e:
            raise KeyError(f"Error in general config: Missing key in general in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in general config: {e}")

        # Parse species tree info
        try:
            config_dict["species tree file"] = config["Species Tree"]["tree"]
            config_dict["match p and r"] = config.getboolean("Species Tree","match p and r")
            config_dict["p"], grid_items, grid_names = self._get_grid_info(config["Species Tree"]["p"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="p")
            config_dict["qratio"], grid_items, grid_names = self._get_grid_info(config["Species Tree"]["qratio"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="qratio")
            config_dict["r"], grid_items, grid_names = self._get_grid_info(config["Species Tree"]["r"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="r")

        except KeyError as e:
            raise KeyError(f"Error in species tree config: Missing key for species tree information in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in species tree config: {e}")

        # Parse SimPhy info
        try:
            config_dict["cap mu"] = config.getboolean("SimPhy","cap mu")
            config_dict["match mu and lambda"] = config.getboolean("SimPhy","match mu and lambda")
            config_dict["substitution rate"], grid_items, grid_names = self._get_grid_info(config["SimPhy"]["substitution rate"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="substitution rate")
            config_dict["pop ne"], grid_items, grid_names = self._get_grid_info(config["SimPhy"]["pop ne"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="pop ne")
            config_dict["duplication rate"], grid_items, grid_names = self._get_grid_info(config["SimPhy"]["duplication rate"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="duplication rate")
            config_dict["loss rate"], grid_items, grid_names = self._get_grid_info(config["SimPhy"]["loss rate"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="loss rate")
            config_dict["outgroup"], grid_items, grid_names = self._get_grid_info(config["SimPhy"]["outgroup"], config_dict=config_dict, grid_items=grid_items, grid_names=grid_names, name_of_entry="outgroup")

        except KeyError as e:
            raise KeyError(f"Error in simphy config: Missing key for simphy information in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in simphy config: {e}")

        # Parse SeqGen info
        try:
            config_dict["model"] = config["SeqGen"]["model"]
            config_dict["length"] = config["SeqGen"]["length"]

        except KeyError as e:
            raise KeyError(f"Error in seqgen config: Missing key for seqgen information in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in seqgen config: {e}")

        # Parse ASTRAL info
        try:
            config_dict["score tree"] = config["ASTRAL"]["score tree"]

        except KeyError as e:
            raise KeyError(f"Error in ASTRAL config: Missing key for ASTRAL information in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in ASTRAL config: {e}")

        # Parse IQTree info
        try:
            config_dict["IQTree model"] = config["IQTree"]["IQTree model"]

        except KeyError as e:
            raise KeyError(f"Error in IQTree config: Missing key for IQTree information in configuration file: {e}")
        except Exception as e:
            raise Exception(f"Error in IQTree config: {e}")


        # Get sampling grids
        if config_dict["scheme"] == "Grid":
            config_dict = self._get_sampling_grid(config_dict, grid_names, grid_items=grid_items)

        # check matching rules
        if config_dict['match p and r']:
            config_dict["p"] = config_dict["r"]
        if config_dict["match mu and lambda"]:
            config_dict["loss rate"] = config["duplication rate"]

        if config_dict['match p and r'] and grid_names == ["p", "r"]:
            raise Exception("Please do not use p and r in a grid and set p and r to match.")
        if config_dict['match mu and lambda'] and grid_names == ["duplication rate", "loss rate"]:
            raise Exception("Please do not use mu and lambda in a grid and set mu and lambda to match.")

        # create output directory
        os.system('mkdir -p %s/%s' % (config_dict["output directory"], config_dict["output prefix"]))

        # get species tree
        if not config_dict["species tree file"] == "None":
            config_dict["tree"] = list(itertools.repeat(open(config_dict["species tree file"], 'r').readlines()[0],config_dict["replicates"]))
        else:
            config_dict["tree"] = self._create_species_tree(config_dict)
            if not config_dict["outgroup"] == None:
                config_dict["tree"] = self._add_outgroup(config_dict)


        return(config_dict)

    def _get_grid_info(self, entry, config_dict, grid_items, grid_names, name_of_entry):

        if 'Uniform' in entry:
            min_val = float(entry.split("Uniform(")[1].split(",")[0])
            max_val = float(entry.split("Uniform(")[1].split(",")[1].strip().strip(")"))
            dictentry = np.random.uniform(low=min_val, high=max_val, size = config_dict["replicates"])
        elif 'Grid' in entry:
            min_val = float(entry.split("Grid(")[1].split(",")[0])
            max_val = float(entry.split("Grid(")[1].split(",")[1].strip().strip(")"))
            dictentry = np.linspace(start=min_val, stop=max_val, num = config_dict["choices"])
            grid_items.append(list(dictentry))
            grid_names.append(name_of_entry)
        elif entry == "None":
            dictentry = None
        else:
            dictentry = list(itertools.repeat(float(entry), config_dict["replicates"]))
        
        return(dictentry, grid_items, grid_names)

    def _get_sampling_grid(self, config_dict, grid_names, grid_items):

        # create sampling grids
        if config_dict["cap mu"] and grid_names == ["duplication rate", "loss rate"]:
            combos = list(itertools.product(*grid_items))
            # decide which combos to keep
            new_combos = []
            for item in combos:
                if item[1] <= item[0]:
                    new_combos.append(item)
            # change number of replicates
            config_dict["replicates"] = len(new_combos)
            # create dictionary entries for duprate and lossrate.
            for item in range(len(grid_names)):
                config_dict[grid_names[item]] = []
                for j in range(config_dict["replicates"]):
                    config_dict[grid_names[item]].append(new_combos[j][item])
            # shorten other dictionary entries (p, qratio, r, outgroup)
            config_dict["p"] = config_dict["p"][0:config_dict["replicates"]]
            config_dict["qratio"] = config_dict["qratio"][0:config_dict["replicates"]]
            config_dict["r"] = config_dict["r"][0:config_dict["replicates"]]
            if config_dict["outgroup"] is not None:
                config_dict["outgroup"] = config_dict["outgroup"][0:config_dict["replicates"]]

        else:
            combos = list(itertools.product(*grid_items))
            for item in range(len(grid_names)):
                config_dict[grid_names[item]] = []
                for j in range(config_dict["replicates"]):
                    config_dict[grid_names[item]].append(combos[j][item])
        
        return(config_dict)

    def _create_species_tree(self, config_dict):
        newick_list = []
        for i in range(config_dict["replicates"]):
            newick_base = "((A:%s,B:%s*%s):%s,(C:%s,D:%s*%s):%s);" % (config_dict["p"][i], config_dict["p"][i], config_dict["qratio"][i], config_dict["r"][i]/2, config_dict["p"][i], config_dict["p"][i], config_dict["qratio"][i], config_dict["r"][i]/2)
            newick_list.append(newick_base)

        return(newick_list)

    def _add_outgroup(self, config_dict):
        newick_list = []
        for i in range(config_dict["replicates"]):
            height = (config_dict["p"][i] + config_dict["r"][i]/2)
            ogheight = height * config_dict["outgroup"][i]
            subheight = ogheight - height
            newick_base = "(O:%s,((A:%s,B:%s*%s):%s,(C:%s,D:%s*%s):%s):%s);" % (ogheight, config_dict["p"][i], config_dict["p"][i], config_dict["qratio"][i], config_dict["r"][i]/2, config_dict["p"][i], config_dict["p"][i], config_dict["qratio"][i], config_dict["r"][i]/2, subheight)
            newick_list.append(newick_base)
        return(newick_list)

class DataSimulator:
    """Run SimPhy and SeqGen."""

    def __init__(self, config_dict):
        self.config_dict = config_dict

    def simulate_simphy(self):

        print("Running simulations in SimPhy.")

        # change directory
        startdir = os.getcwd()
        os.chdir(self.config_dict["output directory"])

        for i in range(self.config_dict['replicates']):

            # create command
            command = "%s -RS 1 -RL f:%s -S '%s' -SP f:%s -SU f:%s -SG f:1 -LB f:%s -LD f:%s -LL 4 -O '%s'" % (
                self.config_dict["simphy"],
                self.config_dict["subreps"],
                self.config_dict["tree"][i],
                int(self.config_dict["pop ne"][i]),
                self.config_dict["substitution rate"][i],
                self.config_dict["duplication rate"][i],
                self.config_dict["loss rate"][i],
                os.path.join(self.config_dict["output prefix"], 'rep'+str(i))
                )

            # run command
            os.system(command)

        # reorganize
        concat_locus_command = 'cat '
        for i in range(self.config_dict['replicates']):
            concat_locus_command += ' '+os.path.join(self.config_dict["output prefix"],'rep'+str(i),'1', 'l_trees.trees')
        concat_locus_command += ' > '+ os.path.join(self.config_dict["output prefix"],'l_trees.trees') 
        os.system(concat_locus_command)

        concat_species_command = 'cat '
        for i in range(self.config_dict['replicates']):
            concat_species_command += ' '+os.path.join(self.config_dict["output prefix"],'rep'+str(i),'1', 's_tree.trees')
        concat_species_command += ' > '+ os.path.join(self.config_dict["output prefix"],'s_tree.trees') 
        os.system(concat_species_command)

        concat_gene_command = 'cat '
        for i in range(self.config_dict['replicates']):
            os.system('cat %s > %s' % (os.path.join(self.config_dict["output prefix"], 'rep'+str(i), '1', 'g_trees*.trees'), os.path.join(self.config_dict["output prefix"], 'rep'+str(i), 'all_g_trees.trees')))
            gtfilename = os.path.join(self.config_dict["output prefix"], 'rep'+str(i), 'all_g_trees.trees')
            count_of_lines = subprocess.check_output('wc -l %s' % gtfilename, shell=True)
            linecount = int(count_of_lines.split()[0])
            if linecount < self.config_dict["subreps"]:
                raise Exception('ERROR: we did not generate enough gene trees.')
            concat_gene_command += ' '+os.path.join(self.config_dict["output prefix"],'rep'+str(i), 'all_g_trees.trees')
        concat_gene_command += ' > '+ os.path.join(self.config_dict["output prefix"],'g_trees.trees') 
        os.system(concat_gene_command)

        concat_command_command = 'awk 1 '
        for i in range(self.config_dict['replicates']):
            concat_command_command += ' '+os.path.join(self.config_dict["output prefix"],'rep'+str(i), 'rep'+str(i)+'.command')
        concat_command_command += ' > '+ os.path.join(self.config_dict["output prefix"],'commands.txt') 
        os.system(concat_command_command)

        for i in range(self.config_dict['replicates']):
            os.system('rm -r %s' % (os.path.join(self.config_dict["output prefix"], 'rep'+str(i))))

        # change directory
        os.chdir(startdir)

    def simulate_seqgen(self):

        # change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)

        # read gene trees
        gene_trees = open('g_trees.trees', 'r').readlines()

        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):

            # get the gene tree
            thistree = gene_trees[i]

            # temp tree
            with open('temp.tre', 'w') as f:
                f.write(thistree)

            # create command
            command = "%s -l %s -m %s temp.tre > %s_%s.phy" % (
                self.config_dict["seqgen"],
                self.config_dict["length"],
                self.config_dict["model"],
                self.config_dict["output prefix"],
                str(i)
            )

            # run command
            os.system(command)

            # remove temp
            os.system('rm temp.tre')

            # remove outgroup
            if self.config_dict["outgroup"] != None:
            
                newfilename = "%s_%s.new.phy" % (self.config_dict["output prefix"], str(i))
                oldfilename = "%s_%s.phy" % (self.config_dict["output prefix"], str(i))

                count = 0
                newfile = open(newfilename, 'w')
                with open(oldfilename, 'r') as f:
                    for line in f.readlines():
                        if not 'O_' in line:
                            newfile.write(line)
                        else:
                            count+=1
                newfile.close()

                oldfile = open(oldfilename, 'w')
                newcount = 0
                with open(newfilename, 'r') as f:
                    for line in f.readlines():
                        if newcount == 0:
                            sequences = int(line.split()[0]) - count
                            length = int(line.split()[1])
                            newline = ' %s %s\n' % (str(sequences), str(length))
                            oldfile.write(newline)
                            newcount+=1
                        else:
                            oldfile.write(line)
                oldfile.close()
                os.system('rm %s' % newfilename)

        # change directory
        os.chdir(startdir)

class TreeInferrer:
    """Infer trees from sequence data."""

    def __init__(self, config_dict):
        self.config_dict = config_dict

    def run_mpboot(self):

        # change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)

        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):
            
            # create command
            command = '%s -s %s_%s.phy -pre rep%s' % (
                self.config_dict["mpboot"],
                self.config_dict["output prefix"],
                str(i),
                str(i)
            )
            
            # run command
            os.system(command)

            # check that the file was generated
            if not os.path.isfile('rep%s.treefile' % str(i)):
                with open('rep%s.treefile' % str(i), 'w') as f:
                    f.write('None\n')
        
        # clean up
        os.system('rm rep*.mpboot')
        os.system('rm rep*.log')
        os.system('rm rep*.parstree')

        # concatenate
        concat_command = 'cat'
        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):
            concat_command += ' rep%s.treefile' % str(i)
        concat_command += ' > all_inferred_mp.tre'
        os.system(concat_command)
        os.system('rm rep*.treefile')

        # change directory
        os.chdir(startdir)

    def run_iqtree(self):

        ## change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)

        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):

            if not os.path.exists(f"rep{i}_{self.config_dict["IQTree model"]}.treefile"):

                # create command
                command = '%s -s %s_%s.phy -m %s -pre rep%s_%s --redo --quiet' % (
                    self.config_dict["iqtree"],
                    self.config_dict["output prefix"],
                    str(i),
                    self.config_dict["IQTree model"],
                    str(i),
                    self.config_dict["IQTree model"],
                )

                # run command
                os.system(command)

                # check that the file was generated
                if not os.path.isfile('rep%s_%s.treefile' % (str(i), self.config_dict["IQTree model"])):
                    with open('rep%s_%s.treefile' % (str(i), self.config_dict["IQTree model"]), 'w') as f:
                            f.write('None\n')

        
        os.system('find . -maxdepth 1 -name "*.bionj" -delete')
        os.system('find . -maxdepth 1 -name "*.ckp.gz" -delete')
        os.system('find . -maxdepth 1 -name "*.iqtree" -delete')
        os.system('find . -maxdepth 1 -name "*.log" -delete')
        os.system('find . -maxdepth 1 -name "*.mldist" -delete')
        os.system('find . -maxdepth 1 -name "*.model.gz" -delete')
        os.system('find . -maxdepth 1 -name "*.uniqueseq.phy" -delete')

        # concatenate
        output_filename = 'all_inferred_ml_%s.tre' % self.config_dict["IQTree model"]
        with open(output_filename, 'w') as outfile:
            for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):
                input_filename = 'rep%s_%s.treefile' % (str(i), self.config_dict["IQTree model"])
                with open(input_filename, 'r') as infile:
                    outfile.write(infile.read())  # Add a newline between concatenated files



        os.system('find . -maxdepth 1 -name "rep*.treefile" -delete')

        # change directory
        os.chdir(startdir)

    def clean_directory(self):

        ## change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)
        
        # clean up
        os.system('rm *.phy')

        # change directory
        os.chdir(startdir)

class ConcordanceCalculator:
    """Calculate concordance."""

    def __init__(self, config_dict):
        self.config_dict = config_dict

    def check_concordance(self, trees_to_score):

        q1_list = []
        q2_list = []
        q3_list = []
        sco = []

        # change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)

        # get trees
        all_trees = open(trees_to_score, 'r').readlines()

        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):

            if "None" in all_trees[i]:
                result = None
                sco.append('NA')

            else:
                # create temp tree file
                with open('temp.tre', 'w') as f:
                    f.write(all_trees[i])

                # create mapping file
                num_leaves = 0
                spdict = {}
                with open("temp.tre", 'r') as f:
                    tree = f.readlines()[0]
                    etetree = ete3.Tree(tree)
                    for leaf in etetree:
                        num_leaves += 1
                        spname = leaf.name.split('_')[0]
                        # check if key exists
                        if spname in spdict:
                            spdict[spname] = spdict[spname] + [leaf.name]
                        else:
                            spdict[spname] = [leaf.name]

                with open("temp.map", "w") as f:
                    for key in spdict:
                        for item in spdict[key]:
                            f.write(f"{item} {key}\n")
                    #for key in spdict:
                    #    line = key
                    #    line = line + ":"
                    #    for item in spdict[key]:
                    #        line = line + item
                    #        line = line + ','
                    #    line = line.strip(',')
                    #    f.write(line)
                    #    f.write('\n')

                if len(spdict) < 4:
                    result = None
                    os.system('rm temp.tre temp.map')
                    sco.append("NA")

                else:
                    # create command
                    command = f"{self.config_dict['astral']} -C -c {self.config_dict['score tree']} -i temp.tre -a temp.map -u 2 > temp.scored.log"

                    # run command
                    os.system(command)

                    scored_tree = dendropy.Tree.get(path="temp.scored.log", schema="newick")
                    filter_fn = lambda n: hasattr(n, 'label') and n.label is not None 
                    nodes = scored_tree.find_node(filter_fn=filter_fn)
                    children = [x.taxon.label for x in nodes.child_nodes()]
                    if ('C' in children and 'D' in children) or ('A' in children and 'B' in children):
                        q1 = nodes.label.split("q1=")[1].split(";")[0]
                        q2 = nodes.label.split("q2=")[1].split(";")[0]
                        q3 = nodes.label.split("q3=")[1].split("]")[0]
                    else:
                        raise Exception("Issue when scoring tree.")
                    
                    os.system('rm temp.tre temp.map temp.scored.log')

                    if num_leaves == 4 and len(spdict) == 4:
                        sco.append(True)
                    elif len(spdict) == 4:
                        sco.append(False)
                    else:
                        sco.append('NA')

            q1_list.append(q1)
            q2_list.append(q2)
            q3_list.append(q3)
            del q1, q2, q3

        # change directory
        os.chdir(startdir)

        return(q1_list, q2_list, q3_list, sco)

    def check_lsds(self, trees_to_check):

        # change directory
        startdir = os.getcwd()
        changedir = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"])
        os.chdir(changedir)

        # get trees
        all_trees = open(trees_to_check, 'r').readlines()
        results = []
        results_lsdonly = []

        for i in range(self.config_dict["replicates"] * self.config_dict["subreps"]):

            if "None" in all_trees[i]:
                indicator = "NA"
                indicator_only = "NA"

            else:
                t = ete3.Tree(all_trees[i])
                R = t.get_midpoint_outgroup()
                t.set_outgroup(R)
    
                indicator = False
                indicator_only = True
    
                lsd_count = 0
    
                # iterate over nodes, if there is any node where there are multiple monophyletic B or D copies, then the result is true
                for node in t.traverse("postorder"):
                    samples = node.get_leaf_names()
                    samples = [x.split("_")[0]for x in samples]
                    species = set(samples)
                    if len(species) == 1 and len(samples) > 1 and samples[0] == "B":
                        indicator = True
                        lsd_count+=1
                    elif len(species) == 1 and len(samples) > 1 and samples[0] == "D":
                        indicator = True
                        lsd_count+=1
                    elif len(species) == 1 and len(samples) > 1 and samples[0] == "A":
                        lsd_count+=1
                    elif len(species) == 1 and len(samples) > 1 and samples[0] == "C":
                        lsd_count+=1
                    
                samples = t.get_leaf_names()
                samples = [x.split("_")[0]for x in samples]
                species = set(samples)
                if len(species) + lsd_count < len(samples):
                    indicator_only = False
    

            results.append(indicator)
            results_lsdonly.append(indicator_only)

        os.chdir(startdir)
        return(results, results_lsdonly)

class ResultsWriter:
    """Save results to file."""

    def __init__(self, config_dict):
        self.config_dict = config_dict
    
    def write_results(self, results_q1, results_q2, results_q3, results_sco, results_lsds, results_lsd_only, name, params):

        filename = os.path.join(self.config_dict["output directory"], self.config_dict["output prefix"], name+'.csv')

        results_index = 0
        with open(filename, 'w') as f:
            f.write('prefix,paramfile,duplication rate,loss rate,p,qratio,r,outgroup,q1,q2,q3,sco,lsd,lsdonly,replicate\n')
            for i in range(self.config_dict["replicates"]):
                for j in range(self.config_dict["subreps"]):
                    if self.config_dict["outgroup"] == None:
                        f.write(f"{self.config_dict['output prefix']},{params},{self.config_dict['duplication rate'][i]},{self.config_dict['loss rate'][i]},"
                                f"{self.config_dict['p'][i]},{self.config_dict['qratio'][i]},{self.config_dict['r'][i]},{self.config_dict['outgroup']},"
                                f"{results_q1[results_index]},{results_q2[results_index]},{results_q3[results_index]},"
                                f"{results_sco[results_index]},{results_lsds[results_index]},{results_lsd_only[results_index]},{str(j+1)}\n")
                    else:
                        f.write(f"{self.config_dict['output prefix']},{params},{self.config_dict['duplication rate'][i]},{self.config_dict['loss rate'][i]},"
                                f"{self.config_dict['p'][i]},{self.config_dict['qratio'][i]},{self.config_dict['r'][i]},{self.config_dict['outgroup'][i]},"
                                f"{results_q1[results_index]},{results_q2[results_index]},{results_q3[results_index]},"
                                f"{results_sco[results_index]},{results_lsds[results_index]},{results_lsd_only[results_index]},{str(j+1)}\n")
                    results_index += 1
