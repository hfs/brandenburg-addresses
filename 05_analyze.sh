#!/bin/bash -e
set -o pipefail
source env.sh
echo ">>> Analyze addresses and find matches"
psql -f analyze_addresses.sql -ab -v ON_ERROR_STOP=ON | ts '%Y-%m-%dT%H:%M:%S   '
