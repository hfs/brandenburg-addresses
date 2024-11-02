ALTER TABLE adressen_bb ALTER COLUMN geom TYPE geometry(Point, 25833);

DROP TABLE IF EXISTS osm_address;
CREATE TABLE osm_address AS (
    SELECT
        osm_id, osm_type,
        -- Standardize house number suffixes like "1 A"
        REPLACE(LOWER(housenumber), ' ', '') AS housenumber,
        street, suburb, postcode, city,
        geom,
        ST_Transform(p.geom, 25833) AS geom_25833
    FROM address_point p
    UNION ALL
    SELECT
        osm_id, osm_type,
        REPLACE(LOWER(housenumber), ' ', '') AS housenumber,
        street, suburb, postcode, city,
        ST_Centroid(p.geom) AS geom,
        ST_Transform(ST_Centroid(p.geom), 25833) AS geom_25833
    FROM address_polygon p
);

-- If one building has several addresses (duplexes, apartment buildings, big
-- buildings such as schools with several housenumbers) they are sometimes
-- mapped as "addr:housenumber=1,2,3" or "addr:housenumber=1;2;3". Split such
-- housenumber strings and add one copy of the point for each single
-- housenumber. As we're only interested which of the LGB addresses are matched,
-- the duplicates are no problem.
INSERT INTO osm_address
SELECT
    osm_id, osm_type,
    regexp_split_to_table(housenumber, E'\\s*[,;]\\s*'),
    street, suburb, postcode, city, geom, geom_25833
FROM osm_address
WHERE
    housenumber LIKE '%,%' OR
    housenumber LIKE '%;%'
;

CREATE INDEX ON osm_address USING GIST(geom);
CREATE INDEX ON osm_address USING GIST(geom_25833);

DROP TABLE IF EXISTS geoadr_matches CASCADE;
CREATE TABLE geoadr_matches AS
    SELECT
        g.id,
        g.geom,
        g.oid,
        g.stnnr,
        g.house_number,
        g.gmd,
        g.ott,
        g.str,
        g.postplz,
        g.aud,
        o.osm_id IS NOT NULL AS has_match,
        g.str LIKE '%KG%' OR g.str LIKE '%Kleingarten%' AS "ignore",
        ST_Distance(o.geom_25833, g.geom) AS distance,
        h3_lat_lng_to_cell(point(ST_Transform(g.geom, 4326)), 10) AS h3_10
    FROM (
        SELECT
            id,
            geom,
            oid_ AS oid,
            landschl || regbezschl || kreisschl || gmdschl || ottschl || strschl AS stnnr,
            CASE
                WHEN adz IS NULL OR adz = '' THEN CAST(hnr AS text)
                WHEN adz ~ '^[0-9]' THEN CAST(hnr AS text) || '/' || adz
                ELSE CAST (hnr AS text) || regexp_replace(adz, '[pP][0-9]+', '/\&')
            END AS house_number,
            gmd,
            ott,
            str,
            postplz,
            aud
        FROM adressen_bb
    ) g LEFT JOIN osm_address o
    ON
        REPLACE(TRIM(BOTH FROM g.str), ' - ', '-') = REPLACE(o.street, ' - ', '-') AND
        REPLACE(LOWER(g.house_number), ' ', '') = o.housenumber AND
        ST_Distance(o.geom_25833, g.geom) < 200
;
-- Delete duplicate matches if addresses exist several times in OSM.
-- This is legitimate: An address can e.g. be tagged on a building and on a POI
-- inside the building.
DELETE FROM geoadr_matches
WHERE id IN (
    SELECT id
    FROM  (
        SELECT
            id,
            ROW_NUMBER() OVER(PARTITION BY id ORDER BY distance, id ASC) AS row_num
        FROM geoadr_matches
    ) find_duplicates
    WHERE find_duplicates.row_num > 1
)
;
ALTER TABLE geoadr_matches ADD PRIMARY KEY(id);
CREATE INDEX ON geoadr_matches USING GIST(geom);

CREATE VIEW geoadr_top_matches AS
SELECT
    h3_10,
    (h3_cell_to_lat_lng(h3_10))[1] AS lng,
    (h3_cell_to_lat_lng(h3_10))[0] AS lat,
    COUNT(has_match) FILTER (WHERE NOT has_match AND NOT "ignore") AS "missing",
    mode() WITHIN GROUP (ORDER BY gmd) AS gmd,
    mode() WITHIN GROUP (ORDER BY str) AS str
