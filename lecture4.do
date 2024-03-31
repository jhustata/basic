capture log close
log using lecture04.log, replace text

//This log file contains most of the examples used in Lecture 4 of
//Stata Programming and Data Management, along with additional explanations
//and examples.

version 14 //We're teaching new-style merging. According to the CoursePlus survey (70% response rate so far), all students have version >=11
//also, "export excel" requires version 14
//if you have version 13 or earlier, you can comment that stuff out and edit line 8
clear all //clear all data from memory
macro drop _all //clear all macros in memory
set more off   //give output all at once (not one screenful at a time)
set linesize 80 //maximum allowed width for output
set varabbrev on //allows variable abbreviation



////////////////////////////////////////////////////////
//                  MERGING
////////////////////////////////////////////////////////

// Merging
use transplants, clear

//examples of syntax for merging
//NOTE: after each example we reload transplants.dta

//simplest merge: link data in memory (transplants.dta) to donors_recipients.dta
//by matching on the variable fake_id which appears in both datasets
//NOTE: rename your datasets after downloading 
//e.g. donors_recipients2022.dta -> donors_recipients.dta
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


////////////////////////////////////////////////////////
//                  POSTFILE
////////////////////////////////////////////////////////

//minimal postfile example

//create a new dataset. The "postname" (what we'll call this dataset within
//our Stata script) is "mypost". There will be three variables, a, b, and c.
//the file name on disk will be abc.dta
postfile mypost a b c using abc.dta, replace

//write three rows of data directly into the new dataset.
//note that each value has to be surrounded by parentheses
post mypost (1) (2) (3)
post mypost (4) (5) (6)
post mypost (7) (8) (-2)

//all done. Save the file and close it
postclose mypost

//check out our results
use abc, clear
list, clean noobs


use transplants, clear

regress bmi gender age 
postfile pp str80 coef double(result CIleft CIright pvalue) ///
    using betas.dta, replace
