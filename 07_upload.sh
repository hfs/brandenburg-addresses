#!/bin/bash -e

set -o pipefail

source env.sh

export ADDRESS_DATE=$(sqlite3 data/geoadr.gpkg 'SELECT MAX("AUD") FROM geoadr')
export OSM_DATE=$(date -d @$(stat --format %Y data/$REGION-latest.osm.pbf) +%Y-%m-%dT%H:%M:%S%z)
export CHANGE_DATE=$(cat data/timestamp.txt)
export TILES_DATE=$(date -d @$(stat --format %Y tiles/) +%Y-%m-%dT%H:%M:%S%z)

[ -d ../brandenburg_addresses_site/tiles/ ]
rm -rf ../brandenburg_addresses_site/*
cp -a --reflink=auto tiles/ site/* style.json mapbox-gl-style.json ../brandenburg_addresses_site/
cat site/index.md | envsubst > ../brandenburg_addresses_site/index.md
cat site/en.md | envsubst > ../brandenburg_addresses_site/en.md
cd ../brandenburg_addresses_site/
git add -u .
git add .
git commit -m "Temporary commit"
git reset $(git commit-tree HEAD^{tree} -m "Tiles generated on $TILES_DATE" -m "Addresses from: $ADDRESS_DATE" -m "OpenStreetMap dump from: $OSM_DATE")
git push -f
