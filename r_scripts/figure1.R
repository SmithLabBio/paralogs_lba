library(dplyr)
library(ggplot2)

setwd('~/Documents/GitHub/paralogs_lba/')

# read files
results_ml <- read.csv('./results/figure1b/results_ml.csv')

results_mp <- read.csv('results/figure1b/results_mp.csv')

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
  filter(lsd == " True" & lsdonly == " True") %>%
  mutate(category = "LSD")

# combine data
results_plot <- bind_rows(all_data, sco_true, lsd_true) %>%
  mutate(category = factor(category, levels = c("SC", "All", "LSD"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML")))

# make a box plot
figure1 <- ggplot(results_plot, aes(x=category, y=q1)) + 
  geom_violin() + 
  facet_wrap(~ method, scales="free") + 
  labs(x = NULL, y = "Q1") +
  theme_bw() +
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=12),
    axis.text.y = element_text(size=12),
    axis.title.y = element_text(size=14)
  )

pdf('./figures/Figure1.pdf', height=3, width=7)
figure1
dev.off()

png('./figures/Figure1.png',height=3, width=7, units = "in", res=400)
figure1
dev.off()

