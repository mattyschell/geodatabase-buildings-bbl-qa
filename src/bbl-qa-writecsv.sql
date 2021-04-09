SET HEADING OFF
SET FEEDBACK OFF
SET ECHO OFF
SET TERMOUT OFF
SET PAGESIZE 0
SPOOL bbl-qa.csv
select 'DOITT_ID' from dual;
select doitt_id from bbl_qa order by doitt_id;
SPOOL OFF
