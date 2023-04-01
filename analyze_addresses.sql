ALTER TABLE geoadr ALTER COLUMN geom TYPE geometry(Point, 32633);

DROP TABLE IF EXISTS osm_address;
CREATE TABLE osm_address AS (
    SELECT
        osm_id, osm_type,
        -- Standardize house number suffixes like "1 A"
        REPLACE(LOWER(housenumber), ' ', '') AS housenumber,
        street, suburb, postcode, city,
        geom,
        ST_Transform(p.geom, 32633) AS geom_32633
    FROM address_point p
    UNION ALL
    SELECT
        osm_id, osm_type,
        REPLACE(LOWER(housenumber), ' ', '') AS housenumber,
        street, suburb, postcode, city,
        ST_Centroid(p.geom) AS geom,
        ST_Transform(ST_Centroid(p.geom), 32633) AS geom_32633
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
    street, suburb, postcode, city, geom, geom_32633
FROM osm_address
WHERE
    housenumber LIKE '%,%' OR
    housenumber LIKE '%;%'
;

CREATE INDEX ON osm_address USING GIST(geom);
CREATE INDEX ON osm_address USING GIST(geom_32633);

DROP TABLE IF EXISTS geoadr_matches;
CREATE TABLE geoadr_matches AS
    SELECT
        g.id,
        g.geom,
        g.oi,
        g.stnnr,
        g.hnr,
        g.adz,
        g.hnradz,
        g.gmdname,
        g.ottname,
        g.stn,
        g.plz,
        g.aud,    
        o.osm_id IS NOT NULL AS has_match,
        ST_Distance(o.geom_32633, g.geom) AS distance,
        h3_lat_lng_to_cell(point(ST_Transform(g.geom, 4326)), 10) AS h3_10
    FROM geoadr g LEFT JOIN osm_address o
    ON
        g.stn = o.street AND 
        REPLACE(LOWER(g.hnradz), ' ', '') = o.housenumber AND 
        ST_Distance(o.geom_32633, g.geom) < 200
;
CREATE INDEX ON geoadr_matches USING GIST(geom);

DROP TABLE IF EXISTS geoadr_aggregation;
CREATE TABLE geoadr_aggregation AS
    SELECT
        h3_10 AS h3_id,
        10 AS resolution,
        COUNT(has_match) FILTER (WHERE has_match) AS match,
        COUNT(has_match) FILTER (WHERE NOT has_match) AS missing,
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
                CASE
                    WHEN res >= 7 THEN
                        -- Using the percentiles doesn't work well for higher resolutions, because it has too many "1".
                        -- k-means then delivers too few classes.
                        -- Just use the linearly spaced values in this case.
                        ARRAY(SELECT generate_series(
                            (SELECT MIN(missing) FROM geoadr_aggregation WHERE resolution = res AND missing > 0),
                            (SELECT MAX(missing) FROM geoadr_aggregation WHERE resolution = res AND missing > 0),
                            (SELECT (MAX(missing) - MIN(missing)) / 7 AS step FROM geoadr_aggregation WHERE resolution = res AND missing > 0)
                        ))
                    ELSE
                        -- Evenly spaced percentiles 0/7, 1/7, ...
                        (
                            SELECT
                                percentile_disc(ARRAY(SELECT generate_series(0.0, 1.0, 1.0/7)))
                                WITHIN GROUP (ORDER BY missing)
                            FROM geoadr_aggregation
                            WHERE resolution = res AND missing > 0
                        )
                    END
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
                WHEN NOT has_match THEN 2
            END AS category
        FROM
            geoadr_matches m,
            args
        WHERE
            ST_Intersects(m.geom, ST_Transform(args.bounds, 32633))
    ) mvtgeom
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
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
            hnradz,
            stn || ' ' || hnradz || ', ' || plz || ' ' || ottname || ', ' || gmdname AS address,
            ST_AsMVTGeom(ST_Transform(m.geom, 3857), args.bounds) AS geom,
            CASE
                WHEN has_match AND distance <= 75 THEN 0
                WHEN has_match AND distance > 75 THEN 1
                WHEN NOT has_match THEN 2
            END AS category
        FROM
            geoadr_matches m,
            args
        WHERE
            ST_Intersects(m.geom, ST_Transform(args.bounds, 32633))
    ) mvtgeom
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;