FROM geoadr_matches m
GROUP BY h3_10
ORDER BY "missing" DESC
;

DROP TABLE IF EXISTS geoadr_aggregation;
CREATE TABLE geoadr_aggregation AS
    SELECT
        h3_10 AS h3_id,
        10 AS resolution,
        CAST (COUNT(has_match) FILTER (WHERE has_match AND distance <= 75) AS integer) AS match,
        CAST (COUNT(has_match) FILTER (WHERE (NOT has_match OR distance > 75) AND NOT "ignore") AS integer) AS missing,
        ST_ForcePolygonCW(ST_GeomFromEWKB(h3_cell_to_boundary_wkb(h3_10))) AS geom
    FROM
        geoadr_matches g
    GROUP BY
        g.h3_10
;

CREATE OR REPLACE FUNCTION geoadr_aggregate(res int)
  RETURNS TABLE (h3_id h3index, resolution int, "match" int, missing int, geom geometry) AS
$func$
    SELECT
        h3_cell_to_parent(h3_id, res) AS h3_id,
        res AS resolution,
        SUM(match) AS "match",
        SUM(missing) AS missing,
        ST_ForcePolygonCW(ST_GeomFromEWKB(h3_cell_to_boundary_wkb(h3_cell_to_parent(h3_id, res)))) AS geom
    FROM geoadr_aggregation
    WHERE resolution = 10
    GROUP BY
        h3_cell_to_parent(h3_id, res)
$func$ LANGUAGE sql;
;
INSERT INTO geoadr_aggregation
SELECT * FROM geoadr_aggregate(9)
UNION ALL
SELECT * FROM geoadr_aggregate(8)
UNION ALL
SELECT * FROM geoadr_aggregate(7)
UNION ALL
SELECT * FROM geoadr_aggregate(6)
UNION ALL
SELECT * FROM geoadr_aggregate(5)
;
ALTER TABLE geoadr_aggregation ALTER COLUMN geom TYPE geometry(Polygon, 4326);
CREATE INDEX ON geoadr_aggregation(resolution);
CREATE INDEX ON geoadr_aggregation USING GIST(geom);

-- Take an integer array and return an array of the same size where the values
-- are distinct and strictly increasing. Examples:
-- ARRAY[1, 1, 2, 4, 6] -> ARRAY[1, 2, 3, 4, 6]
-- ARRAY[3, 1, 5, 4, 8] -> ARRAY[3, 4, 5, 6, 8]
CREATE OR REPLACE FUNCTION make_distinct_increasing(input_array integer[])
RETURNS integer[] AS $$
DECLARE
    result integer[];
    current_value integer;
    current_min integer := -2147483648;  -- Minimum possible integer value in PostgreSQL
    i integer;
BEGIN
    -- Initialize result array with same size as input
    result := array_fill(NULL::integer, ARRAY[array_length(input_array, 1)]);
    -- Iterate through the input array
    FOR i IN 1..array_length(input_array, 1) LOOP
        current_value := input_array[i];
        -- If current value is less than or equal to current_min
        -- set it to current_min + 1
        IF current_value <= current_min THEN
            current_value := current_min + 1;
        END IF;
        -- Update current_min and add value to result
        current_min := current_value;
        result[i] := current_value;
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Calculate color breaks per resolution using k-means. The idea is similar to
-- Jenks Natural Breaks. Going with k-means because an extension is readily
-- available for PostgreSQL
DROP TABLE IF EXISTS breakpoints;
CREATE TABLE breakpoints AS
SELECT
    "cluster" + 1 AS "cluster",
    resolution,
    MIN(value) AS bound_lower,
    MAX(value) AS bound_upper
FROM
    generate_series(5, 10) AS res
    CROSS JOIN LATERAL
    -- Calculate the class bounds separately for each resolution
    -- 0 is a special case and excluded in this part. Extra entries are added below with a UNION
    (
        SELECT
            -- The kmeans function adds a cluster ID to every row
            kmeans(
                ARRAY[missing], -- which attributes to use for the clustering
                8, -- Number of desired classes. One more hardcoded class for missing==0 is added below
                -- Evenly spaced percentiles 0/7, 1/7, ...
                (
                    SELECT
                        make_distinct_increasing(
                            percentile_disc(
                                ARRAY(SELECT generate_series(0.0, 1.0, 1.0/7))
                            ) WITHIN GROUP (ORDER BY missing)
                        )
                    FROM geoadr_aggregation
                    WHERE resolution = res AND missing > 0
                )
            ) OVER () AS "cluster",
            resolution,
            missing AS value
        FROM geoadr_aggregation WHERE resolution = res AND missing > 0
    ) cluster_per_resolution
