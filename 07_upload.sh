#!/bin/bash -e

set -o pipefail

source env.sh

ADDRESS_DATE=$(sqlite3 data/geoadr.gpkg 'SELECT MAX("AUD") FROM geoadr')
OSM_DATE=$(date -d @$(stat --format %Y data/$REGION-latest.osm.pbf) +%Y-%m-%dT%H:%M:%S)
TILES_DATE=$(date -d @$(stat --format %Y tiles/) +%Y-%m-%dT%H:%M:%S)

[ -d ../brandenburg_addresses_site/tiles/ ]
rm -rf ../brandenburg_addresses_site/tiles/
cp -a _config.yml index.md style.json tiles/ ../brandenburg_addresses_site/
cd ../brandenburg_addresses_site/
git add -u .
git add .
git commit -m "Temporary commit"
git reset $(git commit-tree HEAD^{tree} -m "Tiles generated on $TILES_DATE" -m "Addresses from: $ADDRESS_DATE" -m "OpenStreetMap dump from: $OSM_DATE")
git push -f
