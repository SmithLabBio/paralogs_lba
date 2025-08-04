library(dplyr)
library(ggplot2)
library(viridis)
library(gridExtra)
library(paletteer)
library(patchwork)

setwd('/mnt/home/ms4438/paralogs_lba/')

results_mp <- read.csv('results/varyqr_mp/results_mp.csv', sep=",")
results_ml <- read.csv('results/varyqr_ml/results_ml.csv', sep=",")

results_mp <- results_mp %>%
  mutate(method="MP")
results_ml <- results_ml %>%
  mutate(method="ML")

# combine data
results <- rbind(results_mp, results_ml)

# create data subsets
all_data <- results %>% 
  mutate(category = "All")

sco_true <- results %>%
  filter(sco == "True") %>%
  mutate(category = "SC")

# combine data
results_plot <- bind_rows(all_data, sco_true) %>%
  mutate(category = factor(category, levels = c("SC", "All"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML")))

# calculate averages
data_average <- results_plot %>%
  mutate(q1 = as.numeric(q1)) %>%
  group_by(r, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "ML - SC", "ML - All")))

# break apart again
data_average_mp_sc <- data_average %>%
  filter(method_category == "MP - SC")
data_average_mp_all <- data_average %>%
  filter(method_category == "MP - All")
data_average_ml_sc <- data_average %>%
  filter(method_category == "ML - SC")
data_average_ml_all <- data_average %>%
  filter(method_category == "ML - All")


figure_mp_sc <- ggplot(data_average_mp_sc, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + 
  scale_fill_viridis_c(limits=c(0,1.0), option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14),
    legend.position = "none"
  )
figure_mp_all <- ggplot(data_average_mp_all, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + 
  scale_fill_viridis_c(limits=c(0,1.0), option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14),
    legend.position = "right"
  )
figure_ml_sc <- ggplot(data_average_ml_sc, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + 
  scale_fill_viridis_c(limits=c(0,1.0), option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14),
    legend.position = "none"
  )
figure_ml_all <- ggplot(data_average_ml_all, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + 
  scale_fill_viridis_c(limits=c(0,1.0), option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14),
    legend.position = "right"
  )

combined_plot <- ((figure_mp_sc | figure_mp_all) / (figure_ml_sc | figure_ml_all)) + 
  plot_annotation(tag_levels = 'A')

pdf('./figures/varyqr.pdf', height=8, width=10)
combined_plot
dev.off()
