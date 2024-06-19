"""This script will use simulate_data.py to simulate data based on information in the parameter file, infer trees from simulated data, and calculate quartet concordance factors."""
""" usage: python usage.py paramfile.txt"""

import simulate_data as simulator
import sys

# parse parameters
paramfile = sys.argv[1]
config_parser = simulator.ConfigParser(paramfile)
config_dict = config_parser.parse_config()

## simulate data in SimPhy and SeqGen
#simphy_simulator = simulator.DataSimulator(config_dict)
#simphy_simulator.simulate_simphy()
#simphy_simulator.simulate_seqgen()
#
## infer trees
#tree_inferrer = simulator.TreeInferrer(config_dict)
#tree_inferrer.run_mpboot()
#tree_inferrer.run_iqtree()
#tree_inferrer.clean_directory()

# calculate concordance
concordance_calculator = simulator.ConcordanceCalculator(config_dict)
results_mp_q1, results_mp_q2, results_mp_q3, sco_results_mp = concordance_calculator.check_concordance('all_inferred_mp.tre')
results_ml_q1, results_ml_q2, results_ml_q3, sco_results_ml = concordance_calculator.check_concordance('all_inferred_ml_HKY.tre')
lsd_results_mp, lsd_only_results_mp = concordance_calculator.check_lsds('all_inferred_mp.tre')
lsd_results_ml, lsd_only_results_ml = concordance_calculator.check_lsds('all_inferred_ml_HKY.tre')

# save results to file
result_writer = simulator.ResultsWriter(config_dict)
result_writer.write_results(results_q1=results_mp_q1, results_q2=results_mp_q2, results_q3=results_mp_q3, results_sco=sco_results_mp, results_lsds=lsd_results_mp, results_lsd_only = lsd_only_results_mp, name="results_mp", params=paramfile)
result_writer.write_results(results_q1=results_ml_q1, results_q2=results_ml_q2, results_q3=results_ml_q3, results_sco=sco_results_ml, results_lsds=lsd_results_ml, results_lsd_only = lsd_only_results_ml, name="results_ml", params=paramfile)