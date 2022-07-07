library(sf)
d <- st_read('~/Documents/GitHub/safewalk/Crime_Incidents_in_2022.geojson')
l <- st_read('~/Documents/GitHub/safewalk/Street_Lights.geojson')

# d$WARD <- as.integer(d$WARD)
# d <- subset(d,!is.na(BLOCK) & !is.na(WARD) & !is.na(geometry))
# l <- subset(l,!is.na(STREETNAME) & !is.na(WARD) & !is.na(geometry))
# l$street_stub <- str_pad(gsub(' [^ ]*$','',l$STREETNAME),1,'both')
l$geometry <- st_transform(l$geometry,3857)
d$geometry <- st_transform(d$geometry,3857)
l_d_100m <- st_is_within_distance(l$geometry,d$geometry,100,sparse=F)


k <- pbapply(l,1,function(l_r){
  apply(d,1,function(d_r){
    if(l_r$WARD==d_r$WARD & grepl(l_r['street_stub'],d_r['BLOCK'])){
      # print('match')
      return(st_distance(l_r$geometry,d_r$geometry))
    } else {
      return(Inf)
    }
  })
})

boxplot(is.finite(k),col='lightblue')


