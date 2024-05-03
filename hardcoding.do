qui {
	cls
	use ${repo}transplants, clear
    ds, not(type string)  
	global threshold 9  
	putexcel set levelsof, replace 
	local row=2
    foreach v of varlist age gender race { //`r(varlist)'
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			putexcel A`row' = ("`v'") B`row' = ("per")
			noi di  _col(1)    "`v'"  _col(30)  "per"
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			putexcel A`row' = ("`v', %") B`row' = ("")
			noi di   _col(1)   "`v', %" _col(30)   ""
			foreach l of numlist `numlevels' {
				local row = `row' + 1
                putexcel A`row' = ("    catlab") B`row' = ("per")
				noi di  _col(1)    "    catlab" _col(30)   "per"
			}	
	    }
	    else {  
			putexcel A`row' = ("`v'") B`row' = ("m_iqr")
			noi di   _col(1)   "`v'"  _col(30)  "m_iqr"
			local row = `row' + 1
	    }
		
    }
	
}
