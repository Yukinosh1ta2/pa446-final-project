library(tidycensus)
library(tidyverse)
library(sf)

options(tigris_use_cache = TRUE)

acs_year   <- 2023
state_abbr <- "IL"

# Variables:
# - B19013_001: Median household income
# - B28002_001: Total households in internet table
# - B28002_004: Households with broadband of any type
acs_vars <- c(
  med_income       = "B19013_001",
  hh_total         = "B28002_001",
  hh_broadband_any = "B28002_004"
)

# Pull ACS 5-year data for all Illinois counties, with geometry
il_broadband_raw <- get_acs(
  geography = "county",
  state     = state_abbr,
  variables = acs_vars,
  year      = acs_year,
  survey    = "acs5",
  geometry  = TRUE,
  output    = "wide"
)

glimpse(il_broadband_raw)

if (!dir.exists("data/raw")) dir.create("data/raw", recursive = TRUE)

saveRDS(il_broadband_raw, file = "data/raw/il_broadband_raw.rds")
