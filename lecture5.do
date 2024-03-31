capture log close
log using lecture5.log, replace text

//This log file contains most of the examples used in Lecture 5 of
//Stata Programming and Data Management, along with additional explanations
//and examples.

version 11 //Hopefully most people have Stata 11
clear all //clear all data from memory
macro drop _all //clear all macros in memory
set more off   //give output all at once (not one screenful at a time)
set linesize 80 //maximum allowed width for output
set varabbrev on //lets stata understand abbreviated variable names (this is the default) 

use transplants, clear

//check that ctr_id exists
describe ctr_id

//explore it
tab ctr_id, sum(age)

//demonstrate collapse
collapse (mean) age, by(ctr_id)
//create a new dataset with one record per ctr_id. In the variable age, store
//the mean age among all records with a given ctr_id. 
list, clean

use transplants, clear
//alternate syntax for collapse
collapse (mean) mean_age=age, by(ctr_id)
//call the new variable mean_age
list, clean

//collapsing several variables at once
use transplants, clear
collapse (mean) age wait bmi, by(ctr_id) //obtain the mean of each variable
list, clean noobs

//collapsing using different functions
use transplants, clear
collapse (min) min_age=age (max) max_age=age, by(ctr_id) //max/min age for each ctr
list, clean noobs

//counting records with collapse
//first method to count # records per center
use transplants, clear
gen int n=1  //n=1 for every record
collapse (sum) n, by(ctr_id)  //sum of all n = # records
list, clean

//second method
use transplants, clear
assert !missing(fake_id)
collapse (count)n=fake_id, by(ctr_id)
list, clean

//demonstrate count() when there are missing values
use transplants, clear
replace age = . in 1/20
collapse (count) n1=age n2=fake_id, by(ctr_id)
list, clean noobs

//collapsing on more than one variable
use transplants, clear
gen yr=year(transplant_date)
collapse (count)n=fake_id  (mean)mean_age=age, by(ctr_id yr)
list if ctr_id==24, clean noobs

//prep work for playing with reshape
use transplants if !mi(transplant_date), clear
gen yr = year(transplant_date)
gen int n=1
collapse (sum) n, by(ctr_id yr)
save ctr_yr, replace

//example of reshape wide
reshape wide n, i(ctr_id) j(yr)
list ctr_id n2007-n2010, clean noobs


//go back to long
reshape long

//and again
reshape wide
reshape long
reshape wide

//change missingness of n2006-n2015 variables to 0
foreach v of varlist n20* {
    replace `v' = 0 if missing(`v')
}

reshape long

//syntax for reshaping wide to long
//setup
reshape wide
reshape clear

reshape long n, i(ctr_id) j(yr)
list, clean noobs
 

//expand

//a simple example with expand
//prep work
clear
set obs 3   //set # of records in dataset
gen id = _n
list,clean 

//expand 3 (2 more of each observation)
expand 3
list,clean


//prep work for more complicated "expand" example
use transplants, clear
gen int n=1
collapse (sum) n (mean)mean_age=age (sd)sd_age=age, by(ctr_id)
save ctr_age, replace

list if ctr_id==24, clean noobs

//now we have a dataset of transplant centers
//we want one record per patient
//perhaps we're going to do some sort of simulation

use ctr_age, clear
count
expand n //make n copies of each record
count 
//since the original transplants.dta has 2000 records, after doing our
//collapse then expand we should still have 2000 records
assert r(N) == 6000

//now generate sim ages (just as a demonstration)
gen sim_age = mean_age+rnormal()*sd_age

//were the sim ages realistic?
sum sim_age

use transplants, clear
sum age
//mean+SD are similar, but sim ages had more extreme values than the real ones

//extended macro functions
local ll: variable label race
disp "`ll'"   //display "Patient race"

local ll: variable label gender
disp "`ll'"   //nothing

local vlabel: value label race
disp "`vlabel'"   //display "race" which is the name of race's value label

local val: label race 4
disp "`val'"   //display "4=Hispanic"

sum wait_yrs
local m1: disp %3.2f r(mean)
disp "`m1'"

sum wait_yrs
local m2: di "Mean: " %3.2f r(mean)
display "`m2'"

sum wait_yrs
local m3: di "Range: " ///
    %3.1f r(min) "-" %3.1f r(max)
display "`m3'"


//global vs local macros
global mymacro = 11
disp "Here is $mymacro"

local mymacro = 7
global mymacro = 11
disp "Headed to the `mymacro'-$mymacro"

//show the difference between local and global macros
capture program drop macro_show
program define macro_show
    local inside = "in Vegas"
    global inside = "in Vegas"
    disp "Local: `inside'  `outside'"
    disp "Global: $inside  $outside"
    disp "Done."
end
local outside = "At home"
global outside = "At home"
macro_show
disp "Local: `inside'  `outside'"
disp "Global: $inside  $outside"

capture program drop mystery_program
program define mystery_program
    local myvalue = 24
    global myvalue = 24
end

local myvalue = 5
global myvalue = 5
mystery_program
disp "I have `myvalue' fingers."
disp "I have $myvalue fingers."


//skeleton "unlabeled" program
//fill this in as an in-class exercise
capture program drop unlabeled
program define unlabeled 
   //list variables with no variable label
   syntax varlist
   foreach v of varlist `varlist' {
       local vlabel: variable label `v'
       if "`vlabel'" == "" {
            disp "`v'"
       }
       //What goes here?
   }
end

//test
unlabeled age race ctr_id don_ecd

capture program drop labelval
program define labelval 
   //labelval abo, val(3) prints "3=B"
   syntax varname, val(int)
   local labname: value label `varlist'
   local opt: label `labname' `val'
   disp "`opt'"
   //What goes here?
end

//test
labelval abo, val(3)

