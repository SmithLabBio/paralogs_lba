# Paralogs and long-branch attraction

Scripts for paper "Using paralogs for phylogenetic inference mitigates the effects of long-branch attraction"

## Simulation Studies

We use the scripts usage.py or usage_v2.py for simulations.
These scripts rely on modules from simulate_data.py and simulate_data_v2.py, respectively.
Both of these scripts must be in the working directory.
As input, this script takes a configuration files.
The configuration files used here are in the config_files folder.
Each is described below, and the command used to run the scirpt is shown.

### Varying the internal branch length, *r*, and the branch length multipliers for long branches, *q*

Maximum Parsimony (no loss): 
```
python usage.py config_files/config_varyqr_mp.txt True False
```
Results: results/varyqr_mpp

Maximum Likelihood (no loss):
```
python usage.py config_files/config_varyqr_ml.txt False True
```
Results: results/varyqr_ml

Maximum Likelihood with misspecified substitition model (no loss):
```
python usage_v2.py config_files/config_varyqr_ml_complexsubstitution.txt False True
```
Results: results/varyqr_ml_complexsubstitution

Maximum Parsimony (loss): 
```
python usage.py config_files/config_varyqr_mp_loss.txt True False
```
Results: results/varyqr_mp_loss

Maximum Likelihood (loss):
```
python usage.py config_files/config_varyqr_ml_loss.txt False True
```
Results: results/varyqr_ml_loss

Maximum Likelihood with misspecified substitition model (loss):
```
python usage_v2.py config_files/config_varyqr_ml_loss_complexsubstitution.txt False True
```
Results: results/varyqr_ml_loss_complexsubstitution

### Varying the ratio between total tree height and the ingroup height, *O*, and the branch length multipliers for long branches, *q*

Maximum Parsimony (no loss):
```
python usage.py config_files/config_varyqO_mp.txt True False
```

Maximum Likelihood (no loss):
```
python usage.py config_files/config_varyqO_ml.txt False True
```

Maximum Likelihood with misspecified substitution model (no loss):
```
python usage_v2.py config_files/config_varyqO_ml_complexsubstitution.txt False True
```
Results: results/varyqO_ml_complexsubstitutionmodel

### Evaluating the effect of duplicate age on inference

Maximum Parsimony (no loss):
```
python usage.py config_files/config_fixqr_lsdage_mp.txt True False
```

## Calculating additional statistics
```
python additional_data_info.py -r ./results/varyqr_mp/results_mp.csv -t ./results/varyqr_mp/all_inferred_mp.tre -o results/varyqr_mp_additional.csv
```
```
python additional_data_info.py -r ./results/varyqr_mp_loss/results_mp.csv -t ./results/varyqr_mp_loss/all_inferred_mp.tre -o results/varyqr_mp_loss_additional.csv
```

## Analysing only gene families with lineage-specific duplicates (excluding or including those duplicates during gene tree inference)
Note: usage_v3.py uses simulations_v3.py
```
python usage_v3.py config_files/config_varyqr_mp_lsdfocus.txt True False
```
## Plotting Results
Figure 2: r_scripts/varyqr_difference_complexsubstitution.R
Figure 3: r_scripts/lsdheight_vs_Q_fixedqr.R
Figure 4: r_scripts/varyqO_complexsubstitution.R
Figure S3: r_acripts/datacharacteristics.R
Figure S4: r_scripts/varyqr_loss_difference_complexsubstitution.R
Figure S5: r_scripts/varyqr_lsdfocus.R
Figure S6:r_scripts/varyqO_difference_complexsubtitution.R

