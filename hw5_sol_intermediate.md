# HW5 Solution (Intermediate)

The focus here is not on the exact response to the homework question. [This script](https://github.com/jhustata/basic/raw/main/table1.do) offers something more general

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

[Here](table1.md) are some additional notes that break-down the process of building this script