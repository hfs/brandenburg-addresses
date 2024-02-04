#!/bin/bash -e

set -o pipefail

source env.sh

export ADDRESS_DATE=$(sqlite3 data/adressen-bb.gpkg 'SELECT MAX("aud") FROM adressen_bb')
export OSM_DATE=$(date -d @$(stat --format %Y data/$REGION-latest.osm.pbf) +%Y-%m-%dT%H:%M:%S%z)
export CHANGE_DATE=$(cat data/timestamp.txt)
export TILES_DATE=$(date -d @$(stat --format %Y tiles/) +%Y-%m-%dT%H:%M:%S%z)

echo ">>> Checking if the expected number of tiles was generated"
# There were several random problems with the tile generation crashing in the
# middle. If that happens, cancel the upload and keep the data of the previous
# day.
number_of_tiles=$(find tiles/15/ -type f | wc -l)
if [[ $number_of_tiles -lt 19000 ]]; then
	echo ">>> Error: Expected more than 19,000 tiles on zoom level 15, but directory tiles/15/ contains only $number_of_tiles."
	echo ">>> Canceling the upload."
	exit 1
fi

[ -d ../brandenburg_addresses_site/ ]
echo ">>> Clear website staging directory"
rm -rf ../brandenburg_addresses_site/*
echo ">>> Copy generated tiles and website into site directory"
cp -a --reflink=auto tiles/ site/* .github/ style.json mapbox-gl-style.json data/task_area.geojson data/top.csv data/missing.pmtiles ../brandenburg_addresses_site/
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
