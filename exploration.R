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

u <- "http://0.0.0.0:5000/"
options(osrm.server = u)

st_layers('~/Documents/GitHub/safewalk/district-of-columbia-latest.osm',do_count=T)
dc_points <- read_sf('~/Documents/GitHub/safewalk/district-of-columbia-latest.osm',layer='points')
dc_lines <- read_sf('~/Documents/GitHub/safewalk/district-of-columbia-latest.osm',layer='lines')
# dc_lines_sidewalk <- subset(dc_lines,grepl('sidewalk',other_tags) & !grepl('\"sidewalk\"=>\"no\"',other_tags))
dc_crossings <- subset(dc_points,highway=='crossing')
crossing_bbox <- st_bbox(dc_crossings)

if(0){ # rerun after changing osm file
  waypoint_nodes <- apply(d, 1, function(d_row){
    print(d_row)
    st_nearest_feature(d_row,dc_lines)
  })
  dc_lines_crimes <- unique(dc_lines[st_nearest_feature(d,dc_lines),])
  hist(st_length(st_transform(dc_lines_crimes$geometry,'EPSG:25832')))
  ggplot() +
    geom_sf(data = dc_lines$geometry,
            inherit.aes = FALSE,
            color = "lightgrey") +
    geom_sf(data=dc_lines_crimes$geometry,
            inherit.aes = FALSE,
            color = dc_lines_crimes$osm_id) +
    # scale_discrete_identity(color = dc_lines_crimes$osm_id) + 
    coord_sf(xlim = crossing_bbox[c(1,3)], 
             ylim = crossing_bbox[c(2,4)],
             expand = TRUE) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  str(waypoint_nodes)
  waypoint_nodes <- data.frame(t(matrix(waypoint_nodes,nrow=4)))
  names(waypoint_nodes) <- c('OBJECTID','node1','node2','OFFENSE')
  
  l <- c("HOMICIDE" = 1, "ASSAULT W/DANGEROUS WEAPON" = 2, "ROBBERY" = 3, "SEX ABUSE" = 4)
  traffic_update <- apply(waypoint_nodes,1,function(node_row){
    crime_weight <- l[node_row[4]]
    as.matrix(c(c(node_row[2],node_row[3],0),
              c(node_row[3],node_row[2],0)))
  })
  
  traffic_update <- t(matrix(traffic_update,nrow=3))
  write.table(traffic_update,'~/Documents/GitHub/safewalk/traffic_update.csv',
              row.names = F, col.names = F,  sep=",", quote = F)
}

if(0){
  register_google('AIzaSyCcwO8I6HIxfmCckS4pku_6-1N9s0ijSB4')
  home_ll <- geocode('2032 belmont rd nw washington dc')
  seylou_ll <- geocode('seylou washington dc')
  
  route4 <-  osrmRoute(src = seylou_ll, 
                       dst = home_ll,
                       returnclass = "sf",
                       osrm.profile = 'foot')
}

if(0){
  route4_bbox <- st_bbox(route4)
  osm_q <- opq(bbox=route4_bbox)
  bmap <- osmdata_sf(osm_q)
}

ggplot() +
  geom_sf(data = bmap$osm_lines,
          inherit.aes = FALSE,
          color = "steelblue") +
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


route4_postcrime <-  osrmRoute(src = seylou_ll, 
                     dst = home_ll,
                     returnclass = "sf",
                     osrm.profile = 'foot')


if(0){
  route4_postcrime_bbox <- st_bbox(route4_postcrime)
  osm_postcrime_q <- opq(bbox=route4_postcrime_bbox)
  bmap_postcrime <- osmdata_sf(osm_postcrime_q)
}

ggplot() +
  geom_sf(data = bmap_postcrime$osm_lines,
          inherit.aes = FALSE,
          color = "lightgrey") +
  geom_sf(data = route4$geometry,
          inherit.aes = FALSE,
          color = "blue") +
  geom_sf(data = route4_postcrime$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  geom_sf(data = d$geometry,
          inherit.aes = FALSE,
          aes(color=d$OFFENSE)) +
  coord_sf(xlim = route4_postcrime_bbox[c(1,3)], 
           ylim = route4_postcrime_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


ggplot() +
  geom_sf(data = dc_streets$geometry,
          inherit.aes = FALSE,
          color = "lightgrey") +
  # geom_sf(data = route4$geometry,
  #         inherit.aes = FALSE,
  #         color = "blue") +
  geom_sf(data = route4_postcrime$geometry,
          inherit.aes = FALSE,
          color = "orange") +
  geom_sf(data = d$geometry,
          inherit.aes = FALSE,
          aes(color=d$OFFENSE)) +
  coord_sf(xlim = route4_postcrime_bbox[c(1,3)], 
           ylim = route4_postcrime_bbox[c(2,4)],
           expand = TRUE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
