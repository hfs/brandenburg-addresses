local srid = 4326
local tables = {}

function get_columns(geom_type)
    return {
        { column = 'osm_type',    type = 'text',    not_null = true },
        { column = 'housenumber', type = 'text' },
        { column = 'street',      type = 'text' },
        { column = 'suburb',      type = 'text' },
        { column = 'postcode',    type = 'text' },
        { column = 'city',        type = 'text' },
        { column = 'geom',        type = geom_type, projection = srid },
    }
end

tables.address_point = osm2pgsql.define_table({
    name = 'address_point',
    ids = { type = 'node', id_column = 'osm_id' },
    columns = get_columns('point')
})

tables.address_line = osm2pgsql.define_table({
    name = 'address_line',
    ids = { type = 'way', id_column = 'osm_id' },
    columns = get_columns('linestring')
})

tables.address_polygon = osm2pgsql.define_table({
    name = 'address_polygon',
    ids = { type = 'area', id_column = 'osm_id' },
    columns = get_columns('multipolygon')
})

function osm2pgsql.process_node(object)
    local housenumber = object.tags['addr:housenumber']
    -- See https://wiki.openstreetmap.org/wiki/Key:addr:place for addresses
    -- that are not bound to a street, but some other locality.
    local street      = object.tags['addr:street'] or object.tags['addr:place']
    local suburb      = object.tags['addr:suburb']
    local postcode    = object.tags['addr:postcode']
    local city        = object.tags['addr:city']

    if housenumber or street or suburb or postcode or city then
        tables.address_point:insert({
            osm_type = 'node',
            housenumber = housenumber,
            street = street,
            suburb = suburb,
            postcode = postcode,
            city = city,
            geom = object:as_point()
        })
    end
end

function osm2pgsql.process_way(object)
    local housenumber = object.tags['addr:housenumber']
    local street      = object.tags['addr:street'] or object.tags['addr:place']
    local suburb      = object.tags['addr:suburb']
    local postcode    = object.tags['addr:postcode']
    local city        = object.tags['addr:city']

    if housenumber or street or suburb or postcode or city then
        if object.is_closed then
            tables.address_polygon:insert({
                osm_type = 'way',
                housenumber = housenumber,
                street = street,
                suburb = suburb,
                postcode = postcode,
                city = city,
                geom = object:as_polygon()
            })
        else
            tables.address_line:insert({
                osm_type = 'way',
                housenumber = housenumber,
                street = street,
                suburb = suburb,
                postcode = postcode,
                city = city,
                geom = object:as_linestring()
            })
        end
    end
end

function osm2pgsql.process_relation(object)
    local housenumber = object.tags['addr:housenumber']
    local street      = object.tags['addr:street'] or object.tags['addr:place']
    local suburb      = object.tags['addr:suburb']
    local postcode    = object.tags['addr:postcode']
    local city        = object.tags['addr:city']

    if housenumber or street or suburb or postcode or city then
        tables.address_polygon:insert({
            osm_type = 'relation',
            housenumber = housenumber,
            street = street,
            suburb = suburb,
            postcode = postcode,
            city = city,
            geom = object:as_multipolygon()
        })
    end
end
