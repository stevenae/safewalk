# for initialization
# run from ~/Documents/GitHub/safewalk
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/district-of-columbia-latest.osm.pbf
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/district-of-columbia-latest.osrm
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/district-of-columbia-latest.osrm
# to service requests
docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/district-of-columbia-latest.osrm
# for crime updates
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/district-of-columbia-latest.osrm --segment-speed-file /data/traffic_update_lines.csv
docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/district-of-columbia-latest.osrm