capture log close
log using lecture07.log, text replace

//This .do file contains most of the examples used in Lecture 7 of
//Stata Programming and Data Management, along with additional explanations

//example: nested macros
local a6 = 35
local b = 6
disp `a`b''  //get 35


//more complicated example
use transplants, clear
local vars age bmi prev_ki
regress peak_pra `vars'
foreach v of varlist `vars' {
    local beta_`v' = _b[`v']
}
//other stuff
foreach v of varlist `vars' {
    disp "`v'" _col(10) %3.2f `beta_`v'' 
}

//even more complicated example
local vars age bmi prev_ki
regress peak_pra `vars' if gender==0  //get coefficients for males
foreach v of varlist `vars' {
    local beta_`v'_m = _b[`v']
}
regress peak_pra `vars' if gender==1
foreach v of varlist `vars' {
    local beta_`v'_f = _b[`v']
}
local header = 1
foreach v of varlist `vars' {
    if `header' == 1 {
        display "Variable" _col(10) "Overall" _col(20) "Male" _col(30) "Female"
        local header = 0
    }
    disp "`v'" _col(10) %3.2f `beta_`v'' _col(20) %3.2f `beta_`v'_m' _c
    disp _col(30) %3.2f `beta_`v'_f'
}


capture graph drop _all

//prep work:
//make a dataset of # SCD and ECD transplants for each year
use transplants, clear
gen int yr = year(transplant_date)  //year of transplant
gen byte n=1 
rename gender female //total # female transplants
//n = total # records; sum(ecd) = # SCD transplants; sum(female) = # females
rename don_ecd ecd
collapse (sum) n ecd female, by(yr) 
gen int scd = n-ecd
gen int male = n-female
save tx_yr, replace

//show various kinds of graph in their simplest form
graph twoway line n yr  //line graph
graph twoway connected n yr  //connected graph
graph twoway area n yr  //area graph
graph twoway bar n yr  //bar graph
graph twoway scatter ecd scd  //scatter plot
graph twoway function y=x^2+2  //function


//range() option for function
graph twoway function y=x^2+2, range (1 10)  //function
graph twoway function y=x^2+2, range(yr)

//graphing more than one Y variable
graph twoway line ecd scd yr
graph twoway line n ecd scd yr
graph twoway area ecd scd yr //ecd area is hidden by scd area
graph twoway area scd ecd yr //now ecd area shows, since it's drawn second
graph twoway bar  scd ecd yr 

//combining several plots
graph twoway line n yr || connected male female yr

//another way of writing the same thing, using /// to continue the same
//command on two lines
graph twoway line n yr ///
     || connected male female yr

//overlay observed data with linear regression fit
regress n yr
graph twoway line n yr ///
  || function y=_b[_cons]+_b[yr]*x, range(yr)
graph copy Graph slide51


//illustrate that you can combine lots of plots in one graph
graph twoway line female yr ///
  || line male yr ///
  || line scd yr ///
  || line ecd yr ///
  || line n yr

//of course, you could make the same graph with
//graph twoway line female male scd ecd n yr

//xscale/yscale
graph twoway line n yr, yscale(range(0)) //range of Y axis includes zero
graph twoway line n yr, yscale(range(0 700)) //Y axis range includes 0 and 700

//specify ranges for both X and Y axes
graph twoway line n yr, xscale(range(2050)) 

graph twoway line female yr, yscale(log) //write Y axis on a log scale
graph twoway line female yr, xscale(reverse) //reverse the X axis - mirror image
graph twoway line female yr, xscale(off) yscale(off) //suppress axes entirely

//combining several scale options
//this graph doesn't look great. For the variables that we're using for this
//exercise, the default Stata axes look pretty good. But this illustrates
//that you can combine as many scale options as you want.
graph twoway line ecd yr, xscale(off) yscale(log range(1) reverse)

