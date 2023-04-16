#!/bin/bash -e

set -o pipefail
source env.sh

pg_tileserv &> /dev/null &
pid_tileserv=$!

# Stop pg_tileserv when the script finishes
cleanup() {
	kill $pid_tileserv
}
trap cleanup EXIT

# Register function for export
psql -f tile_coordinates.sql

iterate_tiles() {
	local table="$1"
	local min_zoom="$2"
	local max_zoom="$3"
	psql -c "\\COPY (SELECT x, y, z FROM getTiles((SELECT ST_Extent(ST_Transform(geom, 4326)) FROM $table), $min_zoom, $max_zoom)) TO STDOUT (FORMAT CSV, HEADER FALSE, DELIMITER '/')"
}

export_tiles() {
	local table="$1"
	local min_zoom="$2"
	local max_zoom="$3"
	local extent_table="${4:-$1}"

	echo ">>> Exporting table $table for zoom levels $min_zoom to $max_zoom"
	tiles=$(mktemp -t addresses.XXXXXX)
	iterate_tiles $extent_table $min_zoom $max_zoom > $tiles
	# Create all directories in advance
	cut -d / -f 1-2 $tiles | sort -u | xargs -I % mkdir -p tiles/%

	# Workaround for kernel panic experienced every few days: Ignore curl's exit code
	xargs -P 6 -I % --verbose \
		./bliss curl --silent "http://localhost:7800/public.$table/%.pbf" -o tiles/%.mvt \
		< $tiles
	echo -n ">>> Number of tiles expected: "
	wc -l < $tiles
	echo -n ">>> Number of tiles generated: "
	find tiles -name "*.mvt" | wc -l
	rm $tiles
}

# Zoom levels are mutually exclusive, because tiles from all tables are merged
# in a single directory
echo ">>> Delete old 'tiles' directory"
rm -rf tiles
export_tiles geoadr_overview 0 13 geoadr_aggregation
export_tiles geoadr_point 14 14 geoadr_matches
export_tiles geoadr_detail 15 15 geoadr_matches

echo ">>> Export Top 10 places with missing addresses"
psql -c "\\COPY (SELECT * FROM geoadr_top_matches LIMIT 10) TO 'data/top10.csv' (FORMAT CSV)"
echo ">>> Export done"
