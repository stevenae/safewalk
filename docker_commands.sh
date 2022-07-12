# for initialization
# run from ~/Documents/GitHub/safewalk
# osm.pbf file downloaded manually from Geofabrik

# osmconvert district-of-columbia-latest.osm.pbf > district-of-columbia-latest.osm

osmfilter district-of-columbia-latest.osm --keep-tags='all highway= bridge= route= leisure= man_made= railway= platform= amenity= public_transport=' > dc_foot.osm

# osmfilter district-of-columbia-latest.osm --keep='footway' > dc_footway.osm
# osmfilter district-of-columbia-latest.osm --keep='highway=footway =crossing' > dc_highway_footway_crossing.osm
# osmfilter district-of-columbia-latest.osm --keep="name=*Northeast* or name=*Northwest* or name=*Southeast* or name=*Southwest*" > dc_streets.osm

# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/district-of-columbia-latest.osm.pbf
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/dc_foot.osm


# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/district-of-columbia-latest.osrm
# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/district-of-columbia-latest.osrm
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/dc_foot.osrm
# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/dc_foot.osrm


# to service requests

# docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/district-of-columbia-latest.osrm
docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/dc_foot.osrm

# for crime updates

# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/district-of-columbia-latest.osrm --segment-speed-file /data/traffic_update.csv
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/dc_foot.osrm --segment-speed-file /data/traffic_update.csv