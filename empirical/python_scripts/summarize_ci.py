import pandas as pd

def get_95_CI(data):
    sorted_data = sorted(data)
    n = len(sorted_data)
    num_to_remove = int(n * 0.025)  # Number of elements to remove from each end
    trimmed_data = sorted_data[num_to_remove:-num_to_remove]
    
    return min(trimmed_data), max(trimmed_data)

dfs = []

list_of_files = [
    "confidenceintervals_300_sco_mp_bootstrappingresults.csv",
    "confidenceintervals_300_all_mp_bootstrappingresults.csv",
    "confidenceintervals_300_lsd_mp_bootstrappingresults.csv",
    "confidenceintervals_300_sco_ml_bootstrappingresults.csv",
    "confidenceintervals_300_lsd_ml_bootstrappingresults.csv",
    "confidenceintervals_300_all_ml_bootstrappingresults.csv"]

for file in list_of_files:
    results = pd.read_csv(file)
    q1 = list(results['Q1'])
    ci_95 = get_95_CI(list(q1))
    ci_100 = min(q1), max(q1)
    df_temp = pd.DataFrame({'Filename': [file], 'CI_95_min': [ci_95[0]], 'CI_95_max': ci_95[1], 'CI_100_min': [ci_100[0]], 'CI_100_max': ci_100[1]})
    dfs.append(df_temp)

all_results = pd.concat(dfs, ignore_index=True)

all_results.to_csv('ConfidenceInterval_summary.csv')
