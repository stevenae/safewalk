library(sf)
library(osrm)
library(osmdata)
library(ggplot2)
library(ggmap)

d <- st_read('~/Documents/GitHub/safewalk/Crime_Incidents_in_2022.geojson')
d <- subset(d, OFFENSE %in% c('ASSAULT W/DANGEROUS WEAPON','HOMICIDE','ROBBERY','SEX ABUSE'))
l <- st_read('~/Documents/GitHub/safewalk/Street_Lights.geojson')

# l_d_100m <- st_is_within_distance(st_transform(l$geometry,3857),st_transform(d$geometry,3857),100,sparse=F)

# l_ineff <- apply(l_d_100m,1,any)

if(0){
  register_google('AIzaSyCcwO8I6HIxfmCckS4pku_6-1N9s0ijSB4')
  home_ll <- geocode('2032 belmont rd nw washington dc')
  seylou_ll <- geocode('seylou washington dc')
}

route4 <-  osrmRoute(src = seylou_ll, 
                     dst = home_ll,
                     returnclass = "sf",
                     osrm.profile = 'foot')

route4_bbox <- st_bbox(route4)
osm_q <- opq(bbox=route4_bbox)
bmap <- osmdata_sf(osm_q)
ggplot() +
  geom_sf(data = bmap$osm_lines,
          inherit.aes = FALSE,
          color = "steelblue") +
  # geom_sf(data = l[!l_ineff,]$geometry,
  #         inherit.aes = FALSE,
  #         color = "white") +
  # geom_point( alpha = 0.1 ) +
  geom_sf(data = route4$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  geom_sf(data = d$geometry,
          inherit.aes = FALSE,
          aes(color=d$OFFENSE)) +
  coord_sf(xlim = route4_bbox[c(1,3)], 
           ylim = route4_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

