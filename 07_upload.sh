#!/bin/bash -e

set -o pipefail

source env.sh

export ADDRESS_DATE=$(sqlite3 data/geoadr.gpkg 'SELECT MAX("AUD") FROM geoadr')
export OSM_DATE=$(date -d @$(stat --format %Y data/$REGION-latest.osm.pbf) +%Y-%m-%dT%H:%M:%S%z)
export CHANGE_DATE=$(cat data/timestamp.txt)
export TILES_DATE=$(date -d @$(stat --format %Y tiles/) +%Y-%m-%dT%H:%M:%S%z)

[ -d ../brandenburg_addresses_site/ ]
echo ">>> Clear website staging directory"
rm -rf ../brandenburg_addresses_site/*
echo ">>> Copy generated tiles and website into site directory"
cp -a --reflink=auto tiles/ site/* .github/ style.json mapbox-gl-style.json ../brandenburg_addresses_site/
echo ">>> Variable substitution"
cat site/de/timestamp.md | envsubst > ../brandenburg_addresses_site/de/timestamp.md
cat site/en/timestamp.md | envsubst > ../brandenburg_addresses_site/en/timestamp.md
cd ../brandenburg_addresses_site/
echo ">>> git commit"
git add -u .
git add .
git commit -m "Temporary commit"
git reset $(git commit-tree HEAD^{tree} -m "Tiles generated on $TILES_DATE" -m "Addresses from: $ADDRESS_DATE" -m "OpenStreetMap dump from: $OSM_DATE")
echo ">>> Push to GitHub"
git push -f
