## TOMS data (ALL WB)

library(sp)

#read data
WB <- read.csv("WB_SNP_2010_2021_forImogen.csv")

# set crs
crs <- CRS("+init=epsg:32736")

#reformat date column as POSIX
#str(WB)

# convert date to posix class
WB$datetime <- as.POSIXct(WB$Date, format="%d/%m/%Y %H:%M", tz='GMT')
#str(WB)

# time is in GMT, but we need to convert it to local time (East African time)
attributes(WB$datetime)$tzone <- "Africa/Nairobi" #change from UTC to Nairobi timezone
#str(WB)

# project data - convert to spatialpoints df
coordinates(WB) <- ~x+y
proj4string(WB) <- crs

# plot points as a spatial object
colr <- rgb(0,0.5,1,alpha=0.3) 
plot(WB, col=colr, pch=16, cex=0.7)

## Trying to calculate the mean number of tracking days for Hopcraft data (no need for spatial object, data frame suffices)
library(dplyr)

#read data
WB <- read.csv("WB_SNP_2010_2021_forImogen.csv")

#subset Hopcraft data only
WBH <- subset(WB, OWNER == "HOPCRAFT")
str(WBH)

# convert date to posix class
WBH$datetime <- as.POSIXct(WBH$Date, format="%d/%m/%Y %H:%M", tz='GMT')

# calculate number of days tracked for each animal
trackingtime <- WBH %>% group_by(AID) %>% summarise(max(datetime) -min(datetime))

#convert to numeric
trackingtime <- as.numeric(trackingtime$`max(datetime) - min(datetime)`)

#calculate mean
mean(trackingtime)
# 884.1408
range(trackingtime)
# 30.45833 1692.16736
median(trackingtime)
#960.4236


######calculate maximum observe steplength
library(adehabitatHR)
library(rgdal)

#read data
WBS <- readOGR("WB-2010-2013.shp")

WBS <- as.data.frame(WBS) #must be dataframe

#reformat date column as POSIX
WBS$datetime <- as.POSIXct(WBS$Date, format="%d/%m/%Y %H:%M", tz='GMT')

# convert points into a trajectory using 'adehabitat' package
WBtraj <- as.ltraj(cbind(WBS$coords.x1, WBS$coords.x2),date = WBS$datetime,id = (WBS$AID))

# Create a dataframe to holds all of the contents of WBtraj 
# Put first individual into the dataframe
WBtraj.df <- data.frame(WBtraj[[1]], id = attr(WBtraj[[1]], "id"))

# Use a for loop to fill the larger dataframe with the rest of the trajectories
for(i in 2:length(WBtraj)) {
  WBtraj.df <- rbind(WBtraj.df, 
                    data.frame(WBtraj[[i]],
                    id = attr(WBtraj[[i]], "id")))
}

# remove NA's (final location has no distance displaced thereafter)
WBtraj.df <- subset(WBtraj.df, dist != "NA")

#obtain maximum distance displaced total
max(WBtraj.df$dist)
# 27446.55 ~ 27.5 km

#maximum distance displaced over 3 h per individual
library(dplyr)
indiv.max.dist <- WBtraj.df %>% group_by(id) %>% summarise(maxdist = max(dist))
mean(indiv.max.dist$maxdist)
#10968.45 m ~ 11 km
median(indiv.max.dist$maxdist)
#7903.08 m  ~  8 km

#create vector of buffer sizes
sizes <- c(indiv.max.dist$maxdist)



### Creating an individual buffer corresponding to the respective maximum observed step length over a 3 h interval (for the availability points)

library(rgeos)

#read data
WBS <- readOGR("WB-2010-2013.shp")

# split WBS into list of dataframes for each individual
WBS_indiv <- split(WBS, WBS$AID)


# create an empty list for the results
Result <- list()

# For loop to run through every item in the list of indiviudals, to create a buffer with the extracted maxiumum observed steplength corresponding to each individual (careful loooong run time)
for (i in 1:length(sizes)) {
  
  #iterate through
  Result[[i]] <- rgeos::gBuffer(WBS_indiv[[i]], 
                                byid = TRUE, 
                                width = sizes[i])
}


# results can be converted back into one dataframe by using unsplit