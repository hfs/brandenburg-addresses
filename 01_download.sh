#!/bin/bash -e
set -o pipefail
source env.sh

cd data

if [ ! -r geoadr.gpkg ]; then
    echo "Please go to https://geobroker.geobasis-bb.de/ and download the data"
    echo "set “Georeferenzierte Adresse” in GeoPackage format. Please provide"
    echo "it as file data/geoadr.gpkg."
fi
echo ">>> Downloading OpenStreetMap dump for '$REGION_PATH'"
wget "https://download.geofabrik.de/$REGION_PATH-latest.osm.pbf" \
    --timestamping
