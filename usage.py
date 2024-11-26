"""This script will use simulate_data.py to simulate data based on information in the parameter file, infer trees from simulated data, and calculate quartet concordance factors."""
""" usage: python usage.py paramfile.txt mp ml"""
""" paramfile.txt is name of paramfile."""
""" mp: True = infer trees with Maximum Parsimony"""
""" ml: True = infer trees with Maximum Likelihood"""


import simulate_data as simulator
import sys

# parse parameters
paramfile = sys.argv[1]
config_parser = simulator.ConfigParser(paramfile)
config_dict = config_parser.parse_config()

# simulate data in SimPhy and SeqGen
simphy_simulator = simulator.DataSimulator(config_dict)
simphy_simulator.simulate_simphy()
simphy_simulator.simulate_seqgen()

# make objects
tree_inferrer = simulator.TreeInferrer(config_dict)
concordance_calculator = simulator.ConcordanceCalculator(config_dict)
result_writer = simulator.ResultsWriter(config_dict)

## MP
if sys.argv[2] == "True":
    tree_inferrer.run_mpboot()
    results_mp_q1, results_mp_q2, results_mp_q3, sco_results_mp = concordance_calculator.check_concordance('all_inferred_mp.tre')
    lsd_results_mp, lsd_only_results_mp = concordance_calculator.check_lsds('all_inferred_mp.tre')
    results_lsds_true, results_lsd_only_true, max_ages, min_ages = concordance_calculator.check_lsds_true('g_trees.trees')
    result_writer.write_results(results_q1=results_mp_q1, results_q2=results_mp_q2, results_q3=results_mp_q3, results_sco=sco_results_mp, results_lsds=lsd_results_mp, results_lsd_only = lsd_only_results_mp, name="results_mp", params=paramfile, results_lsds_true=results_lsds_true, results_lsd_only_true=results_lsd_only_true, max_ages=max_ages, min_ages=min_ages)

# ML
if sys.argv[3] == "True":
    tree_inferrer.run_iqtree()
    results_ml_q1, results_ml_q2, results_ml_q3, sco_results_ml = concordance_calculator.check_concordance('all_inferred_ml_HKY.tre')
    lsd_results_ml, lsd_only_results_ml = concordance_calculator.check_lsds('all_inferred_ml_HKY.tre')
    results_lsds_true_ml, results_lsd_only_true_ml, max_ages_ml, min_ages_ml = concordance_calculator.check_lsds_true('g_trees.trees')
    result_writer.write_results(results_q1=results_ml_q1, results_q2=results_ml_q2, results_q3=results_ml_q3, results_sco=sco_results_ml, results_lsds=lsd_results_ml, results_lsd_only = lsd_only_results_ml, name="results_ml", params=paramfile, results_lsds_true=results_lsds_true_ml, results_lsd_only_true=results_lsd_only_true_ml, max_ages=max_ages_ml, min_ages=min_ages_ml)

tree_inferrer.clean_directory()
