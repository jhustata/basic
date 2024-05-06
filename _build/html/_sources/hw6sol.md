# HW6 Solution

```stata
qui {
cls 
capture log close
log using hw2.lastname.firstname.log, replace text

*** Question 1
global repo https://github.com/jhustata/basic/raw/main/
use ${repo}pra_hist.dta, clear //input data


capture program drop Question1_i
program define Question1_i //program to print table
       syntax [varlist]
	
      di _col(1) "Question 1.i)" //column headers
	  di _col(1) "Visit" _col(10) "Count"
	
	preserve //preserve in case entire dataset is later required
	quietly keep if !missing(pra) //restrict to non-missing PRA
	gen Count=1 //create counter
	quietly collapse (sum) Count, by(visit_id) //observations per visit
	quietly sum visit_id
	local tot=r(N) //total number of visits

	forvalues i=1/`tot' {
	  di _col(1) `i' _col(10) Count[`i'] //display required output
	}

end

//Q1_i:  
noi Question1_i //invoke program that prints required table

bys hosp_id px_id: egen peak_pra=max(pra) //create peak_pra for each person
quietly sum peak_pra if visit_id==1, detail //extract only one peak_pra per person
local p50=r(p50)
local p25=r(p25)
local p75=r(p75)

//Q1_ii:  
noi di "Question 1.ii): The median (IQR) of peak_pra is " ///
        %4.1f `p50' " (" %4.1f `p25' "-" %4.1f `p75' ")" 

merge m:1 hosp_id using ${repo}hosp.dta, ///
     keep(matched) nogen //merge with new dataset

sort region px_id
bys region: egen peak_pra_reg=max(pra) //used highest pra the region ever "sees"

//Q1_iii:  
noi list region px_id peak_pra if pra==peak_pra_reg, sepby(region) noobs 	
log close 
}




```