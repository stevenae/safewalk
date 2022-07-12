library(sf)
library(osrm)
library(osmdata)
library(ggplot2)
library(ggmap)

d <- st_read('~/Documents/GitHub/safewalk/Crime_Incidents_in_2022.geojson')
d <- subset(d, OFFENSE %in% c('ASSAULT W/DANGEROUS WEAPON','HOMICIDE','ROBBERY','SEX ABUSE'))

dc_latest <- read_sf('~/Documents/GitHub/safewalk/dc_foot.osm',layer='lines')
# dc_intersections <- read_sf('~/Documents/GitHub/safewalk/dc_highway_footway_crossing.osm',layer='points')
# dc_blocks <- read_sf('~/Documents/GitHub/safewalk/dc_highway_footway_crossing.osm',layer='lines')
# intersection_bbox <- st_bbox(dc_intersections)

if(0){ # rerun after changing osm file
  node_near_crime <- st_is_within_distance(x=d,y=dc_latest,dist=100)
  table(lengths(node_near_crime))
  dc_block_crimes <- dc_latest[unlist(node_near_crime),]
  dc_block_crimes$offense <- rep(d$OFFENSE,lengths(node_near_crime))
  
  ggplot() +
    geom_sf(data = dc_latest$geometry,
            inherit.aes = FALSE,
            aes(color = dc_latest$highway)) +
    coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
             ylim = route_no_crime_bbox[c(2,4)],
             expand = TRUE) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  ggplot() +
    geom_sf(data = dc_latest$geometry,
            inherit.aes = FALSE,
            color = "lightgrey") +
    geom_sf(data=d$geometry[which(lengths(node_near_crime)!=0)],
            inherit.aes = FALSE,
            aes(color = d$OFFENSE[which(lengths(node_near_crime)!=0)])) +
    geom_sf(data=dc_block_crimes$geometry,
            inherit.aes = FALSE,
            aes(color = dc_block_crimes$offense)) +
    # coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
    #          ylim = route_no_crime_bbox[c(2,4)],
    #          expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  dc_block_crime_intersects_indices <- st_intersects(dc_block_crimes,dc_latest)
  dc_block_crime_intersects <- dc_latest[unlist(dc_block_crime_intersects_indices),]
  
  ggplot() +
    geom_sf(data = dc_latest$geometry,
            inherit.aes = FALSE,
            color = "lightgrey") +
    geom_sf(data=dc_block_crimes$geometry,
            inherit.aes = FALSE,
            linetype = "dashed",
            aes(color = dc_block_crimes$offense)) +
    # geom_sf(data=dc_block_crime_intersects$geometry,
    #         inherit.aes = FALSE,
    #         linetype = "dotted",
    #         aes(color = rep(dc_block_crimes$offense,lengths(dc_block_crime_intersects_indices)))) +
    geom_sf(data=d$geometry,
            inherit.aes = FALSE,
            aes(color = d$OFFENSE)) +
    coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
             ylim = route_no_crime_bbox[c(2,4)],
             expand = TRUE) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  traffic_update <- lapply(dc_block_crime_intersects_indices,function(crime_indices){
    if(length(crime_indices)<2){
      return()
    }
    osm_ids <- dc_latest$osm_id[crime_indices]
    combination <- combn(c(osm_ids,rev(osm_ids)),2)
    rbind(combination,0)
  })
  
  
  traffic_update <- t(matrix(unlist(traffic_update,recursive = F),nrow=3))
  
  write.table(traffic_update,'~/Documents/GitHub/safewalk/traffic_update.csv',
              row.names = F, col.names = F,  sep=",", quote = F)
  
  slowed_ids <- apply(traffic_update,1,function(traffic_ids){
    intersect(unlist(st_touches(subset(dc_latest,osm_id==traffic_ids[1]),dc_latest)),
                            unlist(st_touches(subset(dc_latest,osm_id==traffic_ids[2]),dc_latest)))
  })
  slowed_ids <- unlist(slowed_ids)
}

if(0){
  register_google('AIzaSyCcwO8I6HIxfmCckS4pku_6-1N9s0ijSB4')
  home_ll <- geocode('2032 belmont rd nw washington dc')
  seylou_ll <- geocode('seylou washington dc')
  
  u <- "http://0.0.0.0:5000/"
  options(osrm.server = u)
  
  route_no_crime <-  osrmRoute(src = seylou_ll, 
                       dst = home_ll,
                       returnclass = "sf",
                       osrm.profile = 'foot')
}

route_no_crime_bbox <- st_bbox(route_no_crime)

ggplot() +
  geom_sf(data = dc_latest$geometry,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = route_no_crime$geometry,
          inherit.aes = FALSE,
          color = "blue") +
  geom_sf(data=dc_block_crimes$geometry,
          inherit.aes = FALSE,
          linetype = "dashed",
          aes(color = dc_block_crimes$offense)) +
  # geom_sf(data=dc_block_crime_intersects$geometry,
  #         inherit.aes = FALSE,
  #         linetype = "dotted",
  #         aes(color = rep(dc_block_crimes$offense,lengths(dc_block_crime_intersects_indices)))) +
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

route_post_crime_bbox <- st_bbox(route_post_crime)

route_post_crime == route_no_crime

ggplot() +
  geom_sf(data = dc_latest$geometry,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = route_no_crime$geometry,
          inherit.aes = FALSE,
          color = "blue") +
  geom_sf(data = route_post_crime$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  # geom_sf(data=dc_block_crimes$geometry,
  #         inherit.aes = FALSE,
  #         linetype = "dashed",
  #         aes(color = dc_block_crimes$offense)) +
  geom_sf(data=dc_block_crime_intersects$geometry,
          inherit.aes = FALSE,
          linetype = "dotted",
          aes(color = rep(dc_block_crimes$offense,lengths(dc_block_crime_intersects_indices)))) +
  geom_sf(data=d$geometry,
          inherit.aes = FALSE,
          aes(color = d$OFFENSE)) +
  coord_sf(xlim = route_no_crime_bbox[c(1,3)], 
           ylim = route_no_crime_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())



ggplot() +
  geom_sf(data = dc_latest$geometry,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = subset(dc_latest,osm_id %in% traffic_update,)$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
