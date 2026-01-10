# 01_analysis.R  (copy/paste the whole file)

# 1) Load packages (installs tidyverse if missing)
if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
library(tidyverse)

# 2) Read data
df <- readr::read_csv("data/nlc_data.csv", show_col_types = FALSE)

# 3) Quick check
print(df)

# 4) Summary statistics (means)
summary_stats <- df %>%
  dplyr::group_by(Formulation) %>%
  dplyr::summarise(
    Size_mean = mean(Size_nm, na.rm = TRUE),
    PDI_mean  = mean(PDI, na.rm = TRUE),
    ZP_mean   = mean(ZP_mV, na.rm = TRUE),
    EE_mean   = mean(EE_percent, na.rm = TRUE),
    .groups = "drop"
  )

# 5) Save summary to outputs/
readr::write_csv(summary_stats, "outputs/summary_stats.csv")

# 6) Plot particle size
ggplot2::ggplot(df, ggplot2::aes(x = Formulation, y = Size_nm, fill = Formulation)) +
  ggplot2::geom_boxplot(alpha = 0.7, outlier.alpha = 0.4) +
  ggplot2::geom_jitter(width = 0.12, size = 2, alpha = 0.7) +
  ggplot2::theme_minimal(base_size = 13) +
  ggplot2::labs(
    title = "Particle size of meropenem-loaded NLCs",
    y = "Size (nm)",
    x = NULL
  )

