# Question 1 (Detailed)

For quick review of solutions to HW 5 please see:
- [Basic level](hw5sol.md)
- [Intermediate level](hw5_sol_intermediate.md)
- [Advanced level](hw5_sol_advanced.md)

But a stepwise discussion of the solution to `Question 1`, lets systemmatically walk through these 20-steps:

# 1
Let's use datasets from our class repo
```stata
global repo https://github.com/jhustata/basic/raw/main
```
# 2
Import the data 
```stata
use ${repo}/transplants.dta, clear
```

- All URLs using forward slashes `/` for remote directory paths
- Operating systems other than Windows also use `/` for local directory paths 
- Windows OS uses `\` for local directory filepaths
- This matters when a macro in your script only points to a directory
   - You datasets of interest might be in a subdirectory that you need to specificy

# 3
Exclude strings for now, to keep it simple
```stata
ds, not(type string) 
return list  
```
# 4
Now loop over all the variables in the dataset, except those with string values:
```stata
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
    }	
```
# 5
The above loop creates a macro `numlevels` that quantifies the number of levels in variable. For instance, a binary variable in the dataset like gender (0=Male, 1=Female) has two levels
```stata
levelsof gender
return list 
```
- Please recognize the return value `r(r)` from the above command
- We'll use this macro to automate the process of distinguishing among binary, multicategory and continuous variables

# 6
You can now compare that to `levelsof bmi`, or `levelsof wait_yrs`.

# 7
In this dataset, `levelsof extended_dgn` is of interest, if we wish to write an algorithm that helps the user classify variables as "continuous", "binary", or "multicategory" for the purpose of reporting in Table 1. A trial-and-error process will lead to an optimal threshold:

```stata
	cls
	ds
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    qui levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di "`v' binary"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di "`v' multicat"
	    }
	    else {  
			noi di "`v' continuous"
	    }
    }
