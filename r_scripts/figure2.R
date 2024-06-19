library(dplyr)
library(ggplot2)
library(viridis)

setwd('~/Documents/GitHub/paralogs_lba/')

# read files
results_ml <- read.csv('./old_results/vary_qratio_r/results_ml.tsv', sep="\t")

results_mp <- read.csv('./old_results/vary_qratio_r/results_mp.tsv', sep="\t")

# add new columns indicating method
results_ml <- results_ml %>% 
  mutate(method="ML")

results_mp <- results_mp %>%
  mutate(method="MP")

# combine data frames
results <- bind_rows(results_ml, results_mp)

# create data subsets
all_data <- results %>% 
  mutate(category = "All")

sco_true <- results %>%
  filter(sco == "True") %>%
  mutate(category = "SC")

lsd_true <- results %>%
  filter(lsd == "True" & lsdonly == "True") %>%
  mutate(category = "LSD")

# combine data
results_plot <- bind_rows(all_data, sco_true, lsd_true) %>%
  mutate(category = factor(category, levels = c("SC", "All", "LSD"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML")))

# calculate averages
data_average <- results_plot %>%
  mutate(normalized.QS = as.numeric(normalized.QS)) %>%
  group_by(r, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(normalized.QS, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "MP - LSD", "ML - SC", "ML - All", "ML - LSD")))



# make a box plot
figure2 <- ggplot(data_average, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + scale_fill_viridis_c(limits=c(0,1.0)) + 
  facet_wrap(~ method_category, scales="free") +
  theme(
    strip.text = element_text(size=12),
    axis.text.x = element_text(size=12),
    axis.text.y = element_text(size=12),
    axis.title.y = element_text(size=12)
  )

pdf('./figures/Figure2.pdf', height=7, width=10)
figure2
dev.off()

png('./figures/Figure2.png',height=5, width=10, units = "in", res=400)
figure2
dev.off()

