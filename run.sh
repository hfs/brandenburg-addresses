#!/bin/bash -e
set -o pipefail

basedir=$(dirname "$BASH_SOURCE[0]")
cd "$basedir"

source env.sh
./01_download.sh
./02_createdb.sh
./03_import_addresses.sh
./04_import_osm.sh
./05_analyze.sh
./06_export_mvt.sh
