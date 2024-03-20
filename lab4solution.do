capture log close
log using lab4_abimuzaale.log, replace

version 15
clear all
macro drop _all
set more off
set linesize 255

use transplants, clear

//q1, 10pt
bys ctr_id: gen ctr_volume= _N  

//q2, 10pt
bys ctr_id: gen tx_id = _n
egen ctr_tag = tag(ctr_id )

summarize ctr_volume if ctr_tag==1, detail 

//q3, 20pt  ; give a full 20 to any N>800
tab extended_dgn  
gen unknown=0 

replace unknown=1 if regexm(ext, "UNCERTAIN") | regexm(ext, "BLANK") | regexm(ext, "NO REPORT") | regexm(ext, "^NOT SPECI") | regexm(ext, "NA$") | regexm(ext, "UNK") | regexm(ext, "UNCLEAR") | regexm(ext, "UNDET") | regexm(ext, "U$") | regexm(ext, "OTHER") | regexm(ext, "ETIOLOGY$") | regexm(ext, "COMPLEX CAUSES") | regexm(ext, "UNOS 999") | regexm(ext, "UKNOWN")  
tab extended_dgn unknown
tab unknown
count if unknown==1
display r(N)
disp (r(N)/(_N)*100)
disp r(N) " of 2000 patients (" %2.1f (r(N)/(_N)*100) "%) have an unknown cause of ESRD."

//q4, 10pt
format end_date %tdnn/dd/CCYY
gen died_180=0
replace died_180=1 if died==1 & ( end_date- transplant_date<=180)  
count if died_180==1  
display r(N)  
disp (r(N)/(_N)*100)  
disp r(N) " of 2000 patients (" %2.1f (r(N)/(_N)*100) "%) died within 6 months of their transplant date."  

//q5, 10pt 
sort abo  
egen abotag = tag(abo)  
bys abo: egen mean_time = mean(wait_yrs)  
bys abo: egen median_time = median(wait_yrs)  
list abo mean_time median_time if abotag==1, noobs  


//q6, 10pt
gen over50=0  
replace over50=1 if age>50
assert age!=.
stset end_date, origin(transplant_date) failure(died==1) scale (365.25)  
sts graph, by(over50) t

//q7, 15pt 
sts test over50   
scalar p=(1-chi2(r(df), r(chi2)))  
if p < 0.05 {  
    disp "There is a statistically significant difference in survival by age category (p<0.05)"
}
if p > 0.05 {
    disp "There is no statistically significant difference in survival by age category (p=" p ")"
}

//q8, 15pt
qui stcox over50  

if c(version) < 15 {      
	disp "Hazard ratio:  " %3.2f exp(_b[over50]) " (95% CI " ///       
	                       %3.2f exp(_b[over50]+invnormal(0.025)*_se[over50]) ///      
					   "-" %3.2f exp(_b[over50]+invnormal(0.975)*_se[over50]) ")"      
}
else {     
	qui lincom over50      
	disp "Hazard ratio:  " %3.2f exp(r(estimate)) " (95% CI " ///      
	                       %3.2f exp(r(lb)) ///      
					   "-" %3.2f exp(r(ub)) ")"      
}   


 