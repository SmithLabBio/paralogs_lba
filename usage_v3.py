"""This script will use simulate_data.py to simulate data based on information in the parameter file, infer trees from simulated data, and calculate quartet concordance factors."""
""" usage: python usage.py paramfile.txt mp ml"""
""" paramfile.txt is name of paramfile."""
""" mp: True = do MP"""
""" ml: True = do ML"""
""" updated to use simulate_data_v2.py, which has been edited to handle gamma-rate and invariant sites, and to compare trimmed vs untrimmed LSDs."""


import simulate_data_v3 as simulator
import sys

# parse parameters
paramfile = sys.argv[1]
config_parser = simulator.ConfigParser(paramfile)
config_dict = config_parser.parse_config()

# simulate data in SimPhy and SeqGen
simphy_simulator = simulator.DataSimulator(config_dict)
simphy_simulator.simulate_simphy()
simphy_simulator.simulate_seqgen()

## make objects
result_writer = simulator.ResultsWriter(config_dict)
lsd_worker = simulator.LSDTreeInferrer(config_dict)
#
## MP
if sys.argv[2] == "True":
    results_q1_trimmed, results_q2_trimmed, results_q3_trimmed, results_q1_untrimmed, results_q2_untrimmed, results_q3_untrimmed = lsd_worker.lsd_analysis('g_trees.trees')
    result_writer.write_results_lsdfocus(results_q1_trimmed=results_q1_trimmed, results_q2_trimmed=results_q2_trimmed, results_q3_trimmed=results_q3_trimmed, results_q1_untrimmed=results_q1_untrimmed, results_q2_untrimmed=results_q2_untrimmed, results_q3_untrimmed=results_q3_untrimmed, name="results_mp", params=paramfile)
