### Fencing rasterise

library(raster)
library(rgdal)

# first clip fence by county (already done in GIS, but need to incorporate in code?)

Narokfence <- readOGR("Smithsonian_data/Data/Fencing/LandDx/Fence_Narok.shp")

# create an empty raster
r <- raster()

#set up extent of raster
# read in extent file (Narok county) first
Narok <- readOGR("Smithsonian_data/Data/Country/Narok/Narok.shp")
extent(r) <- extent(Narok)

#set up spatial resolution
res(r) <- c(100, 100)
#if decreased, precision increased, but also computational time increased, depends on size of data set

Narok@proj4string@projargs <- Narokfence@proj4string@projargs

#transform fence polygons into raster
Narokfence.r <- rasterize(Narokfence, r, Narokfence$collect_da, background = NA)