GROUP BY resolution, "cluster"
UNION ALL
SELECT
    0 AS "cluster",
    resolution,
    0 AS bound_lower,
    0 AS bound_upper
FROM
    generate_series(5, 10) AS resolution
ORDER BY
    resolution,
    "cluster"
;

-- Function to export the overview polygons for a certain resolution
CREATE OR REPLACE
FUNCTION public.aggregation_for_resolution(z integer)
RETURNS TABLE(geom geometry, "match" int, missing int, "cluster" int)
AS $func$
    SELECT
        g.geom,
        g."match",
        g.missing,
        b."cluster"
    FROM
        geoadr_aggregation g,
        breakpoints b
    WHERE
        CASE
          WHEN z <= 6 THEN 5
          WHEN z >= 11 THEN 10
          ELSE z - 1
        END = g.resolution AND
        g.resolution = b.resolution AND
        g.missing >= b.bound_lower AND
        g.missing <= b.bound_upper
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;

-- Function to serve geoadr_aggregate as MVTs based on the requested zoom z.
-- The tile contains one "cluster" for each color interval.
CREATE OR REPLACE
FUNCTION public.geoadr_overview(z integer, x integer, y integer)
RETURNS bytea
AS $func$
    WITH
    args AS (
      SELECT
        ST_TileEnvelope(z, x, y) AS bounds,
          CASE
            WHEN z <= 6 THEN 5
            WHEN z >= 11 THEN 10
            ELSE z - 1
          END AS resolution
    )
    SELECT ST_AsMVT(mvtgeom) AS mvt
    FROM (
        SELECT
            ST_AsMVTGeom(ST_Transform(g.geom, 3857), args.bounds) AS geom,
            g."match",
            g.missing,
            b."cluster"
        FROM
            geoadr_aggregation g,
            args,
            breakpoints b
        WHERE
            ST_Intersects(g.geom, ST_Transform(args.bounds, 4326)) AND
            args.resolution = g.resolution AND
            args.resolution = b.resolution AND
            g.missing >= b.bound_lower AND
            g.missing <= b.bound_upper
    ) mvtgeom
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;

COMMENT ON FUNCTION geoadr_overview  IS 'Number of matched and missing house number coordinates, aggregated on a hexagonal grid';

CREATE OR REPLACE VIEW geoadr_point AS
SELECT
    ST_Transform(geom, 4326) AS geom,
    CASE
        WHEN has_match AND distance <= 75 THEN 0
        WHEN has_match AND distance > 75 THEN 1
        WHEN NOT has_match AND NOT "ignore" THEN 2
        ELSE 3
    END AS category
FROM
    geoadr_matches
;

-- Simplified version of table for MVT tiles at lower zoom levels containing
-- only the point geometry but no details
CREATE OR REPLACE
FUNCTION public.geoadr_point(z integer, x integer, y integer)
RETURNS bytea
AS $func$
    WITH
    args AS (
      SELECT
        ST_TileEnvelope(z, x, y) AS bounds
    )
    SELECT ST_AsMVT(mvtgeom) AS mvt
    FROM (
        SELECT
            ST_AsMVTGeom(ST_Transform(m.geom, 3857), args.bounds) AS geom,
            CASE
                WHEN has_match AND distance <= 75 THEN 0
                WHEN has_match AND distance > 75 THEN 1
                WHEN NOT has_match AND NOT "ignore" THEN 2
                ELSE 3
            END AS category
        FROM
            geoadr_matches m,
            args
        WHERE
            ST_Intersects(m.geom, ST_Transform(args.bounds, 25833))
    ) mvtgeom
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;

CREATE OR REPLACE VIEW geoadr_detail AS
SELECT
    id,
    house_number AS hnradz,
    COALESCE(str, '') ||
        CASE WHEN (house_number <> '') IS TRUE THEN ' ' || house_number ELSE '' END ||
        CASE WHEN
            (str <> '') IS TRUE OR (house_number <> '') IS TRUE
            THEN ', ' ELSE '' END ||
        CASE WHEN (postplz <> '') IS TRUE THEN postplz || ' ' ELSE '' END ||
        CASE WHEN (ott <>  '') IS TRUE AND ott <> gmd THEN ott || ', ' ELSE '' END ||
        COALESCE(gmd, '')
    AS address,
    CASE
        WHEN has_match AND distance <= 75 THEN 0
        WHEN has_match AND distance > 75 THEN 1
        WHEN NOT has_match AND NOT "ignore" THEN 2
        ELSE 3
    END AS category,
    ST_Transform(geom, 4326) AS geom
