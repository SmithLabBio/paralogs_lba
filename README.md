# Paralogs and long-branch attraction

Scripts for paper "Using large gene families for phylogenetic inference mitigates the effects of long-branch attraction"

## Simulation Studies

We use the script usage.py for simulations.
This script relies on modules from simulate_data.py.
Both of these scripts must be in the working directory.
As input, this script takes a configuration files.
The configuration files used here are in the config_files folder.
Each is described below, and the command used to run the scirpt is shown.

### Varying the internal branch length, *r*, and the branch length multipliers for long branches, *q*

Maximum Parsimony (no loss): 
```
python usage.py config_files/config_varyqr_mp.txt True False
```

Maximum Likelihood (no loss):
```
python usage.py config_files/config_varyqr_ml.txt False True
```

Maximum Parsimony (loss): 
```
python usage.py config_files/config_varyqr_mp_loss.txt True False
```

Maximum Likelihood (loss):
```
python usage.py config_files/config_varyqr_ml_loss.txt False True
```

### Varying the ratio between total tree height and the ingroup height, *O*, and the branch length multipliers for long branches, *q*

Maximum Parsimony (no loss):
```
python usage.py config_files/config_varyqO_mp.txt True False
```

Maximum Likelihood (no loss):
```
python usage.py config_files/config_varyqO_ml.txt False True
```

### Evaluating the effect of duplicate age on inference

Maximum Parsimony (no loss):
```
python usage.py config_files/config_fixqr_lsdage_mp.txt True False
```
