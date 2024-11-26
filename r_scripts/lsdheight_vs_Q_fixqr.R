library(dplyr)
library(ggplot2)


setwd('/mnt/home/ms4438/paralogs_lba/')

# read files

results_mp <- read.csv('/mnt/scratch/smithfs/megan/lba/fixqr_lsdage_mp/results_mp.csv', sep=",")
# add new columns indicating method

results_mp <- results_mp %>%
  mutate(method="MP")

# combine data frames
results <- results_mp
results$max.age = as.numeric(results$max.age)
results$min.age = as.numeric(results$min.age)

# get only results with heights
heights <- results %>%
  filter(lsdtrue == "True") %>%
  filter(lsdonlytrue == " True") %>%
  mutate(category = "LSD")

# filter to include only 0 or 1
heights_filt <- heights %>%
  filter(q1 == 0 | q1 == 1) %>%
    mutate(q1_cat = factor(case_when(
    q1 == 1 ~ "Concordant",
    q1 == 0 ~ "Discordant"))) %>%
    mutate(prop_age = max.age/0.5)

print(nrow(heights))
print(nrow(heights_filt))

figure_mp_max_filt <- ggplot(heights_filt, aes(x = q1_cat, y=prop_age, fill=q1_cat)) +
  geom_violin() +
  geom_boxplot(width=0.1, fill="white")+
  labs(y="Age of Duplication") +
  scale_fill_manual(values = c("Discordant" = "#bd3228", "Concordant" = "#90d3cb")) +
  theme_bw() + theme(legend.position="none")+ 
  theme(
    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=14),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size=16),
  )






pdf('./figures/fix_lsdheight_max_filt.pdf', height=6, width=6)
figure_mp_max_filt
dev.off()
