library(tidyverse)
library(sf)

il_broadband_raw <- readRDS("data/raw/il_broadband_raw.rds")

# Clean county names and compute broadband percentage
il_broadband_geo <- il_broadband_raw %>%
  mutate(
    county = str_remove(NAME, " County, Illinois"),
    geoid  = GEOID
  ) %>%
  select(
    geoid,
    county,
    med_incomeE,
    hh_totalE,
    hh_broadband_anyE,
    geometry
  ) %>%
  rename(
    med_income       = med_incomeE,
    hh_total         = hh_totalE,
    hh_broadband_any = hh_broadband_anyE
  ) %>%
  mutate(
    pct_broadband_any = 100 * hh_broadband_any / hh_total
  )


il_broadband <- il_broadband_geo %>%
  st_drop_geometry()

summary(il_broadband$med_income)
summary(il_broadband$pct_broadband_any)
sum(is.na(il_broadband$med_income))
sum(is.na(il_broadband$pct_broadband_any))

if (!dir.exists("data/processed")) dir.create("data/processed", recursive = TRUE)

saveRDS(il_broadband_geo, "data/processed/il_broadband_geo.rds")
write_csv(il_broadband, "data/processed/il_broadband.csv")