FROM
    geoadr_matches m
;

CREATE OR REPLACE VIEW missing_with_osm_tags AS
SELECT
    house_number as "addr:housenumber",
    str AS "addr:street",
    postplz AS "addr:postcode",
    ott AS "addr:suburb",
    gmd AS "addr:city",
    'DE' AS "addr:country",
    ST_Transform(geom, 4326) AS geom
FROM
    geoadr_matches m
WHERE
    (
        NOT has_match OR
        distance > 75
    ) AND
    NOT "ignore"
;

CREATE OR REPLACE
FUNCTION public.geoadr_detail(z integer, x integer, y integer)
RETURNS bytea
AS $func$
    WITH
    args AS (
      SELECT
        ST_TileEnvelope(z, x, y) AS bounds
    )
    SELECT ST_AsMVT(mvtgeom) AS mvt
    FROM (
        SELECT
            id,
            house_number AS hnradz,
            COALESCE(str, '') ||
                CASE WHEN (house_number <> '') IS TRUE THEN ' ' || house_number ELSE '' END ||
                CASE WHEN
                    (str <> '') IS TRUE OR (house_number <> '') IS TRUE
                    THEN ', ' ELSE '' END ||
                CASE WHEN (postplz <> '') IS TRUE THEN postplz || ' ' ELSE '' END ||
                CASE WHEN (ott <>  '') IS TRUE AND ott <> gmd THEN ott || ', ' ELSE '' END ||
                COALESCE(gmd, '')
            AS address,
            ST_AsMVTGeom(ST_Transform(m.geom, 3857), args.bounds) AS geom,
            CASE
                WHEN has_match AND distance <= 75 THEN 0
                WHEN has_match AND distance > 75 THEN 1
                WHEN NOT has_match AND NOT "ignore" THEN 2
                ELSE 3
            END AS category
        FROM
            geoadr_matches m,
            args
        WHERE
            ST_Intersects(m.geom, ST_Transform(args.bounds, 25833))
    ) mvtgeom
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;

DROP TABLE IF EXISTS geoadr_missing_cluster CASCADE;
CREATE TABLE geoadr_missing_cluster AS
WITH missing_points AS (
    SELECT *
    FROM geoadr_matches
    WHERE
        (NOT has_match OR
        distance > 75) AND
        NOT "ignore"
)
SELECT
    id,
    kmeans(
        -- Columns to use for the distance function
        ARRAY[ST_X(geom), ST_Y(geom)],
        -- Number of classes. Every class should have roughly 10 points
        (SELECT COUNT(*)::int / 10 AS cnt FROM missing_points),
        -- Start centroids for the clusters.
        -- By picking every 10th point after sorting by street ID and house
        -- number the points are evenly spaced out over the whole area, with
        -- higher density where more points are missing
        (
            SELECT
                array_agg(xy)
            FROM
                (
                    SELECT
                        ROW_NUMBER() OVER(ORDER BY stnnr, house_number) AS rnk,
                        ARRAY[ST_X(geom), ST_Y(geom)] AS xy
                    FROM
                        missing_points
                ) fixed_order
            WHERE rnk % 10 = 0
        )
    ) OVER () AS "cluster"
FROM
    missing_points m
;
ALTER TABLE geoadr_missing_cluster ADD PRIMARY KEY(id);

CREATE OR REPLACE VIEW geoadr_missing AS
SELECT m.*, c."cluster"
FROM geoadr_matches m, geoadr_missing_cluster c
WHERE m.id = c.id
;

DROP TABLE IF EXISTS task_area;
CREATE TABLE task_area AS
SELECT "cluster" AS id, ST_ConvexHull(ST_Collect(geom)) AS geom, COUNT("cluster")
FROM geoadr_missing
GROUP BY "cluster"
;
-- If a cluster contains only one or two points, the convex hull is only a
-- point or linestring. Buffering converts them into polygons.
UPDATE task_area
SET geom = ST_Buffer(geom, 100)
WHERE ST_GeometryType(geom) != 'ST_Polygon'
;
ALTER TABLE task_area ADD PRIMARY KEY ("id");
CREATE INDEX ON task_area USING GIST(geom);
