library(dplyr)
library(ggplot2)
library(viridis)

setwd('~/Documents/GitHub/paralogs_lba/')

# read files
results <- read.csv('./results/varyqr/results_mp.csv', sep=",")

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
  mutate(category = factor(category, levels = c("SC", "All", "LSD")))

# calculate averages
data_average <- results_plot %>%
  mutate(q1 = as.numeric(q1)) %>%
  group_by(r, qratio, category) %>%
  summarize(avg_norm_qs = mean(q1, na.rm = TRUE))



# make a box plot
figure2 <- ggplot(data_average, aes(x=r, y=qratio, fill=avg_norm_qs)) +
  geom_tile() + 
  labs(x="r", y="q", fill="Q1") +
  theme_bw() + scale_fill_viridis_c(limits=c(0,1.0)) + 
  facet_wrap(~ category, scales="free") +
  theme(
    strip.text = element_text(size=12),
    axis.text.x = element_text(size=10),
    axis.text.y = element_text(size=10),
    axis.title.y = element_text(size=12)
  )

pdf('./figures/varyqr_mp.pdf', height=3, width=10)
figure2
dev.off()

png('./figures/varyqr_mp.png',height=3, width=10, units = "in", res=400)
figure2
dev.off()