foreach v of varlist gender age {
    local res=_b[`v']
    local left=_b[`v']+_se[`v']*invttail(e(df_r),0.975)
    local right=_b[`v']+_se[`v']*invttail(e(df_r),0.025)
    local pval=2*ttail(e(df_r), abs(_b[`v']/_se[`v']))
    post pp ("`v'") (`res') (`left') (`right') (`pval')
}
postclose pp

//let's have a look
use betas, clear
list, clean noobs

////////////////////////////////////////////////////////
//                  EXPORT EXCEL
////////////////////////////////////////////////////////

export excel coef result CIleft CIright using betas_table.xlsx, replace

format %3.2f result

gen ci = "(" + string(CIleft, "%3.2f") + ", " + string(CIright, "%3.2f") + ")"

export excel coef result ci using betas_table2.xlsx, replace firstrow(variables)

label var coef "Variable"
label var result "Coefficient"
label var ci "95% CI"
export excel coef result ci using betas_table3.xlsx, replace firstrow(varlabels)


////////////////////////////////////////////////////////
//                  OPTIONS
////////////////////////////////////////////////////////


//demonstrate options
use transplants, clear

capture program drop opt_demo
program define opt_demo
    syntax, [myoption]  //the user can choose to specify "myoption"
    if "`myoption'" != "" {  //if they said "myoption", display it
        disp "You picked the option `myoption'"
    }
    else {
        disp "No option" //otherwise, display this
    }
end

opt_demo   //"No option"
opt_demo, myoption   //"You picked the option myoption"

capture program drop table1_o
program define table1_o
    syntax varlist [if] , [round]

    //set display format
    //if they specified "round", then macro round will equal the word "round"
    //otherwise, it's blank (equals "")
    if "`round'" != "" {  
        local D %1.0f  //macro D will contain the display format
    }
    else {
        local D %3.2f  //set macro D to %3.2f
    }

    disp "Variable" _col(12) "mean(SD)" _col(25) "range"
    foreach v of varlist `varlist' {
        quietly sum `v' `if'
        disp "`v'" _col(12) `D' r(mean) "(" `D' r(sd) ")" _col(25) ///
            `D' r(min) "-" `D' r(max)  //notice we use macro D for format
    }
end


table1_o age bmi wait_yrs if age<40
table1_o age bmi wait_yrs if age>40, round

capture program drop minmax
program define minmax
    syntax  , [min(int 0) max(int 99)]
    disp "Min: `min'" _col(12) "Max: `max'"
end
minmax
minmax, min(20)
minmax, min(20) max(40)

//another example
capture program drop list_top
program define list_top
    syntax varname, [top(int 10)]
    //list the top `top' values
    //if `top' not specified, list the top 10
    preserve
    gsort -`varlist'
    list `varlist' in 1/`top', clean noobs
end

list_top age
list_top age, top(5)

//illustrating a function that takes a string option
capture program drop disptwice
program define disptwice
    syntax, [mystring(string)]
    disp "`mystring'"
    disp "`mystring'"
end


program define birthday
    syntax, name(string)
    disptwice, mystring("Happy Birthday to you")
    disp "Happy Birthday, dear `name'"
    disp "Happy birthday to you"
end

birthday, name("Gugu Mbatha")  //04/21/1983


//combining several of the above techniques into a "table1" program
capture program drop table1_nice
program define table1_nice
    syntax varlist [if] , [replace] [precision(int 1)] [title(string)]
    //if: specify records to include in analysis (optional)
    //precision: # of digits to the right of decimal point (optional, default 1)
    //title: title to display before the table (optional)

    preserve
    capture keep `if' //temporarily drop any records not required

    //set display format
    assert inrange(`precision', 0, 6) //allow 0-6 digits to R of decimal point
    local pplus = `precision' + 1 //first number for formatting code
    local D %`pplus'.`precision'f

    if "`title'" != "" {
        disp "`title'"
    }

    disp "Variable" _col(12) "mean(SD)" _col(25) "range"
    foreach v of varlist `varlist' {
        quietly sum `v' `if'
        disp "`v'" _col(12) `D' r(mean) "(" `D' r(sd) ")" _col(25) ///
            `D' r(min) "-" `D' r(max)  //notice we use macro D for format
    }
end


table1_nice age bmi wait_yrs if age>40, precision(2) replace ///
    title("Study population")





//put it in a program
capture program drop model
program define model
    //takes a varlist of independent (x) variables,
    //a filename to post the data to,
    //and the name of a dependent (y) variable
    syntax varlist, yvar(varname) filename(string)

    regress `yvar' `varlist'

    postfile pp str80 variable double(result CIleft CIright pvalue) ///
        using `filename', replace
    foreach v of varlist `varlist' {
        local res=_b[`v']
        local left=_b[`v']+_se[`v']*invttail(e(df_r),0.975)
        local right=_b[`v']+_se[`v']*invttail(e(df_r),0.025)
        local pval=2*ttail(e(df_r), abs(_b[`v']/_se[`v']))
        post pp ("`v'") (`res') (`left') (`right') (`pval')
    }
    postclose pp
end

use transplants, clear
model age wait_yrs gender rec_hcv_antibody, yvar(bmi) filename(model_bmi)


use model_bmi, clear
list, clean noobs

//BONUS: make it fancy
capture program drop model2
program define model2
    syntax varlist, cmd(string) [show replace] filename(string)

    `cmd' `varlist'
     local cmd1=word("`cmd'",1)

    assert inlist("`cmd1'", "regress", "logit", "logistic")

    postfile pp str80 variable double(result CIleft CIright pvalue) ///
        using `filename', `replace'
    foreach v of varlist `varlist' {
        if "`cmd1'"=="logistic" | "`cmd1'" == "logit" {
            local res=exp(_b[`v'])
            local left=exp(_b[`v']+_se[`v']*invnormal(0.025))
            local right=exp(_b[`v']+_se[`v']*invnormal(0.975))
            local pval=(1-normal(abs(_b[`v']/_se[`v'])))*2
        }
        else if "`cmd1'"=="regress" {
            local res=_b[`v']
            local left=_b[`v']+_se[`v']*invttail(e(df_r),0.975)
            local right=_b[`v']+_se[`v']*invttail(e(df_r),0.025)
            local pval=2*ttail(e(df_r), abs(_b[`v']/_se[`v']))
        }
        post pp ("`v'") (`res') (`left') (`right') (`pval')
    }
    postclose pp

    quietly {
        preserve
        use `filename', clear
        if "`show'"!="" {
            noisily list, clean noobs
        }
        compress
        save, replace
        format %3.2f result CIleft CIright pvalue
        export excel using `filename'.xlsx, replace firstrow(variables)
    }
end

use transplants, clear
model2 gender race age, filename(model_bmi) cmd("regress bmi") show replace
model2 bmi race age, filename(model_gender) cmd("logistic gender") show replace



log close
