capture log close
log using lecture03.log, replace text

//This log file contains most of the examples used in Lecture 3 of
//Stata Programming and Data Management, along with additional explanations
//and examples.

version 12 //I'm using Stata 16, but the courseplus survey tells us that some students have earlier versions 
clear all //clear all data from memory
macro drop _all //clear all macros in memory
set more off   //give output all at once (not one screenful at a time)
set linesize 80 //maximum allowed width for output

local p = 1/78
disp %3.2f `p'

local p = 1/7778
disp %3.2f `p'

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

list abo gender spread if grouptag


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
graph export graph_lecture3.png, replace width(2400)


use transplants, clear

//conditional if
if _N > 100 {
    disp "Meh. That's a big dataset"
}
if _N > 10000 { 
    disp "That's a huge dataset"
}
else {
    disp "Bah! Not so big."
}



tab dx gender, chi2
if r(p) < 0.05 {
    disp "p<0.05"
}
else {
    disp %3.2f r(p)
}

count if !inlist(rec_hcv_antibody, 0, 1, .)
if r(N) == 0 {
    logistic rec_hcv_antibody age
}
else {
    disp "Non-binary outcome. " ///
        "can't do logistic regression"
}

//note the line continuation ( ///) in the previous else-statement. 
//line continuations can be used to improve readibility of a do-file, but 
//they should not change functionality.
//stata interprets " ///" as if the next line is on the same line


//for loops.
forvalues i = 1/5 {  //first time: create a macro i, set it equal to 1
    disp `i'        //display macro i
}                  //go back to the "forvalues" statement.
//the second time, macro i will equal 2 and it will run again.
//then it will go back and set i equal to 3 and run again
//and then run a fourth time with i equal to 4
//finally, it will run one last time with i equal to 5
//then it will stop.

//all the output from a "forvalues" loop is displayed together, because
//Stata doesn't actually start running code in the loop until you type the
//closing brace }. So if you have a bunch of "disp" statements and you want
//all the display to appear together (instead of separately, after each 
//"disp" command in your code) you can put it all inside a loop that
//only runs once.

//another example of "forvalues"
forvalues b = 35/45 {
    quietly count if age>=`b' & age<`b'+1
    disp "Age of `b': " r(N) " patients"
}


foreach v of varlist age wait_yrs died {
    if inlist("`v'", "age",  "wait_yrs") {
        quietly sum `v'
        disp "Mean `v': " _col(20) %3.2f r(mean)
    }
    else {
        quietly sum `v'
        disp "Percent `v': " _col(20) %3.2f 100 * r(mean) "%"
    }
}

//foreach works like forvalues. Except that forvalues sets the macro
//equal to a number which increases each time, and foreach sets the macro
//equal to something from a list.
//there are actually several varieties of foreach, but a useful one is 
//foreach... of varlist...

//first time through the loop, macro v will equal "age". Second time it will
//equal "wait_yrs". Third time it will equal "died".
foreach v of varlist age wait_yrs died { 
    quietly sum `v' //summarize whatever variable is referred to by "v"
    disp "Max `v': " _col(10) r(max) //display maximum value
}


//example of foreach.. of varlist with if-statement
foreach v of varlist age wait_yrs died {
    if inlist("`v'", "age",  "wait_yrs") {
        quietly sum `v'
        disp "Mean `v': " _col(20) %3.2f r(mean)
    }
    else {
        quietly sum `v'
        disp "Percent `v': " _col(20) %3.2f 100 * r(mean) "%"
    }
}

//table1 program from lecture 2
capture program drop table1
program define table1
    disp "Variable" _col(20) "mean (SD)" _col(40) "range"
    quietly sum age
    disp "age" _col(20) %3.2f r(mean) " (" %3.2f r(sd) ")" ///
            _col(40) %3.2f r(min) "-" %3.2f r(max)
    quietly sum wait_yrs
    disp "wait_yrs" _col(20) %3.2f r(mean) " (" %3.2f r(sd) ")" ///
            _col(40) %3.2f r(min) "-" %3.2f r(max)
    quietly sum bmi
    disp "bmi" _col(20) %3.2f r(mean) " (" %3.2f r(sd) ")" ///
            _col(40) %3.2f r(min) "-" %3.2f r(max)
end

table1
table1 age peak_pra