```
- How accurate is our algorithm at classifying the variables in the dataset?
- Is `extended_dgn` correctly classified?

```stata
tab extended_dgn
codebook extended_dgn 
```

- So in our next iteration, lets exclude `extended_dgn`
- It has 133 categories or levels
- This will not do for Table 1 without "collapsing" into broader categories
- `dx` is the collapsed version of this variable

# 8
Now that our algorith can classify most of the variables accurately, lets "hardcode" into our script some results outputted into an `.xlsx` file. Then gradually we can replace each "hardcoding" with a macro:

Remember, the statistics we traditionally report depend on the variable type:
- Continuous: `median [IQR]`
- Binary: `%` of one of the categories (the other can be imputed)
- Multicategory: `%` of each category and they should all sum to 100%

# 10
```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di _col(1) "`v'" _col(30) "percent"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			foreach l of numlist `numlevels' {
				noi di _col(1) "`v'" _col(30) "percent"
			}	
	    }
	    else {  
			noi di _col(1) "`v'" _col(30) "m_iqr"
	    }
		
    }
	
}
```

The geneeral structure of our Table 1 looks neat. But lets indent the `levelsof` the categorical variable:

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di _col(1) "`v'" _col(30) "percent"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			foreach l of numlist `numlevels' {
				noi di _col(1) "   `v'" _col(30) "percent" //see indentation
			}	
	    }
	    else {  
			noi di _col(1) "`v'" _col(30) "m_iqr"
	    }
		
    }
	
}
```

Now lets include the name of the categorical variable before the indentation of the `levelsof` that variable. This should **not** be part of the `foreach l of numlist` loop, but it should be within the `else if inrange` conditional block:

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di _col(1) "`v'" _col(30) "percent"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`v', %" //multicat variable name
			foreach l of numlist `numlevels' {
				noi di _col(1) "   `v'" _col(30) "percent" //levelsof indentation
			}	
	    }
	    else {  
			noi di _col(1) "`v'" _col(30) "m_iqr"
	    }
		
    }
	
}
```

# 11

Notice in this "hardcoding" the categorical variable name and its levels are identical. Let's replace the `levelsof` with the correct term: `l` vs. `v`

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di _col(1) "`v'" _col(30) "percent"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`v', %" //multicat variable name
			foreach l of numlist `numlevels' {
				noi di _col(1) "   `l'" _col(30) "percent" //levelsof indentation
			}	
	    }
	    else {  
			noi di _col(1) "`v'" _col(30) "m_iqr"
	    }
		
    }
	
}
```


# 12

So its now time to replace the "hardcoded" `percent` and `m_iqr` with appropropriate macros

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v'
			local percent: di %3.1f r(mean) 
			noi di _col(1) "`v'" _col(30) "`percent'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`v', %" //multicat variable name
			foreach l of numlist `numlevels' {
				sum `v'
				local percent: di %3.1f r(mean) 
				noi di _col(1) "   `l'" _col(30) "`percent'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v', detail 
			local m_iqr: di %2.0f r(p50) "[" %2.0f r(p25) "-" %2.0f r(p75) "]"
			noi di _col(1) "`v'" _col(30) "`m_iqr'"
	    }
		
    }
	
}
```

The estimates for continuous variables and binary variable seem ok; however, categorical variables are of a uniform % across `levelsof` the variable. More work is needed!

```stata
tab prev_ki
tab gender
sum age, detail
tab rec_education
```

# 13

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v'
			local percent: di %3.1f r(mean) 
			noi di _col(1) "`v'" _col(30) "`percent'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`v', %" //multicat variable name
			foreach l of numlist `numlevels' {
				count if !missing(`v')
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den = r(N)
				count if `v' == `l'
				local num = r(N)
				local percent: di %2.0f `num'*100/`den'
				noi di _col(1) "   `l'" _col(30) "`percent'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v', detail 
			local m_iqr: di %2.0f r(p50) "[" %2.0f r(p25) "-" %2.0f r(p75) "]"
			noi di _col(1) "`v'" _col(30) "`m_iqr'"
	    }
		
    }
	
}
```

Do our calculations match those by Stata? Let compare using one categorical variable:

```stata
tab rec_education
```

# 14

Now lets replace variable names with variable labels to look more publication-worthy:

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
		/* note where we insert this */
		local varlab: var lab `v' //this is all we inserted
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v'
			local percent: di %3.1f r(mean) 
			noi di _col(1) "`varlab'" _col(30) "`percent'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				count if !missing(`v')
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den = r(N)
				count if `v' == `l'
				local num = r(N)
				local percent: di %2.0f `num'*100/`den'
				noi di _col(1) "   `l'" _col(30) "`percent'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v', detail 
			local m_iqr: di %2.0f r(p50) "[" %2.0f r(p25) "-" %2.0f r(p75) "]"
			noi di _col(1) "`varlab'" _col(30) "`m_iqr'"
	    }
		
    }
	
}
```

In the above script we replace all the variable names `v` with the variable labels `varlab` to produce a more aesthetic output. But now lets do some more:
1. Move the column further from `_col(30)` to `_col(50)` to minimize overlap with `varlab`
2. Create space in `p50[p25-p75]` so that it looks like `p50 [p25-p75`] 
3. Replace `levelsof` `numlevels` with the appropriate labels

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
		/* note where we insert this */
		local varlab: var lab `v'
		
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v'
			local percent: di %3.1f r(mean) 
			noi di _col(1) "`varlab'" _col(50) "`percent'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v')
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den = r(N)
				count if `v' == `l'
				local num = r(N)
				local percent: di %2.0f `num'*100/`den'
				noi di _col(1) "   `catlab'" _col(50) "`percent'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v', detail 
			local m_iqr: di %2.0f r(p50) "[" %2.0f r(p25) "-" %2.0f r(p75) "]"
			noi di _col(1) "`varlab'" _col(50) "`m_iqr'"
	    }
		
    }
	
}
```

# 15 

Next, lets stratify our output by gender. First, by hardcoding:
```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
		/* note where we insert this */
		local varlab: var lab `v'
		
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v'
			local percent: di %3.1f r(mean) 
			noi di _col(1) "`varlab'" _col(50) "`percent'" _col(70) "`percent'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v')
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den = r(N)
				count if `v' == `l'
				local num = r(N)
				local percent: di %2.0f `num'*100/`den'
				noi di _col(1) "   `catlab'" _col(50) "`percent'" _col(70) "`percent'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v', detail 
			local m_iqr: di %2.0f r(p50) "[" %2.0f r(p25) "-" %2.0f r(p75) "]"
			noi di _col(1) "`varlab'" _col(50) "`m_iqr'" _col(70) "`m_iqr'"
	    }
		
    }
	
}
```
- All I did was add a `_col(70)` duplicate of what was in `_col(50)`
- Next we use `if gender==` conditional statments to get appropriate output

# 16 

```stata
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
		/* note where we insert this */
		local varlab: var lab `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v' if gender==0 
			local percent_0: di %3.1f r(mean) 
			sum `v' if gender==1
			local percent_1: di %3.1f r(mean) 
			noi di _col(1) "`varlab'" _col(50) "`percent_0'" _col(70) "`percent_1'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v') & gender==0
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den_0 = r(N)
				count if `v' == `l' & gender==0
				local num_0 = r(N)
				local percent_0: di %2.0f `num_0'*100/`den_0'
				count if !missing(`v') & gender==1
                local den_1 = r(N)
				count if `v' == `l' & gender==1
				local num_1 = r(N)
				local percent_1: di %2.0f `num_1'*100/`den_1'
				noi di _col(1) "   `catlab'" _col(50) "`percent_0'" _col(70) "`percent_1'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v' if gender==0, detail 
			local m_iqr_0: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			sum `v' if gender==1, detail 
			local m_iqr_1: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			noi di _col(1) "`varlab'" _col(50) "`m_iqr_0'" _col(70) "`m_iqr_1'"
	    }
		
    }
	
}

```

# 17 
You may have noted some meaningless output such as the `median [IQR]` of `fake_id`, `center_id`, or even `transplant_date`. Now let's empower the user to select meaningful variables that will appear in Table (and in the order requested). 

```stata
capture program drop table1_hw5
program define table1_flexible
    syntax varlist
    //copy & paste the above here & ask ChatGPT to help indent the code
	//or do it yourself
end 
```

Here's the table1_hw5 program

```stata

capture program drop table1_hw5
program define table1_hw5
syntax varlist, by(varname) threshold(int)
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `varlist'  { //`r(varlist)'
		/* note where we insert this */
		local varlab: var lab `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v' if `by'==0 
			local percent_0: di %3.1f r(mean) 
			sum `v' if `by'==1
			local percent_1: di %3.1f r(mean) 
			tab `v'
			noi di _col(1) "`varlab'" _col(50) "`percent_0'" _col(70) "`percent_1'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v') & `by'==0
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den_0 = r(N)
				count if `v' == `l' & `by'==0
				local num_0 = r(N)
				local percent_0: di %2.0f `num_0'*100/`den_0'
				count if !missing(`v') & `by'==1
                local den_1 = r(N)
				count if `v' == `l' & `by'==1
				local num_1 = r(N)
				local percent_1: di %2.0f `num_1'*100/`den_1'
				noi di _col(1) "   `catlab'" _col(50) "`percent_0'" _col(70) "`percent_1'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v' if `by'==0, detail 
			local m_iqr_0: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			sum `v' if `by'==1, detail 
			local m_iqr_1: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			noi di _col(1) "`varlab'" _col(50) "`m_iqr_0'" _col(70) "`m_iqr_1'"
	    }
		
    }
	
}
end 
table1_hw5 age prev_ki dx, by(gender) threshold(9)

