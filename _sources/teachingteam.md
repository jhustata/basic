
# Resource for the Teaching Team

## 1. Lab Solutions
   - [Lab 1 Solution](lab1sol.md)
   - [Lab 2 Solution](lab1sol.md) *(Note: Same link to Lab 1's solution. No error)*
   - [Lab 3 Solution](lab3sol.md)
   - Lab 4 Solution (pending)
   - Lab 5 Solution (pending)

## 2. Homework Solutions
   - [HW 1 Solution](hw1sol.md)
   - [HW 2 Solution](hw2sol.md)
   - [HW 3 Solution](hw3sol.md)
   - HW 4 Solution (pending)
   - HW 5 Solution (pending)
   - HW 6 Solution (pending)
   - HW 7 Solution (pending)

## 3. Quick References
   - [Stata Commands Quick Reference](https://jhustata.github.io/basic/chapter3.html#commands-that-run-without-additional-syntax)

## 4. GitHub Discussions
   - Link to discussions (pending)

## 5. TA-Student Match
   - [TA-Student Matching for HW3 Grading](tastudentmatch.md)
   - Overview:
     - TAs will grade assigned students for HW3.
     - TAs should provide feedback in the `.do` file and via GradeBook notifications.
     - The matching list will be updated for subsequent homeworks.

## 6. Rubrics for Grading
   - See below for the initial grading rubric for HW3.

### GPT-4 Rubric, First Iteration

The following grading rubric is designed to assess students on HW3. TAs are encouraged to adjust the rubric as they see fit, especially in providing feedback. All students start with 100%, and points are deducted based on the issues noted below, but they may earn up to 5 bonus points for innovation and accuracy of output:

**Note**: If you disagree with any aspect of this rubric, let me know ASAP. Your critique will be regarded in a timely fashion!

#### Total Points: 100 (no student will lose more than 20 points; some students may score as many as 105 points)

1. **Code Structure and Documentation**
   - **Clarity (up to -1 point)**: Deduct if code is disorganized or hard to follow. (`deduct only once, even if several blocks of code are disorganized; use same approach for other issues`)
   - **Comments (up to -2 points)**: Deduct for inadequate comments explaining code blocks, methods, or variables.
   - **Readability (up to -1 point)**: Deduct for poor use of spacing, indentation, or naming conventions.

2. **Execution and Functionality**
   - **Correctness (up to -3 points)**: Deduct if the script has errors or does not produce the expected output.
   - **Efficiency (up to -2 points)**: Deduct if code is inefficient with unnecessary repetitions or calculations. 
      - `Based on this point, our solution below loses about one point; -1 points for repetition in creating the .xlsx file; a loop should make this more efficient`
   - **Completeness (up to -1 point)**: Deduct if any part of the script is missing or non-functional.

3. **Data Handling and Analysis**
   - **Data Import (up to -1 point)**: Deduct if data is incorrectly imported or cleaned.
   - **Variable Creation (up to -2 points)**: Deduct if variable creation or transformation is incorrect.
   - **Descriptive Statistics (up to -2 points)**: Deduct if there are errors in the computation or display of statistics.

4. **Results and Output Quality**
   - **Table Outputs (up to -2 points)**: Deduct if outputs in both `.log` and `.xlsx` formats are incorrect or unclear.
   - **Labeling and Presentation (up to -2 points)**: Deduct if variables and results are improperly labeled or presented.
   - **Interpretation (up to -1 point)**: Deduct if the results are not briefly explained or interpreted correctly.

#### Additional Considerations:
- **Innovation (Bonus up to +5 points)**: Award for creative approaches that enhance the analysis or presentation. Perhaps five innovations earn five points. Three earn three, etc.

### Final Note
Please ensure to email any doubts regarding grading to me and write the final score at the top of the script as shown in the rubric example.


```stata
//Final grade: 99.5%. Outstanding!

//code

//General note: be lenient, since I didn't give the students this rubric early enough (the rubric is really lenient anyway!)
//use comments like this above the code
//-0.5 points: could improve on organization of code

```


### HW 3 Solution, `debugged`

```stata
quietly { 
	cls
	if 0 { //background, purpose
		1. HW3 solution
		2. Just for TAs
	}
	if 1 { //methods, log, settings
        cls
        clear 
        set more off
		set timeout1 1000 //in week 1 the Hopkins internet speeds were slow and for some Stata "time-out" before importing the dataset
        capture log close 
        log using "hw3.lastname.firstname.log", replace 
        global data "https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt"
        import delimited $data, clear // Refresh data in memory, as is the case in lecture1.do and others supplements
	}
    if 2 { //results, Q1
        gen htn = dx == "4=Hypertensive"
        replace htn = 0 if missing(htn)
        
        // Label values for hypertension
        label define htn_lab 0 "No" 1 "Yes"
        label values htn htn_lab 
        noi tab htn 
    }
	if 3 { //results, Q2
		//capture program drop q2
		//program define q2
		   //.xlsx output
		   putexcel set question2, replace 
		   
		   //labels
		   label variable init_age "Age, median (IQR)"
		   label variable prev "Previous transplant, %"
		   
		   //label macros 
		   local agelab: variable label init_age
		   local prevlab: variable label prev 
			  
		   forvalues i = 0/1 {
		   	   
			   //+5 points: for innovative use of loops to avoid repetition
			   //0=Males, 1=Females 
		       sum init_age if female==`i', detail
		   
		       //row 1
		       local female`i'_n=r(N)
		   
		       //row2
		       local female`i'_age_p50: di %2.0f r(p50)
		       local female`i'_age_p25: di %2.0f r(p25)
		       local female`i'_age_p75: di %2.0f r(p75)

		       //row3
		       sum prev if female==`i' //debugged
		       local female`i'_prev: di %2.1f r(mean)*100
		   }   
		   
		   
		   //align output for .log file 
		   local row1: di "Question 2" _col(30) "Males (N=`female0_n')" _col(60) "Females (N=`females1_n')"
		   local row2: di "`agelab'"   _col(30) "`female0_age_p50' (`female0_age_p25' - `female0_age_p75')" ///
		                               _col(60) "`female1_age_p50' (`female1_age_p25' - `female1_age_p75')"
		   local row3: di "`prevlab'"  _col(30) "`female0_prev'" _col(60) "`female1_prev'"
		   local excel_row=1
		   
		   forvalues i=1/3 {
		      
			  //.log file
			  noi di "`row`i''"	
			  
	       }
		   	  //-1 for unecessary repetitions; will get a more ideal solution later  
			  //.xlsx file
			  //row1
			  putexcel A1 = "Question 2"
			  putexcel B1 = "Males (N=`female0_n')"
			  putexcel C1 = "Females (N=`female1_n')"
			  
			  //row2
			  putexcel A2 = "`agelab'"
			  putexcel B2 = "`female0_age_p50' (`female0_age_p25' - `female0_age_p75')"
			  putexcel C2 = "`female1_age_p50' (`female1_age_p25' - `female1_age_p75')"
			  
			 //row3
			  putexcel A3 = "`prevlab'"
			  putexcel B3 = "`female0_prev'"
			  putexcel C3 = "`female1_prev'"
		  
		//end 
	}
	log close 
    
	// Restore initial settings
    set more on
	set timeout1 30
}
```
 