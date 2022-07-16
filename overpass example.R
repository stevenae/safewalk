file_osm <- "~/Documents/GitHub/safewalk/dc_node_overpass.osm"

overpass_query_str <- 'nwr["highway"~"primary|primary_link|secondary|secondary_link|tertiary|tertiary_link|unclassified|residential|road|living_street|service|track|path|steps|pedestrian|footway"](area:3600162069);(._;>;);out;'
overpass_server <- 'https://overpass-api.de/api/interpreter?'
overpass_url <- paste0(overpass_server,overpass_query_str)
print (overpass_url)
# curl_call <- paste("curl -g -o", file_osm, shQuote(overpass))
# system (curl_call)
dc_osm <- osmdata_sf(overpass_query_str)

