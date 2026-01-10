# NLC_Thyme_Meropenem

Reproducible analysis workflow for meropenem-loaded nanostructured lipid carriers (NLCs), including figure generation and statistical outputs.

---

## Project structure
NLC_Thyme_Meropenem/
├── data/
│ └── nlc_data.csv
├── scripts/
│ ├── 01_analysis.R
│ └── 02_stats.R
├── figures/
├── outputs/
└── README.md

---

## Particle size analysis (Meropenem-loaded NLCs)

### Script
- `scripts/01_analysis.R`

### Input
- `data/nlc_data.csv`  
  The script automatically detects columns using keywords:
  - **Formulation/group** column: `formulation`, `group`, `sample`, or `treat`
  - **Particle size** column (nm): `size`, `particle`, `ps`, or `nm`

### Analysis performed
- Summary statistics (**mean ± SD**) per formulation
- Shapiro–Wilk normality test (when n ≥ 3 per group)
- Automatic 2-group comparison:
  - **t-test** if both groups pass normality
  - **Mann–Whitney** otherwise
- Publication-ready figure:
  - boxplot + individual points
  - mean point
  - mean ± SD labels
  - p-value bracket annotation

### Outputs
**Figures**
- `figures/particle_size_boxplot_stats.png`
- `figures/particle_size_boxplot_stats.pdf`
## Example output

**Particle size of meropenem-loaded NLCs**

![Particle size boxplot](figures/particle_size_boxplot_stats.png)

**Tables**
- `outputs/summary_stats_particle_size.csv`
- `outputs/group_comparison_particle_size.csv`

---

## How to run

From the project root in R / Positron / RStudio:

```r
source("scripts/01_analysis.R")
