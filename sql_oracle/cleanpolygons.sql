update 
    tax_lot_polygon_dtm a
set 
    a.shape = cleanpolygons(a.shape)
where 
    a.shape.sdo_gtype = 2004