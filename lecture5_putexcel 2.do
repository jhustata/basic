capture log close
log using lecture05_putexcel.log, replace text

//This log file contains examples used to illustrate the putexcel command,
//available only for Stata 13 and later.

version 13 //Hopefully most people have Stata 13
clear all //clear all data from memory
macro drop _all //clear all macros in memory
set more off   //give output all at once (not one screenful at a time)
set linesize 80 //maximum allowed width for output

use transplants, clear

//simple
//putexcel set lecture05.xlsx

//overwrite existing file
putexcel set lecture05.xlsx, replace

//overwrite existing file
putexcel set lecture05.xlsx, modify

//putexcel: simple
putexcel A1=("Variable")

//multiple cells
putexcel A1=("Variable") B1=("Median (IQR)")

//age bmi peak_pra wait_yrs
sum age, detail 
local med_iqr: disp r(p50) " (" r(p25) "-" r(p75) ")"
putexcel A2=("Age at transplant") B2=("`med_iqr'")

//four variables

label var age "Age at transplant"
label var bmi "BMI"
label var peak_pra "Peak PRA"
label var wait_yrs "Years on waitlist"

local row=2
foreach v of varlist age bmi peak_pra wait_yrs {
    sum `v', detail
    local varlabel: variable label `v'
    local med_iqr: disp %3.1f r(p50) " (" %3.1f r(p25) "-" %3.1f r(p75) ")"
    putexcel A`row'=("`varlabel'") B`row'=("`med_iqr'")
    local row = `row' + 1
}

log close
