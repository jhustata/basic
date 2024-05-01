# HW5 Solution (Advanced)

### `.do` file with comments

```stata
do "https://github.com/jhustata/basic/raw/main/hw5_solution.do"
```

<Details> 
   <Summary> 🔥 </Summary>

```stata
qui {
	cls
	set more off
	set varabbrev on
	
	if 0 {
		this is solutions for homework 5
	}
	
	if 1 {
		capture log close
		log using "hw5.lastname.firstname.log", replace
	}
	
	if 1 {
		/*
		Question 1. Now you have all the skills to create your first automated Table 1! 
		Write a program called question1 that prints the following table (including Question 1 in the header). 
		The XX values should be replaced with correct values found in the dataset, 
		and should be rounded to the nearest whole number for age and to one decimal place 
		to the right of the decimal point for other variables. 
		Make sure the summary statistics are vertically aligned and justified along the left margin. 
		Run your program and display the table (i.e., in .log file). 
		Also, output these results to Question1.xlsx
		*/
		capture program drop ind_translator
		program define ind_translator
			syntax, row(int) col(int)

			// tokenize the alphabet
			local alphabet "`c(ALPHA)'"
			tokenize `alphabet'
			// now translate col
			local col_helper = `col'
			
			
			while (`col_helper' > 0) {
				local temp_helper2 = (`col_helper' - 1)
				local temp_helper = mod(`temp_helper2', 26) + 1
				local col_name : di "``temp_helper''" "`col_name'"
				local col_helper = (`col_helper' - `temp_helper') / 26
			} 
			
			
			// generate a global macro that can be used in main program
			global ul_cell "`col_name'`row'"
			
		end
		
		capture program drop question1
		program define question1
			qui {
				if 1 { // load dataset and general settings
					global repo https://github.com/jhustata/basic/raw/main/
					import delimited "${repo}hw1.txt", clear
					local c_base = 40
					local c_seq = 20
					local by_var : di "female"
					local row = 1
					local del = "="
				}
				
				// set up excel file
				putexcel set "Question1", replace
				
				// First line
				count if female == 0
				local male_n = `r(N)'
				count if female == 1
				local female_n = `r(N)'
				local female_col = `c_base' + `c_seq'
				
				noi di "Question 1" _col(`c_base') "Males (N=`male_n')" _col(`female_col') "Females (N=`female_n')"
				putexcel A1 = "Question 1"
				putexcel B1 = "Males (N=`male_n')"
				putexcel C1 = "Females (N=`female_n')"
				
				// Label all vars
				label variable init_age "Age"
				label variable prev "Previous transplant"
				label variable dx "Cause of ESRD"
				
				// Run through all vars
				levelsof `by_var', local(by_val)
				
				// assemble variables for loop
				local var_list init_age prev dx
				local var_type 0 1 2
				
				local var_pos = 0
				foreach i in `var_list' {
					local var_pos = `var_pos' + 1
					tokenize `var_type'
					local type = ``var_pos''
					local row = `row' + 1
					if (`type' == 0) { // con
						// display the variable label
						local col = 1
						local var_lab : variable label `i'
						local name : di "`var_lab'" ", median (IQR)"
						ind_translator, row(`row') col(`col')
						noi di "`name'", _continue
						putexcel ${ul_cell} = "`name'"
						foreach j in `by_val' {
							local col = `col' + 1
							sum `i' if `by_var' == `j', detail
							local med = `r(p50)'
							local p25 = `r(p25)'
							local p75 = `r(p75)'
							local dis : di %3.1f `med' " (" %3.1f `p25' "-" %3.1f `p75' ")"
							local sep = `c_base' + `c_seq' * (`col' - 2)
							noi di _col(`sep') "`dis'", _continue
							ind_translator, row(`row') col(`col')
							putexcel ${ul_cell} = "`dis'"
						}
						noi di ""
					}
					else if (`type' == 1) {
						local col = 1
						local var_lab : variable label `i'
						local name : di "`var_lab'" ", %"
						ind_translator, row(`row') col(`col')
						putexcel ${ul_cell} = "`name'"
						noi di "`name'", _continue
						foreach j in `by_val' {
							local col = `col' + 1
							sum `i' if `by_var' == `j'
							local mean = (`r(mean)' * 100)
							local mean : di %3.1f `mean'
							ind_translator, row(`row') col(`col')
							local col_h = `col' - 2
							local sep = `c_base' + `c_seq' * `col_h'
							noi di _col(`sep') "`mean'", _continue
							putexcel ${ul_cell} = "`mean'"
						}
						noi di ""
					}
					else if (`type' == 2) {
						local col = 1
						local var_lab : variable label `i'
						local name : di "`var_lab'" ": "
						ind_translator, row(`row') col(`col')
						putexcel ${ul_cell} = "`name'"
						noi di "`name'"
						levelsof `i', local(var_val)
						foreach k in `var_val' {
							local row = `row' + 1
							local col = 1
							// get the cat name
							local del_pos = strpos("`k'", "`del'") + 1
							local cat_name : di substr("`k'", `del_pos', .)
							local cat_name : di "`cat_name'" ", %"
							noi di "`cat_name'", _continue
							ind_translator, row(`row') col(`col')
							putexcel ${ul_cell} = "`cat_name'"
							foreach j in `by_val' {
								local col = `col' + 1
								count if `i' == "`k'" & `by_var' == `j'
								local k_num = `r(N)'
								count if `by_var' == `j'
								local total = `r(N)'
								local dis : di %3.1f (`k_num' / `total' * 100)
								local sep = `c_base' + `c_seq' * (`col' - 2)
								noi di _col(`sep') "`dis'", _continue
								ind_translator, row(`row') col(`col')
								putexcel ${ul_cell} = "`dis'"
							}
							noi di ""
						}
					}
				}
				noi di " "
			}
		end
		noi question1
	}
	
	if 2 {
		/*
		Print a summary table as shown below (this is how it should appear in your .log file), 
		with odds ratios (OR) and 95% confidence intervals (CI). 
		The XXXX values should be replaced with the actual values found in the dataset, 
		and should be displayed with two decimal places to the right of the decimal point. 
		Also, create a Question2.xlsx with this output properly formatted.
		*/
		putexcel set "Question2", replace
		noi di "Question2"
		putexcel A1 = "Question2"
		noi di "Variable" _col(40) "OR" _col(60) "(95% CI)"
		putexcel A2 = "Variable"
		putexcel B2 = "OR"
		putexcel C2 = "(95% CI)"
		
		// get statistics
		local vars init_age female
		label variable init_age "Age"
		label variable female "Female"
		logistic received_kt `vars'
		local row = 2
		foreach i in `vars' {
			local row = `row' + 1
			local name : variable label `i'
			noi di "`name'", _continue
			putexcel A`row' = "`name'"
			lincom `i'
			local or = `r(estimate)'
			local or : di %4.2f `or'
			local lb : di %4.2f `r(lb)'
			local ub : di %4.2f `r(ub)'
			local ci : di "(`lb'-`ub')"
			noi di _col(40) "`or'" _col(60) "`ci'"
			putexcel B`row' = "`or'"
			putexcel C`row' = "`ci'"
		}
		
	}
	
	capture log close
}
```

</Details>

### GPT-4 Annotation

*This might contain errors since even the most advanced GPT occassionally "hallucinates"*

### Setting Up the Environment
```stata
qui {
    cls
    set more off
    set varabbrev on
}
```
- `qui {}`: Starts a block of commands that run quietly, meaning they won't show any output in the Stata window.
- `cls`: Clears the Stata results window, making it clean for new output.
- `set more off`: Stops Stata from pausing when the output fills the screen.
- `set varabbrev on`: Allows you to use abbreviated names for variables.

### Check and Handle Logging
```stata
if 1 {
    capture log close
    log using "hw5.lastname.firstname.log", replace
}
```
- `if 1 { ... }`: This always executes since `1` is always true. It's a way to group commands.
- `capture log close`: Tries to close any open log file, ignoring any error if no log is open.
- `log using "hw5.lastname.firstname.log", replace`: Starts a new log file with a specified name, replacing any existing file with the same name.

### Define `ind_translator` Function
```stata
capture program drop ind_translator
program define ind_translator
    syntax, row(int) col(int)
```
- `capture program drop ind_translator`: Attempts to delete any existing program named `ind_translator`, ignoring errors if it doesn’t exist.
- `program define ind_translator`: Begins definition of a new program called `ind_translator`.
- `syntax, row(int) col(int)`: Specifies that this program requires two integer arguments: `row` and `col`.

**Inside `ind_translator`**
```stata
    local alphabet "`c(ALPHA)'"
    tokenize `alphabet'
    local col_helper = `col'
```
- `local alphabet "`c(ALPHA)'"`: Creates a local macro `alphabet` that contains all letters A-Z.
- `tokenize `alphabet'`: Splits `alphabet` into tokens accessible via numbered local macros (e.g., `1` for A, `2` for B, etc.).
- `local col_helper = `col'`: Initializes `col_helper` with the value of `col`.

**Translating Column Numbers to Excel Columns**
```stata
    while (`col_helper' > 0) {
        local temp_helper2 = (`col_helper' - 1)
        local temp_helper = mod(`temp_helper2', 26) + 1
        local col_name : di "``temp_helper''" "`col_name'"
        local col_helper = (`col_helper' - `temp_helper') / 26
    }
    global ul_cell "`col_name'`row'"
```
- The loop and calculations inside translate a numeric column index into an Excel column name (e.g., 1 -> A, 28 -> AB).
- `global ul_cell "`col_name'`row'"`: Stores the final Excel cell reference in a global macro `ul_cell`.

**End of `ind_translator`**
```stata
end
```
- `end`: Marks the end of the `ind_translator` program definition.

### Define `question1` Function
```stata
capture program drop question1
program define question1
    qui {
        if 1 { // load dataset and general settings
            global repo https://github.com/jhustata/basic/raw/main/
            import delimited "${repo}hw1.txt", clear
```
- `capture program drop question1`: Deletes `question1` program if it already exists.
- `program define question1`: Starts defining a new program `question1`.
- `global repo https://github.com/jhustata/basic/raw/main/`: Sets a global macro `repo` to store the URL base.
- `import delimited "${repo}hw1.txt", clear`: Imports data from a `.txt` file located at the URL stored in `repo`, clearing any existing data in memory.

**Setting Up Excel File**
```stata
            local c_base = 40
            local c_seq = 20
            local by_var : di "female"
            local row = 1
            local del = "="
        }
```
- `local c_base = 40`, `local c_seq = 20`: Set up constants to control column positions in output.
- `local by_var : di "female"`: Sets a local macro `by_var` to the string "female", intended for use in categorizing data.
- `local row = 1`: Initializes a counter for Excel rows.
- `local del = "="`: Defines a delimiter used later in text processing.

#

### Excel Setup and Header Output
```stata
putexcel set "Question1", replace
```
- `putexcel set "Question1", replace`: Prepares a new Excel file named "Question1.xlsx" and replaces any existing file with the same name.

### Counting and Outputting Gender-Specific Data
```stata
count if female == 0
local male_n = `r(N)'
count if female == 1
local female_n = `r(N)'
putexcel A1 = "Question 1"
putexcel B1 = "Males (N=`male_n')"
putexcel C1 = "Females (N=`female_n')"
```
- `count if female == 0`: Counts the number of records where the gender is male (assuming 'female' is 0 for males).
- `local male_n = `r(N)'`: Stores the number of males from the last `count` command into a local macro `male_n`.
- `count if female == 1`: Similar to above, but counts females.
- `local female_n = `r(N)'`: Stores the number of females.
- `putexcel A1 = "Question 1"`: Writes "Question 1" into cell A1 of the Excel file.
- `putexcel B1 = "Males (N=`male_n')"`: Writes the count of male participants into cell B1.
- `putexcel C1 = "Females (N=`female_n')"`: Writes the count of female participants into cell C1.

### Variable Labeling
```stata
label variable init_age "Age"
label variable prev "Previous transplant"
label variable dx "Cause of ESRD"
```
- `label variable init_age "Age"`: Assigns the label "Age" to the variable `init_age`.
- `label variable prev "Previous transplant"`: Labels the `prev` variable to indicate it represents previous transplants.
- `label variable dx "Cause of ESRD"`: Labels the `dx` variable, indicating it describes the cause of End-Stage Renal Disease (ESRD).

### Processing and Outputting Variable Statistics
```stata
levelsof `by_var', local(by_val)
local var_list init_age prev dx
local var_type 0 1 2
```
- `levelsof `by_var', local(by_val)`: Identifies unique values in the `by_var` variable (here "female") and stores them in the `by_val` local macro.
- `local var_list init_age prev dx`: Creates a list of variables (`init_age`, `prev`, `dx`) to loop through.
- `local var_type 0 1 2`: Sets up a list to indicate the type of each variable in `var_list` for processing (0 for continuous, 1 for binary, 2 for categorical).

### Loop for Summary Statistics
```stata
local var_pos = 0
foreach i in `var_list' {
    local var_pos = `var_pos' + 1
    tokenize `var_type'
    local type = ``var_pos''
    local row = `row' + 1
```
- `local var_pos = 0`: Initializes a position counter for the variables.
- `foreach i in `var_list' { ... }`: Begins a loop over the variables listed in `var_list`.
- `local var_pos = `var_pos' + 1`: Increments the position counter.
- `tokenize `var_type'`: Breaks the string `var_type` into tokens that can be accessed sequentially.
- `local type = ``var_pos''`: Gets the type of the current variable using the position counter.
- `local row = `row' + 1`: Increments the row counter to move to the next row in Excel.

### Handling Different Variable Types
```stata
if (`type' == 0) { // con
    local col = 1
    local var_lab : variable label `i'
    local name : di "`var_lab'" ", median (IQR)"
    ind_translator, row(`row') col(`col')
    putexcel ${ul_cell} = "`name'"
    ... [handling of continuous variables] ...
}
```
- `if (`type' == 0) { ... }`: Checks if the variable is continuous (type 0).
- `local col = 1`: Initializes the column position in Excel for output.
- `local var_lab : variable label `i'`: Retrieves the label of the current variable.
- `local name : di "`var_lab'" ", median (IQR)"`: Prepares the name and statistic type (median and interquartile range) for display.
- `ind_translator, row(`row') col(`col')`: Calls the `ind_translator` function