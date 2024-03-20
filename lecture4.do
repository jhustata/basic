capture log close
log using lecture4.log, replace text

//This log file contains most of the examples used in Lecture 4 of
//summer Stata Programming and Data Management, 
///along with additional explanations and examples.

version 12 //We're teaching new-style merging
clear all //clear all data from memory
macro drop _all //clear all macros in memory
set more off   //give output all at once (not one screenful at a time)
set linesize 80 //maximum allowed width for output

use transplants, clear

//examples of syntax for merging
//NOTE: after each example we reload transplants.dta

//simplest merge: link data in memory (transplants.dta) to donors_recipients.dta
//by matching on the variable fake_id which appears in both datasets
merge 1:1 fake_id using donors_recipients

//the merge command creates a new variable, _merge
//check how many records matched
tab _merge

//"master" = dataset that was in memory before we merged
//"using" = dataset that we are bringing in with the merge command
//"match" = appears in both master and using datasets

use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(match)
//only keep records that appear both in the original dataset and in the new dataset


use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(master match)
//only keep records that appear in the master dataset only, or both datasets

use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(master using)
//only keep records that appear in the master dataset only, 
//or the using dataset only, but not both

use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(master match) gen(mergevar)
//call the newly created created variable "mergevar" instead of "_merge"

use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(match) nogen
//don't create a new variable

merge m:1 fake_don_id using donors, keep(match) nogen keepusing(age_don)
//don't load all the new variables from the donors dataset.
//just load age_don.

corr age*
//are donor age and recipient age correlated in our fake data? No.

//merging: using assert to make sure that all your records match
use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(master match)
assert _merge==3
drop _merge

//merging: using assert to make sure that *most* of your records match
use transplants, clear
merge 1:1 fake_id using donors_recipients, keep(master match)
assert inlist(_merge, 1, 3) //master only, or matched
quietly count if _merge == 3
assert r(N)/_N > 0.99  //99% of records have _merge==3
drop _merge


//by

use transplants, clear
sort abo
by abo: gen cat_n = _N //cat_n = # records in each abo category

sort abo age
by abo: gen cat_id = _n //1 for youngest patient, 2 for next youngest, etc.


//egen

//obtaining mean age and storing it in a variable
use transplants, clear
egen mean_age = mean(age)

//more egen examples
egen median_age = median(age)
egen max_age = max(age)
egen min_age = min(age)
egen age_q1 = pctile(age), p(25) //25th percentile
egen age_sd = sd(age)  //standard deviation
egen total_prev = sum(prev) //add all the values (all are 1 or 0 in this case)

//using egen with by
use transplants, clear
sort dx
by dx: egen mean_age = mean(age)
by dx: egen min_bmi = min(bmi)

//combining sort and by to get bysort / bys
use transplants, clear
bys abo: egen m_bmi=mean(bmi)
bys abo gender: egen max_bmi = max(bmi)
bys abo gender: egen min_bmi = min(bmi)
gen spread = max_bmi - min_bmi

//egen = tag
egen grouptag = tag(abo gender)
//now, for all gorups of abo/gender, (1/M, 3/F, etc), there's exactly one
//record that has grouptag = "1". All others have grouptag = "0".

list abo gend spread if grouptag

//more examples of bys
use donors_recipients, clear
bys fake_don: gen n_tx = _N
bys fake_don: gen tx_id = _n
egen don_tag = tag(fake_don)
tab n_tx if don_tag


//graphing example with egen and tag
use transplants, clear
egen tag_race = tag(race)
bys race: egen mean_bmi=mean(bmi)
bys race: egen mean_age=mean(age)

label define race_label 1 "White" ///
    2 "Black/AA" 4 "Hispanic/Latino" ///
    5 "East Asian" 6 "Native American" ///
    7 "Asian Indian" 9 "Other"  //create a label race_label

