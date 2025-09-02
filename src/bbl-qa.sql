-- part 1 - buildings who do not touch the indicated bbl of the building
-- part 2 - buildings with a bbl that does not exist at all
--          (exclude skybridge and building under construction)
insert into bbl_qa 
   (doitt_id
   ,base_bbl)
select /*+ ALL_ROWS */
    a.doitt_id
   ,a.base_bbl 
from
    building_evw a
join
    tax_lot_polygon b
on 
    a.base_bbl = b.bbl
where 
    sdo_geom.relate(a.shape,'anyinteract',b.shape,.0005) <> 'TRUE'
and REGEXP_LIKE(a.base_bbl, '^\d+$')
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
            bbl_qa_ack)
union
select 
    a.doitt_id
   ,a.base_bbl 
from 
    building_evw a
where 
    REGEXP_LIKE(a.base_bbl, '^\d+$')
and a.base_bbl in (
        select 
            base_bbl 
        from 
            building_evw
        where 
            feature_code in (1000,1002,1003,1004,1005,1006,2100,5110)
        and 
            base_bbl not like '%9999'
        minus
        select 
            bbl 
        from 
            tax_lot_polygon
    )
and a.doitt_id not in (
        select 
            doitt_id 
        from 
            bbl_qa_ack);
commit;
-- for buildings outside of the borough we do not expect tax lots
delete from 
    bbl_qa   
where 
    doitt_id in (select 
                    a.doitt_id
                from
                    building_evw a
                join
                    bbl_qa b
                on 
                    a.doitt_id = b.doitt_id
                where
                    sdo_geom.relate(a.shape,'anyinteract',(select shape from boroughagg),.0005) <> 'TRUE'
                );
commit;
-- for buildings on the borough line we also have no expectations
-- this pays no mind to whether these buildings on the city line happen to touch
-- some other tax lot.  I reviewed the list and as of coding all buildings on 
-- the city line do not touch any tax lots. I see no reason to overcomplicate 
-- for nonexistent edge cases
delete from 
    bbl_qa   
where 
    doitt_id in (select 
                    a.doitt_id
                from
                    building_evw a
                join
                    bbl_qa b
                on 
                    a.doitt_id = b.doitt_id
                where
                    sdo_geom.relate(a.shape,'mask=OVERLAPBDYINTERSECT',(select shape from boroughagg),.0005) <> 'FALSE'
                );       
commit;