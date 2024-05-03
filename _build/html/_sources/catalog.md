## Catalog of Commands

***Before running any sample codes, please run this line of command in Stata***

``` Stata
global repo : di "https://raw.githubusercontent.com/jhustata/basic/main"
```

### display

`display` is a command that let's Stata to print out a value, a string, and etc. to the result window.

``` Stata
di "This is an example"
```

### quitely

`quitely` is a command control the output displayed in Stata result window. It can be used as a prefix to other commands to hide it's results in the result window.
Use `{}` to create chunks for `quitely`. All results for codes within the chunk will be hide unless otherwise specified.

``` Stata 
// display the result
di "This is an example"
// hide with quitely
qui di "This is an example"
// code chunk
qui {
    di "This is an example"
}
```

### noisily

`noisily` is a command control the output displayed in Stata result window. It does exactly the opposite as quitely and forces the output to be displayed in the result window even if within a quitely block.

``` Stata
qui {
    di "This line will be hidden"
    noi di "This line will be displayed"
}
```

### cls

`cls` is a command clearing up the result window.

``` Stata
noi di "Some random staff to be removed from your screen"
cls
```

### //, /*, if 0 {}, *

`//`, `/*` and `*/`, `if 0 {}`, `*` are different ways of commenting or annotating in Stata.
``` Stata
// Works in Do-files
// This is a comment
/* This is a comment chunk, and this is the start of this chunk
This is a comment
This is the end of this chunk */

if 0 {
    if 0 is a special way of commenting in Stata
    if 0 is a condition that is always being considered as False in Stata
    therefore, codes in if 0 will never be read-in as commands thus never runned
    so it can act as a way of commenting
}

* This is a very traditional way of commenting
```

### if

`if` is the way to tell Stata to execute specific commands when a condition is met
If a number that is not equal to 0 is being used as condition, Stata will always consider it as `True`

``` Stata
if 1 {
    di "This is an example"
}
import delimited "${repo}/transplants.txt"
// summarize age among overall population
sum age, detail
// summarize age among females only
sum age if gender == 1, detail
```

### else/else if

`else` and `else if` are used with `if` to establish more sets of codes if additional conditions needs to be checked other than the original `if` condition.

`else` and `else if` has to start from a new line and cannot be specified after `}` in the same line.

