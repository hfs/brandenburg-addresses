# Georeferenced Addresses in Brandenburg (Germany) as background layer for the OpenStreetMap editor JOSM

The basic geo data of the state of Brandenburg (in Germany) are available as
Open Data. This includes the
[Georeferenced Addresses (house number coordinates)](https://geobasis-bb.de/lgb/de/geodaten/liegenschaftskataster/georeferenzierte-adresse/).
Since April 2020 it is possible to use this data in
[OpenStreetMap](https://www.openstreetmap.org/).

This project compares the official addresses to those found in OpenStreetMap.
It provides the addresses as background layer that can be used while editing
OpenStreetMap’s map data and highlights the addresses that might be missing.

See

## → https://hfs.github.io/brandenburg-addresses/

for background and usage information and a preview of the data.


## Data processing steps

### [01_download.sh](01_download.sh)

The official address data cannot be downloaded automatically. Please go to
https://geobroker.geobasis-bb.de/ and download the data set “Georeferenzierte
Adresse” in GeoPackage format. Don’t be discourage by the “order” process. The
data is free and Open Data. Extract the download and provide the data as file
`data/geoadr.gpkg`.

Run `./01_download.sh`. This will download the latest OpenStreetMap dump for
Brandenburg.


### [02_createdb.sh](02_createdb.sh)

The data is merged in a PostGIS database. This script creates a new working
database.


### [03_import_addresses.sh](03_import_addresses.sh)

Import the official addresses into the database using `ogr2ogr`.


### [04_import_osm.sh](04_import_osm.sh)

Import the OpenStreetMap addresses into the same database using `osmium` and
`osm2pgsql`.


### [05_analyze.sh](05_analyze.sh)

Match the addresses from the different data sets by executing
[analyze_addresses.sql](analyze_addresses.sql).

Addresses are matched by comparing only street and house number (and not city
or postal code). House numbers with suffixes such as `1 A`, `1 B` are
standardized by removing whitespace and turning them to lower case.

As result the official addresses are annotated whether or not they could be
matched in OSM.

The script also computes aggregations for lower zoom levels. The address points
are mapped onto a hexagonal grid using the
[H3 indexing system](https://h3geo.org/). It counts for each hexagon how many
unmatched addresses there are.

Usually one could color the hexagons by value later when they are visualized
using [MapLibre JS](https://maplibre.org/). But JOSM doesn’t support this
syntax, so the classes for the colors have to be precomputed instead. The style
then uses a fixed mapping from class ID to color.

Finally the script also provides the functions that are used to export the data
in tiles in
[Mapbox Vector Tiles (MVT) format](https://docs.mapbox.com/data/tilesets/guides/vector-tiles-introduction/).


### [06_export_mvt.sh](06_export_mvt.sh)

Export the data in MVT format. This uses
[pg_tileserv](https://github.com/CrunchyData/pg_tileserv). It calls the MVT
export functions defined in `analyze_addresses.sql` and writes them to files.


### [07_upload.sh](07_upload.sh)

Script to upload the website Markdown files and the exported MVT tiles to
branch
[gh_pages](https://github.com/hfs/brandenburg-addresses/tree/gh_pages).
A GitHub action renders the website into static HTML using Jekyll. Finally
everything is served as static files from
https://hfs.github.io/brandenburg-addresses/.


## Running the pipeline yourself

### Running via `podman`

The easiest way to get all required dependencies and run the pipeline is to use
[podman](https://podman.io/). It should be readily available as package on
recent Linux distributions. If you have `podman` installed you can run

```bash
podman play kube kube.yaml
```

This will first build the two images defined in
[brandenburg_addresses/](brandenburg_addresses/) and
[brandenburg_addresses_postgres/](brandenburg_addresses_postgres/) which
contain all the required dependencies.

It starts the two as containers and runs [run.sh](run.sh), which just calls the
scripts 01 to 06 (except the final upload).

The generated output data can be found in `tiles/`.


### Running locally

You need to install these dependencies:

* curl, wget, pv
* osm2pgsql, osmium-tool
* PostgreSQL server and client, PostGIS
* pg_tileserv
* ogr2ogr (package gdal-bin)

Also you need PostgreSQL extensions [H3](https://pgxn.org/dist/h3/) and
[kmeans](https://pgxn.org/dist/kmeans/) which probably aren’t available as
packages. You can install the PostgreSQL extension manager `pgxnclient` and
then run

```bash
pgxn install h3
pgxn install kmeans
```

to install them.

You need a PostgreSQL superuser – typically it’s called `postgres`. Set a
password for it. Edit `env.sh` and insert the password there.

Then you can run the processing pipeline using

```bash
./run.sh
```


## Editing the map style

[style.json](style.json) contains the Mapbox GL JS style which defines the look
of the map data in JOSM. [mapbox-gl-style.json](mapbox-gl-style.json) is a
variant of the same style, and the only difference is the `attribution` which
uses HTML links to point to the source data.

If you want to edit the style you can load it in the
[Maputnik Style Editor](https://maputnik.github.io/editor/?style=https://hfs.github.io/brandenburg-addresses/style.json#7.39/52.454/13.436).

JOSM supports only a subset of the Mapbox Style specification. You can test the
results locally by adding MVT imagery source in JOSM which uses a `file://` URL
to point to your local modified copy of the style.
