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