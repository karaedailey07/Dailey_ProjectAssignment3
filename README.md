ESCI 620 Week 3 Course Project
The Art of Data Cleaning: NLCD Land Cover Dataset (2001–2021)

Author: Kara Dailey
Course: ESCI 620-01 Big Data in Environmental Science
Institution: Unity Environmental University


Project Overview
This project focuses on transforming raw environmental data into an analysis-ready dataset using reproducible data cleaning techniques in R. The dataset used is the National Land Cover Database (NLCD) for 2001 and 2021, which provides categorical land cover classifications across the conterminous United States.

Because real-world environmental data is often large and complex, this project emphasizes practical data cleaning decisions, including handling large raster datasets, ensuring consistency across time, and documenting all transformations for transparency and reproducibility.

Dataset Information
Dataset Name: NLCD Land Cover (2001 & 2021)
Source: U.S. Geological Survey (USGS), Multi-Resolution Land Characteristics (MRLC) Consortium
Format: Raster (.tif)
Resolution: 30 meters
Coverage: Conterminous United States

Data Cleaning Approach

Key Challenge
The NLCD raster datasets are extremely large, making it computationally impractical to convert each pixel into a row-level dataset using standard hardware.

Solution
Instead of converting the full raster to a dataframe, the terra::freq() function was used to calculate the number of cells in each land cover class. This approach preserves the full distribution of land cover categories while producing a manageable dataset for analysis. All data cleaning decisions were documented in a cleaning log to ensure transparency and reproducibility.

Cleaning Steps
*Loaded raster datasets using the terra package
*Verified raster structure, resolution, and projection
*Reviewed class distributions using freq()
*Filtered the dataset to include only valid NLCD class codes
*Converted frequency tables to dataframes
*Added a Year column for temporal comparison
*Applied consistent class labels
*Verified no missing values or duplicate records

Repository Contents
*Dailey_ProjectAssignment3.csv — cleaned dataset
*Dailey_ProjectAssignment3.R — annotated R cleaning script
*README — project overview

Cleaned Dataset Description
The final cleaned dataset contains:
*32 rows
*4 variables:
  *Year
  *landcover
  *ClassName
  *CellCount
This structure supports efficient comparison of land cover change between 2001 and 2021.

Ethical Considerations
All valid land cover classes were retained, including low-frequency categories. No data was removed based on rarity or magnitude. Cleaning choices were documented to support transparency, reproducibility, and accurate ecological interpretation.

Tools and Technologies

*R
*terra
*dplyr

Reproducibility
To reproduce this workflow:
1. Download the raster files
2. Open the R script
3. Update file paths if needed
4. Run the script step-by-step

References
U.S. Geological Survey (USGS). (2023). National Land Cover Database (NLCD).
https://www.mrlc.gov
