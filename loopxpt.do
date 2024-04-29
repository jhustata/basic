qui {
	cls
    clear 
    set timeout1 1000
    global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"
    tokenize "`c(ALPHA)'"
	local y = 1999
    forvalues i=1/3 {
		local yp1 = `y' + 1
	    if `y' == 1999 {
		    local letter = ""
	    }
	    else {
		    local letter = "_``i''"
	    }
	    import sasxport5 "${nhanes}`y'-`yp1'/DEMO`letter'.XPT", clear
		//tempfile nh`y'_`yp1'
		g surv = "`i'"
		save nh`y'_`yp1', replace 
	    noi di "`letter'"
		local y = `y' + 2
    }
	local y = 1999
	forvalues i=1/3 {
		local yp1 = `y' + 1
		append using nh`y'_`yp1' 
		rm "nh`y'_`yp1'.dta"
		local y = `y' + 2
	}
	save nh, replace 
	//verify at https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.htm
	noi tab surv 
	noi ls	
}
