qui {
	/*
	1. Kidney Transplant Recipient Data
	2. NHANES 1999-2000 Demographics Data  
	3. Homework 1 Textfile Data
	*/
	if 0 {
		cls
	    noi di "How many datasets are you going to use?" _request(N)
	    forvalues i=1/$N {
		    noi di "What is dataset `i'?" _request(data`i')
	    }
	    global repo "https://github.com/jhustata/basic/raw/main/"
	}	
	if $N {
        use $repo$data1, clear
		ds 
		foreach v of varlist `r(varlist)' {
			noi di "`v'"
		}
		levelsof dx, local(dxcat)
		foreach n of numlist `dxcat' {
			noi di `n'
		}
	}
}