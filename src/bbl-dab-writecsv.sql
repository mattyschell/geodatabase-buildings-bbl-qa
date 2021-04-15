SET HEADING OFF
SET FEEDBACK OFF
SET ECHO OFF
SET TERMOUT OFF
SET PAGESIZE 0
set LINESIZE 9999
set TRIMSPOOL ON
@src/bbl-dab-load.sql
SPOOL bbl-dab-history.csv
select 'BBL, CHANGE_DATE, WIZARD_NAME, LOT_ACTION, AUTH_FOR_CHANGE' from dual;
select b.bbl || ',' ||
       to_char(a.change_date, 'YYYY-MM-DD') || ',' ||
       a.wizard_name || ',' ||
       b.lot_action || ',' ||
       substr(replace(replace(replace(a.auth_for_change,chr(10),' '),chr(13),' '),',',' '),1,128) as auth_for_change 
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
SPOOL OFF