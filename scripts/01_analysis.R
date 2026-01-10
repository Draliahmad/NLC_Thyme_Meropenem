# ===============================
# 01_analysis.R
# NLC_Thyme_Meropenem
# ===============================

# ---- Libraries ----
library(tidyverse)

# ---- Working directory safety check ----
# (Optional but recommended)
# setwd("/Users/mariamurad/NLC_Thyme_Meropenem")

# ---- Load data ----
df <- read_csv("data/nlc_data.csv")

# ---- Ensure figures directory exists (MUST BE FIRST) ----
if (!dir.exists("figures")) {
  dir.create("figures")
}

# ---- Particle size boxplot ----
p_size <- ggplot(
  df,
  aes(
    x = Formulation,
    y = Size_nm,
    fill = Formulation
  )
) +
  geom_boxplot(alpha = 0.7, width = 0.6, outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2, alpha = 0.9) +
  labs(
    title = "Particle size of meropenem-loaded NLCs",
    y = "Size (nm)",
    x = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold")
  )

# ---- Display plot in Viewer ----
p_size

# ---- SAVE plot to figures/ (AFTER folder exists) ----
ggsave(
  filename = "figures/particle_size_boxplot.png",
  plot     = p_size,
  width    = 7,
  height   = 5,
  dpi      = 300
)

# ---- Message for confirmation ----
cat("✔ Plot saved to figures/particle_size_boxplot.png\n")
