library(tidyverse)
library(sf)
library(tmap)
library(plotly)
library(htmlwidgets)

il_geo <- readRDS("data/processed/il_broadband_geo.rds")
il_df  <- read_csv("data/processed/il_broadband.csv", show_col_types = FALSE)

if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)

### 1. Map of % broadband by county ----

tmap_mode("plot")

map_broadband <- tm_shape(il_geo) +
  tm_polygons(
    col   = "pct_broadband_any",
    style = "quantile",
    title = "% households with broadband"
  ) +
  tm_layout(
    main.title     = "Broadband Access in Illinois Counties",
    legend.outside = TRUE
  )

map_broadband

tmap_save(map_broadband, filename = "figs/map_broadband.png")

### 2. Scatter: income vs broadband ----

scatter_income_bb <- ggplot(il_df, aes(x = med_income, y = pct_broadband_any)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    x     = "Median household income (USD)",
    y     = "% households with broadband",
    title = "Income vs Broadband Access in Illinois Counties"
  )

scatter_income_bb

ggsave("figs/scatter_income_broadband.png", scatter_income_bb, width = 7, height = 5)


