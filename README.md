# Wildebeest 
Master thesis repository: Wildebeest Migration in the Greter Mara and Impacts of Fencing

###   PROJECT  ###

Develop a habitat suitability model based on historic GPS movement data of wildebeest in the Greater Mara. Use this model to make predictions of habitat suitabilty across the study area and then analyse connectivity before and after incorporating fencing using the inverse of the predicted suitability as a resistance surface in Circuitscape v.4.0 (McRae et al. 2008) in R . Additionally contains analysis of simulated restoration of connectivity via fence removal and validation of results from both.


###   CONTENTS  ###
Scripts numbered in order. 
Code builds on objects from previous scripts and can either be run consecutively or by storing final objects as .RData files for later use in the next script.

### 1_Data_WMF.Rmd

Script used to create "Wildebeest_and_Covariates_data.RData" includes 

Wildebeest GPS collar data from teh Greater Mara

- Wildebeest movement data from 2010-2013 (historic STABACH et al. (2020) data set - available on movebank.org - **doi.org/10.5441/001/1.h0t27719**) 

- Wildebeest movement data from 2017-2021 (newer data set HOPCRAFT - unpublished data) used as validation data

Raster layers (EPSG:32736, resolution 51.3 m) of covariates sued in habitat suitability model

### 2_Pseudo_Absences-1013.Rmd

Generates 50 random pseudo-absence points per presence/occurrence point in the 2010-2013 wildebeest data to simulate what other conditions were available to the animal as opposed to the selected conditions found at the presence/occurrence point. Availability defined as a buffer size of the maximum observed steplength for each animal around each presence/occurrence point.

- requires "Wildebeest_and_Covariates_data.RData"

### 3_ndviExtract.R

Script to extract different NDVI metrics, written by T. Morrison, edited. 

- requires "RSF" object build in "4_RSF.Rmd" as well as MODIS NDVI data layers (more detail within)

### 4_RSF.Rmd

Extract covariates and builds habitat suitability model in a resource selection function framework using a generalised linear mixed effects modle (GLMM) with a binomial error structure. 

- requires "ndvi" object created in "3_ndviExtract.R" for building the final data farme and model, but must supply "RSF" object for the NDVI extraction to be created before.

### 5_Prediction.Rmd

Makes predictions of habitat suitability across the study area using the model built in "4_RSF.Rmd" and the covariate layers in "Wildebeest_and_Covariates_data.RData"

- requires model, "RSFdf" data frame and covariate layer rasters and folder "NDVI_layers_for_prediction" containing mean NDVI and two consecuitive NDVI ratsers for DNDVI

- creates predicted habitat suitability raster across the study area ("pred_rast.tif") needed for connectiivty analysis in Circuitscape. 

### Connectivity Analysis

### 6_Connectivity_Analysis.Rmd

Models connectivity across the study area as cumulative current maps for historic pre-fencing and current fenced (2022) scenarios. 

- requiress the predidcted habitat suitability model created in "4_RSF.Rmd" and "5_Prediction.Rmd" as well as fencing data and focal area shapefiles - all found in "files_for_Connectivity_Analysis" folder. Fencing data not uploaded here but available from: **https://www.arcgis.com/home/search.html?q=landDx** (Tyrell et al. 2022)

### Restoration

### 7_Restoration.Rmd

Uisng different corridors delineated in QGIGS v.3.16 using historic connectivity levels and the raw fencing data, the fencerasters are altered to simulate these corridors and connectivity analysis repeated. Results are then compared to historic and current levels to assess improvement.

- requires historic and current connectivity maps created in "6_Connectivity_Analysis.Rmd" as well as fence rasters for each corridor restoration scanerio "corridor_fenceratsers.zip" (files were cretaed in QGIS v.3.16)

### Validation

### 8_Pseudo_Absences-1721.Rmd

Creates pseudo-absences for validation data set.

- requires "Wildebeest_and_Covariates_data.RData"

### 9_Validation.R

Script to run several analyses to validate results using t.tests

- requires "Wildebeest_and_Covariates_data.RData" and pseudo-absences cretaed in "6_Pseudo_Absences-1721.Rmd"

### KEY REFERENCES

McRae, B. H., Dickson, B. G., Keitt, T. H., & Shah, V. B. (2008). Using circuit theory to model connectivity in ecology, evolution, and conservation. Ecology, 89(10), 2712–2724. **https://doi.org/10.1890/07-1861.1**

Stabach, J., Hughey, L., Reid, R., Worden, J., Leimgruber, P., & Boone, R. (2020). Data from: Comparison of movement strategies of three populations of white-bearded wildebeest. Movebank Data Repository. **https://doi.org/doi:10.5441/001/1.h0t27719**

Tyrrell, P., Amoke, I., Betjes, K. et al. Landscape Dynamics (landDX) an open-access spatial-temporal database for the Kenya-Tanzania borderlands. Sci Data 9, 8 (2022). https://doi.org/10.1038/s41597-021-01100-9
