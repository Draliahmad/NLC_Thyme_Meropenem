# =========================
# 02_stats.R
# Statistical comparison of NLC formulations
# =========================

# Load libraries
library(tidyverse)
library(effsize)

# -------------------------
# Load data
# -------------------------
df <- read_csv("data/nlc_data.csv")

# Ensure correct factor levels
df$Formulation <- factor(
  df$Formulation,
  levels = c("Mero_NLC", "Mero+Thyme_NLC")
)

# -------------------------
# T-tests
# -------------------------
t_size <- t.test(Size_nm ~ Formulation, data = df)
t_pdi  <- t.test(PDI ~ Formulation, data = df)
t_zp   <- t.test(ZP_mV ~ Formulation, data = df)
t_ee   <- t.test(EE_percent ~ Formulation, data = df)

# -------------------------
# Effect sizes (Cohen's d)
# -------------------------
d_size <- cohen.d(Size_nm ~ Formulation, data = df)
d_pdi  <- cohen.d(PDI ~ Formulation, data = df)
d_zp   <- cohen.d(ZP_mV ~ Formulation, data = df)
d_ee   <- cohen.d(EE_percent ~ Formulation, data = df)

# -------------------------
# Final results table
# -------------------------
final_results <- tibble(
  Parameter = c(
    "Particle size (nm)",
    "PDI",
    "Zeta potential (mV)",
    "Encapsulation efficiency (%)"
  ),

  Mean_Mero_NLC = c(
    mean(df$Size_nm[df$Formulation == "Mero_NLC"]),
    mean(df$PDI[df$Formulation == "Mero_NLC"]),
    mean(df$ZP_mV[df$Formulation == "Mero_NLC"]),
    mean(df$EE_percent[df$Formulation == "Mero_NLC"])
  ),

  Mean_Mero_Thyme_NLC = c(
    mean(df$Size_nm[df$Formulation == "Mero+Thyme_NLC"]),
    mean(df$PDI[df$Formulation == "Mero+Thyme_NLC"]),
    mean(df$ZP_mV[df$Formulation == "Mero+Thyme_NLC"]),
    mean(df$EE_percent[df$Formulation == "Mero+Thyme_NLC"])
  ),

  P_value = c(
    t_size$p.value,
    t_pdi$p.value,
    t_zp$p.value,
    t_ee$p.value
  ),

  Cohens_d = c(
    d_size$estimate,
    d_pdi$estimate,
    d_zp$estimate,
    d_ee$estimate
  )
)

# -------------------------
# Save + print
# -------------------------
write_csv(final_results, "outputs/final_statistical_results.csv")
print(final_results)

