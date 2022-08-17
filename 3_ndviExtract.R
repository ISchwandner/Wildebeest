###################################################################
### Extract NDVI metrics from a set of NDVI rasters over time: 
###################################################################
# (1) interpolated NDVI (indvi)
# (2) delta NDVI (dndvi)
# (3) cumulative NDVI (cumulative ndvi)
# (4) maximum delta ndvi (maxirg)
# (5) days different from the maximum delta NDVI for the most recent growing period (daysdiffirg)
# (6) anomally NDVI (andvi)

## see example run code at the bottom of script 
## last updated 20-Jun-22
## T Morrison <thomas.morrison@glasgow.ac.uk>
## Edited for this project I Schwandner <2671952@student.gla.ac.uk>

###################################################################

#Requires the following in your working directory

# empty folder "tempfiles"

# folder : "ndvi" contains MODIS derived (with original names) mean ndvi raster for each 16-day period
# - files should take this format and naming:
#   "MOD13Q1.A2021001.250m_16days_NDVI.tif"

# folder : "ndvi_mean" contains mean NDVI raster of all 16-day means
# - file should take this format and naming:
#  "MEAN_MOD13Q1_250m_16days_NDVI_2022-06-08.tif"
# optional to add Metadata text file as well as standard deviation
#  "SD_MOD13Q1_250m_16days_NDVI_2022-05-09.tif"

# empty folder: "MODIS_NDVI_MATRIX"

###################################################################


#########################################
####### Functions to extract ndvi data
#########################################

## create dataframe with details of stack
build.ndvi.description <- function(folder, # full path location of folder containing NDVI geotifs
                                   date.loc=c(10,16), # character location in filenames of NDVI containing dates 
                                   date.format="%Y%j", # format of dates
                                   start.date = NULL, end.date = NULL){ 
  #
  ndvi.data <- data.frame(filenames=list.files(folder,pattern = "MOD13Q1"),
                        year=NA,date=ymd("1970-01-01"))
  
  if(nrow(ndvi.data)==0) stop('Folder with NDVI layers missing OR file names of NDVI layers must be renamed to include MOD13Q1')
  
  ndvi.data$filenames <- as.character(ndvi.data$filenames)
  
  ndvi.data$date<-as.Date(substr(ndvi.data$filenames, date.loc[1], date.loc[2]),
                          format=date.format,
                          tz="GMT")
  
  ndvi.data$year<-year(ndvi.data$date)
  
  ndvi.data$folder<-folder
  
  ## order by date
  ndvi.data<-ndvi.data[order(ndvi.data$date),]
  ndvi.data[,1]<-as.character(ndvi.data[,1])
  
  ## filter by start and end date if provided
  if (!is.null(start.date)){
    start.date <- as.Date(start.date)
    ndvi.data <- ndvi.data[ndvi.data$date >= start.date,]
  }
  
  if (!is.null(end.date)){
    end.date <- as.Date(end.date)
    ndvi.data <- ndvi.data[ndvi.data$date <= end.date,]
  }
  
  return(ndvi.data)
}

# create raster stack 
build.ndvi.stack <- function(ndvi.description){

  ndvi.stack <- rast(paste("C:/Users/Administrator/Desktop/Imogen/NDVI_Imo/ndvi/",
                           ndvi.description$filenames,
                           sep="/"))
  
  return(ndvi.stack)
}

