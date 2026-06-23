# Spatial regression of fire occurrence
# Goal:
# 1. Fit a logistic regression model using 75% of the data
# 2. Validate it with the remaining 25% and compute RMSE
# 3. Select the model with the lowest AIC
# 4. Produce a spatial prediction map

rm(list = ls())

# Load packages
library(sf)
library(tidyverse)
library(terra)

# -------------------------------------------------------------------
# 1) Read fire occurrence data and convert to spatial points
# -------------------------------------------------------------------

fire_logit <- read.csv2("fire_logit.csv") %>%
  drop_na()

# Convert to sf object using coordinate columns
fire_logit <- st_as_sf(fire_logit, coords = c("X_INDEX", "Y_INDEX"), crs = 25830)

# Dependent variable
vdep <- fire_logit$logit_1_0

# Extract coordinates for raster sampling
fire_coords <- st_coordinates(fire_logit)

# -------------------------------------------------------------------
# 2) Load raster predictors
# -------------------------------------------------------------------

# Read all raster layers from the folder
files <- list.files("variables_fire", pattern = "\\.asc$", full.names = TRUE)
rasters <- rast(files)

# Give raster layers the same names as the predictor columns
names(rasters) <- tools::file_path_sans_ext(basename(files))

# Extract raster values at point locations
vindep <- terra::extract(rasters, fire_coords)
vindep <- vindep[, -1]   # remove ID column

# Combine response and predictors
regression <- data.frame(vdep, vindep)

# Remove any rows with missing values
regression <- na.omit(regression)

# -------------------------------------------------------------------
# 3) Split data into calibration (75%) and validation (25%)
# -------------------------------------------------------------------

set.seed(123)  # for reproducibility

n <- nrow(regression)
cal_size <- floor(0.75 * n)

cal_index <- sample(seq_len(n), size = cal_size)

regression_cal <- regression[cal_index, ]
regression_val <- regression[-cal_index, ]

# -------------------------------------------------------------------
# 4) Fit logistic regression models and compare AIC
# -------------------------------------------------------------------

# Initial model with all predictors
mod_full <- glm(vdep ~ ., data = regression_cal, family = binomial)

# Check correlation among predictors
cor_matrix <- cor(regression_cal[, -1], method = "spearman", use = "complete.obs")
print(cor_matrix)

# Example reduced model:
# Replace this formula with the predictor set that gives the lowest AIC
mod_reduced <- glm(
  vdep ~ elect_50 + ferroc_200 + int_cf_200 + int_pf_200 +
    int_uf_200 + pistas_200 + varpot,
  data = regression_cal,
  family = binomial
)

# Compare AIC values
aic_full <- AIC(mod_full)
aic_reduced <- AIC(mod_reduced)

print(aic_full)
print(aic_reduced)

# Select the model with the lowest AIC
final_model <- if (aic_reduced < aic_full) mod_reduced else mod_full

# -------------------------------------------------------------------
# 5) Validate on the 25% validation sample
# -------------------------------------------------------------------

pred_val <- predict(final_model, newdata = regression_val, type = "response")

obs_pred <- data.frame(
  OBS = regression_val$vdep,
  PRED = pred_val
)

rmse <- sqrt(mean((obs_pred$OBS - obs_pred$PRED)^2))
print(rmse)

# -------------------------------------------------------------------
# 6) Spatial prediction using the selected model
# -------------------------------------------------------------------

# Predict probability of fire occurrence across all raster cells
pred_map <- predict(rasters, final_model, type = "response")

# Save prediction raster
writeRaster(pred_map, "fire_occurrence_prediction.tif", overwrite = TRUE)

# Plot result
plot(pred_map, main = "Spatial prediction of fire occurrence")
points(fire_logit, pch = 20, cex = 0.5)