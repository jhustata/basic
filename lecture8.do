capture log close
log using lecture8.log, replace

//.do file for Lecture 8 of Stata programming class
//comments
//miscellaneous useful commands
//cool stuff that's new in Stata 15:
* transparency in graphs
* putdocx: make Word docs


//importing from the Internet
local COVID https://github.com/nytimes/covid-19-data/raw/master/us-states.csv 
import delimited `COVID', clear


use transplants, clear

//levelsof
levelsof race
disp r(levels)
local rlevel = r(levels)
foreach r in `rlevel' {
    sum age if race==`r'
}




if c(version) >= 17 {
    disp "You are running Stata 17"
}
else {
    disp "You are running an earlier version of Stata"
}

//transparent graph colors
use transplants, clear

if c(version) >= 15 {
    tw scatter rec_wgt_kg rec_hgt_cm if age>18, mcolor(%20)
    tw scatter rec_wgt_kg rec_hgt_cm if age>18, mcolor(red%20)
}


//FRAMES (version 16)
if c(version) >= 16 {
    do lecture8_frames_2021
}


if c(version) >= 15 {
    do lecture8_putdocx_2021
}

//PROGRAMS FOR WRITING OUT STATA TABLES

capture program drop v14_setup
program define v14_setup
    syntax, filename(string)
    putexcel set `filename', modify

    putexcel B1= ("aOR")
    putexcel C1= ("p")
end

capture program drop v14_writerow
program define v14_writerow
    syntax, row(int) label(string) parameter(string)
    //"int" = row we're writing to
    //"label" = label of first column
    //"parameter" = parameter to do in this row

    lincom `parameter'  //obtain estimate, 95% CI, p value
                       //NOTE: v13/14 lincom gives only estimate and se
//     return list
//     assert 0
    local lb: disp %2.1f r(lb)
    local ub: disp %2.1f r(ub)
    local p = r(p)
    local est: disp %2.1f r(estimate)

    local pdisp: disp %2.1f `p'
    if `p' < 0.15 {
        local pdisp: disp %3.2f `p'
    }
    if inrange(`p', 0.045, 0.055) {
        local pdisp: disp %4.3f `p'
    }
    if `p' < 0.01 {
        local pdisp = "<0.01"
    }
    if `p' < 0.001 {
        local pdisp = "<0.001"
    }

    putexcel A`row'=("`label'")
    putexcel B`row' = ("`est' (`lb'-`ub')")
    putexcel C`row' = ("`pdisp'")
end




capture program drop v15_docsetup
program define v15_docsetup
    putdocx clear
    putdocx begin
end

capture program drop v15_tablesetup
program define v15_tablesetup
    syntax, caption(string) table(string)

    putdocx paragraph, font(Calibri,11, black)
    putdocx text ("`caption'"), bold

    //create a custom-formatted table
    putdocx table `table' = (6,3), ///    6 rows, 3 columns
        halign(center)          ///       center the table
        border(insideH,, white) ///       interior horiz borders are white
        border(insideV,, white) ///       interior vert  borders are white
        border(start,, white)  ///        left border is white
        border(end,, white)  ///          right border is white
        border(top,, black)  ///          top border is black
        border(bottom,, black)  ///       bottom border is black
        width(70%)         //             make the table 70% as wide as the page

    //make the top row (header) have a black bottom border
    //NOTE: must have *no space* between table name and parenthesis
    //because Stata is soooo fussy about spaces
    putdocx table `table'(1,.), border(bottom,,black)


    //write header text
    //NOTE: produces an error if there's a space between the "e" and the "("
    //because of course it does
    putdocx table `table'(1,2) = ("aOR"), halign(center)
    putdocx table `table'(1,3) = ("p"), halign(center)

end

capture program drop v15_writerow
program define v15_writerow
    syntax, table(string) row(int) label(string) parameter(string)
    //"table" = name of the table we're writing to
    //"int" = row we're writing to
    //"label" = label of first column
    //"parameter" = parameter to do in this row

    //put the label for the table row (first column)
    //remember: no space between table name and parenthesis
    putdocx table `table'(`row', 1)=("`label'")

    //calculate OR for parameter
    //use lincom so that we can pass, say, 10*age
    lincom `parameter'
    local lb: disp %2.1f r(lb)
    local ub: disp %2.1f r(ub)
    local p = r(p)
    local est: disp %2.1f r(estimate)
    if r(p)<0.05 {
        local b = "bold"
    }

    //p value
    local pdisp: disp %2.1f `p'
    if `p' < 0.15 {
        local pdisp: disp %3.2f `p'
    }
    if inrange(`p', 0.045, 0.055) {
        local pdisp: disp %4.3f `p'
    }
    if `p' < 0.01 {
        local pdisp = "<0.01"
    }
    if `p' < 0.001 {
        local pdisp = "<0.001"
    }

    //whew! Now actually put the stuff in the table
    putdocx table `table'(`row', 2) = ("`lb'"), `b' halign(center) script(sub)
    putdocx table `table'(`row', 2) = (" `est' "), `b' append
    putdocx table `table'(`row', 2) = ("`ub'"), `b' script(sub) append

    putdocx table `table'(`row', 3) = ("`pdisp'"), halign(center)
end

//a bit of prep work
use transplants, clear
//new functional form of race/ethnicity based on prior regression
gen byte race_aa = race==2  //African-American
gen byte race_na = race==5  //Native American/indigenous

logistic don_ecd age race_aa race_na gender bmi

//this code requires Stata 15.1 or later to work
assert c(stata_version)>=15.1

//Stata 13/14

if c(stata_version)<15 {
    v14_setup, filename("table_v14.xlsx")

    v14_writerow, row(2) label("Age (per 10y)") parameter(10*age)
    v14_writerow, row(3) label("African-American") parameter(race_aa)
    v14_writerow, row(4) label("Native American") parameter(race_na)
    v14_writerow, row(5) label("Female") parameter(gender)
    v14_writerow, row(6) label("BMI (per 5 units)") parameter(5*bmi)
}
else {
    //Stata 15 version
    putdocx begin
    v15_tablesetup, table(t1) ///
    caption("Table 1. Characteristics associated with receiving an ECD kidney.")


    v15_writerow, table(t1) row(2) label("Age (per 10y)") parameter(10*age)
    v15_writerow, table(t1) row(3) label("African-American") parameter(race_aa)
    v15_writerow, table(t1) row(4) label("Native American") parameter(race_na)
    v15_writerow, table(t1) row(5) label("Female") parameter(gender)
    v15_writerow, table(t1) row(6) label("BMI (per 5 units)") parameter(5*bmi)

    putdocx save doc4.docx, replace
}

log close
