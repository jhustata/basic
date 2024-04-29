capture program drop nhanes_demo
program define nhanes_demo
    syntax, begin(int) end(int)
    qui {
        cls
        clear 
        set timeout1 1000
        global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"
        tokenize "`c(ALPHA)'"
        local y = `begin' //edit
		local N = `end' - `begin' //insertion
        forvalues i=1/`N' { //edit
            local yp1 = `y' + 1
            if `y' == 1999 {
                local letter = ""
            }
            else {
                local letter = "_``i''"
            }
            import sasxport5 "${nhanes}`y'-`yp1'/DEMO`letter'.XPT", clear
            //tempfile nh`y'_`yp1'
            gen surv = "`i'"
            save nh`y'_`yp1', replace 
            noi di "`letter'"
            local y = `y' + 2
        }
        local y = `begin'
		clear //insertion
        forvalues i=1/`N' {
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
end
