# ============================================================
# ESCI 620 Week 4 Course Project Assignment
# Exploratory Data Analysis
# Kara Dailey
# ============================================================

# -----------------------------
# STEP 1: Descriptive Statistics (Mean, Median, SD, IQR)
# -----------------------------

library(e1071)  # for skewness


# Descriptive Statistics by Year

desc_stats <- df_percent %>%
  group_by(Year) %>%
  summarise(
    Mean = mean(PercentOfTotal),
    Median = median(PercentOfTotal),
    SD = sd(PercentOfTotal),
    IQR = IQR(PercentOfTotal),
    Skewness = skewness(PercentOfTotal)
  )

print(desc_stats)

desc_by_class <- df_percent %>%
  group_by(Year, ClassName) %>%
  summarise(Percent = sum(PercentOfTotal)) %>%
  arrange(desc(Percent))

print(desc_by_class)

# -----------------------------
# STEP 2: Correlation Analysis
# -----------------------------

#Create categories
df_percent <- df_percent %>%
  mutate(Category = case_when(
    landcover %in% c(21,22,23,24) ~ "Developed",
    landcover %in% c(41,42,43) ~ "Forest",
    landcover %in% c(81,82) ~ "Agriculture",
    TRUE ~ "Other"
  ))

# Aggregate by category
df_summary <- df_percent %>%
  group_by(Year, Category) %>%
  summarise(Percent = sum(PercentOfTotal)) %>%
  ungroup()

# Convert to wide format for correlation
library(tidyr)

df_wide <- df_summary %>%
  pivot_wider(names_from = Category, values_from = Percent)

print(df_wide)

# Pearson Correlation
cor_dev_forest <- cor(df_wide$Developed, df_wide$Forest, method = "pearson")
cor_dev_ag <- cor(df_wide$Developed, df_wide$Agriculture, method = "pearson")

cor_dev_forest
cor_dev_ag

# Optional: Spearman Correlation
cor(df_wide$Developed, df_wide$Forest, method = "spearman")

# -----------------------------
# STEP 3: Change Over Time (More Meaningful than Correlation with 2 Years)
# -----------------------------

df_change <- df_wide %>%
  arrange(Year) %>%   # VERY IMPORTANT so lag works correctly
  mutate(
    Dev_Change = Developed - lag(Developed),
    Forest_Change = Forest - lag(Forest),
    Ag_Change = Agriculture - lag(Agriculture)
  )

print(df_change, n = Inf)

# -----------------------------
# Step 4: Visualizations
# -----------------------------

library(ggplot2)

# Plot 1: Histogram of Percent of Total by Year

plot_hist <- ggplot(df_percent, aes(x = PercentOfTotal)) +
  geom_histogram(binwidth = 2, fill = "#0072B2", color = "black") +
  geom_vline(aes(xintercept = mean(PercentOfTotal)), 
             color = "red", linetype = "dashed") +
  facet_wrap(~Year) +
  labs(
    title = "Distribution of Land Cover Percentages (2001 vs 2021)",
    x = "Land Cover (% of Total Area)",
    y = "Number of Land Cover Classes"
  ) +
  theme_minimal()

print(plot_hist)

ggsave(
  filename = "Week4_Histogram_LandCoverPercent.png",
  plot = plot_hist,
  width = 8,
  height = 5,
  dpi = 300
)

# Plot 2: Scatterplot of 2001 vs 2021 Land Cover Percentages

library(ggrepel)

df_scatter <- df_percent %>%
  select(Year, ClassName, PercentOfTotal) %>%
  pivot_wider(names_from = Year, values_from = PercentOfTotal, names_prefix = "Year_") %>%
  mutate(ChangeDirection = case_when(
    Year_2021 > Year_2001 ~ "Increased",
    Year_2021 < Year_2001 ~ "Decreased",
    TRUE ~ "No Change"
  ))

plot_scatter <- ggplot(df_scatter, aes(x = Year_2001, y = Year_2021, color = ChangeDirection)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray40") +
  geom_point(size = 3.5) +
  coord_equal() +
  scale_color_manual(
    values = c(
      "Increased" = "#009E73",   # green
      "Decreased" = "#D55E00",   # orange/red
      "No Change" = "#0072B2"    # blue
    )
  ) +
  labs(
    title = "Land Cover Percentages in 2001 and 2021",
    subtitle = "Points above the dashed line increased; points below it decreased",
    x = "Percent of Total Area (2001)",
    y = "Percent of Total Area (2021)",
    color = "Change"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

print(plot_scatter)

ggsave(
  filename = "Week4_Scatter_Clean_ColorLegend.png",
  plot = plot_scatter,
  width = 9,
  height = 6,
  dpi = 300
)


# Plot 3: Time-Series of Major Land Cover Categories

plot_time <- ggplot(
  df_summary,
  aes(x = Year, y = Percent, color = Category, group = Category)
) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = c(2001, 2021)) +
  scale_color_manual(values = c(
    "Developed" = "#D55E00",
    "Forest" = "#009E73",
    "Agriculture" = "#F0E442",
    "Other" = "#999999"
  )) +
  labs(
    title = "Land Cover Change Over Time by Category",
    subtitle = "Developed land increased slightly, while forest and agriculture declined",
    x = "Year",
    y = "Percent of Total Land Cover",
    color = "Category"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(size = 10),
    legend.position = "right"
  )

print(plot_time)

ggsave(
  filename = "Week4_TimeSeries_LandCover.png",
  plot = plot_time,
  width = 8,
  height = 5,
  dpi = 300
)