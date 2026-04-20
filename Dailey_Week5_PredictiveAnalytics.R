# ============================================================
# ESCI 620 Week 5 Course Project Assignment
# Predictive Analytics
# Kara Dailey
# ============================================================

# -----------------------------
# 1. Load required packages
# -----------------------------
library(tidyverse)
library(caret)

# -----------------------------
# 2. Load cleaned dataset (from Week 3)
# -----------------------------
df_clean <- read.csv("NLCD_Cleaned_Data.csv")

# -----------------------------
# 3. Recreate percent dataset (from Week 4)
# -----------------------------
df_percent <- df_clean %>%
  group_by(Year) %>%
  mutate(
    TotalCells = sum(CellCount),
    PercentOfTotal = (CellCount / TotalCells) * 100
  ) %>%
  ungroup()

# Recreate land cover categories
df_percent <- df_percent %>%
  mutate(Category = case_when(
    landcover %in% c(21,22,23,24) ~ "Developed",
    landcover %in% c(41,42,43) ~ "Forest",
    landcover %in% c(81,82) ~ "Agriculture",
    TRUE ~ "Other"
  ))

# -----------------------------
# 4. Prepare modeling dataset
# -----------------------------
model_data <- df_percent %>%
  mutate(
    Year = as.numeric(Year),
    Category = as.factor(Category)
  ) %>%
  select(Year, Category, PercentOfTotal)

# -----------------------------
# 5. Train/test split (80/20)
# -----------------------------
set.seed(123)
trainIndex <- createDataPartition(model_data$PercentOfTotal, p = 0.8, list = FALSE)
train_data <- model_data[trainIndex, ]
test_data  <- model_data[-trainIndex, ]

# -----------------------------
# 6. Train regression model
# -----------------------------
model_lm <- lm(PercentOfTotal ~ Year + Category, data = train_data)

# -----------------------------
# 7. Model summary
# -----------------------------
summary(model_lm)

# -----------------------------
# 8. Predictions
# -----------------------------
predictions <- predict(model_lm, newdata = test_data)

# -----------------------------
# 9. Validation metrics
# -----------------------------
rmse <- sqrt(mean((predictions - test_data$PercentOfTotal)^2))
mae  <- mean(abs(predictions - test_data$PercentOfTotal))

cat("RMSE:", rmse, "\n")
cat("MAE:", mae, "\n")