# convert stack into ff-matrix
stack.to.mat <- function(st){
  
  require(ff)
  
  # break into 2 pieces bc of memory crashing
  if(dim(st)[3] > 250){
    st1 <- st[[1:250]]
    st2 <- st[[251:(dim(st)[3])]]
  }else{
    # work around to simplify code
    st1 <- st[[1:(nlyr(st)-1)]]
    st2 <- st[[nlyr(st)]]
  }
  ndvi.mat1 <- ff(vmode="double",dim=c(ncell(st),dim(st1)[3]),filename=paste0(getwd(),"/stack1_",Sys.Date(),".ffdata"))
  ndvi.mat2 <- ff(vmode="double",dim=c(ncell(st),dim(st2)[3]),filename=paste0(getwd(),"/stack2_",Sys.Date(),".ffdata"))
  
  ## part 1
  for(i in 1:dim(st1)[3]){
    ndvi.mat1[,i] <- st1[[i]][]
  }
  # save as R file  
  save(ndvi.mat1,file=paste0('ndvi_mat1_',Sys.Date(),".RData"))
  
  ## part 2
  for(i in 1:dim(st2)[3]){
    ndvi.mat2[,i] <- st2[[i]][]
  }
  
  # save as R file  
  save(ndvi.mat2,file=paste0('ndvi_mat2_',Sys.Date(),".RData"))
  
  # combine 
  x <- as.ffdf(ndvi.mat1)
  z <- as.ffdf(ndvi.mat2)
  ndvi.mat <- do.call("ffdf", c(physical(x), physical(z)))
  
  return(ndvi.mat)
}

# mean and sd across all ndvi layers
calc.meansd <- function(st, sdes){
  
  ave.ndvi <- mean(st,na.rm=T)
  writeRaster(ave.ndvi,paste0('./MODIS_MEAN_NDVI/','MEAN_MOD13Q1_250m_16_days_NDVI_',max(sdes$date),'.tif'),overwrite=T) 
  sd.ndvi <- stdev(st,na.rm=T)
  writeRaster(sd.ndvi,paste0('./MODIS_MEAN_NDVI/','SD_MOD13Q1_250m_16_days_NDVI_',max(sdes$date),'.tif'),overwrite=T) 

}