```

key points:
- `syntax varlist`
- `foreach v of varlist`

How would you further adapt this program to:
- Ask the user what specific variable should be used to stratify?
   - For now it stratifies by gender
   - Hint: `syntax varlist, by(varname)`
   - Replace `gender` with the local macro `by` throughout the program; that simple!

And how would you adapt the program to:
- Allow the user to choose the arbitrary "threshold" to distinguish continuous from multicategory variables?
   - It's been set to "9" throughout the examples
   - Hint: `syntax varlist, by(name) threshold(int 9)`
   - Replace `global threshold 9` with:
   ```stata
   global threshold `threshold'
   ```

And how would you further adapt it to include a third column with a p-value answering the hypothesis: the statistic in column 1 is significantly different from the one in column 2?

You may choose the statistic you wish to deploy. A common one is $\chi^2$:

```stata
capture program drop table1_flexible
program define table1_flexible
    syntax varlist
    //copy & paste the above here & ask ChatGPT to help indent the code
	//or do it yourself
end 
```



```stata
capture program drop table1_hw5
program define table1_hw5
syntax varlist, by(varname) threshold(int 9)
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `varlist'  { //`r(varlist)'
		/* note where we insert this */
		local varlab: var lab `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v' if `by'==0 
			local percent_0: di %3.1f r(mean) 
			sum `v' if gender==1
			local percent_1: di %3.1f r(mean) 
			tab 
			noi di _col(1) "`varlab'" _col(50) "`percent_0'" _col(70) "`percent_1'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di _col(1) "`varlab', %" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v') & gender==0
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den_0 = r(N)
				count if `v' == `l' & gender==0
				local num_0 = r(N)
				local percent_0: di %2.0f `num_0'*100/`den_0'
				count if !missing(`v') & gender==1
                local den_1 = r(N)
				count if `v' == `l' & gender==1
				local num_1 = r(N)
				local percent_1: di %2.0f `num_1'*100/`den_1'
				noi di _col(1) "   `catlab'" _col(50) "`percent_0'" _col(70) "`percent_1'" //levelsof indentation
			}	
	    }
	    else {  
			sum `v' if gender==0, detail 
			local m_iqr_0: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			sum `v' if gender==1, detail 
			local m_iqr_1: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			noi di _col(1) "`varlab'" _col(50) "`m_iqr_0'" _col(70) "`m_iqr_1'"
	    }
		
    }
	
}
end 
table1_hw5 age prev dx

