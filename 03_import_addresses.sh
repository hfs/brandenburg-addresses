#!/bin/bash -e
set -o pipefail
source env.sh

ogr2ogr -f "PGDUMP" -lco GEOMETRY_NAME=geom --config PG_USE_COPY YES /vsistdout  data/adressen-bb.gpkg | psql
