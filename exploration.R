install.packages('sf')
library(sf)
d <- st_read('~/Documents/GitHub/safewalk/Crime_Incidents_in_2022.geojson')
plot(d)
plot(d['OFFENSE'])
ggplot() + 
  geom_sf(data = d, aes(colour = OFFENSE))
d$BLOCK
?aes
?osrm
l <- st_read('~/Documents/GitHub/safewalk/Street_Lights.geojson')
str(l)
l$geometry
d$geometry

d$BLOCK
l$STREETNAME
l$WARD
d$WARD

d$WARD <- as.integer(d$WARD)
outer(d$WARD,l$WARD,'==')

wards <- unique(d$WARD)

l$street_stub <- str_pad(gsub(' [^ ]*$','',l$STREETNAME),1,'both')
l$geometry <- st_transform(l$geometry,3857)
d$geometry <- st_transform(d$geometry,3857)
k <- apply(l,1,function(l_r){
  apply(d,1,function(d_r){
    # print(l_r['street_stub'])
    if(l_r$WARD==d_r$WARD & grepl(l_r['street_stub'],d_r['BLOCK'])){
      print('match')
      return(st_distance(l_r$geometry,d_r$geometry))
    } else {
      return(Inf)
    }
  })
})

boxplot(is.finite(k),col='lightblue')


