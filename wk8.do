if c(os) == "MacOSX" {
    use wk7output/student_pressure, clear  
}
else {
	use wk7output\student_pressure, clear 
} 
set seed 340600
g withdraw = rbinomial(1, .1)
sort student_id session_date
list if inrange(student_id, 2, 5)
g withdraw_dt = session_date if withdraw==1
sum session_date
*replace withdraw_dt = r(max)
format withdraw_dt %td
list if inrange(student_id, 2, 5)
by student_id: egen end = min(withdraw_dt)
format end %td
list if inrange(student_id, 2, 5)
tab end, mi
sum session_date 
list if inrange(student_id, 2, 5)
replace end=r(max) if missing(end)
tab end, mi
by student_id: egen begin = min(session_date)
format begin %td
list if inrange(student_id, 2, 5)
by student_id: replace withdraw = 1 if withdraw[_n-1]==1  
list if inrange(student_id, 2, 5)
/* --- insertion ---*/
bys student_id: egen inelig=min(withdraw)
l if inelig==1
drop if inelig==1 
codebook student_id 
keep student_id session sbp withdraw end begin 
order student_id session begin end withdraw sbp 
/* --- continue ---*/
stset end, fail(withdraw) enter(begin) origin(begin) scale(7.0242308)
g stressed = sbp>140
#delimit ;   
sts graph, 
    fail per(100)
	ylab(,format(%2.0f))
	by(stressed)
	tmax(7)
	xlab(0(1)7)
	xti("Week")
	ti("Stata I dropout rate, %")
	/*
	legend(
	    order(1 2)
		lab(1 "SBP>140mmHg")
		lab(2 "SBP<140mmHg")
		ring(0)
		pos(11)
	)
	*/
	risktable
	note("Source: From Simulated Data",
	    pos(7)
	)
; 
#delimit cr 
graph export wk7output/class_attrition_wk8.png, replace 
list in 1
capture isid student_id
if _rc !=0 {
    di "These data are nested and each student has several records"	
}
else {
	di "There's only a single record per student"
}
stcox stressed
//creturn list
ereturn list 
return list
matrix m = r(table)
matrix list m
lincom stressed 
return list
qui {  
	local p = r(p)
	local hr : di %3.2f exp(r(estimate))
	local lb : di %3.2f exp(r(lb))
	local ub : di %3.2f exp(r(ub))
    if r(p) < 0.01 {
       local p: di "p < 0.01"
    }
    else if inrange(r(p),0.01,0.05) {
       local p: di %3.2f r(p)
    }
    else {
       local p: di %2.1f r(p)
    }
    if `p' < .05 {
		noi di "There's an association between SBP>140mmHg and withrawal from Stata I: HR=`hr', 95%CI: `lb'-`ub', p=`p'"
	}
	else {
		noi di "There's no association between SBP>140mmHg and withrawal from Stata I: HR=`hr', 95%CI: `lb'-`ub', p=`p'"
	}
} 
 
egen representation = tag(student_id)
l in 1/10 
keep if representation==1
count
capture isid student_id
if _rc !=0 {
    di "These data are nested and each student has several records"	
}
else {
	di "There's only a single record per student"
}
 