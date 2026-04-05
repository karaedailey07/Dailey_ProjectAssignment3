# ============================================================
# ESCI 620 Week 3 Course Project Assignment
# The Art of Data Cleaning: Transforming Raw Data into an Analysis-Ready Dataset
# Kara Dailey
# ============================================================

# -----------------------------
# 1. Set working directory
# -----------------------------

setwd("C:\\Users\\karae\\OneDrive\\Documents\\Unity 2026 SPRING TERM DE8W03.16.26\\ESCI 620-01 Big Data in Environmental Science\\Land Cover Data")

# Confirm working directory
getwd()

# View files in the folder
list.files()


# -----------------------------
# 2. Load required packages
# -----------------------------

library(terra)
library(dplyr)


# -----------------------------
# 3. Load raw raster datasets
# -----------------------------

nlcd_2001 <- rast("LANDCOVER2001_RAW_20260329.tif")
nlcd_2021 <- rast("LANDCOVER2021_RAW_20260329.tif")

# Print raster information to verify they loaded correctly
nlcd_2001
nlcd_2021


# -----------------------------
# 4. visual inspection
# -----------------------------
# Plot each raster for a quick visual check.

plot(nlcd_2001)
plot(nlcd_2021)


# -----------------------------
# 5. Summarize raster values using frequency tables
# -----------------------------
# IMPORTANT:
# These rasters are too large to convert every pixel into a dataframe.
# Instead, freq() calculates the number of cells in each land cover class.
# This is a much more efficient and appropriate workflow for NLCD data.

freq_2001 <- freq(nlcd_2001)
freq_2021 <- freq(nlcd_2021)

# View frequency tables
freq_2001
freq_2021


# -----------------------------
# 6. Convert frequency tables to dataframes
# -----------------------------
# The freq() output contains 3 columns:
# layer = raster layer number
# value = NLCD class code
# count = number of cells in that class
#
# We only need "value" and "count" for the cleaned dataset.

df_2001 <- as.data.frame(freq_2001)[, c("value", "count")]
df_2021 <- as.data.frame(freq_2021)[, c("value", "count")]

# Rename columns for clarity
colnames(df_2001) <- c("landcover", "CellCount")
colnames(df_2021) <- c("landcover", "CellCount")

# Check results
df_2001
df_2021


# -----------------------------
# 7. Add year field
# -----------------------------

df_2001$Year <- 2001
df_2021$Year <- 2021

# Check results
df_2001
df_2021


# -----------------------------
# 8. Merge 2001 and 2021 datasets
# -----------------------------
# Combine both years into one analysis-ready table.

df_all <- bind_rows(df_2001, df_2021)

# View merged data
df_all


# -----------------------------
# 9. Filter to valid NLCD classes only
# -----------------------------
# These are the valid NLCD class codes identified in the raster metadata.
# Filtering ensures that only meaningful land cover categories are retained.
# This step also helps exclude any possible NoData or invalid values.

valid_classes <- c(11, 12, 21, 22, 23, 24, 31, 41, 42, 43, 52, 71, 81, 82, 90, 95)

df_clean <- df_all %>%
  filter(landcover %in% valid_classes)

# View filtered data
df_clean


# -----------------------------
# 10. Add descriptive class names
# -----------------------------
# Convert NLCD numeric codes into readable land cover class labels.
# This makes the dataset easier to interpret and use in analysis.

class_labels <- c(
  "11" = "Open Water",
  "12" = "Perennial Ice/Snow",
  "21" = "Developed, Open Space",
  "22" = "Developed, Low Intensity",
  "23" = "Developed, Medium Intensity",
  "24" = "Developed, High Intensity",
  "31" = "Barren Land",
  "41" = "Deciduous Forest",
  "42" = "Evergreen Forest",
  "43" = "Mixed Forest",
  "52" = "Shrub/Scrub",
  "71" = "Grassland/Herbaceous",
  "81" = "Pasture/Hay",
  "82" = "Cultivated Crops",
  "90" = "Woody Wetlands",
  "95" = "Emergent Herbaceous Wetlands"
)

df_clean$ClassName <- class_labels[as.character(df_clean$landcover)]

# View updated data
df_clean


# -----------------------------
# 11. Reorder columns neatly
# -----------------------------
# Put columns in a cleaner order for export and reporting.

df_clean <- df_clean %>%
  select(Year, landcover, ClassName, CellCount)

# Print final cleaned dataset
print(df_clean)


# -----------------------------
# 12. Basic quality checks
# -----------------------------
# Check for missing values in each column
colSums(is.na(df_clean))

# Check for duplicate rows
sum(duplicated(df_clean))


# -----------------------------
# 13. Export cleaned dataset
# -----------------------------
# Save the final cleaned table as a CSV file.

write.csv(df_clean, "NLCD_Cleaned_Data.csv", row.names = FALSE)

# Confirm the file was created
list.files()


# -----------------------------
# 14. Optional: create a simple summary table
# -----------------------------

summary_table <- df_clean %>%
  arrange(Year, landcover)

write.csv(summary_table, "NLCD_Class_Summary.csv", row.names = FALSE)

# Print summary table
print(summary_table)


# -----------------------------
# 15. Optional: calculate percent of total cells by year
# -----------------------------

df_percent <- df_clean %>%
  group_by(Year) %>%
  mutate(TotalCells = sum(CellCount),
         PercentOfTotal = (CellCount / TotalCells) * 100) %>%
  ungroup()

# View percent table
print(df_percent)

# Export percent table if desired
write.csv(df_percent, "NLCD_Class_Percentages.csv", row.names = FALSE)