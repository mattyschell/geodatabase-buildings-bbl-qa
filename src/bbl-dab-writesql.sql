SET HEADING OFF
SET FEEDBACK OFF
SET ECHO OFF
SET TERMOUT OFF
SET PAGESIZE 0
SPOOL src/bbl-dab-load.sql
select dabsql from (
    select 1 as step, 'insert into bbl_dab values(' || to_char(bbl) || ');' as dabsql
    from 
       (select base_bbl as bbl 
        from 
            bbl_qa
        union
        select distinct to_number(a.bbl) 
        from 
            tax_lot_polygon a
        join
            building_evw b
        on 
            sdo_filter(a.shape, b.shape) = 'TRUE'
        where 
            b.doitt_id in (select doitt_id from bbl_qa)
       )
    union all
    select 2 as step, 'commit;' as dabsql from dual
) order by step;
SPOOL OFF