//add "syntax varlist" to control the list of variables
capture program drop table1_v
program define table1_v
    syntax varlist
    //write out a nicely formatted table 
    //NOTE: could also write out with commas instead of spacing
    //which would make it easier to import into Excel
    disp "Variable" _col(15) "mean(SD)" _col(30) "range"
    foreach v of varlist `varlist' {
        quietly sum `v'
        disp "`v'" _col(15) %3.2f r(mean) "(" %3.2f r(sd) ")" _col(30) ///
            %3.2f r(min) "-" %3.2f r(max)
    }
end

table1_v age wait_yrs rec_wgt_kg 

//demonstrate behavior of local macros inside programs
program define varprogram
    syntax varlist  
    disp "`varlist'"  //displays the varlist macro
end

//syntax varname: exactly one variable
program define varfavorite
    syntax varname  
    disp "My favorite variable is `varlist'"  //displays the varlist macro
end

varfavorite fake_id

varprogram fake_id
disp "`varlist'"  //displays nothing. Stata has forgotten the varlist macro

program define macroprog
    local a=4   //define local macro a
    disp "`a'        `b'"  //Stata knows macro a, but macro b is empty
end
local b=3   //define local macro b
macroprog
disp "`a'        `b'"  //Stata knows macro b, but macro a is empty


program define varprogram2
    syntax [varlist]   //now, "varlist" is optional
    disp "`varlist'"
end


varprogram2 fake_id
varprogram2 

program define myif
    syntax [if]  //accepts an optional "if" statement
    if "`if'" != "" {  //if there's something in the "if" statement...
        disp "`if'"    //display it
    }
    else {
        disp "No if statement"  //otherwise, display this message
    }
end



myif  //displays "no if statement"
myif if age > 35  //displays "if age > 35"

capture program drop countif
program define countif 
    syntax if
    quietly count `if'
    disp "total count is " r(N)
end




capture program drop table1_if
program define table1_if
    syntax varlist [if]
    //write out a nicely formatted table
    disp "Variable" _col(12) "mean(SD)" _col(25) "range"
    foreach v of varlist `varlist' {
        quietly sum `v' `if' 
        disp "`v'" _col(12) %3.2f r(mean) "(" %3.2f r(sd) ")" _col(25) ///
            %3.2f r(min) "-" %3.2f r(max)
    }
end

table1_if age peak_pra wait_yrs
table1_if age peak_pra wait_yrs if race==1 //summarize for only race==1

//tempvar

//non-working program - as an example
capture program drop tabyear0
program define tabyear0
    syntax varname
    gen year = year(`varlist')
    tab year
end

//here's how you *should* do it (using a temporary variable)
capture program drop tabyear
program define tabyear
    syntax varname
    tempvar year  //create a temporary variable called year
    //use backquote-apostrophe to refer to the temporary variable (like a macro)
    //NOTE: even if, by some chance, there's already a variable called "year",
    //this code will still work
    gen `year' = year(`varlist')
    tab `year'
    //the temporary variable disappears automatically when the program is done
end

tabyear transplant_date
tabyear end_date

//an example of what *not* to do when you want to temporarily alter the dataset
capture program drop savesample0
program define savesample0
    //save random 10% of records
    syntax using/ , [replace]
    sample 10 //delete 90% of records!
    save `using', `replace'
end

//here's how you should do it
capture program drop savesample
program define savesample
    //save random 10% of records
    syntax using/ , [replace]
    preserve   //save a temporary copy of the data
    sample 10 //no worries
    save `using' , `replace'
    //when the program reaches the end, the temporary copy is reloaded,
    //undoing any changes
end

count
savesample using tenpct.dta, replace
count

//another way to do table1_if
capture program drop table1_if2
program define table1_if2
    syntax varlist [if]
    preserve
    capture keep `if'
    //write out a nicely formatted table
    disp "Variable" _col(12) "mean(SD)" _col(25) "range"
    foreach v of varlist `varlist' {
        quietly sum `v' `if' 
        disp "`v'" _col(12) %3.2f r(mean) "(" %3.2f r(sd) ")" _col(25) ///
            %3.2f r(min) "-" %3.2f r(max)
    }
end

table1_if2 age peak_pra wait_yrs
table1_if age peak_pra wait_yrs if age<40 //summarize for only age<40


log close
exit

