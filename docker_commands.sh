# for initialization
# run from ~/Documents/GitHub/safewalk
# osm.pbf file downloaded manually from Geofabrik

# osmconvert district-of-columbia-latest.osm.pbf > district-of-columbia-latest.osm

# osmfilter district-of-columbia-latest.osm --keep='footway' > dc_footway.osm
# osmfilter district-of-columbia-latest.osm --keep="name=*Northeast* or name=*Northwest* or name=*Southeast* or name=*Southwest*" > dc_streets.osm
# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/district-of-columbia-latest.osm.pbf
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/dc_streets.osm

# for crime updates

# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-contract /data/district-of-columbia-latest.osrm --segment-speed-file /data/traffic_update.csv
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-contract /data/dc_streets.osrm --segment-speed-file /data/traffic_update.csv

# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/district-of-columbia-latest.osrm
# docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/district-of-columbia-latest.osrm
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/dc_streets.osrm
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/dc_streets.osrm


# to service requests

# docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/district-of-columbia-latest.osrm
docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/dc_streets.osrm