library(dplyr)
library(ggplot2)
library(viridis)
library(gridExtra)
library(paletteer)
library(patchwork)

setwd('~/Documents/GitHub/paralogs_lba/')

results_mp <- read.csv('results/varyqr_mp/results_mp.csv', sep=",")
results_ml <- read.csv('results/varyqr_ml/results_ml.csv', sep=",")
results_ml_complex <- read.csv('results/varyqr_ml_complexsubstitution/results_ml.csv')

results_mp <- results_mp %>%
  mutate(method="MP")
results_ml <- results_ml %>%
  mutate(method="ML")
results_ml_complex <- results_ml_complex %>%
  mutate(method="ML-misspecified") %>%
  select (-c("q2","q3"))

# combine data
results <- rbind(results_mp, results_ml, results_ml_complex)

# create data subsets
all_data <- results %>% 
  mutate(category = "All")

sco_true <- results %>%
  filter(sco == TRUE | sco == "True") %>%
  mutate(category = "SC")

# combine data
results_plot <- bind_rows(all_data, sco_true) %>%
  mutate(category = factor(category, levels = c("SC", "All"))) %>%
  mutate(method = factor(method, levels = c("MP", "ML", "ML-misspecified")))

# calculate averages
data_average <- results_plot %>%
  mutate(q1 = as.numeric(q1)) %>%
  group_by(r, qratio, method, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE)) %>%
  mutate(method_category = paste(method, category, sep = " - ")) %>%
  mutate(method_category = factor(method_category, levels = c("MP - SC", "MP - All", "ML - SC", "ML - All", "ML-misspecified - SC", "ML-misspecified - All")))

# break apart again
data_average_mp_sc <- data_average %>%
  filter(method_category == "MP - SC")
data_average_mp_all <- data_average %>%
  filter(method_category == "MP - All")
data_average_ml_sc <- data_average %>%
  filter(method_category == "ML - SC")
data_average_ml_all <- data_average %>%
  filter(method_category == "ML - All")
data_average_ml_complex_sc <- data_average %>%
  filter(method_category == "ML-misspecified - SC")
data_average_ml_complex_all <- data_average %>%
  filter(method_category == "ML-misspecified - All")

# compute differences
mp_data_diff <- inner_join(data_average_mp_sc, data_average_mp_all,
                        by = c("r", "qratio"),
                        suffix = c("_sc", "_all")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_all - avg_norm_qs_sc)
ml_data_diff <- inner_join(data_average_ml_sc, data_average_ml_all,
                           by = c("r", "qratio"),
                           suffix = c("_sc", "_all")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_all - avg_norm_qs_sc)
ml_complex_data_diff <- inner_join(data_average_ml_complex_sc, data_average_ml_complex_all,
                           by = c("r", "qratio"),
                           suffix = c("_sc", "_all")) %>%
  mutate(diff_avg_norm_qs = avg_norm_qs_all - avg_norm_qs_sc)

# original plots
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

figure_ml_complex_sc <- ggplot(data_average_ml_complex_sc, aes(x=r, y=qratio, fill=avg_norm_qs)) +
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
figure_ml_complex_all <- ggplot(data_average_ml_complex_all, aes(x=r, y=qratio, fill=avg_norm_qs)) +
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


# we want to plot the difference between plots A and B 
figure_mp_diff <- ggplot(mp_data_diff, aes(x=r, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1(All)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-0.65, 0.65),
    name = "Q1(All) - Q1(SC)"
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

figure_ml_diff <- ggplot(ml_data_diff, aes(x=r, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1(All)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-0.65, 0.65),
    name = "Q1(All) - Q1(SC)"
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

figure_ml_complex_diff <- ggplot(ml_complex_data_diff, aes(x=r, y=qratio, fill=diff_avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1(All)-Q1(SC)") +
  theme_bw() + 
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-0.65, 0.65),
    name = "Q1(All) - Q1(SC)"
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

# compute average differences
avg_dif_mp <- sum(mp_data_diff$diff_avg_norm_qs)/ nrow(mp_data_diff)
avg_dif_ml <- sum(ml_data_diff$diff_avg_norm_qs)/ nrow(mp_data_diff)

# histograms
hist(mp_data_diff$diff_avg_norm_qs)
hist(ml_data_diff$diff_avg_norm_qs)

combined_plot <- ((figure_mp_sc | figure_mp_all | figure_mp_diff) / (figure_ml_sc | figure_ml_all | figure_ml_diff) /
                    (figure_ml_complex_sc | figure_ml_complex_all | figure_ml_complex_diff)) + 
  plot_annotation(tag_levels = 'A')

pdf('./figures_revision/varyqr_diff_complexML.pdf', height=12, width=16)
combined_plot
dev.off()
