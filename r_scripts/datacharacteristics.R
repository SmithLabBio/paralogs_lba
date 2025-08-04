library(dplyr)
library(ggplot2)
library(viridis)
library(gridExtra)
library(paletteer)
library(patchwork)

setwd('~/Documents/GitHub/paralogs_lba/')

results_mp_noloss <- read.csv('results_revision/varyqr_mp_additional.csv', sep=',')
results_mp_loss <- read.csv('results_revision/varyqr_mp_loss_additional.csv', sep=',')

# add method variable and condition variable
results_mp_noloss <- results_mp_noloss %>%
  mutate(method="MP") %>%
  mutate(loss=FALSE)
results_mp_loss <- results_mp_loss %>%
  mutate(method="MP") %>%
  mutate(loss=TRUE)

# combine data
results <- rbind(results_mp_noloss, results_mp_loss)

# calculate averages
results_revised <- results %>%
  mutate(q1 = as.numeric(q1)) %>%
  mutate(sco = as.logical(sco)) %>%
  mutate(lsd = as.logical(lsd)) %>%
  mutate(lsdonly = as.logical(lsdonly)) %>%
  mutate(lsdcount = lsd & lsdonly) %>%
  mutate(lsdtrue = as.logical(lsdtrue)) %>%
  mutate(lsdonlytrue = trimws(lsdonlytrue) %>% tolower() == "true") %>%
  mutate(lsdcounttrue = lsdtrue & lsdonlytrue) 

data_average <- results_revised %>%
  group_by(r, qratio, method, loss) %>%
  summarize(
    avg_norm_qs = mean(q1, na.rm = TRUE),
    avg_duplications = mean(num_duplications, na.rm = TRUE),
    avg_sco = sum(sco, na.rm=TRUE),
    avg_lsd = sum(lsdcount, na.rm = TRUE),
    avg_lsdtrue = sum(lsdcounttrue, na.rm = TRUE)
    ) %>%
  mutate(method_loss = paste(method, loss, sep = " - "))

# break apart again
data_average_mp_noloss <- data_average %>%
  filter(method_loss == "MP - FALSE")
data_average_mp_loss <- data_average %>%
  filter(method_loss == "MP - TRUE")


# original plots
figure_mp_noloss_sco <- ggplot(data_average_mp_noloss, aes(x=r, y=qratio, fill=avg_sco)) +
  geom_tile() + 
  labs(x="r", y="q", fill="# SC") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

figure_mp_noloss_lsd <- ggplot(data_average_mp_noloss, aes(x=r, y=qratio, fill=avg_lsdtrue)) +
  geom_tile() + 
  labs(x="r", y="q", fill="# LSD") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

figure_mp_noloss_duplications <- ggplot(data_average_mp_noloss, aes(x=r, y=qratio, fill=avg_duplications)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Average # duplications") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

figure_mp_loss_sco <- ggplot(data_average_mp_loss, aes(x=r, y=qratio, fill=avg_sco)) +
  geom_tile() + 
  labs(x="r", y="q", fill="# SC") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

figure_mp_loss_lsd <- ggplot(data_average_mp_loss, aes(x=r, y=qratio, fill=avg_lsdtrue)) +
  geom_tile() + 
  labs(x="r", y="q", fill="# LSD") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

figure_mp_loss_duplications <- ggplot(data_average_mp_loss, aes(x=r, y=qratio, fill=avg_duplications)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Average # duplications") +
  theme_bw() + 
  scale_fill_viridis_c(option="magma") + 
  theme(
    strip.text = element_text(size=14),
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.title.x = element_text(size=14),
    legend.text = element_text(size=14),
    legend.title = element_text(size=14)
  )

combined_plot <- ((figure_mp_noloss_sco | figure_mp_noloss_lsd | figure_mp_noloss_duplications) / ((figure_mp_loss_sco | figure_mp_loss_lsd | figure_mp_loss_duplications))) + 
  plot_annotation(tag_levels = 'A')

# THIS DOES NOT MAKE SENSE...
sum(results_mp_noloss$num_duplications)/length(results_mp_noloss$num_duplications)
sum(results_mp_loss$num_duplications)/length(results_mp_loss$num_duplications)


pdf('./figures_revision/datasummary.pdf', height=8, width=16)
combined_plot
dev.off()
