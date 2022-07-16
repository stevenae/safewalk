library(sf)
library(osrm)
library(osmdata)
library(ggplot2)
library(ggmap)

d <- st_read('~/Documents/GitHub/safewalk/Crime_Incidents_in_2022.geojson')
d <- subset(d, OFFENSE %in% c('ASSAULT W/DANGEROUS WEAPON','HOMICIDE','ROBBERY','SEX ABUSE'))

overpass_query_str <- 'nwr["highway"~"primary|primary_link|secondary|secondary_link|tertiary|tertiary_link|unclassified|residential|road|living_street|service|track|path|steps|pedestrian|footway"](area:3600162069);(._;>;);out;'
overpass_server <- 'https://overpass-api.de/api/interpreter?'
overpass_url <- paste0(overpass_server,overpass_query_str)

file_osm <- "~/Documents/GitHub/safewalk/dc_node_overpass.osm"
# dc_osm <- osmdata_xml(overpass_query_str,file_osm)
dc_osm <- osmdata_sf(overpass_query_str,file_osm)

dc_latest <- dc_osm$osm_points

node_near_crime <- st_is_within_distance(x=d,y=dc_latest,100)
table(lengths(node_near_crime))
dc_block_crimes <- dc_latest[unlist(node_near_crime),]

dc_block_crime_next_nearest_ids <- st_nearest_feature(dc_block_crimes,dc_latest[-unlist(node_near_crime),])
dc_block_crime_next_nearest <- dc_latest[-unlist(node_near_crime),][dc_block_crime_next_nearest_ids,]

dc_block_crimes$offense <- rep(d$OFFENSE,lengths(node_near_crime))
  
register_google('AIzaSyCcwO8I6HIxfmCckS4pku_6-1N9s0ijSB4')
home_ll <- geocode('2032 belmont rd nw washington dc')
seylou_ll <- geocode('seylou washington dc')

u <- "http://0.0.0.0:5000/"
# u <- "https://routing.openstreetmap.de/"
options(osrm.server = u)

route_no_crime <-  osrmRoute(src = seylou_ll, 
                     dst = home_ll,
                     returnclass = "sf",
                     osrm.profile = 'foot',
                     annotations = TRUE)
route_no_crime$geometry <- googlePolylines::decode(route_no_crime$routes$geometry)[[1]][,c(2,1)]
route_no_crime$geometry <- paste0(route_no_crime$geometry$lon, ' ', route_no_crime$geometry$lat, collapse = ", ")
route_no_crime$geometry <- (st_as_sfc(paste0("LINESTRING(",route_no_crime$geometry,")")))
route_no_crime$geometry <- st_set_crs(route_no_crime$geometry,4326)

traffic_update <- apply(cbind(dc_block_crimes$osm_id,dc_block_crime_next_nearest$osm_id),1,function(osm_ids){
  route_match <- pmatch(osm_ids,route_no_crime$routes$legs[[1]]$annotation$nodes[[1]])
  if(all(!is.na(route_match)) & abs(diff(route_match))==1){
    print('found affected node pair')
  }
  return(c(c(osm_ids,0),c(rev(osm_ids),0)))
})

traffic_update <- t(matrix(unlist(traffic_update,recursive = F),nrow=3))

write.table(traffic_update,'~/Documents/GitHub/safewalk/traffic_update.csv',
            row.names = F, col.names = F,  sep=",", quote = F)

route_no_crime_bbox <- st_bbox(route_no_crime$geometry)
crime_lines <- st_sfc(mapply(function(a,b){st_cast(st_union(a,b),"LINESTRING")}, dc_block_crimes$geometry, dc_block_crime_next_nearest$geometry, SIMPLIFY=FALSE))
crime_lines <- st_set_crs(crime_lines,4326)

ggplot() +
  geom_sf(data = dc_osm$osm_lines,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = route_no_crime$geometry,
          inherit.aes = FALSE,
          color = "blue") +
  geom_sf(data=crime_lines,
          inherit.aes = FALSE,
          # alpha=.1,
          aes(color = dc_block_crimes$offense)) +
  geom_sf(data=d$geometry,
          inherit.aes = FALSE,
          aes(color = d$OFFENSE)) +
  coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
           ylim = route_no_crime_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

route_post_crime <-  osrmRoute(src = seylou_ll, 
                     dst = home_ll,
                     returnclass = "sf",
                     osrm.profile = 'foot')
route_post_crime$geometry <- googlePolylines::decode(route_post_crime$routes$geometry)[[1]][,c(2,1)]
route_post_crime$geometry <- paste0(route_post_crime$geometry$lon, ' ', route_post_crime$geometry$lat, collapse = ", ")
route_post_crime$geometry <- (st_as_sfc(paste0("LINESTRING(",route_post_crime$geometry,")")))
route_post_crime$geometry <- st_set_crs(route_post_crime$geometry,4326)

route_post_crime_bbox <- st_bbox(route_post_crime$geometry)

route_post_crime$routes$geometry == route_no_crime$routes$geometry

ggplot() +
  geom_sf(data = dc_osm$osm_lines,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = route_no_crime$geometry,
          inherit.aes = FALSE,
          color = "blue") +
  geom_sf(data = route_post_crime$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  geom_sf(data=dc_block_crimes$geometry,
          inherit.aes = FALSE,
          alpha=.1,
          aes(color = dc_block_crimes$offense)) +
  geom_sf(data=d$geometry,
          inherit.aes = FALSE,
          aes(color = d$OFFENSE)) +
  coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
           ylim = route_no_crime_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())



