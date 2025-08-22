# Script for generating Figure 4

library(dplyr)
library(ggplot2)
library(viridis)
library(gridExtra)
library(paletteer)
library(patchwork)

setwd('~/Documents/GitHub/paralogs_lba/')

results_mp <- read.csv('results/varyqO_mp/results_mp.csv', sep=",")
results_ml <- read.csv('results/varyqO_ml/results_ml.csv', sep=",")
results_ml_complex <- read.csv('results/varyqO_ml_complexsubstitution_redo/results_ml.csv')

results_mp <- results_mp %>%
  mutate(method="MP")
results_ml <- results_ml %>%
  mutate(method="ML")
results_ml_complex <- results_ml_complex %>%
  mutate(method="ML (misspecified)") %>%
  select (-c("q2","q3")) %>%
  mutate(lsdonly = as.logical(lsdonly))

# combine data
results <- rbind(results_mp, results_ml, results_ml_complex)

results <- results %>%
  mutate(sco = as.logical(sco)) %>%
  mutate(lsd = as.logical(lsd))
  

# create data subsets
all_data <- results %>% 
  mutate(category = "All")

sco_true <- results %>%
  filter(sco == TRUE) %>%
  mutate(category = "SC")

lsd_true <- results %>%
  filter(lsd == TRUE & lsdonly == TRUE) %>%
  mutate(category = "LSD")

# combine data
results_plot <- bind_rows(all_data, sco_true, lsd_true) %>%
  mutate(category = factor(category, levels = c("SC", "All", "LSD"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML", "ML (misspecified)")))

# calculate averages
data_average <- results_plot %>%
  mutate(q1 = as.numeric(q1)) %>%
  group_by(outgroup, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "MP - LSD", "ML - SC", "ML - All", "ML - LSD", "ML (misspecified) - SC", "ML (misspecified) - All", "ML (misspecified) - LSD")))

# break apart again
data_average_mp_sc <- data_average %>%
  filter(method_category == "MP - SC")
data_average_mp_all <- data_average %>%
  filter(method_category == "MP - All")
data_average_mp_lsd <- data_average %>%
  filter(method_category == "MP - LSD")
data_average_ml_sc <- data_average %>%
  filter(method_category == "ML - SC")
data_average_ml_all <- data_average %>%
  filter(method_category == "ML - All")
data_average_ml_lsd <- data_average %>%
  filter(method_category == "ML - LSD")
data_average_ml_complex_sc <- data_average %>%
  filter(method_category == "ML (misspecified) - SC")
data_average_ml_complex_all <- data_average %>%
  filter(method_category == "ML (misspecified) - All")
data_average_ml_complex_lsd <- data_average %>%
  filter(method_category == "ML (misspecified) - LSD")

figure_mp_sc <- ggplot(data_average_mp_sc, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_mp_all <- ggplot(data_average_mp_all, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_mp_lsd <- ggplot(data_average_mp_lsd, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_ml_sc <- ggplot(data_average_ml_sc, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_ml_all <- ggplot(data_average_ml_all, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_ml_lsd <- ggplot(data_average_ml_lsd, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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

figure_ml_complex_sc <- ggplot(data_average_ml_complex_sc, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_ml_complex_all <- ggplot(data_average_ml_complex_all, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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
figure_ml_complex_lsd <- ggplot(data_average_ml_complex_lsd, aes(x=outgroup, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1") +
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

combined_plot <- ((figure_mp_sc | figure_mp_all | figure_mp_lsd) / (figure_ml_sc | figure_ml_all | figure_ml_lsd) / (figure_ml_complex_sc | figure_ml_complex_all | figure_ml_complex_lsd)) + 
  plot_annotation(tag_levels = 'A')

pdf('./figures_revision/varyqO_complexML.pdf', height=12, width=15)
combined_plot
dev.off()

