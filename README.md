# Wildebeest
Master thesis repository: Wildebeest Migration Mara (SME) and Fencing

###   PROJECT   ###


###   CONTENTS  ###
Scripts numbered in order

### 1_Data_WMF.Rmd

Script used to create "Wildebeest_and_Covariates_data.RData" includes 

Wildebeest GPS collar data from teh Greater Mara

- Wildebeest movement data from 2010-2013 (historic STABACH et al. (2020) data set - available on movebank.org - doi.org/10.5441/001/1.h0t27719) and 

- Wildebeest movement data from 2017-2021 (newer data set HOPCRAFT - unpublished data)

Raster layers (EPSG:32736, resolution 51.3 m) of covariates sued in habitat suitability model

### 2_Pseudo_Absences-1013.Rmd

Generates 50 random pseudo-absence points per presence/occurrence point in the 2010-2013 wildebeest data to simulate what other conditions were available to the animal as opposed to the selected conditions found at the presence/occurrence point. Availability defined as a buffer size of the maximum observed steplength for each animal around each presence/occurrence point.

- requires "Wildebeest_and_Covariates_data.RData"

### 3_ndviExtract.R

Script to extract different NDVI metrics, written by T.Morrison, edited. 

- requires "RSF" object build in "4_RSF.Rmd" as well as MODIS NDVI data layers (more detail within)

### 4_RSF.Rmd

Extract covariates and builds habitat suitability model in a resource selection function framework using a generalised linear mixed effects modle (GLMM) with a binomial error structure. 

- requires "ndvi" object created in "3_ndviExtract.R" for building the final data farme and model, but must supply "RSF" object for the NDVI extraction to be created before.

### 5_Prediction.Rmd