``` Stata
local e1 = 1
local e2 = 0
local e3 = 4
if (`e1' == 0) {
    noi di "in if condition"
} 
else if (`e2' == 0) {
    noi di "in else if condition"
}
else {
    noi di "in else condition"
}

```

### clear

`clear` is a command clear up designated memory. In default, it clears up the dataset in memory.
If using `clear all`, it clears up everything (dataset, programs, macros) in memory

``` Stata
local test : di "This is an example"
import delimited "${repo}/transplants.txt", clear
clear
di "`test'"
import delimited "${repo}/transplants.txt", clear
clear all
di "`test'"
```

### capture, _rc

`capture` is a command which lets Stata to continue execution if an error occurs in the command line start with `capture`
`_rc` is a backstage value that Stata use to store the error code encountered in the command line with `capture`

```Stata
capture this is an error
di _rc
this is an error
```

### log

`log` is a command modifies log file settings

``` Stata
// close up currently opened log file for writing
capture log close
// start a new log file to write on
log using "log_file_name.txt", text replace
```

### set

`set` regulates Stata's systematic settings

``` Stata
// change number of records
set obs 100
// allow Stata to use abbreviation of variable names
set varabbrev on
// turn off the more prmopt when generating long results
set more off
// change timeout setting when connecting to internet resources
set timeout1 1000
```

### local/global/macros

`macros` are temporary user/command defined scalars that are stored in Stata's backstage to hold temporary values, strings, files, and etc.

A `local macro` means that such a temporary scalar will only remaining functional in this specific do-file/program and will lose information stored in it after running. To call a local macro, use ` and ' to wrap the macro name.

``` Stata
// define a local macro called example with a value of 0
local example = 0
// define a local macro called example2 with a string
local example2 : di "This is an example"
// define a local macro with variable names
local example3 var1 var2 var3
// call macros
di `example'
di "`example2'"
di "`example3'"
```

A `global macro` has the same idea as a `local macro`. Instead, as its name shows, it will remain functional as long as the current running Stata session is not terminated. To call a global macro, use `$` sign before the macro name. To avoid potential error, `{}` can be used to wrap the macro name after `$` sign.

``` Stata
// defining global macro is the same as local macro, just change from local to global
global example = 0
// call a global macro
di ${example}
```

### use/import/infile/infix

`use`, `import`, and `infile` commands are Stata commands that read in dataset files into memory for analysis.

`use` is specifically for `.dta` files
`import` is for all other file types with different syntax
`import delimited` - for `.csv` and `.txt`
`import excel` - for `.xls` and `.xlsx`
see more with `help` command.

`infile`/`infix` are specific ways to read in text data with a dictionary

`, clear` is an option that helps clear out the dataset in memory to avoid issues

``` Stata
// read in .dta sets
use "dataset.dta", clear
// read in .csv/.txt
import delimited "dataset.csv", clear
// read in text file with dictionary
infile using dictionary, using(dataset) clear
infix var1 1-2 var2 3-7 var3 8-20 using "dataset.raw", clear
```

### generate

`generate` is a command to create a new variable in current dataset.

``` Stata
clear
set obs 100
// generate a variable called example and set all rows to 0
gen example = 0
```

### replace

`replace` is a command to change values of a specific variable for certain rows.

``` Stata
import delimited "${repo}/transplants.txt", clear
// generate a new variable called example and assign all rows 1
gen example = 1
// change example to 0 for rows have age less than 30
replace example = 0 if age < 30
```

### drop

`drop` is a command tells Stata to drop certain observations in dataset.

When using with variable names, `drop` command deletes the variable in the list of variable names.

``` Stata
import delimited "${repo}/transplants.txt", clear
drop if gender == 1
drop age gender
```

### keep

`keep` is a command tells Stata to keep only rows in dataset.

When using with variable names, `keep` command deletes all variable that are not in the list of variable names.

``` Stata
import delimited "${repo}/transplants.txt", clear
keep if gender == 1
keep age gender
```

### label

`label` is a command to help labeling the variables or variable values.

``` Stata
clear
set obs 100
gen example = 0
// to label a variable
label variable example "Example Variable"
```

To label variable values, a label needs to be defined and then applied to the variable.

``` Stata
clear
set obs 100
gen example = round(runiform(0,1))
// to label variable values
/* label as below:
0 - No
1 - Yes
*/
capture label drop example_lab
label define example_lab 0 "No" 1 "Yes"
label values example example_lab
```

### tabulate

`tabulate` is a command that quickly tallies the number of each unique values for a variable, or the number of each unique combination among values of two variables.

``` Stata
import delimited "${repo}/transplants.txt", clear
tab race
tab gender race
```

### putexcel

`putexcel` is a command that writes contents from Stata into designated excel file cells.

To use `putexcel`, first need to do `set` to designate file to write in. Then a specific cell can be referred using excel row-column combination (A1, A2, B1, B2, etc.).

``` Stata
putexcel set example, replace
putexcel A1 = "This is an example"
putexcel B2 = 1
```

### putdocx

`putdocx` is a command that weites contents from Stata into desginated word documents.

To use `putdocx`, the process should start with `putdocx begin` and end with `putdocx save`

``` Stata
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("This Is an Example")
putdocx paragraph, style(Heading1)
putdocx text ("1. Heading")
putdocx save example, replace
```

### loops - for/while

`loops` in Stata refers to a block, or a set of code, that was executed repeatitively until a certain condition is met. The `for` and `while` commands are different ways of defining such a condition.

There are two ways of defining `for` loops in Stata.

#### forvalues 

`forvalues` is a way of defining a `for loop` in Stata. It will execute a set of codes based on a set of values. In default, the loop will execute from lowest value to the highest value, and everytime the set of code was executed, the value goes up for 1.

``` Stata
forvalues i = 1/10 {
    noi di "i value: `i'"
}
```

#### foreach

`foreach` is a way of defining a `for loop` in Stata. It will execute a set of codes based on a list of values (can be many things like numbers, variables, strings and etc.). In default, executing the set of codes one time will make the loop proceed to the next element in the list. The loop will finish execution once it finish the execution for the last element in the list.

``` Stata
foreach i in sample1 sample2 sample3 {
    noi di "This is `i'"
}
```

#### while

`while` is a way of defining a `while loop` in Stata. It will continue executing a set of codes until the condition specified in `while` command is not statisfied anymore. In default, elements used in determining the condition for the while loop will not being automatically changed unless the code modifies it. ***This means if no modification is being done through the code in the loop, the conditions may always remain*** `True` ***thus leading to endless iterations of the loop and cause execution issues.***

``` Stata
local end = 0
local i = 0
while (`end' == 0) {
    local i = `i' + 1
    noi di "This is iteration: `i'"
    if (`i' == 10) { // this is very important!
        // this means we are changing our element for determining the condition after 10 iterations
        // if we miss this part, the end macro will always equal to 0
        // which means the condition is always satisfied thus the loop will always continue executing
        local end = 1 
    }
}
```

### summarize

`sum` is a command in Stata that quickly gives summary statistics for continuous variables. In default, it will show observation numbers, mean, standard deviation, min, and max of such variable. To get more information like quartiles, medians, use its `detail` option.

``` Stata
import delimited "${repo}/transplants.txt", clear
// summarize age
sum age
// summarize age among females
sum age if gender == 1
```

### pwd

`pwd` is a command in Stata to ask Stata to print out current working directory.

``` Stata
pwd
```

### cd

`cd` is a command changes the working directory of current running Stata.

``` Stata
cd "your_path_here"
```

### split

`split` is a command that can help parsing one string variable into 2 string variables based on a special delimiter within the string.

``` Stata
import delimited "${repo}/transplants.txt", clear
// we can take a look at the dx variable
// it is formatted as x=xxxx
// this means it has a very special delimiter of =
// therefore, we can split it into two variables by using this special delimiter
split dx, p("=")
// now we can see that there are two variables generated, one called dx1 and one called dx2
// dx1 refer to all information before =
// dx2 refer to all information after =
```

### destring

`destring` is a command that changes a string variable to numbers like int, float. `destring` can be problematic if the variable has strings containing non-numeric information.
For new variable created, use `replace` option to make it substitute the original variable, use `gen(var_name)` option to generate a new variable to store numeric version of the original variable.

``` Stata
import delimited "${repo}/transplants.txt", clear
split dx, p("=")

destring dx1, replace
```

### delimit

`#delimit` is a special command which changes the symbol that Stata consider as the end of code line. In short, if we set `#delimit` to `;`, Stata will consider everything before a `;` as a whole single long code line.
In default, `#delimit` is set to cr, which means everytime user hits the enter in do-file, it is the end of that code line unless otherwise specified.

``` Stata
#delimit ;
noi 
di 
as error
"This is an example";
#delimit cr
```

### matrix

`matrix` is a special way of storing information (in matrice) in Stata. `matrix` are special scalars in Stata that are defined, displayed, stored, and called in special ways.

``` Stata
mat X = (1+1, 2*3/4 \ 5/2, 3)
mat list X
// to call a value in matrix
di X[1,2]
mat drop X
// to see more
help mat
```

### count

`count` quickly counts the number of observations in the dataset. When using with an `if` condition, it counts the number of observations satisfy the condition.

``` Stata
import delimited "${repo}/transplants.txt", clear
count
count if gender == 0
count if race == 1
```

### preserve

`preserve` take a snapshot of the current dataset and store it in memory. When the dataset is being changed by other codes, this snapshot will not change and may be a back-up point if the user would want to recover the dataset.

`preserve` itself only stores the snapshot, and will not recover or update the current dataset. ***Only 1 snapshot*** can exist simultaneously. If preserved once, no more `preserve` can be called again unless restored.

``` Stata
preserve
```

### restore

`restore` is the command tells Stata to recover the dataset based on the snapshot taken through `preserve`.

`restore` can not act by itself as it does not create any snapshot. It has to be called after `preserve` to recover the dataset in memory. However, to just clear out the snapshot without influencing the real dataset, `not` option may be used.

``` Stata
// these lines can be executed on one-by-one basis to best understand the command results.
import delimited "${repo}/transplants.txt", clear
preserve
di "`c(N)' observations before modification preserved"
clear
di "`c(N)' observations after modification, dataset changed"
restore
di "`c(N)' observation after restore, dataset recovered"
preserve
di "`c(N)' observations before modification preserved"
clear
di "`c(N)' observations after modification, dataset changed"
restore, not
di "`c(N)' observation after restore, dataset not recovered if not option is used in restore"
```

### program

`program` is the command tells Stata that a customized program is being defined or modified.

`program` has to start with `program define` and end with `end`. Stata cannot have two programs with the same name. To call the program that is defined, just enter the program name.
To drop a program, use `program drop`. It may be a good appraoch to drop the program before defining it, which avoids a lot of naming issues.

``` Stata
capture program drop example
program define example
    noi di "This is an example program"
end
example
```

### syntax

`syntax` is a special command which has to be used within the definition of a program (i.e. between `program define` and `end`).

`syntax` regulates the mandatory and optional customized syntax and options the program can take. Each syntax or option will be store under a local macro with the same name of the syntax/option. All customized syntax/option wrapped by `[]` are optional and otherwise mandatory. Optional syntax/options need a default value, but mandatory syntax/options do not.

``` Stata
capture program drop example
program define example

    syntax [in] [if], opt1(int) [opt2(real 0.1)]
    import delimited "${repo}/transplants.txt", clear
    noi di "opt1=" `opt1'
    noi di "opt2=" `opt2'

    keep in 1/50
    list `in' `if'

end

example, opt1(3) opt2(2.45)
example in 1/10 if gender == 0, opt1(20)
```

### tokenize

`tokenize` strikes a list of elements into single elements and store them into macros based on their order in the list.

``` Stata
local example_list a1 a2 a3 a4 a5 a6
tokenize `example_list'
macro list
forvalues i = 1/6 {
    noi di "No.`i' element: ``i''"
}
```

### postfile

`postfile` creates a temporary dataset in memory that can be modified by the user to store information.

`postfile` has to have a `postfile close` to start creating another dataset file.

``` Stata
postfile your_file_name var_name1 var_name2 var_name3, replace
post your_file_name (var_name1 = 1) (var_name2 = 2) (var_name3 = 3)
postfile close your_file_name
```