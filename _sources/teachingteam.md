﻿# Resource for the Teaching Team 

1. Lab solutions
   - [Lab 1](lab1sol.md) 
   - [Lab 2](lab1sol.md)
   - [Lab 3](lab3sol.md)
   - Lab 4
   - Lab 5
2. HW solutions
   - [HW 1](hw1sol.md)
   - [HW 2](hw2sol.md) 
   - [HW 3](hw3sol.md)
   - HW 4
   - HW 5
   - HW 6
   - HW 7

3. Quick [refs](https://jhustata.github.io/basic/chapter3.html#commands-that-run-without-additional-syntax) for Stata code
4. GitHub Discussions
5. TA-Student Match
   - Click [here](tastudentmatch.md)
   - These are students you'll grade for HW 3
      - You'll do the grading (simple rubric will be ready by Thursday)
      - Including giving students feedback in .do file
      - Send notifications via GradeBook
   - We'll update it for subsequent homeworks
6. Rubrics for grading

# HW 3 Solution

```stata
quietly {
	cls
	if 0 { //background, purpose
		1. HW3 solution
		2. Just for TAs
	}
	if 1 { //methods, log, settings
		capture log close 
		log using "hw1.lastname.firstname.log", replace 
		global data https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt
	}
	if 2 { //data
		import delimited $data, clear 
	}
	if 3 { //results, analysis
		//Q1
		g htn=dx=="4=Hypertensive"
		replace htn=0 if missing(htn)
		
		//label values
		label define htn_lab 0 "No" 1 "Yes"
		label values htn htn_lab 
		noi tab htn 
		
		//Q2
		//capture program drop q2
		//program define q2
		   //our goals; this step is not needed
		   local row1=1
		   local row2=2
		   local row3=3
		   
		   //labels
		   label variable init_age "Age, median (IQR)"
		   label variable prev "Previous transplant, %"
		   //Males
		   sum init_age if female==0, detail
		   //row 1
		   local males_n=r(N)
		   
		   //row2
		   local males_age_p50: di %2.0f r(p50)
		   local males_age_p25: di %2.0f r(p25)
		   local males_age_p75: di %2.0f r(p75)
		  
		   
		   local agelab: variable label init_age
		   local prevlab: variable label prev 
		   
		   //row3
		    local males_prev: di %2.1f r(mean)
	
		   //Females
		   sum init_age if female==1, detail
		   //row 1
		   local females_n=r(N)
		   
		   //row2
		   local females_age_p50: di %2.0f r(p50)
		   local females_age_p25: di %2.0f r(p25)
		   local females_age_p75: di %2.0f r(p75)
		   
		   //row3
		    local females_prev: di %2.1f r(mean)
	
		   
		   //assign correct values
		   local row1: di "Question 2" _col(30) "Males (N=`males_n')" _col(60) "Females (N=`females_n')"
		   local row2: di "`agelab'" _col(30) "`males_age_p50' (`males_age_p25' - `males_age_p75')" ///
		      _col(60) "`females_age_p50' (`females_age_p25' - `females_age_p75')"
		   local row3: di "`prevlab'" _col(30) `males_prev' _col(60) `females_prev'
		   forvalues i=1/3 {
		      //given our goals above:
			  noi di "`row`i''"	
		   }
		//end 
		//q2
	}
	log close 
}
```
 