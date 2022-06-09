## DATA EXPLORATION

#mapping/ checking
library(mapview)
mapview(kenya, color = "black", alpha.regions = 0) + mapview(rivers) + mapview(roads, color = "brown")

mapview(MMNR) + mapview(SNP) +mapview(MC)

#mapview(WOP, zcol = "ID") #takes a veeery long time

## EXPLORATION OF FENCE DATA
str(fence@data)

unique(fence@data$active)
# only 1, only sctive ones shown

unique(fence@data$type)
# many many categories, potentailly classify as electric/non electric, by height (in feet)

unique(fence@data$spatial_da)
# MEP, SORALO, NA 
### ASK ABOUT THIS

# collect_da, created_da
unique(fence@data$collect_da)

unique(fence@data$ground_ver)
# soime yes some no some NA

unique(fence@data$spatial_da)
# methods in landdx data MEP and Soralo (check after clipping again)

## EXPLORATION OF OLD WILDEBEEST POINT DATA
str(WOP@data)

unique(WOP@data$Nav)
#"3D" "2D"
unique(WOP@data$Main)
#3.36 3.44 3.28 3.52
unique(WOP@data$Descriptio)
# meaning of name             

unique(WOP@data$Sex)
# "F" "M"
unique(WOP@data$Location)
# "Maasai Mara"
unique(WOP@data$DOP)
range(WOP@data$DOP)
# 1.0, 9.8


##checking dates of WOP

head(str(WOP@data))
library(lubridate)
WOP@data$date <- as_date(WOP@data$date)

min(WOP@data$date)
#25.05.2010
max(WOP@data$date)
#15.01.2013


#eles recode codee

vole_sp@data$Occurrence[vole_sp@data$Occurrence == "absent"] <- 0
