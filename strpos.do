use "${repos}strpos.dta", clear 
set seed 340600
replace usrds_id = round(runiform(0,10000))
replace srvc_dt = srvc_dt + 365.25*10
save strpos.dta, replace 
