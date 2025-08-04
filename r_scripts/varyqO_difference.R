library(dplyr)
library(ggplot2)
library(viridis)
library(gridExtra)
library(paletteer)
library(patchwork)

setwd('~/Documents/GitHub/paralogs_lba/')

results_mp <- read.csv('results/varyqO_mp/results_mp.csv', sep=",")
results_ml <- read.csv('results/varyqO_ml/results_ml.csv', sep=",")

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
  filter(sco == TRUE) %>%
  mutate(category = "SC")

lsd_true <- results %>%
  filter(lsd == TRUE & lsdonly == TRUE) %>%
  mutate(category = "LSD")

# combine data
results_plot <- bind_rows(all_data, sco_true, lsd_true) %>%
  mutate(category = factor(category, levels = c("SC", "All", "LSD"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML")))

# calculate averages
data_average <- results_plot %>%
  mutate(q1 = as.numeric(q1)) %>%
  group_by(outgroup, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "MP - LSD", "ML - SC", "ML - All", "ML - LSD")))

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

# get differences
mp_data_diff_sc_all <- inner_join(data_average_mp_sc, data_average_mp_all,
                           by = c("outgroup", "qratio"),
                           suffix = c("_sc", "_all")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_all - avg_norm_qs_sc)
mp_data_diff_sc_lsd <- inner_join(data_average_mp_sc, data_average_mp_lsd,
                                  by = c("outgroup", "qratio"),
                                  suffix = c("_sc", "_lsd")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_lsd - avg_norm_qs_sc)
ml_data_diff_sc_all <- inner_join(data_average_ml_sc, data_average_ml_all,
                                  by = c("outgroup", "qratio"),
                                  suffix = c("_sc", "_all")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_all - avg_norm_qs_sc)
ml_data_diff_sc_lsd <- inner_join(data_average_ml_sc, data_average_ml_lsd,
                                  by = c("outgroup", "qratio"),
                                  suffix = c("_sc", "_lsd")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_lsd - avg_norm_qs_sc)

# make plots
figure_mp_diff_sc_all <- ggplot(mp_data_diff_sc_all, aes(x=outgroup, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1(All)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1.01, 1.01),
    name = "Q1(All) - Q1(SC)"
  ) +
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

figure_mp_diff_sc_lsd <- ggplot(mp_data_diff_sc_lsd, aes(x=outgroup, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1(LSD)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1.01, 1.01),
    name = "Q1(LSD) - Q1(SC)"
  ) +
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)#,
    #legend.position = "none"
  )

figure_ml_diff_sc_all <- ggplot(ml_data_diff_sc_all, aes(x=outgroup, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1(All)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1.01, 1.01),
    name = "Q1(All) - Q1(SC)"
  ) +
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

figure_ml_diff_sc_lsd <- ggplot(ml_data_diff_sc_lsd, aes(x=outgroup, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="O", y="q", fill="Q1(LSD)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1.01, 1.01),
    name = "Q1(LSD) - Q1(SC)"
  ) +
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)#,
    #legend.position = "none"
  )

combined_plot <- ((figure_mp_diff_sc_all | figure_mp_diff_sc_lsd) / (figure_ml_diff_sc_all | figure_ml_diff_sc_lsd)) + 
  plot_annotation(tag_levels = 'A')

pdf('./figures_revision/varyqO_difference.pdf', height=8, width=12)
combined_plot
dev.off()

