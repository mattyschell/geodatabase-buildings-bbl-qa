-- work in progress

-- run this in building qa schema
select dabsql from (
    select 1 as step, 'create table bbl_dab (bbl number, constraint bbl_dab_pkc primary key(bbl));' as dabsql from dual
    union all
    select 2 as step, 'insert into bbl_dab values(' || to_char(bbl) || ');' as bbl
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
    select 3 as step, 'commit;' from dual
) order by step;

-- spool it out/over to dof_readonly
-- execute it

-- scratch work in progress
select b.bbl
      ,a.change_date
      ,a.wizard_name
      ,b.lot_action
      ,replace(replace(a.auth_for_change, chr(10), ' '),chr(13), ' ') as auth_for_change
from 
    dof_taxmap.dab_wizard_transaction a
join
    dof_taxmap.dab_tax_lots b
on 
    a.trans_num = b.trans_num
where 
    b.bbl in 
        (select bbl from bbl_dab)
order by bbl, change_date;

-- spool that out to bbl-dab-history.csv

drop table bbl_dab;