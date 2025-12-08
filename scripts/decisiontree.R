library(tidyverse)
library(tidymodels)
library(rpart)
library(rpart.plot)


il_df <- read_csv("data/processed/il_broadband.csv", show_col_types = FALSE)

median_pct <- median(il_df$pct_broadband_any, na.rm = TRUE)

il_ml <- il_df %>%
  mutate(
    low_bb = if_else(pct_broadband_any < median_pct, "yes", "no"),
    low_bb = factor(low_bb, levels = c("no", "yes"))
  ) %>%
  select(county, med_income, pct_broadband_any, low_bb) %>%
  drop_na()

table(il_ml$low_bb)


set.seed(123)
split_obj <- initial_split(il_ml, prop = 0.8, strata = low_bb)
train_data <- training(split_obj)
test_data  <- testing(split_obj)


tree_spec <- decision_tree(
  tree_depth      = 4,
  cost_complexity = 0
) %>%
  set_engine("rpart") %>%
  set_mode("classification")


tree_fit <- workflow() %>%
  add_model(tree_spec) %>%
  add_formula(low_bb ~ med_income) %>%  # can add predictors later if desired
  fit(data = train_data)

tree_preds <- predict(tree_fit, test_data, type = "class") %>%
  bind_cols(test_data)

tree_metrics <- tree_preds %>%
  metrics(truth = low_bb, estimate = .pred_class)

print(tree_metrics)


simple_tree <- tree_fit %>%
  extract_fit_parsnip() %>%
  pluck("fit")

if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)

png("figs/decision_tree_low_broadband.png", width = 1000, height = 700, res = 120)
par(mar = c(4, 4, 2, 1))
rpart.plot(
  simple_tree,
  type          = 3,
  extra         = 104,
  fallen.leaves = TRUE,
  main          = "Decision Tree: Counties with Low Broadband Access"
)
dev.off()
