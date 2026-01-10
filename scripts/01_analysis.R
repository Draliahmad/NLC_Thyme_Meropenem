# ============================================================
# Particle size boxplot with mean ± SD and statistical testing
# Meropenem-loaded NLCs
# ============================================================

library(readr)
library(dplyr)
library(ggplot2)
library(forcats)

# 1) Load data
df <- read_csv("data/nlc_data.csv", show_col_types = FALSE)

# 2) Detect columns
cn <- names(df)
form_col <- cn[grepl("formulation|group|sample|treat", cn, ignore.case = TRUE)][1]
size_col <- cn[grepl("size|particle|ps|nm", cn, ignore.case = TRUE)][1]
if (is.na(form_col)) stop("Formulation column not found")
if (is.na(size_col)) stop("Particle size column not found")

df <- df %>%
  rename(Formulation = all_of(form_col),
         Size_nm     = all_of(size_col)) %>%
  mutate(Formulation = as.factor(Formulation),
         Size_nm = as.numeric(Size_nm)) %>%
  filter(!is.na(Formulation), !is.na(Size_nm))

preferred_order <- c("Mero_NLC", "Mero+Thyme_NLC", "Mero_Thyme_NLC", "MeroThyme_NLC")
df <- df %>%
  mutate(Formulation = fct_relevel(Formulation,
                                  intersect(preferred_order, levels(Formulation))))

# 3) Summary stats
summary_stats <- df %>%
  group_by(Formulation) %>%
  summarise(
    n = n(),
    mean = mean(Size_nm),
    sd = ifelse(n >= 2, sd(Size_nm), 0),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f ± %.1f", mean, sd))

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write_csv(summary_stats, "outputs/summary_stats_particle_size.csv")

# 4) Statistical test (2 groups only)
if (nlevels(df$Formulation) != 2) stop("This script expects exactly TWO formulations")

levels_f <- levels(df$Formulation)
x1 <- df$Size_nm[df$Formulation == levels_f[1]]
x2 <- df$Size_nm[df$Formulation == levels_f[2]]

p_sh1 <- if (length(x1) >= 3) shapiro.test(x1)$p.value else NA
p_sh2 <- if (length(x2) >= 3) shapiro.test(x2)$p.value else NA

use_ttest <- !is.na(p_sh1) && !is.na(p_sh2) && p_sh1 > 0.05 && p_sh2 > 0.05

if (use_ttest) {
  test_name <- "t-test"
  p_value <- t.test(x1, x2)$p.value
} else {
  test_name <- "Mann-Whitney"
  p_value <- wilcox.test(x1, x2, exact = FALSE)$p.value
}

# ✅ FIXED IF/ELSE BLOCK
p_text <- if (p_value < 0.001) {
  "p < 0.001"
} else {
  paste0("p = ", formatC(p_value, digits = 3, format = "f"))
}

write_csv(
  data.frame(group1 = levels_f[1], group2 = levels_f[2], test = test_name, p_value = p_value),
  "outputs/group_comparison_particle_size.csv"
)

# 5) Annotation positions
ymin <- min(df$Size_nm)
ymax <- max(df$Size_nm)
yrange <- ymax - ymin

summary_stats <- summary_stats %>%
  mutate(y = mean + 0.08 * yrange)

y_bracket <- ymax + 0.22 * yrange
y_text <- y_bracket + 0.06 * yrange
tick <- 0.04 * yrange

# 6) Plot
p <- ggplot(df, aes(Formulation, Size_nm, fill = Formulation)) +
  geom_boxplot(width = 0.55, outlier.shape = NA, alpha = 0.8) +
  geom_jitter(width = 0.1, size = 2.2, alpha = 0.9) +
  stat_summary(fun = mean, geom = "point", size = 3.2, shape = 23) +
  geom_text(
    data = summary_stats,
    aes(x = Formulation, y = y, label = label),
    inherit.aes = FALSE,
    fontface = "bold",
    size = 3.6
  ) +
  annotate("segment", x = 1, xend = 2, y = y_bracket, yend = y_bracket) +
  annotate("segment", x = 1, xend = 1, y = y_bracket - tick, yend = y_bracket) +
  annotate("segment", x = 2, xend = 2, y = y_bracket - tick, yend = y_bracket) +
  annotate("text", x = 1.5, y = y_text,
           label = paste(test_name, p_text, sep = "\n"),
           fontface = "bold", size = 4) +
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
    legend.position = "right"
  ) +
  coord_cartesian(clip = "off")

# 7) Save
dir.create("figures", showWarnings = FALSE, recursive = TRUE)
ggsave("figures/particle_size_boxplot_stats.png", p, width = 7, height = 5, dpi = 300)
ggsave("figures/particle_size_boxplot_stats.pdf", p, width = 7, height = 5)

p