//graph label options
//Pick "approximately four" nice values based on axis range
graph twoway line n yr, yscale(range(0)) ylabel(#4)

//label minimum and maximum values
graph twoway line n yr, yscale(range(0)) ylabel(minmax)

//start at 0, and go in increments of 100 up to 600
graph twoway line n yr, yscale(range(0)) ylabel(0(100)600)

//custom labels
graph twoway line n yr, ylabel(0(100)600) ///
    xlabel(2005 2007 "policy change" 2010(5)2020)
 

//add "ticks" (small vertical line) every unlabeled year in X axis
graph twoway line n yr, yscale(range(0)) ylabel(0(100)600) xtick(2005(1)2020)

//axis titles
//DDKT = deceased donor kidney transplant
graph twoway line n yr, xtitle("Calendar year") ytitle("DDKT") ylabel(0(100)600)

//minor ticks
graph twoway line n yr, ylabel(0(200)600) ymlabel(100(200)500)
graph export l7_mlabel.png, replace width(600)

//angle
graph twoway line n yr,  ylabel(0(100)600, angle(horizontal))
graph export l7_angle.png, replace width(600)

//graph titles
graph twoway line n yr, title("Transplants per year") ylabel(0(100)600)

//title and subtitle
graph twoway line n yr, title("Transplants per year") ylabel(0(100)600) ///
    subtitle("2006-2018") 

//note and caption options
graph twoway line n yr, title("title") subtitle("subtitle") ///
  note("note") caption("caption")
 graph copy Graph slide79

//stacking up the options
graph twoway line male female yr, title("Transplants per year, 2006-2018") subtitle("stratified by gender") 
 

 
//legend options
//put the legend inside the graph
graph twoway line male female yr, legend(ring(0)) 

//put the legend inside the graph, in upper-left corner ("eleven o'clock")
graph twoway line male female yr, legend(ring(0) pos(11)) 

//put the legend inside the graph, in lower-right corner ("five o'clock")
graph twoway line male female yr, legend(ring(0) pos(5)) 

//put the legend at 5:00 - change Y range so it fits
graph twoway line male female yr, legend(ring(0) pos(5)) yscale(range(0))

//put the different legend "keys" in one column
graph twoway line male female yr, legend(ring(0) pos(5) cols(1)) 

//change the order of the "keys"
//in this case, you just could do "twoway line female male yr"
//but order() is really handy when you have complicated graphs containing
//multiple types of plot
graph twoway line male female yr, legend(ring(0) pos(5)  order(2 1)) 
graph twoway line male female yr, legend(ring(0) pos(5) cols(1) order(2 1)) 

//print the legend for males but not females
// ("order") suppresses legend for anything that's not included)
graph twoway line male female yr, legend(ring(0) pos(5) cols(1) order(1)) 

//legend labels
graph twoway line male female yr, ///
    legend(ring(0) pos(5) cols(1) label(1 "Men") label(2 "Women"))
	graph copy Graph slide88

//force legend to print (when it normally wouldn't)
graph twoway line n yr, legend(on)

//force legend *NOT* to print (when it normally would)
graph twoway line male female yr, legend(off)

//line options
twoway line n yr, xline(2007)
twoway line n yr, yline(500)

//text option
//add the text "policy change" at y=450 x=2007 on the graph
twoway line n yr, xline(2007) text(450 2007 "Policy change")

twoway line n yr, ylabel(0(100)600) text(600 2017 "Local peak in 2017")

//twoway line options
//sort
//first, we have to *UN*sort

sort n
list, clean noobs

//display unsorted graph
twoway line n yr, ylabel(0(100)600)

//now display the graph with the line drawn properly
twoway line n yr, ylabel(0(100)600) sort 

//options for drawing the line: line color
twoway line  scd ecd yr, lcolor(green pink) sort

//line thickness
twoway line scd ecd  yr, lwidth(thick thick) sort
//valid thicknesses are:
//vvthin vthin thin medthin medium medthick thick vthick vvthick vvvthick 


//line pattern
twoway line scd ecd yr, lpattern(solid dash) sort
graph copy Graph slide105
//valid patterns are:
//solid dash dot dash_dot shortdash shortdash_dot longdash longdash_dot blank 

//scatter plot options
use transplants.dta, clear
keep if peak_pra <= 10
graph twoway scatter peak_pra age

//add jitter (random noise)
graph twoway scatter peak_pra age, jitter(2)

graph twoway scatter bmi age if gender==0, mcolor(orange) ///
 || scatter bmi age if gender==1, mcolor(black)
 graph copy Graph slide110

//marker symbol
graph twoway scatter bmi age if gender==0, msymbol(D) ///
    || scatter bmi age if gender==1, msymbol(+)

//marker size
graph twoway scatter bmi age if gender==0, msize(small) ///
    || scatter bmi age if gender==1, msize(large)
//valid sizes:
// tiny vsmall small medsmall medium medlarge large vlarge huge 


//displaying a graph stored from earlier
graph display slide51
graph dir
assert 0

//saving a graph as a Stata .gph file
graph save slide51.gph, replace

//exporting a graph to .PNG (for putting in a document)
graph export slide51.png, replace




log close
