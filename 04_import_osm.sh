#!/bin/bash -e
set -o pipefail
source env.sh

if [ data/$REGION-latest.osm.pbf -nt data/$REGION-filtered.osm.pbf ]; then
    echo ">>> Filter OSM data"
    osmium tags-filter data/$REGION-latest.osm.pbf 'addr:*' -o data/$REGION-filtered.osm.pbf
fi
echo ">>> Import filtered OSM data into PostGIS database"
osm2pgsql --create --slim --cache $MEMORY --number-processes 8 \
    --flat-nodes data/nodes.bin --style addresses.lua \
    --output flex data/$REGION-filtered.osm.pbf
rm data/nodes.bin
