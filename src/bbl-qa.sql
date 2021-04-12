insert into bbl_qa 
   (doitt_id
   ,base_bbl)
select 
    a.doitt_id
   ,a.base_bbl 
from
    building_evw a
join
    tax_lot_polygon b
on 
    a.base_bbl = b.bbl
where 
    sdo_geom.relate(a.shape, 'anyinteract', b.shape, .0005) <> 'TRUE'
and b.bbl not in (
        select 
            bbl
        from tax_lot_polygon
        group by 
            bbl
        having count(bbl) > 1)
and a.doitt_id not in (
        select 
            doitt_id 
        from 
            bbl_qa_ack);
commit;