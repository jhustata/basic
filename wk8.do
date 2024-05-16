// Comments and indentation by GPT-4o 
// Load the dataset based on the operating system
if c(os) == "MacOSX" {
    use wk7output/student_pressure, clear  
}
else {
    use wk7output\student_pressure, clear 
} 

// Set the seed for reproducibility
set seed 340600

// Generate a withdrawal variable with a 10% probability
g withdraw = rbinomial(1, .1)

// Sort the dataset by student_id and session_date
sort student_id session_date

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

// Generate a withdrawal date variable
g withdraw_dt = session_date if withdraw==1

// Summarize session_date
sum session_date

// Format withdraw_dt as a date
format withdraw_dt %td

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

// Generate an end date as the minimum withdrawal date by student_id
by student_id: egen end = min(withdraw_dt)

// Format end date
format end %td

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

// Tabulate the end date with missing values
tab end, mi

// Summarize session_date
sum session_date 

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

// Replace missing end dates with the maximum date
replace end=r(max) if missing(end)

// Tabulate the end date with missing values
tab end, mi

// Generate a begin date as the minimum session date by student_id
by student_id: egen begin = min(session_date)

// Format begin date
format begin %td

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

// Ensure withdrawal continuity by replacing the next record's withdrawal status
by student_id: replace withdraw = 1 if withdraw[_n-1]==1  

// List records for student_ids 2 to 5
list if inrange(student_id, 2, 5)

/* --- insertion ---*/
// Generate ineligibility indicator
bys student_id: egen inelig=min(withdraw)

// List ineligible students
l if inelig==1

// Drop ineligible students
drop if inelig==1 

// Show the codebook for student_id
codebook student_id 

// Keep selected variables
keep student_id session sbp withdraw end begin 

// Order the variables
order student_id session begin end withdraw sbp 
/* --- continue ---*/

// Set the survival time settings
stset end, fail(withdraw) enter(begin) origin(begin) scale(7.0242308)

// Generate a stressed variable based on systolic blood pressure
g stressed = sbp>140

#delimit ;   
// Plot survival curves
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

// Export the graph based on the operating system
if c(os) == "MacOSX" {
    graph export wk7output/class_attrition_wk8.png, replace  
}
else {
    graph export wk7output\class_attrition_wk8.png, replace 
} 

// Calculate absolute risks
sts list, fail by(stressed) at(2 4 6) saving(km, replace ) 
preserve  
    use km, clear  
    replace failure=failure*100
    
    // Calculate mean failure rates at different time points for non-stressed students
    sum failure if stressed==0 & time==2
    local wk2: di %3.2f r(mean)
    sum failure if stressed==0 & time==4
    local wk4: di %3.2f r(mean)
    sum failure if stressed==0 & time==6
    local wk6: di %3.2f r(mean)
    
    // Calculate mean failure rates at different time points for stressed students
    sum failure if stressed==1 & time==2
    local swk2: di %3.2f r(mean)
    sum failure if stressed==1 & time==4
    local swk4: di %3.2f r(mean)
    sum failure if stressed==1 & time==6 
    local swk6: di %3.2f r(mean)
restore 

// Perform log-rank test for nonparametric hypothesis testing
sts test stressed, logrank 

// Capture the chi-squared value and degrees of freedom
local chi2_value = r(chi2)
local df = r(df)

// Calculate the p-value
local p = chi2tail(`df', `chi2_value')
di `p'

qui {    
    if `p' < 0.01 {
        local p: di "p < 0.01"
    }
    else if inrange(`p',0.01,0.05) {
        local p: di %3.2f `p'
    }
    else {
        local p: di %2.1f `p'
    }
    
    if `p' < .05 {
        noi di "Withdraw rates for Stata I at weeks 2, 4 and 6 were `wk2'%, `wk4'%, `wk6'% for students with SBP<140mmHg "
        noi di "For students with SBP>140mmHg, the rates were `swk2'%, `swk4'%, `swk6'%"
        noi di "There's an association between SBP>140mmHg and withdrawal from Stata I: p=`p'"
    }
    else {
        noi di "Withdraw rates for Stata I at weeks 2, 4 and 6 were `wk2'%, `wk4'%, `wk6'% for students with SBP<140mmHg "
        noi di "For students with SBP>140mmHg, the rates were `swk2'%, `swk4'%, `swk6'%"
        noi di "There's no association between SBP>140mmHg and withdrawal from Stata I: p=`p'"
    }
} 

// List the first record
list in 1

// Check if the data is nested
capture isid student_id
if _rc !=0 {
    di "These data are nested and each student has several records"    
}
else {
    di "There's only a single record per student"
}

// Perform Cox regression analysis
stcox stressed

// List results
ereturn list 
return list

// Store the results matrix
matrix m = r(table)
matrix list m

// Perform linear combination of coefficients
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

// Generate a representation tag for each student
egen representation = tag(student_id)

// List the first 10 records
l in 1/10 

// Keep only unique records for each student
keep if representation==1

// Count the number of unique records
count

// Check if the data is nested
capture isid student_id
if _rc !=0 {
    di "These data are nested and each student has several records"    
}
else {
    di "There's only a single record per student"
}
