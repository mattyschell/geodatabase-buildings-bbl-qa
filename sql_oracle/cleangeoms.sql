update 
    tax_lot_polygon a
set
    a.shape = sdo_util.rectify_geometry(a.shape, .0005)
where
    sdo_util.validate_geometry_with_context(a.shape,.0005) <> 'TRUE';
commit;
delete from 
    tax_lot_polygon a
where 
    a.shape.sdo_gtype not in (2003,2007)
or  sdo_geom.validate_geometry_with_context(a.shape, .0005) <> 'TRUE';
commit;