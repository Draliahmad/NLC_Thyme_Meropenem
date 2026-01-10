# =========================================
# Boxplot + points + mean ± SD labels
# + statistical comparison (t-test or Mann-Whitney)
# (NO ggpubr / NO rstatix needed)
# =========================================

library(readr)
library(dplyr)
library(ggplot2)
library(forcats)

# -------------------------
# 1) Load data
# -------------------------
df <- read_csv("data/nlc_data.csv", show_col_types = FALSE)

# -------------------------
# 2) Robust column detection
# -------------------------
cn <- names(df)

form_col <- cn[grepl("formulation|group|sample|treat", cn, ignore.case = TRUE)][1]
if (is.na(form_col) || length(form_col) == 0) stop("Couldn't find a formulation/group column.")

size_col <- cn[grepl("size|particle|ps|nm", cn, ignore.case = TRUE)][1]
if (is.na(size_col) || length(size_col) == 0) stop("Couldn't find a particle size column.")

df <- df %>%
  rename(
    Formulation = all_of(form_col),
    Size_nm     = all_of(size_col)
  ) %>%
  mutate(
    Formulation = as.factor(Formulation),
    Size_nm     = as.numeric(Size_nm)
  ) %>%
  filter(!is.na(Formulation), !is.na(Size_nm))

# Optional: set preferred order if present
preferred_order <- c("Mero_NLC", "Mero+Thyme_NLC", "Mero_Thyme_NLC", "MeroThyme_NLC")
df <- df %>%
  mutate(Formulation = fct_relevel(Formulation, intersect(preferred_order, levels(Formulation))))

# -------------------------
# 3) Summary stats (mean ± SD)
# -------------------------
sumstats <- df %>%
  group_by(Formulation) %>%
  summarise(
    n = n(),
    mean = mean(Size_nm),
    sd = ifelse(n() >= 2, sd(Size_nm), 0),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f \u00B1 %.1f", mean, sd))

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write_csv(sumstats, "outputs/summary_stats_particle_size.csv")

# -------------------------
# 4) Statistical comparison (expects exactly 2 groups)
# -------------------------
ng <- nlevels(df$Formulation)
if (ng != 2) {
  stop(paste0(
    "This script adds ONE comparison and expects 2 groups. You have ", ng,
    ". If you want pairwise comparisons for >2 groups, tell me."
  ))
}

lvl <- levels(df$Formulation)
g1 <- lvl[1]; g2 <- lvl[2]

x1 <- df$Size_nm[df$Formulation == g1]
x2 <- df$Size_nm[df$Formulation == g2]

p_sh1 <- if (length(x1) >= 3) shapiro.test(x1)$p.value else NA_real_
p_sh2 <- if (length(x2) >= 3) shapiro.test(x2)$p.value else NA_real_

use_ttest <- !is.na(p_sh1) && !is.na(p_sh2) && p_sh1 > 0.05 && p_sh2 > 0.05

if (use_ttest) {
  test_name <- "t-test"
  pval <- t.test(x1, x2)$p.value
} else {
  test_name <- "Mann-Whitney"   # ✅ FIXED (normal hyphen)
  pval <- wilcox.test(x1, x2, exact = FALSE)$p.value
}

p_text <- if (pval < 0.001) "p < 0.001" else paste0("p = ", formatC(pval, format = "f", digits = 3))

test_out <- data.frame(
  group1 = g1,
  group2 = g2,
  test = test_name,
  p_value = pval,
  shapiro_p_group1 = p_sh1,
  shapiro_p_group2 = p_sh2
)
write_csv(test_out, "outputs/group_comparison_particle_size.csv")

# -------------------------
# 5) Label positions
# -------------------------
ymin <- min(df$Size_nm, na.rm = TRUE)
ymax <- max(df$Size_nm, na.rm = TRUE)
y_range <- ymax - ymin

offset_mean <- 0.08 * y_range
offset_bracket <- 0.22 * y_range

label_df <- sumstats %>%
  mutate(y = mean + offset_mean)

y_bracket <- ymax + offset_bracket
y_text <- y_bracket + 0.06 * y_range
tick_h <- 0.04 * y_range

# -------------------------
# 6) Plot
# -------------------------
p <- ggplot(df, aes(x = Formulation, y = Size_nm, fill = Formulation)) +
  geom_boxplot(
    width = 0.55,
    outlier.shape = NA,
    alpha = 0.8,
    linewidth = 0.6
  ) +
  geom_jitter(
    width = 0.10,
    height = 0,
    size = 2.2,
    alpha = 0.9
  ) +
  stat_summary(fun = mean, geom = "point", size = 3.2, shape = 23) +
  geom_text(
    data = label_df,
    aes(x = Formulation, y = y, label = label),
    inherit.aes = FALSE,
    size = 3.6,
    fontface = "bold",
    vjust = 0
  ) +
  annotate("segment", x = 1, xend = 2, y = y_bracket, yend = y_bracket, linewidth = 0.6) +
  annotate("segment", x = 1, xend = 1, y = y_bracket - tick_h, yend = y_bracket, linewidth = 0.6) +
  annotate("segment", x = 2, xend = 2, y = y_bracket - tick_h, yend = y_bracket, linewidth = 0.6) +
  annotate("text", x = 1.5, y = y_text, label = paste0(test_name, "\n", p_text),
           size = 4, fontface = "bold") +
  labs(
    title = "Particle size of meropenem-loaded NLCs",
    x = "Formulation",
    y = "Size (nm)"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold"),
    legend.title = element_blank(),
    legend.position = "right",
    plot.margin = margin(10, 15, 10, 10)
  ) +
  coord_cartesian(clip = "off")

# -------------------------
# 7) Save
# -------------------------
dir.create("figures", showWarnings = FALSE, recursive = TRUE)
ggsave("figures/particle_size_boxplot_stats.png", p, width = 7, height = 5, dpi = 300)
ggsave("figures/particle_size_boxplot_stats.pdf", p, width = 7, height = 5)

p
