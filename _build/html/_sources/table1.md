# Table 1 tips

# 1
Let's use datasets from our class repo
```stata
global repo https://github.com/jhustata/basic/raw/main
```
# 2
Import the data
```stata
use ${repo}transplants.dta, clear 
```
# 3
Exclude strings for now, to keep it simple
```stata
ds, not(type string)  
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
```
# 6
You can now compare that to `levelsof bmi`, or `levelsof wait_yrs`.

# 7
In this dataset, `levelsof extended_dgn` is of interest, if we wish to write an algorith that helps the user classify variables as "continuous", "binary", or "multicategory" for the purpose of reporting in Table 1. A trial-and-error process will lead to an optimal threshold:

```stata
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
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

# 8
Lets "hardcode" into our script some results outputted into an `.xlsx` file. Then gradually we can replace each "hardcoding" with a macro:

```stata
qui {
	cls
	use ${repo}transplants, clear
    ds, not(type string)  
	global threshold 9  
	putexcel set levelsof, replace 
	local row=2
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			putexcel A`row' = ("`v'") B`row' = ("per")
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			putexcel A`row' = ("`v', %") B`row' = ("")
			foreach l of numlist `numlevels' {
				local row = `row' + 1
                putexcel A`row' = ("    catlab") B`row' = ("per") 
			}	
	    }
	    else {  
			putexcel A`row' = ("`v'") B`row' = ("m_iqr")
			local row = `row' + 1
	    }
		
    }
	
}
```

# 9 
You may have noted some meaningless output such as the `median [IQR]` of `fake_id`, `center_id`, or even `transplant_date`. Now let's empower the user to select meaningful variables that will appear in Table (and in the order requested). 

```stata
capture program drop table1_flexible
program define table1_flexible
    syntax varlist
    //copy & paste the above here & ask ChatGPT to help indent the code
	//or do it yourself
end 
```

Here's the indented code courtesy of GPT-4:

```stata
capture program drop table1_flexible
program define table1_flexible
    syntax varlist 
    qui {
	cls
	//use ${repo}transplants, clear //the program should work with any dataset
    ds, not(type string)  
	global threshold 9  
	putexcel set levelsof, replace 
	local row=2
    foreach v of varlist `varlist' { //replaced `r(varlist)' with `varlist'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			putexcel A`row' = ("`v'") B`row' = ("per")
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			putexcel A`row' = ("`v', %") B`row' = ("")
			foreach l of numlist `numlevels' {
				local row = `row' + 1
                putexcel A`row' = ("    catlab") B`row' = ("per") 
			}	
	    }
	    else {  
			putexcel A`row' = ("`v'") B`row' = ("m_iqr") //expand to "C`row' = ("pvalue")
			local row = `row' + 1
	    }
		
    }
	
}
end
```

How would you adapt this program to create a Table 1 that is stratified by some other variable, say, sex/gender?

And how would you further adapt it to include a third column with a p-value answering the hypothesis: the statistic in column 1 is significantly different from the one in column 2?

You may choose the statistic you wish to deploy. A common one is $\chi^2$:

```stata
use ${repo}transplants, clear
tab prev gender, chi
di r(p) 
```

Or you could use regression:

```stata
regress age gender
lincom gender
di r(p)
```

These p-values could be included in your loops as we only [cursorily mentioned](https://jhustata.github.io/basic/chapter2.html#combining-everything) in week 2:

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

putexcel A`row' = ("`v'") B`row' = ("m_iqr") C`row' = ("p")
```

# 10

# 11

# 12

The script below is our ultimate destination. But how do we gradually build our script until we get there?

```stata
qui {
	cls
	use ${repo}transplants, clear
    ds, not(type string) //otherwise, extended diagnosis is continuous! 
	global threshold 9 //for multicat vs. continuous
	putexcel set levelsof, replace 
	local row=2
    foreach v of varlist `r(varlist)' {
		local varlab: var lab `v'
		local vallab: value label `v'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di "`v' binary"
			sum `v'
			local per: di %3.1f r(mean)*100
			putexcel A`row' = ("`varlab'") B`row' = (`per')
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di "`v' multicat"
			putexcel A`row' = ("`varlab', %") B`row' = ("")
			foreach l of numlist `numlevels' {
			    local row = `row' + 1
			    count if `v' == `l'
				local num=r(N)
				count if !missing(`v')
				local den=r(N)
				local per: di %3.1f `num'*100/`den'
				local catlab: lab `vallab' `l'
                putexcel A`row' = ("    `catlab'") B`row' = (`per')
			}	
	    }
	    else {  
			noi di "`v' continuous"
			sum `v', detail
			local m_iqr: di %2.0f r(p50) "[" di %2.0f r(p25) "-" di %2.0f r(p75) "]" 
			putexcel A`row' = ("`varlab'") B`row' = ("`m_iqr'")
			local row = `row' + 1
	    }
		
    }
	
}
```

 