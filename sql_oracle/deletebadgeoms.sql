delete from 
    tax_lot_polygon_dtm a
where 
    a.shape.sdo_gtype not in (2003,2007)
or  sdo_geom.validate_geometry_with_context(a.shape, .0005) <> 'TRUE'