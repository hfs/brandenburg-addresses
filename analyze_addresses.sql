ALTER TABLE geoadr ALTER COLUMN geom TYPE geometry(Point, 32633);

DROP TABLE IF EXISTS osm_address;
CREATE TABLE osm_address AS (
    SELECT
        osm_id, osm_type,
        -- Standardize house number suffixes like "1 A"
        REPLACE(LOWER(housenumber), ' ', '') AS housenumber,
        street, suburb, postcode, city,
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
        h3_geo_to_h3(ST_Transform(g.geom, 4326), 10) AS h3_10
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
        h3_to_geo_boundary_geometry(h3_10) AS geom
    FROM
        geoadr_matches g
    GROUP BY
        g.h3_10
;

CREATE OR REPLACE FUNCTION geoadr_aggregate(res int)
  RETURNS TABLE (h3_id h3index, resolution int, "match" int, missing int, geom geometry) AS
$func$
    SELECT
        h3_to_parent(h3_id, res) AS h3_id,
        res AS resolution,
        SUM(match) AS "match",
        SUM(missing) AS missing,
        h3_to_geo_boundary_geometry(h3_to_parent(h3_id, res)) AS geom
    FROM geoadr_aggregation
    WHERE resolution = 10
    GROUP BY
        h3_to_parent(h3_id, res)
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


-- Function to serve geoadr_aggregate as MVTs based on the requested zoom z
CREATE OR REPLACE
FUNCTION public.geoadr_overview(z integer, x integer, y integer)
RETURNS bytea
AS $func$
    WITH
    bounds AS (
      SELECT ST_TileEnvelope(z, x, y) AS geom
    ),
    mvtgeom AS (
      SELECT ST_AsMVTGeom(ST_Transform(g.geom, 3857), bounds.geom) AS geom,
      g."match",
      g.missing
      FROM geoadr_aggregation g, bounds
      WHERE
        ST_Intersects(g.geom, ST_Transform(bounds.geom, 4326))
        AND resolution = CASE
          WHEN z <= 5 THEN 5
          WHEN z >= 10 THEN 10
          ELSE z
        END
    )
    SELECT ST_AsMVT(mvtgeom, 'geoadr_overview') FROM mvtgeom;
$func$
LANGUAGE 'sql'
STABLE
PARALLEL SAFE
;

COMMENT ON FUNCTION geoadr_overview  IS 'Number of matched and missing house number coordinates, aggregated on a hexagonal grid';

-- Simplified version of table for MVT tiles at lower zoom levels
CREATE OR REPLACE VIEW geoadr_matches_point AS
SELECT has_match, distance, geom FROM geoadr_matches;