# NDVI run extraction 
extract.ndvi <- function(ave.ndvi,        # folder in which NDVI_mean.tif is saved
                         #stack,          # Raster stack output from above build.ndvi.stack - no longer needed in extract function
                         stack.desc,      # Stack description from above build.ndvi.description
                         loc,             # All x-y locations projected in latlong
                         date,            # as.Dates from loc, e.g. date column from your GPS points
                         mat
                         ){
  
  # Warning messages
  if(length(date) > 1 && length(date) != nrow(loc))
    stop("Dates must be either one date for all points, or one date for each point")
  if(!class(date) %in% c("Date"))
    date <- as.Date(date)
  if(class(loc) != "SpatialPointsDataFrame")
    stop("Locations must be a SpatialPointsDataFrame with same projection as raster stack")    
  # if(substr(as.character(crs(loc)),1,26) != substr(as.character(crs(stack)),1,26))
  #   stop("Locations and raster stack do not have same CRS projection")    
  if(ncol(mat) != nrow(stack.desc)) 
    stop("NDVI matrix has different number of layers than NDVI stack (ncol(mat)!=nrow(stack.desc))")
  
  # Check if extraction is across multiple dates
  if (length(date) == 1) {multi.extract <- T}else{multi.extract <- F}
  
  # ensure that dates are Dates not posix
  date <- as.Date(date)
  
  # create empty raster stack
  ras <- ave.ndvi
  ras[] <- 1:ncell(ras)

  # identify cell location of loc[,i]
  ext_ID <- raster::extract(ras,loc)
  
  # loop through each date (ie gps pt) and return ndvi metrics
  ndvi.ret <- NULL
  
  for(i in 1:length(date)){
    
    nidx <- which.min(abs(as.numeric(stack.desc$date-as.Date(date[i]))))
    
    ## initialize the before and after layer indices to the nearest layer
    loidx <- nidx
    hiidx <- nidx
    
    ## now calculate whether we want to use the previous or next raster for interpolation;
    ## switch is faster for performing these kind of ifelse operations, so scale and normalize
    diff <- as.numeric(stack.desc$date[nidx]) - as.numeric(date[i])      # -n, 0, n
    if (diff != 0) diff <- diff/abs(diff)
    diff <- diff + 2                                                   #  1, 2, 3
    
    ## 1 means interpolate forward, 3 means interpolate backwards; 2 means we are on an NDVI
    ## layer date, so no interpolation needed
    switch(diff, hiidx <- nidx+1, interp <- 1, loidx <- nidx-1)
    
    ## get the scaling value for interpolation if needed; check if we are interpolating
    if (hiidx != loidx){
      ## calculate the linear scaling value from the previous to the next NDVI values
      interp <- (as.numeric(date[i]) - as.numeric(stack.desc$date[loidx])) /
        (as.numeric(stack.desc$date[hiidx]-stack.desc$date[loidx]))
    } else {
      
      ## we are bang on an NDVI date; check how we need to adjust where we are interpolating to:
      ## full interpolation from the previous NDVI date
      if (loidx > 1){
        loidx <- loidx - 1
        ## no interpolation from the current NDVI date
      } else {
        hiidx <- hiidx + 1
        interp <- 0
      }
    }
    
    ## check if date-i falls within the ndvi dates, ignore if not
    if(as.Date(date[i]) >= min(stack.desc$date,na.rm=T) & 
        as.Date(date[i]) <= max(stack.desc$date,na.rm=T) &
       !is.na(ext_ID[i])){
      
      ndvi_start <- mat[ext_ID[i], loidx]
      ndvi_end <- mat[ext_ID[i], hiidx]
      
      ## calculate NDVI changes, and then interpolate the estimated NDVI value
      indvi <- ndvi_start + (interp * (ndvi_end - ndvi_start)) #NDVI, interpolated
      dndvi <- (ndvi_end - ndvi_start) / as.numeric(stack.desc$date[hiidx] - stack.desc$date[loidx], units = "days") #delta ndvi
      
      ######################
      
      ## calculate days different from max IRG for this time period
      if((loidx-30) > 0) { 
        mint <- 30
      }else{
        mint <- loidx-1  
      }
      
      if((hiidx+30) <= nrow(stack.desc)) { 
        hint <- 30
      }else{
        hint <- nrow(stack.desc)-hiidx
      }
      
      # date range of current window
      dtrange <- (loidx-mint):(hiidx+hint)
      
      # ndvi values for current window
      fs <- mat[ext_ID[i],dtrange]
      fs.na <- as.vector(fs,mode = 'numeric')
      
      # calculate rolling mean of wd values at a time
      wd <- 6
      fs.na <- rollapply(fs.na, width = wd, by = 1, 
                         FUN = mean, 
                         na.rm = TRUE, 
                         fill = c(NA,NA,NA),
                         align='center')
      
      # critical number of segments that must be increasing/decreasing
      critn <- 6
      
      # identify the set of dates where IRG is maximal
      
      xx <- (sapply(1:length(fs.na), function(x) {
      # for(x in 1:length(fs.na)){
        # if(x == 1) xx <- NULL
        if( x > critn & x < (length(fs.na)-critn)){
          # find start of green-up
          p0 <- fs.na[x]-fs.na[x-1]
          p1 <- sapply(1:critn,function(z) fs.na[x+z]-fs.na[x+(z-1)])
          p1 <- p1[!is.na(p1)]
          
          if(p0 < 0 & all(p1>0)) {
            green=1
          }else{
            green=0
          }
          
          # find end of green up
          k0 <- fs.na[x+1]-fs.na[x]
          k1 <- sapply(1:critn,function(z) fs.na[x-(z-1)]-fs.na[x-z])
          k1 <- k1[!is.na(k1)]
          
          if(k0<0 & all(k1>0)) {
            green=2
          }
        }
        else{
          green=0
        }
       return(green)
        # xx <- c(xx,green)
      }
      ))

      # 1 = start of green up
      # 2 = end of green up
      # 3 = midpoint of green up (highest IGR)
      
      # find all starts and ends of green-up in 30+/- window
      startx <- which(xx == 1)
      endx <- which(xx == 2)
      
      ## visualize
      # plot(1:length(fs),fs,type='l',lty=2,col='grey',lwd=1,xlab='',ylab='NDVI')
      # lines(1:length(fs.na),fs.na,type='l',col='red',lwd=1.7)
      # points(startx,fs.na[startx],col='green',cex=3,pch=16)
      # points(endx,fs.na[endx],col='red',cex=3,pch=16)
      
      # identify midpoints between each start and end
      for(k in 1:length(xx)){
        if(xx[k]==1){
          wx <- endx[which(endx>k)]
          wx <- wx[wx==min(wx)]
          xx[k + round(((wx-k)/2))] <- 3
        }
      }
      
      # identify nearest midpoint and days diff from midpoint of green-up
      midpt <- which(xx==3) 
      dfs <- midpt[which.min(abs((length(fs.na)-hint-1) - midpt))]
      maxirg <- median(stack.desc$date[dtrange[c(dfs,dfs+1)]])
      daysdiffirg <- as.numeric(difftime(date[i],maxirg,units = 'days'))
      
      # calc cumulative NDVI
      if( any(((length(fs.na)-hint-1) - startx) > 0) ){
        pre <- startx[which(((length(fs.na)-hint-1) - startx) > 0)] 
        cum.dtrange <- dtrange[pre[which.min(pre)]]:hiidx
        cndvi <- sum(unlist(mat[ext_ID[i],cum.dtrange]),na.rm=T)
      }else{
        cndvi <- NA
      }
      ##########################        
      
      # Compile data
      ndvi.ret <- rbind(ndvi.ret,
                        data.frame(indvi=indvi,
                                   dndvi=dndvi,
                                   cndvi=cndvi,
                                   maxirg=maxirg,
                                   daysdiffirg=daysdiffirg)
      )
    }else{
      
      ndvi.ret <- rbind(ndvi.ret,
                        data.frame(indvi=NA,
                                   dndvi=NA,
                                   cndvi=NA,
                                   maxirg=NA,
                                   daysdiffirg=NA)
      )
    }
    
    # print progress and write data to file (faster)
    if(i/25000 == round(i/25000) | i==length(date)) {
      print(paste(i,Sys.time()))
      write.csv(ndvi.ret,paste0('./tempfiles/',i,'.csv'),row.names=F)
      ndvi.ret <- NULL
    }
  }
  ls <- list.files(path = './tempfiles/',full.names = T)
  ls <- ls[order(file.info(paste0('./tempfiles/',ls))$mtime)]
  
  for(w in 1:length(ls)){
    f <- read.csv(ls[w])
    if(w==1){ 
      ndvi.ret <- f
    }else{
      ndvi.ret <- rbind(ndvi.ret,f)
    }
  }  

  # Anomally NDVI from long-term average NDVI
  ave.ndvi.val <- raster::extract(ave.ndvi,loc)
  andvi <- (ndvi.ret$indvi - ave.ndvi.val) # anomaly NDVI
  ndvi.ret$andvi <- andvi
  
  return(ndvi.ret)
}

