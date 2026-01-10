## Methods

Data analysis was performed in R (v4.5.1) using tidyverse-based workflows.

Statistical summaries were computed per formulation and particle size
distributions were visualised using boxplots.

## Outputs

- `figures/particle_size_boxplot.png`  
  Particle size distribution of meropenem-loaded NLC formulations.

- `outputs/summary_stats.csv`  
  Descriptive statistics (n, mean, SD, SE).

## How to Reproduce

```r
source("scripts/01_analysis.R")
