if 0 {
	1. This is just a very general guide
	2. Any solution with correct output is fine
	3. Remove 1pt per mistake (e.g. includes file path on their computer)
}

cls
capture log close  
log using lab3.log, replace //2pt
use transplants, clear //2pt

tab rec_work gender, chi2 //2pt
local p = r(p) //2pt

if `p' < 0.05 { //2pt
    disp "Question 1: working for income is associated w gender, p=" %4.3f `p' //2pt
}
else { //2pt
    disp "Question 1: working for income is not associated w gender, p=" ///
    %3.2f `p' //2pt
}

//q2
assert !missing(dx)
gen byte hypertensive = dx==4 //2pt
gen byte male = gender==0 //2pt
gen byte college = inrange(rec_edu, 3, 5) if !missing(rec_edu) //2pt
gen byte college2 = inrange(rec_edu, 4, 5) if !missing(rec_edu) //2pt 
gen age_10y = age/10 //2pt
tab rec_edu college //2pt

capture program drop table_loop //2pt
program define table_loop //2pt
    foreach v of varlist age bmi college male { //2pt
        disp "`v'" _col(15) %3.2f exp(_b[`v']) ///
            "  (" %3.2f exp(_b[`v'] + invnormal(0.025)*_se[`v']) "-" ///
                  %3.2f exp(_b[`v'] + invnormal(0.975)*_se[`v']) ")" //2pt
    }
end //2pt

logistic hypertensive age bmi college male //2pt
table_loop //2pt

//q3, 
capture program drop table_varlist //2pt
program define table_varlist //2pt
    syntax varlist //2pt
    foreach v of varlist `varlist' {
        disp "`v'" _col(15) %3.2f exp(_b[`v']) ///
            "  (" %3.2f exp(_b[`v'] + invnormal(0.025)*_se[`v']) "-" ///
                  %3.2f exp(_b[`v'] + invnormal(0.975)*_se[`v']) ")" //2pt
    }
end //2pt

//q4: 

sum rec_hgt_cm,det //2pt
gen tall = 1 if rec_hgt_cm>=r(p75) //2pt
replace tall =0 if tall==. //2pt
replace tall = . if rec_hgt_cm ==. //2pt
gen white = race==1 //2pt


lab var age_10y "Age (per 10y)" //1pt
lab var gender "Female Gender" //1pt
lab var white "White vs Non-white" //1pt
lab var rec_wgt "Weight in kg" //1pt

putexcel set lab3_test.xlsx, modify //3pt
putexcel A1=("Variable") B1=("OR") C1=("95% CI") //15pt
logistic tall age_10y rec_wgt_kg gender white //1pt
local row = 2 //1pt
foreach v of varlist age_10y rec_wgt_kg gender white { //2pt
    local varlabel: variable label `v' //2pt
    local beta: disp %3.2f exp(_b[`v']) //2pt
	local limits: disp %3.2f exp(_b[`v']+invnormal(0.025)*_se[`v']) "-" ///
	%3.2f exp(_b[`v']+invnormal(0.975)*_se[`v']) //1pt
	putexcel A`row'=("`varlabel'") B`row'=("`beta'") C`row'=("`limits'") //3pt
    local row = `row' + 1 //2pt
}

log close //2pt