# run NDVI extraction - arguments will need to be tailored to your specific dataset
run.ndvi.extract <- function(
                             # x-y columns of your locations
                             x,
                             y,
                             
                             # dates-times of each location as Date or POSIX
                             dates,
                             
                             # projection of data - "EPSG:21036" = #UTM 36S
                             dataproj = "+proj=utm +zone=36 +south +a=6378249.145 +rf=293.465 +units=m +no_defs
",
                             
                             # folder location where NDVI layers are saved
                             ndvi.fold,
                             
                             # average ndvi raster 
                             ave.ndvi.fold,

                             # optional argument if ndvi.mat is already in memory
                             ndvi.mat = NA,
                             
                             # optional argument specifying folder location where ndvi.mat is written to file
                             ndvi.mat.fold = NA #
                             ){

  # check install and require packages
  paks <- c('lubridate','raster','rgdal','rgeos','ff','zoo','terra')
  
  if(any(!paks %in% row.names(installed.packages()))){
    lapply(paks, install.packages, character.only = TRUE)
  }
  lapply(paks, require, character.only = TRUE)
  
  # read in long-term mean NDVI raster  
  lf <- list.files(path = ave.ndvi.fold, pattern ='MEAN_MOD')
  ave.ndvi = raster(paste0(ave.ndvi.fold,lf[1]))
  
  ## check the xy & date data
  if(length(x) != length(y)) stop('x & y locations are not same length. Check the column names of xy')
  if(length(x) != length(dates)) stop('x-y locations and Dates are not same length. Check the column names of xy and dates')
  if(!exists('ave.ndvi')) stop('ave.ndvi raster needs to be included in function arguments')

  # retain original working directory
  gwd <- getwd()
  
  ## Run ndvi extract code
  if(!exists('sdes')) {sdes <- build.ndvi.description(folder = ndvi.fold)}

  ## create/load/identify NDVI super-matrix
    # note that if you are using many layers, this function breaks the matrix into 2 pieces
    # because of memory issues. The pieces are then binded together below
  if(is.na(ndvi.mat)) {
    
    # check if ndvi.mat has been written to file, if not create file (this takes ~20 minutes)
    if(is.na(ndvi.mat.fold)){
      
      ## Build raster stack of all scenes
      st <- build.ndvi.stack(sdes)
      
      ## create super matrix ff object from NDVI stack
      gwd <- getwd()
      setwd('./MODIS_NDVI_MATRIX')
      ndvi.mat <- stack.to.mat(st)
    }else{
      
      # if ndvi.mat has been written to file(s), read it/them in
      gwd <- getwd()
      setwd('./MODIS_NDVI_MATRIX')
      lf <- list.files(pattern='RData')
      
      if(length(lf)>2) print('more than 2 RData files in the MODIS NDVI MATRIX folder - only retain most recent 2')
      
      # load first object
      load(lf[1])
      x <- as.ffdf(ndvi.mat1)
      
      # if there are 2 objects, combine them. Convert all to ffdf
      if(length(lf)==2) {
        load(lf[2])
        z <- as.ffdf(ndvi.mat2)
        ndvi.mat <- do.call("ffdf", c(physical(x), physical(z)))
        
        #clean up
        rm(ndvi.mat2,z)
      }else{
        ndvi.mat <- do.call("ffdf", c(physical(x)))
      }
      
      # clean up
      rm(ndvi.mat1,x)
      
    }
    setwd(gwd)
  }

  ## run check on dataset
  if(ncol(ndvi.mat) != nrow(sdes)) stop('ndvi matrix has different number of layers than ndvi description')

  ## set up objects
  dates <- as.Date(dates)
  loc <- data.frame(x=x,y=y,aid=rep(1,length(x)))
  coordinates(loc) <- ~x+y
  proj4string(loc) <- dataproj
  
  ## reproject to same projection as st if it isnt already in the same CRS
  loc <- spTransform(loc,CRSobj = raster::crs(ave.ndvi))
  
  ## check projections are same
  as.character(raster::crs(loc)) == as.character(raster::crs(ave.ndvi))

  setwd(gwd)
  
  ## run NDVI extract function
  xx <- extract.ndvi(ave.ndvi = ave.ndvi,
                     stack.desc=sdes,   # Stack description from above build.ndvi.description
                     loc=loc,           # All x-y locations projected in latlong
                     date=dates,        # as.Date from loc, e.g. date column from your GPS points
                     mat=ndvi.mat)

  setwd(gwd)
  return(xx)
}

###################################################  
#### EXAMPLE RUN CODE #############################
###################################################

#########################################
## Read in data #########################

load("RSF.RData")
RSF <- spTransform(RSF, CRS("+init=epsg:21036"))

setwd("C:/Users/Administrator/Desktop/Imogen/NDVI_Imo/")

# Run NDVI extraction
ndvi <- run.ndvi.extract(x = RSF$x, 
                         y = RSF$y,
                         dates = RSF$datetime,
                         dataproj = "+proj=utm +zone=36 +south +a=6378249.145 +rf=293.465 +units=m +no_defs
",
                         ndvi.fold = "./ndvi/",
                         ave.ndvi.fold = "./ndvi_mean/")

# save NDVI values for use in RSF.Rmd
save(ndvi, file = "ndvi.RData")