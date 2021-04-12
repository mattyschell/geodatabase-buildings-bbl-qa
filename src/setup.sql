
-- Use ArcCatalog to import tax_lot_polygon to building schema
-- shape as sdo_geometry
begin 
    execute immediate 'create index tax_lot_polygon_idx1 on tax_lot_polygon(bbl)';
exception
when others then
    if sqlcode = -955 then
        null; 
    else
         raise;
    end if;
end;
/
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


