#!/bin/bash -e

set -o pipefail
source env.sh

echo ">>> Export tiles for zoom levels 0 to 13 (hexagon overview layers)"
rm -rf tmp_export/
mkdir tmp_export
DB_CONNECTION="PG:host=$PGHOST dbname=$PGDATABASE user=$PGUSER password=$PGPASSWORD"
echo "6 0 6
7 7 7
8 8 8
9 9 9
10 10 10
11 11 13" | while read zoom minzoom maxzoom; do
  ogr2ogr -f GeoJSON /dev/stdout "$DB_CONNECTION" -sql "SELECT * FROM aggregation_for_resolution($zoom)" -nln "geoadr $zoom" \
		| tippecanoe -Z$minzoom -z$maxzoom --output-to-directory=tmp_export/tiles_$zoom -l default --force --no-feature-limit --no-tile-size-limit --no-tile-compression
done

echo ">>> Export tiles for zoom level 14 (points)"
ogr2ogr -f GeoJSON /dev/stdout "$DB_CONNECTION"  geoadr_point \
		| tippecanoe -Z14 -z14 --output-to-directory=tmp_export/tiles_14 -l default --force --no-feature-limit --no-tile-size-limit --no-tile-compression

echo ">>> Export tiles for zoom level 15 (full data)"
ogr2ogr -f GeoJSON /dev/stdout "$DB_CONNECTION"  geoadr_detail \
		| tippecanoe -Z15 -z15 --output-to-directory=tmp_export/tiles_15 -l default --force --no-feature-limit --no-tile-size-limit --no-tile-compression

echo ">>> Merge tile sets in single directory"
rm -rf tiles/
mkdir tiles
tile-join --no-tile-compression -e tiles tmp_export/tiles_*
rm -rf tmp_export/
rm tiles/metadata.json
mmv 'tiles/*/*/*.pbf' 'tiles/#1/#2/#3.mvt'
