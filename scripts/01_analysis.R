# ============================================================
# 01_analysis.R
# Project: NLC_Thyme_Meropenem
# Purpose: Descriptive analysis + particle size figure export
# ============================================================

# ----------------------------
# Libraries
# ----------------------------
library(tidyverse)

# ----------------------------
# Safety: create folders FIRST
# ----------------------------
if (!dir.exists("figures")) dir.create("figures")
if (!dir.exists("outputs")) dir.create("outputs")

# ----------------------------
# Load data
# ----------------------------
df <- read_csv("data/nlc_data.csv")

# Expected columns (example):
# Formulation | Size_nm | PDI | ZP_mV | EE_percent | Drug

# ----------------------------
# Summary statistics
# ----------------------------
summary_stats <- df %>%
  group_by(Formulation) %>%
  summarise(
    n = n(),
    mean_size = mean(Size_nm, na.rm = TRUE),
    sd_size   = sd(Size_nm, na.rm = TRUE),
    min_size  = min(Size_nm, na.rm = TRUE),
    max_size  = max(Size_nm, na.rm = TRUE),
    .groups = "drop"
  )

# Save summary statistics
write_csv(summary_stats, "outputs/summary_stats.csv")

# ----------------------------
# Particle size boxplot
# ----------------------------
p_size <- ggplot(df, aes(x = Formulation, y = Size_nm, fill = Formulation)) +
  geom_boxplot(alpha = 0.7, width = 0.6, outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2, alpha = 0.8) +
  labs(
    title = "Particle size of meropenem-loaded NLCs",
    x = "Formulation",
    y = "Size (nm)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", hjust = 0.5)
  )

# ----------------------------
# SAVE FIGURE (AFTER folders exist)
# ----------------------------
ggsave(
  filename = "figures/particle_size_boxplot.png",
  plot = p_size,
  width = 7,
  height = 5,
  dpi = 300
)

# ----------------------------
# Confirmation messages
# ----------------------------
cat("✓ Plot saved to figures/particle_size_boxplot.png\n")
cat("✓ Summary stats saved to outputs/summary_stats.csv\n")
