### Availability 50 points per use point

library(sp)
library(plyr)
library(readr)
library(raster)

# load data (specifically Buffer_list)
load("Buffer_list_WBS.RData")

##### Random Points coordinates

# bind list of polygons for each location together into one data frame per animal
for (i in 1:length(Buffer_list)) {
  Buffer_list[[i]] <- rbind(Buffer_list[[i]])
}

#then bind all animals together, to get one spatial polygons dataframe with all buffers of all locations and all animals 
Buffer_spdf <- Buffer_list[[1]]

for (i in 2:length(Buffer_list)) {
  Buffer_spdf <- rbind(Buffer_spdf, Buffer_list[[i]])
}


#PA 1:95000

#Now sample 50 random points within each element of Buffer_spdf (each buffer of each location of each animal) for pseudo-absences
PA <- spsample(Buffer_spdf@polygons[[1]], n = 50, "random")

for (i in 2:length(Buffer_spdf@polygons)) {
  rp <- spsample(Buffer_spdf@polygons[[i]], n = 50, "random")

  if(is.null(PA)) {
    PA <- rp
  }else{
    PA <- rbind(PA, rp)
  }

   if(i/1000 == round(i/1000)) {
     print(i)
    write.csv(PA, paste0('./tempfilesPA/temp',i,'csv'), row.names=F)
    PA <- NULL

   }
}

# Combine tempfiles and write to dataframe
#list fiels in directory
mydir <-  "tempfilesPA"
myfiles <-  list.files(path=mydir, pattern="*.csv", full.names=TRUE)
myfiles
# read all files at once into single dataframe
dat_csv <-  ldply(myfiles, read_csv)
dat_csv

#DFF 1:95000

#create dataframe with aid and datetime with 100 reps for each location, to then add coordinates to for ndvi extraction
DFF <- data.frame( "datetime" = rep(WBS@data[1, 22], 50), "AID" = rep(WBS@data[1, 1], 50))

for (i in 2:length(WBS@data$AID)) {
  DF <- data.frame( "datetime" = rep(WBS@data[i, 22], 50), "AID" = rep(WBS@data[i, 1], 50))
  
  if(is.null(DFF)) {
    DFF <- DF
  }else{
    DFF <- rbind(DFF, DF)
  }
  
  if(i/1000 == round(i/1000)) {
    print(i)
    write.csv(DFF, paste0('./tempfilesDFF/temp',i,'csv'), row.names =F)
    DFF <- NULL
  }
}

# Combine tempfiles and write to dataframe
#list fiels in directory
dir <-  "tempfilesDFF"
files <-  list.files(path=dir, pattern="*.csv", full.names=TRUE)
files
# read all files at once into single dataframe
data_csv <-  ldply(files, read_csv)
data_csv

## COMBINE PA and DFF
Points <- cbind(data_csv, dat_csv)

### Problem: only goes up until 95000, ignores the last 940

#solution 1: not elegant but so you can continue working
## for loop for the remaining 940

###PA

# PA.1 dor remaining 940 (95.001-95.940)
PA.1 <- spsample(Buffer_spdf@polygons[[95001]], n = 50, "random")

for (w in 95002:95940) {
  
  rp.1 <- spsample(Buffer_spdf@polygons[[w]], n = 50, "random")
  
  PA.1 <- rbind(PA.1, rp.1)
}

###DFF

#create dataframe with aid and datetime with 100 reps for each location, to then add coordinates to for ndvi extraction
DFF.1 <- data.frame( "datetime" = rep(WBS@data[95001, 22], 50), "AID" = rep(WBS@data[1, 1], 50))

for (v in 95002:95940) {
  DF.1 <- data.frame( "datetime" = rep(WBS@data[v, 22], 50), "AID" = rep(WBS@data[v, 1], 50))
  
    DFF.1 <- rbind(DFF.1, DF.1)
}
    
    
#after cbind rp.1 and DF.1 and then rbind to Points
Points.1 <- cbind(DFF.1, PA.1)
# convert Points.1 to SpatialPoints
coordinates(Points.1) <- ~x+y
crs <- CRS("+init=epsg:32736")
proj4string(Points.1) <- crs

###BIND POINTS up tp 95000 and 95940 together
Points <- spTransform(Points, crs)
Points <- rbind(Points, Points.1)



### solution 2 :
# add an if statement into original loop for 95001 to 95940

###PA

# PA.1 for remaining 940 (95.001-95.940)
PA.1 <- spsample(Buffer_spdf@polygons[[95001]], n = 50, "random")

if(i >= 95002 || i <= 95940) {
  
  rp <- spsample(Buffer_spdf@polygons[[i]], n = 50, "random")
  PA.1 <- rbind(PA.1, rp)
}

#############END RESULT IS POINTS

#check code running time
x <- Sys.time()
Sys.time()-x