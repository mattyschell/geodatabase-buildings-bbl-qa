
-- import.py uses arcpy to import the live property information portal 
-- tax lots to the building schema as tax_lot_polygon_dtm (shape is sdo_geometry) 
-- our next work table, tax_lot_polygon, is unshackled from the esri enterprise geodatabase
begin
    execute immediate 'drop table tax_lot_polygon';
exception
when others 
then 
    null;
end;
/
delete from 
    user_sdo_geom_metadata 
where 
    table_name = 'TAX_LOT_POLYGON'
and column_name = 'SHAPE';
create table 
    tax_lot_polygon
as select 
     a.objectid as objectid
    ,a.bbl as bbl
    ,a.shape as shape
from tax_lot_polygon_dtm a;
alter table 
    tax_lot_polygon 
add constraint 
    tax_lot_polygon_pk 
primary key (objectid);
insert into 
user_sdo_geom_metadata
    (table_name, column_name, srid, diminfo)
values
    ('TAX_LOT_POLYGON','SHAPE',2263,
        SDO_DIM_ARRAY (MDSYS.SDO_DIM_ELEMENT ('X', 900000, 1090000, .0005)
                      ,MDSYS.SDO_DIM_ELEMENT ('Y', 110000, 295000, .0005)
 ));
create index 
    tax_lot_polygon_sidx 
on 
    tax_lot_polygon(shape) 
indextype is mdsys.spatial_index;
create index 
    tax_lot_polygon_bbl 
on 
    tax_lot_polygon(bbl);
-- drop work tables
begin
    execute immediate 'drop table bbl_qa_ack';
exception 
when others 
then 
    null;
end;
/
begin
    execute immediate 'drop table bbl_qa';
exception 
when others 
then 
    null;
end;
/
-- create work tables
create table bbl_qa (
    doitt_id    number
   ,base_bbl    number
   ,constraint bbl_qa_pkc primary key(doitt_id)
); 
create table bbl_qa_ack (
    doitt_id    number
   ,constraint bbl_qa_ack_pkc primary key(doitt_id)
); 