//I personally find this more legible than cond() with seven cases,
//although cond() has its champions
gen racedesc = "White/Caucasian" if race==1
replace racedesc = "Black/AA" if race==2
replace racedesc = "Hispanic/Latino" if race==4
replace racedesc = "Native American" if race==5
replace racedesc = "East Asian" if race==6
replace racedesc = "Asian Indian" if race==7
replace racedesc = "Other" if race==9

twoway scatter m~_bmi m~_age if tag_race, ///
    title("Mean age and BMI by race/ethnicity") ///
    xtitle("Mean age") ytitle("Mean BMI") ///
    xlabel(40(2)60) ylabel(20(2)30) ///
    mlabel(racedesc)
graph export graph_lecture4.png, replace width(2400)


//math functions

//setup for math functions
clear
set obs 1000
gen n = _n/100 - 5

//rounding method 1: floor
disp floor(0.3)
disp floor(4.5)
disp floor(8.9)

//rounding method 2: ceil
disp ceil(0.3)
disp ceil(4.5)
disp ceil(8.9)

//rounding method 3: round
disp round(0.3)
disp round(4.5)
disp round(8.9)

//using round to round to something other than nearest integer
disp round(-0.32, 0.1)  //round to nearest 0.1
disp round(4.5, 2)   //round to nearest 2
disp round(8.9, 10)  //round to nearest 10

//min and max
disp min(8,6,7,5,3,0,9) //display minimum value
disp max(8,6,7,5,3,0,9) //display maximum value

//other math functions
disp exp(1)  //exponent. e^1 = e.
disp ln(20)  //log of 20 ~ 3
disp sqrt(729)  //27

disp abs(-6)  //absolute value
disp mod(529, 10) //modulus (remainder)
disp c(pi)  //constant pi (for illustration of sine)
disp sin(c(pi)/2) //sine function

//string functions
use transplants, clear
list extended_dgn in 1/5, clean

disp word("Hello, is there anybody in there?", 4)
list extended_dgn if word(ext, 5) != "", clean noobs
disp strlen("Same as it ever was")
list extended_dgn if strlen(ext)< 6, clean
assert regexm("Earth", "art")
assert !regexm("team", "I")

tab ext if regexm(ext, "HTN")
list ext if regexm(ext, "^A") 
//starts with A

list ext if regexm(ext, "X$") 
//ends with X

tab ext if regexm(ext, "HIV.*Y") 
//contains "HIV", then some other stuff, then Y


//date and time functions
//review of number formats
disp %3.2f exp(1)
disp %4.1f 3.14159

//examples of the %td format for dates (days since 1/1/1960)
disp %td 19400
disp %td 366
disp %td -5

//doing math on Stata dates
use transplants, clear
gen oneweek = transplant_date +7
format %td oneweek
list transplant_date  oneweek in 1/3

//date functions
//td() function to give integer date for a given calendar date
disp td(04jul1976)

//"Back to the future" start date
disp td(26oct1985) 

//mdy() function to give integer date for a given month/day/year
disp mdy(7,4,1976)

//"Back to the future" start date
disp mdy(10,26,1985) 



//date() function to convert strings to dates
//Woodstock festival starts
disp date("August 15, 1969", "MDY")
//Next perihelion of Halley's comet
disp date("2061 28 July", "YDM")

use donors, clear
gen donor_dob = date(fake_don_dob, "DMY")

format %td donor_dob
list donor_dob fake_don_dob in 1/5

use transplants, clear
//survival analysis overview

//prep work
gen f_time = end_date-transplant_date

//stset (1)
stset f_time, failure(died)

//stset (2)
stset end_date, origin(transplant_date) failure(died)

//set a scale to measure time in years instead of days
stset end_date, origin(transplant_date) failure(died) scale(365.25)

//Kaplan-Meier curve
sts graph

//stratified K-M curve
sts graph, by(don_ecd)

//calculate incidence rate per person-year
stsum
stsum, by(don_ecd)

//rank-sum tests
sts test don_ecd
sts test gender
log close

