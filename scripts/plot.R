library(tidyverse)
library(sf)
library(tmap)
library(plotly)
library(htmlwidgets)

il_geo <- readRDS("data/processed/il_broadband_geo.rds")
il_df  <- read_csv("data/processed/il_broadband.csv", show_col_types = FALSE)

if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)


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


if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)

hist_broadband <- ggplot(il_df, aes(x = pct_broadband_any)) +
  geom_histogram(bins = 15) +
  labs(
    x = "% households with broadband",
    y = "Number of counties",
    title = "Distribution of Broadband Access Across Illinois Counties"
  )

hist_broadband

ggsave("figs/hist_pct_broadband.png", hist_broadband, width = 7, height = 5, dpi = 300)