We only [cursorily mentioned](https://jhustata.github.io/basic/chapter2.html#combining-everything) p-values in week 2:

```stata

    if r(p) < 0.01 {
       local p: di "p < 0.01"
    }
    else if inrange(r(p),0.01,0.05) {
       local p: di %3.2f r(p)
    }
    else {
       local p: di %2.1f r(p)
    }
    noi di "p = `p'"

```

# 18

Let's include a p-value column

```stata

capture program drop table1_hw5
program define table1_hw5
syntax varlist, by(varname) threshold(int)
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `varlist'  { //`r(varlist)'
		/* note where we insert this */
		local varlab: var lab `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v' if `by'==0 
			local percent_0: di %3.1f r(mean) 
			sum `v' if `by'==1
			local percent_1: di %3.1f r(mean) 
			tab `v' `by', chi
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab'" _col(50) "`percent_0'" _col(70) "`percent_1'" _col(90) "`p'"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			/* -- I moved the output for variable name to align with p-value-- */
			tab `v' `by', chi //for categorical we test for nx1 chi-square
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab', %" _col(90) "`p'" //multicat variable name
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v') & `by'==0
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den_0 = r(N)
				count if `v' == `l' & `by'==0
				local num_0 = r(N)
				local percent_0: di %2.0f `num_0'*100/`den_0'
				count if !missing(`v') & `by'==1
                local den_1 = r(N)
				count if `v' == `l' & `by'==1
				local num_1 = r(N)
				local percent_1: di %2.0f `num_1'*100/`den_1'	
				noi di _col(1) "   `catlab'" _col(50) "`percent_0'" _col(70) "`percent_1'"
			}	
	    }
	    else {  
			sum `v' if `by'==0, detail 
			local m_iqr_0: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			sum `v' if `by'==1, detail 
			local m_iqr_1: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			regress `by' `v'
			lincom `v'
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab'" _col(50) "`m_iqr_0'" _col(70) "`m_iqr_1'" _col(90) "`p'"
	    }
		
    }
	
}
end 
table1_hw5 age prev_ki dx, by(gender) threshold(9)
```

# 19

We can now export this tidy output to excel

```stata

capture program drop table1_hw5
program define table1_hw5
syntax varlist, by(varname) threshold(int)
qui {
	cls
	ds, not(type string)
	global threshold 9 //for multicat vs. continuous
	/*--first putexcel statement --*/
	putexcel set table1_hw5, replace 
	putexcel A1 = "Table 1. Demographic and Clinical Characteristics of Transplant Recipients"
	count if `by'==0
	local N0 = r(N)
	count if `by'==1
	local N1 = r(N)
	putexcel B2 = "N=`N0'"
	putexcel C2 = "N=`N1'"
	putexcel D2 = "P-value"
	local row = 3
    foreach v of varlist `varlist'  { //`r(varlist)'
		/* note where we insert this */
		local varlab: var lab `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 { 
			sum `v' if `by'==0 
			local percent_0: di %3.1f r(mean) 
			sum `v' if `by'==1
			local percent_1: di %3.1f r(mean) 
			tab `v' `by', chi
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab'" _col(50) "`percent_0'" _col(70) "`percent_1'" _col(90) "`p'"
			putexcel A`row' = "`varlab'" B`row' = "`percent_0'" C`row' = "`percent_1'" D`row' =  "`p'"
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			/* -- I moved the output for variable name to align with p-value-- */
			tab `v' `by', chi //for categorical we test for nx1 chi-square
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab', %" _col(90) "`p'" //multicat variable name
			putexcel A`row' = "`varlab', %" B`row' = "" C`row' = "" D`row' =  "`p'"
			local row = `row' + 1
			
			foreach l of numlist `numlevels' {
				/* two step process for multicat labels
				   1. value label, e.g. 0, 1, 2
				   2. category label , e.g. white, black, Hispanic
				*/
				local vallab: value label `v'
				local catlab: lab `vallab' `l'
				count if !missing(`v') & `by'==0
				/* manually calculated % for each level:
				   1. denominator first
				   2. numerator next
				   3. and the fraction as perfect, formatted
				*/
				local den_0 = r(N)
				count if `v' == `l' & `by'==0
				local num_0 = r(N)
				local percent_0: di %2.0f `num_0'*100/`den_0'
				count if !missing(`v') & `by'==1
                local den_1 = r(N)
				count if `v' == `l' & `by'==1
				local num_1 = r(N)
				local percent_1: di %2.0f `num_1'*100/`den_1'	
				noi di _col(1) "   `catlab'" _col(50) "`percent_0'" _col(70) "`percent_1'"
				putexcel A`row' = "    `catlab'" B`row' = "`percent_0'" C`row' = "`percent_1'"  
				local row = `row' + 1
			}	
	    }
	    else {  
			sum `v' if `by'==0, detail 
			local m_iqr_0: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			sum `v' if `by'==1, detail 
			local m_iqr_1: di %2.1f r(p50) "[" %2.1f r(p25) "-" %2.1f r(p75) "]"
			regress `by' `v'
			lincom `v'
			if r(p) < 0.01 {
                local p: di "p < 0.01"
            }
            else if inrange(r(p),0.01,0.05) {
                local p: di %3.2f r(p)
            }
            else {
                local p: di %2.1f r(p)
            }
			noi di _col(1) "`varlab'" _col(50) "`m_iqr_0'" _col(70) "`m_iqr_1'" _col(90) "`p'"
			putexcel A`row' = "`varlab'" B`row' = "`m_iqr_0'" C`row' = "`m_iqr_1'" D`row' =  "`p'"
			local row = `row' + 1
	    }
		
    }
	
}
end 
table1_hw5 age prev_ki dx, by(gender) threshold(9)
ls //confirm that your .xlsx file has been formed
```
 
# 20

We're done! Of course you may improve the labels of your variable to achieve the Table 1 output of your interest. You'll need to label the variables prior to running this program