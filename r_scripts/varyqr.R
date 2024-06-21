library(dplyr)
library(ggplot2)
library(viridis)

setwd('~/Documents/GitHub/paralogs_lba/')

# read files
results_ml <- read.csv('./results/varyqr_ml/results_ml.csv', sep=",")

results_mp <- read.csv('./results/varyqr/results_mp.csv', sep=",")

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
  mutate(q1 = as.numeric(q1)) %>%
  group_by(r, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "MP - LSD", "ML - SC", "ML - All", "ML - LSD")))



# make a box plot
figure <- ggplot(data_average, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + scale_fill_viridis_c(limits=c(0,1.0)) + 
  facet_wrap(~ method_category, scales="free") +
  theme(
    strip.text = element_text(size=12),
    axis.text.x = element_text(size=10),
    axis.text.y = element_text(size=10),
    axis.title.y = element_text(size=12)
  )



pdf('./figures/varyqr.pdf', height=6, width=10)
figure
dev.off()

png('./figures/varyqr.png',height=6, width=10, units = "in", res=400)
figure
dev.off()

