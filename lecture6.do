capture log close
log using lecture06, replace text

set varabbrev on
set more off
//examples from Lecture 6 of 340.600 Stata Programming


//histograms
use transplants, clear


//basic histogram (density histogram)
hist bmi

//specify that each bar of the histogram covers an interval of two units
hist bmi, width(2)

//specify age interval of two years, and start the graph at age 0
hist bmi, width(2) start(0)

//specify that we want ten bars
hist bmi, bin(10)

//a *density* histogram (the default)
hist rec_wgt_kg, width(2)
hist rec_wgt_kg, width(10)

//specify that we want a *fraction* histogram (height of 0.1=10% of all values)
hist rec_wgt_kg, fraction width(2)
hist rec_wgt_kg, fraction width(10)

//a *percent* histogram (height of 10 = 10% of all values)
hist rec_wgt_kg, percent width(2)
hist rec_wgt_kg, percent width(10)

//a *frequency* histogram (height = # of records represented by one bar)
hist rec_wgt_kg, freq width(2)
hist rec_wgt_kg, freq width(10)

//illustrating hist, discrete discrete
hist dx //each bar is < 1 diagnosis - histogram looks weird
hist dx, discrete //1 bar per diagnosis



//random number generation
//setup
clear
set obs 1000
gen n = _n

//random numbers - uniform distribution
disp runiform()  //displays random number uniformly distributed between 0 and 1
disp runiform()
disp runiform()

gen unif1 = runiform()
hist unif1, width(.05) start(0) freq

//setting the random number seed
set seed 40301
//should be . 43463916
disp runiform() 

//random number between 0 and 10
gen unif10 = runiform()*10
hist unif10, width(1) start(0) freq

//random number between 0 and 10
gen unif15 = runiform()*10+5
hist unif15, width(1) start(0) freq

gen norm1 = rnormal()
hist norm1, width(0.5) freq

//mean 5, SD 1
gen norm5 = rnormal(5)
hist norm5, width(0.5) start(0) freq

//mean 20, SD 4
gen norm20 = rnormal(20,3)
hist norm20, width(1) start(0) freq

//binomial
gen binom = rbinomial(10,0.5)
hist binom, discrete percent

//scatter plots
use donors, clear
graph twoway scatter don_wgt don_hgt

//abbreviation
twoway scatter don_wgt don_hgt
tw sc don_wgt don_hgt

//line plots
use transplants, clear
collapse (mean) don_ecd, by(age) //ececd = 0 or 1, so for each age get 
//proportion of transplants that were ecd
graph twoway line don_ecd age



//math functions

//setup for math functions
clear
set obs 1000
gen n = _n/100 - 5

//rounding method 1: floor
disp floor(-0.3)
disp floor(4.5)
disp floor(8.9)
gen nfloor = floor(n)
graph twoway line nfloor n

//overlay the function y=x
graph twoway line nfloor n || function y=x, range(n)

//rounding method 2: ceil
disp ceil(-0.3)
disp ceil(4.5)
disp ceil(8.9)
gen nceil = ceil(n)
local DIAG || function y=x, range(n)
graph twoway line nceil n `DIAG'

//rounding method 3: int
disp int(-0.3)
disp int(4.5)
disp int(8.9)
gen nint = int(n)
graph twoway line nint n `DIAG'

//rounding method 4: round
disp round(-0.3)
disp round(4.5)
disp round(8.9)
gen nround = round(n)
graph twoway line nround n `DIAG'

//using round to round to something other than nearest integer
disp round(-0.32, 0.1)  //round to nearest 0.1
disp round(4.5, 2)   //round to nearest 2
disp round(8.9, 10)  //round to nearest 10
gen round2 = round(n,2)
twoway line round2 n `DIAG'

//min and max
disp min(8,6,7,5,3,0,9) //display minimum value
disp max(8,6,7,5,3,0,9) //display maximum value

use ctr_yr if yr>=2015, clear
reshape wide n, i(ctr_id) j(yr)
gen max_vol = max(n2015,n2016,n2017, n2018, n2019) //max of all variables
gen min_vol = min(n2015,n2016,n2017, n2018, n2019) //min of all variables

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

//example of %tc format for times (milliseconds since 1/1/1960)
disp %tc 4*365.25*24*60*60*1000

//doing math on Stata dates
use transplants, clear
gen oneweek = transplant_date +7
format %td oneweek
list transplant_date  oneweek in 1/3

//date and time functions
//td() function to give integer date for a given calendar date
disp td(04jul1976)

//Assignment 2 due date (time travel?)
disp td(5may2021) 

//mdy() function to give integer date for a given month/day/year
disp mdy(7,4,1976)

//Assignment 2 due date
disp mdy(5, 5, 2021) 




//date() function to convert strings to dates
//Woodstock festival starts
disp date("August 15, 1969", "MDY")
//Next perihelion of Halley's comet
disp date("2061 28 July", "YDM")

//mdyhms() function to get a date and time
disp %15.0f mdyhms(1,1,2011,5,15,00)

//Summer solstice 2019 (UTC)
disp %15.0f Clock("June 20, 2021 23:31:00", "MDYhms")

disp "$S_DATE"
disp "$S_TIME"
//using the Clock() function to time a command
local start = Clock("$S_DATE $S_TIME", "DMYhms")

//using timer to time a command
timer clear
timer on 37

//some code to waste time
use transplants, clear
quietly roccomp gender bmi transplant_date  wait_yrs
local end = Clock("$S_DATE $S_TIME", "DMYhms")
timer off 37

disp (`end'-`start')/1000 " seconds"
timer list
disp "More precisely, " r(t37) " seconds"

//cond
capture program drop datasize
program define datasize
    disp _c "The dataset is "
    disp cond(_N>=1000, "big", "small")
end

datasize

gen m_f = cond(gender==1, "Female", "Male")
tab gender m_f


log close

