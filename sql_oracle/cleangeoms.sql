update 
    tax_lot_polygon_dtm a
set
    a.shape = sdo_util.rectify_geometry(a.shape, .0005)
where
    sdo_geom.validate_geometry_with_context(a.shape,.0005) <> 'TRUE'
