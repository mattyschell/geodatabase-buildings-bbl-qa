-- scratch work in progress
select b.bbl
      ,a.change_date
      ,a.wizard_name
      ,b.lot_action
      ,replace(replace(a.auth_for_change, chr(10), ' '),chr(13), ' ') as auth_for_change
from 
    DAB_WIZARD_TRANSACTION a
join
    DAB_TAX_LOTS b
on 
    a.trans_num = b.trans_num
where 
    b.bbl in 
(3073190027,
3057390001,
5031790032)
order by bbl, change_date