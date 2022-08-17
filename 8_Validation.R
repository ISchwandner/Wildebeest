################# Validation #########################
library(raster)
load("WB_and_Covariates_data.RData")
load("Points1721.RData")
Points <- Points[,3:4]
rm(anthro, anthro1, D_river, D_roadT1, D_roadT5, D_wood, TWI, WB, WBS)

#read in pre-fence and fence connectivity (cumulative current) maps
prefence <- raster("PREFENCE_MCP_N_MM_CS_cum_curmap.asc")
fence <- raster("FENCE_polygon_MCP_N_MM_CS_cum_curmap.asc")


######################################################
######### VALIDATING PRE-FENCE RESISTANCE ############
######################################################

resistance <- raster("resistance.asc")

pres <- raster::extract(resistance, WBH)


abs <-  raster::extract(resistance, Points)


t.test(pres, abs)
# Welch Two Sample t-test
# 
# data:  pres and abs
# t = -167.74, df = 46231, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.1793141 -0.1751720
# sample estimates:
#   mean of x mean of y 
# 0.2447994 0.4220425

######################################################
######### VALIDATING FENCE RESISTANCE ################
######################################################

fenceresistance <- raster("fenceplr100.tif")

pres1 <- raster::extract(fenceresistance, WBH)

abs1 <-  raster::extract(fenceresistance, Points)


t.test(pres1, abs1)
# Welch Two Sample t-test
# 
# data:  pres1 and abs1
# t = -9.1673, df = 43911, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -13.080858  -8.472627
# sample estimates:
#   mean of x mean of y 
# 86.51915  97.29590 

######################################################
######### VALIDATING PRE-FENCE CURRENT ###############
######################################################


pres2 <- raster::extract(prefence, WBH)

abs2 <-  raster::extract(prefence, Points)


t.test(pres2, abs2)
# Welch Two Sample t-test
# 
# data:  pres2 and abs2
# t = 53.721, df = 44264, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.0009966925 0.0010721757
# sample estimates:
#   mean of x   mean of y 
# 0.003939388 0.002904954 

######################################################
######### VALIDATING FENCE CURRENT ###################
######################################################


pres3 <- raster::extract(fence, WBH)

abs3 <-  raster::extract(fence, Points)

t.test(pres3, abs3)

# Welch Two Sample t-test
# 
# data:  pres3 and abs3
# t = 51.271, df = 43790, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.001224939 0.001322318
# sample estimates:
#   mean of x   mean of y 
# 0.004349335 0.003075707 


################## COMPARE MEAN RESISTANCE OF 1013 AND 1721 DATA#######

# NEED TO SAMPLE 9 ANIMALS ONLY FORM 1013 TO BE COMPARABLE
# SO CRETAE LOOP AND ITERATE 10 TIMES TO GET A MEAN

library(raster)
load("WB_and_Covariates_data.RData")
rm(anthro, anthro1, D_river, D_roadT1, D_roadT5, D_wood, TWI, WB)



resistance <- raster("resistance.asc")

resWBH <- raster::extract(resistance, WBH)

#loop to iterate 3 times and get mean of values, whilst only selecting 9 animals at random each time

library(sp)

dataframe <-  data.frame("count" = 1:42394)

for (i in 1:10) {
  
  df <- spsample(WBS, 42394, type = "random")
  
  res <- raster::extract(resistance, df)
  
  dataframe[,i] <- res
  
}

resWBS <- rowMeans(dataframe)

t.test(resWBH, resWBS)

# Welch Two Sample t-test
# 
# data:  resWBH and resWBS
# t = -178.81, df = 62862, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.209597 -0.205052
# sample estimates:
#   mean of x mean of y 
# 0.2447994 0.4521239

#   res actually lower base don this surface fro scenario with fences

### do the above again, but with all animals

resistance <- raster("resistance.asc")

resWBH <- raster::extract(resistance, WBH)

resWBS <- raster::extract(resistance, WBS)

t.test(resWBH, resWBS)

# Welch Two Sample t-test
# 
# data:  resWBH and resWBS
# t = 40.959, df = 77153, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.04762281 0.05240961
# sample estimates:
#   mean of x mean of y 
# 0.2447994 0.1947832 

#  WBH MOVE IN AREAS OF HIGHER RESISTANCE THAN WBS

############ test whether 1721 wb are found in areas of lower conncetivity loss/ areas of gain compared to random
library(raster)
load("WB_and_Covariates_data.RData")
load("Points1721.RData")
Points <- Points[,3:4]
rm(anthro, anthro1, D_river, D_roadT1, D_roadT5, D_wood, TWI, WB, WBS)

diffmap <- raster("conndiffMCPNMMfencepoly.tif")

pres4 <- raster::extract(diffmap, WBH)

abs4 <- raster::extract(diffmap, Points)

t.test(pres4, abs4)

# Welch Two Sample t-test
# 
# data:  pres4 and abs4
# t = 16.963, df = 43263, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.0002115559 0.0002668326
# sample estimates:
#   mean of x    mean of y 
# 0.0004099473 0.0001707531 

# WBH are found in areas of higher connectivty gian than random, suggetsing that the current maps and the derived differnece map (change in connectivity) are a good represantation of the observed shift in movement of wildebeest