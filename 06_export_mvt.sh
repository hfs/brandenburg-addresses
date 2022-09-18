#!/bin/bash -e

set -o pipefail
source env.sh

pg_tileserv &> /dev/null &
pid_tileserv=$!

cleanup() {
	kill $pid_tileserv
}
# Stop pg_tileserv when the script finishes
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

	echo "Exporting table $table for zoom levels $min_zoom to $max_zoom"
	tiles=$(mktemp -t addresses.XXXXXX)
	iterate_tiles $extent_table $min_zoom $max_zoom > $tiles
	# Create all directories in advance
	cut -d / -f 1-2 $tiles | sort -u | xargs -I % mkdir -p tiles/%

	xargs -P 6 -I % --verbose \
		curl --silent "http://localhost:7800/public.$table/%.pbf" -o tiles/%.mvt \
		< $tiles 2>&1 |
		pv -l -s $(wc -l < $tiles) > /dev/null
	rm $tiles
}

# Zoom levels are mutually exclusive, because tiles from all tables are merged
# in a single directory
export_tiles geoadr_overview 0 12 geoadr_aggregation
export_tiles geoadr_point 13 13 geoadr_matches
export_tiles geoadr_matches 14 14
