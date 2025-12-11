# Digital Divide in Illinois Counties

Author: Huan Yang  
Course: PA 446 – Coding for Civic Data Applications  

## Project Overview

This project looks at broadband access across Illinois counties using data from the American Community Survey (ACS). I focus on three main questions:

1. How does broadband access vary across counties in Illinois?
2. How is broadband access related to median household income?
3. Can a simple decision tree model classify which counties are at higher risk of low broadband access based on income?

The project includes:

- R scripts for data download, cleaning, and visualization  
- A reproducible R Markdown report  
- An interactive HTML table inside the report  

---

## Repository Structure

```text
project-root/
  README.md
  data/
    raw/
      il_broadband_raw.rds
    processed/
      il_broadband_geo.rds
      il_broadband.csv
  figs/
    map_broadband.png
    scatter_income_broadband.png
    hist_pct_broadband.png
  scripts/
    01_get_data.R
    02_clean_broadband.R
    03_analysis_plots.R
    04_decision_tree.R
    # (optional) 00_run_all.R
  reports/
    final_report_clean.Rmd
    final_report_clean.html  # knitted output
  memo/
    final_memo.docx          # reflection memo
```

---

## Data Description

### Source

All data come from the **American Community Survey (ACS) 5-year estimates** for Illinois counties. The data are pulled via the Census API using the `tidycensus` package in R.

Key ACS tables:

- Median household income  
- Total households (internet table)  
- Households with broadband of any type  

### Raw Data

- `data/raw/il_broadband_raw.rds`  
  - Output of `scripts/01_get_data.R`  
  - Contains county-level ACS data with geometry for mapping  

### Processed Data

Two processed files are created in `scripts/02_clean_broadband.R`:

- `data/processed/il_broadband_geo.rds`  
  - Simple features (`sf`) object with county boundaries and variables  
- `data/processed/il_broadband.csv`  
  - Regular data frame (no geometry) with one row per county and these main variables:
    - `county` – county name  
    - `geoid` – county FIPS code  
    - `med_income` – median household income (USD)  
    - `hh_total` – total households in internet table  
    - `hh_broadband_any` – households with broadband of any type  
    - `pct_broadband_any` – percentage of households with broadband  

---

## Scripts

All scripts are in the `scripts/` folder.

### `01_get_data.R`

- Loads packages (`tidycensus`, `tidyverse`, `sf`)  
- Sets ACS year and state (Illinois)  
- Requests ACS 5-year data for all Illinois counties via the Census API  
- Saves the raw result to `data/raw/il_broadband_raw.rds`

> Note: You need a Census API key set in your R environment (via `census_api_key()` or `.Renviron`) for this script to run.

### `02_clean_broadband.R`

- Reads `data/raw/il_broadband_raw.rds`  
- Cleans and renames variables  
- Calculates `pct_broadband_any` = 100 * broadband households / total households  
- Creates:
  - `data/processed/il_broadband_geo.rds`
  - `data/processed/il_broadband.csv`

### `03_analysis_plots.R`

- Reads `data/processed/il_broadband_geo.rds` and `data/processed/il_broadband.csv`  
- Produces three visualizations and saves them to `figs/`:
  - `map_broadband.png` – choropleth map of broadband access by county  
  - `scatter_income_broadband.png` – scatterplot of income vs. broadband access with a fitted line  
  - `hist_pct_broadband.png` – histogram of broadband access percentages across counties  

These PNG files are later included in the R Markdown report.

### `04_decision_tree.R`

- Reads `data/processed/il_broadband.csv`  
- Creates a binary variable `low_bb` indicating whether a county’s broadband percentage is below the statewide median  
- Splits the data into training and test sets  
- Fits a decision tree classifier (`tidymodels` + `rpart`) with `low_bb` as the target and `med_income` as the predictor  
- Computes model performance metrics and plots the decision tree  

This script is mainly a development/analysis script; the final decision tree code is also included inside the R Markdown report.

### (Optional) `00_run_all.R`

If present, this script can be used as a “pipeline runner”:

- Runs `01_get_data.R`  
- Runs `02_clean_broadband.R`  
- Knits the report  

---

## Report

The main written product is:

- `reports/final_report_clean.Rmd`  
- Knitted to `reports/final_report_clean.html`

The report includes:

1. Background and research questions  
2. Description of data and key variables  
3. Results
   - Map of broadband access by county  
   - Scatterplot of income vs broadband access  
   - Histogram of broadband access percentages  
   - Interactive table of counties (using `DT`)  
   - Decision tree model and interpretation  
4. Interpretation and policy implications  
5. Ethics, fairness, and limitations  
6. Conclusion and possible next steps  

All analysis in the report is based on the processed data created in `scripts/02_clean_broadband.R`.

---

## How to Replicate the Analysis

Below are step-by-step instructions to reproduce the results from a fresh clone.

### 1. Clone or download the repository

From the command line:

```bash
git clone <your-repo-url>.git
cd <your-repo-name>
```

Or download the ZIP from GitHub and unzip it.

### 2. Open the project in RStudio

- Open RStudio  
- Use **File → Open Project…** and select the project folder (if you created an `.Rproj` file), or set the working directory to the repo root.

### 3. Install required R packages

In the R console, run:

```r
install.packages(c(
  "tidyverse",
  "sf",
  "tidycensus",
  "tmap",
  "tidymodels",
  "rpart",
  "rpart.plot",
  "DT",
  "knitr",
  "rmarkdown"
))
```

### 4. Set up your Census API key

If you plan to re-download data:

```r
tidycensus::census_api_key("YOUR_API_KEY_HERE", install = TRUE)
```

Then restart R so the key is picked up.

If you only want to use the provided processed data (`data/processed/*`), you can skip this step.

### 5. Run the data pipeline

From the RStudio console:

```r
source("scripts/01_get_data.R")        # downloads raw ACS data
source("scripts/02_clean_broadband.R") # cleans and processes data
```

This will create/update the raw and processed data files.

### 6. Generate figures (if needed)

```r
source("scripts/03_analysis_plots.R")
```

This will write the PNG files used in the report to the `figs/` folder.

### 7. Knit the report

Open `reports/final_report_clean.Rmd` in RStudio and click **Knit** (to HTML).  
The output file `final_report_clean.html` will appear in the same folder.

### 8. (Optional) Run the decision tree script

```r
source("scripts/04_decision_tree.R")
```

This is mainly for exploring the model outside the report.

---

## Notes

- All paths in the scripts and R Markdown file assume that you are running R from the **project root** (the folder that contains `data/`, `scripts/`, `reports/`, etc.).  
- If you change folder names or move files, you may need to update the paths accordingly.  

This README is meant to give another student or instructor enough information to understand the project, see how the data were prepared, and fully reproduce the analysis and visuals.
