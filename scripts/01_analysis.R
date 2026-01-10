# ======================================================
# 01_analysis.R
# NLC_Thyme_Meropenem
# ======================================================

# ---- Libraries ----
library(tidyverse)

# ---- Project root (SAFE) ----
# IMPORTANT: open the PROJECT, not the script
# DO NOT run setwd() if you opened the project properly
# getwd() should end in: NLC_Thyme_Meropenem

# ---- Create folders if missing (FIRST) ----
if (!dir.exists("figures")) dir.create("figures")
if (!dir.exists("outputs")) dir.create("outputs")

# ---- Load data ----
df <- read_csv("data/nlc_data.csv")

# ---- Summary statistics ----
summary_stats <- df %>%
  group_by(Formulation) %>%
  summarise(
    n = n(),
    mean_size = mean(Size_nm),
    sd_size = sd(Size_nm),
    .groups = "drop"
  )

# ---- Save summary table ----
write_csv(summary_stats, "outputs/summary_stats.csv")

# ---- Boxplot ----
p_size <- ggplot(df, aes(x = Formulation, y = Size_nm, fill = Formulation)) +
  geom_boxplot(width = 0.5, outlier.shape = 16) +
  labs(
    title = "Particle size of meropenem-loaded NLCs",
    x = "Formulation",
    y = "Size (nm)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "right")

# ---- SAVE FIGURE (AFTER folders exist) ----
ggsave(
  filename = "figures/particle_size_boxplot.png",
  plot = p_size,
  width = 7,
  height = 5,
  dpi = 300
)

# ---- Confirmation messages ----
cat("✔ Plot saved to figures/particle_size_boxplot.png\n")
cat("✔ Summary stats saved to outputs/summary_stats.csv\n")
