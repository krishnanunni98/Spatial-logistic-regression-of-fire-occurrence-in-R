# Spatial Logistic Regression of Fire Occurrence in R

## Project overview
This project applies spatial logistic regression to model fire occurrence using georeferenced presence/absence data and raster-based environmental predictors. The workflow includes data preparation, raster value extraction, model calibration with a 75/25 train-validation split, AIC-based model comparison, RMSE evaluation, and spatial prediction mapping.

## Objectives
-	Adapt a logistic regression workflow to a spatial modelling context 
-	Use point coordinates and raster predictor layers to model fire occurrence 
-	Fit the model using 75% of the data 
-	Validate the model using the remaining 25% 
-	Compare candidate models using AIC 
-	Generate a spatial prediction of fire occurrence probability 

## Data
-	fire_logit.csv — presence/absence points with coordinate information 
-	variables_fire/ — raster predictor layers used as explanatory variables 

## Methodology
1.	Imported the fire occurrence dataset into R. 
2.	Converted the table into a spatial point object using coordinate columns. 
3.	Loaded the raster layers from the predictor folder. 
4.	Extracted raster values at each point location. 
5.	Combined response and predictor variables into a modelling dataset. 
6.	Split the dataset into calibration (75%) and validation (25%) samples. 
7.	Fitted logistic regression models on the calibration sample. 
8.	Compared models using AIC. 
9.	Evaluated the final model on the validation sample using RMSE. 
10.	Produced a spatial prediction map of fire occurrence probability.

## Main results
-	Logistic regression model calibrated on 75% of the sample 
-	Validation performed on the remaining 25% 
-	RMSE used to assess predictive accuracy 
-	Spatial prediction map generated from the selected model 

## Skills demonstrated
-	Spatial data handling in R 
-	Raster processing and point-based value extraction 
-	Logistic regression modelling 
-	AIC-based model selection 
-	Model validation using independent data 
-	Spatial prediction and mapping 
-	Reproducible scripting and documentation
