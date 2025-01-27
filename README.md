# Wildebeest 
Repository for manuscript on Wildebeest Migration in the Greater Mara and Impacts of Fencing on Connectivity  
Zenodo DOI 10.5281/zenodo.14599735

#### **Manuscript title: Predicting the impact of targeted fence removal on connectivity in a migratory ecosystem**
Accepted in Ecological Applications

###   PROJECT BACKGROUND ###

Master's thesis project at the University of Glasgow's School of Biodiversity, One Health and Veterinary Medicine in partnership with colleagues from the Smithsonian Institute of Conservation Biology's Conservation Ecology Centre. Under supervision of T.Morrison and J.Stabach.

###   PROJECT APPROACH ###


Develop a habitat suitability model based on historic (pre-fencing) GPS movement data of wildebeest in the Greater Mara. Use this model to make predictions of habitat suitability across the study area and then analyse connectivity before and after incorporating detailed fencing data using the inverse of the predicted suitability as a resistance surface in Circuitscape v.4.0 (McRae et al. 2008) in R . Additional analysis of simulated restoration of connectivity via fence removal and validation of results from both.


###   CONTENTS  ###
Scripts numbered in order. 
Code builds on objects from previous scripts and can either be run consecutively or by storing final objects as .RData files for later use in the next script.

### DATA

"WB_covariates.RData" RData-file with:

- Raster layers of covariates used in habitat suitability model (EPSG:32736, resolution 51.3 m)

Wildebeest GPS collar data from the Greater Mara

- Wildebeest movement data from 2010-2013 (historic STABACH et al. (2020) data set - available on movebank.org - **doi.org/10.5441/001/1.h0t27719**) 

- Wildebeest movement data from 2017-2021 (validation data set HOPCRAFT **https://www.movebank.org/cms/webapp?gwt_fragment=page%3Dstudies%2Cpath%3Dstudy4901146318**) used as validation data  

----------------------

### SCRIPTS 

### 1_Pseudo_Absences-1013.Rmd

Generates 50 random pseudo-absence points per presence/occurrence point in the 2010-2013 wildebeest data to simulate what other conditions were available to the animal as opposed to the selected conditions found at the presence/occurrence point. Availability defined as a buffer size of the maximum observed steplength for each animal around each presence/occurrence point.

- requires "WB_covariates.RData"

### 2_ndviExtract.R

Script to extract different NDVI metrics, written by T. Morrison, edited. 

- requires "RSF" object build in "3_RSF.Rmd" as well as MODIS NDVI data layers (more detail within)

### 3_RSF.Rmd

Extract covariates and builds habitat suitability model in a resource selection function (RSF) framework using a generalised linear mixed effects model (GLMM) with a binomial error structure. 

- requires "ndvi" object created in "2_ndviExtract.R" for building the final data frame and model, but must supply "RSF" object for the NDVI extraction to be created before.

### 4_Prediction.Rmd

Makes predictions of habitat suitability across the study area using the model built in "3_RSF.Rmd" and the covariate layers in "WB_covariates.RData"

- requires model (mod), "RSFdf" data frame and covariate layer rasters and folder "NDVI_layers_for_prediction" containing mean NDVI and two consecutive NDVI rasters for DNDVI (more detail within)

- creates predicted habitat suitability raster across the study area ("pred_rast.tif") needed for connectivity analysis in Circuitscape. 

### Connectivity Analysis

### 5_Connectivity_Analysis.Rmd

Models connectivity across the study area as cumulative current maps for historic pre-fencing (2010-2013) and current fenced (2022) scenarios. 

- requires the predicted habitat suitability model created in "3_RSF.Rmd" and "4_Prediction.Rmd" as well as fencing data and focal area shapefiles - all found in "files_for_Connectivity_Analysis" folder. Fencing data not uploaded here but available from: **https://www.arcgis.com/home/search.html?q=landDx** (Tyrell et al. 2022)

### Restoration

### 6_Restoration_and_Cost.Rmd

Using different corridors delineated in QGIGS v.3.16 using historic connectivity levels and the raw fencing data, the fence rasters are altered to simulate these corridors and connectivity analysis repeated. Results are then compared to historic and current levels to assess improvement. Finally, the cost of fence removal proportional tocorridor area is calculated and plotted against connectivity improvement fro each corridor using real compensation costs from the region.

- requires pre-fence and fenced connectivity maps created in "5_Connectivity_Analysis.Rmd" as well as fence rasters for each corridor restoration scenario "corridor_fencerasters.zip". Files were created in QGIS v.3.16 by outlining corridor paths as described above, then buffering to different corridor widths and cropping corridor extents out of the fencing dataset.

### Validation 

### 7_Pseudo_Absences-1721.Rmd

Creates pseudo-absences for validation data set.

- requires "WB_covariates.RData" 

### 8_Validation.R

Validates the predicted habitat suitability surface, the predicted pre-fencing and fenced connectivity levels and the map of connectivity change by evaulating the impact of presence or pseudo-absence on each metric (Is there a significant difference between presences and absences?). This is done at both a regional scale across the entire Mara and a local scale for only the restoration atrea of interest.

- requires the predicted habitat suitability surface from "4_Prediction.Rmd"
- the pre-fence and fenced connectivity maps and the model of change between the two created in "5_Connectivity_Analysis.Rmd"
- the restoration raea of interest shape from "6_Restoration_and_Cost.Rmd"
- requires validation data set movement data from "WB_covariates.RData" and pseudo-absences created in "7_Pseudo_Absences-1721.Rmd"

### KEY REFERENCES

McRae, B. H., Dickson, B. G., Keitt, T. H., & Shah, V. B. (2008). Using circuit theory to model connectivity in ecology, evolution, and conservation. Ecology, 89(10), 2712–2724. **https://doi.org/10.1890/07-1861.1**

Stabach, J., Hughey, L., Reid, R., Worden, J., Leimgruber, P., & Boone, R. (2020). Data from: Comparison of movement strategies of three populations of white-bearded wildebeest. Movebank Data Repository. **https://doi.org/doi:10.5441/001/1.h0t27719**

Tyrrell, P., Amoke, I., Betjes, K. et al. Landscape Dynamics (landDX) an open-access spatial-temporal database for the Kenya-Tanzania borderlands. Sci Data 9, 8 (2022). https://doi.org/10.1038/s41597-021-01100-9
