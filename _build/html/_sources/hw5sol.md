# HW5 Solution

There's no code to output `.xlsx`in the solution below:
   - But please use the lab 5 code for this
      - `putexcel` section [here](https://jhustata.github.io/basic/lab5.html#putexcel)
   - Also references the [HW3 solution](https://jhustata.github.io/basic/hw3sol.html)
   - Will get an optimal solution ASAP

```stata
qui {
	
	/*
   Adapted from 2023 HW1 solution
   */
	
	if 1 { //methods: macros, logfile, settings
	   global repo https://github.com/jhustata/basic/raw/main/
		noi di "What is your working directory?" _request(workdir)
      cd $workdir
		capture log close 
		log using "hw1.lastname.firstname.log", replace
		cls
		set more off
	}
	if 2 { //results: data, shape, etc.
		import delimited "${repo}hw1.txt", clear  		
	}
	if 3 { //conclusions: questions, code, output
		//q1
		capture program drop question1 
		program define question1
		    
			#delimit ; //use throughout program
		    qui { ; //line 1 quietly doesn't apply inside this program 
				
		        //label variables with output in mind
		        lab var init_age "Age, median [IQR]"; 
		        local age_lab: var lab init_age;
				
				lab var prev "Previous transplant, %" ; 
				local prev_lab: var lab prev; 
		
		        forvalues i=1/2 { ; //columns 1 & 2
			
			        count if !missing(dx) & female==`i'-1;
			
			        //row1
			        count if female==`i'-1;
			        local female`i'_N=r(N); 
	     		    local row1: di "Question 5" 
					      _col(30) "Males (N=`female1_N')" 
						  _col(50) "Females (N=`female2_N')"
					;
		    	    //row2
			        sum init_age if female==`i'-1, 
					    detail; //copy&paste from q2, edit
					
			        local m_iqr`i': di %2.0f r(p50) 
					              " [" %2.0f r(p25) 
								   "-" %2.0f r(p75) 
								   "]"  
			        ;
		            local row2: di "`age_lab'"  
					      _col(30) "`m_iqr1'"              
						  _col(50) "`m_iqr2'"

			        ;
					//row3
					sum prev if female==`i'-1 ;
					local per_prev`i': di %2.1f r(mean)*100 ;
					local row3: di "`prev_lab'"
					      _col(30) "`per_prev1'"
						  _col(50) "`per_prev2'"
					;
		        } ;

			    //rows4_13
		        split dx, p("=") ; //from chapter: delimit
		        destring dx1, replace ; 
		        lab var dx1 "Cause of ESRD, %" ;
 		 
		        local varlab: var lab dx1 ;
		
		        label def varlab
		            1 "Glomerular"
			        2 "Diabetes"
			        3 "PKD"
			        4 "Hypertensive"
			        5 "Renovascular"
			        6 "Congenital"
			        7 "Tubulo"
			        8 "Neoplasm"
			        9 "Other"
		        ;

		        lab values dx1 varlab;
				local row4: di "`varlab'"  ;
	     	    local vallab: value label dx1 
				 ; //debug: chatGPT moved this from line 137 to 152!!!
				 
				 forvalues i=1/2 { ; //columns 1 & 2
				
				    levelsof dx1 if female==`i'-1, 
					    local(diagnosis) ; //variable-level
			        global N_`i'=r(N) ;
					
		            local row=5 ; //based on Q5. template
				
			        foreach l of numlist `diagnosis' { ;
			
			            local dxcat: lab `vallab' `l' ; //alliterative
			            sum dx1 if dx1==`l' & female==(`i'-1) ;
			            local col_`i'_`row': di %2.1f r(N)*100/${N_`i'} ;
					
					    //indent the lab `dxcat' 
		                local row`row': di "    `dxcat'" 
						          _col(30) "`col_1_`row''" 
								  _col(50) "`col_2_`row''" 
								  ;
		                local row = `row' + 1 ; //tracks rows 5-13

		            } ;
			
		         } ;
				
			     forvalues i=1/13 { ; //rows1-13
				 	
					noi di "`row`i''";  
					
				 } ;
				 
      
	        } ; 
	   
	    #delimit cr
	    end 
		
		noi question1
		
		//q6
		
		logistic received_kt init_age female
		matrix define m=r(table)
		
		//row1 
		noi di ""
		noi di "Question 6"
		
		//row2 
		local row2: di "Variable" _col(30) "OR" _col(35) "(95% CI)"
		noi di "`row2'"
		
		//rows3-4
		lab var init_age "Age"
		local age_lab: var lab init_age 
		
		lab var female "Female"
		local female_lab: var lab female 
		
		local row=3
		local col=1
		foreach v of varlist init_age female {
			
			local `v'_lab: var lab `v'
			
			#delimit ;
			local row`col': di "``v'_lab'" %3.2f _col(30) m[1,`col'] 
			                               %3.2f _col(35) 
									   "(" %3.2f          m[5,`col'] 
									   "-" %3.2f          m[6,`col'] 
									   ")"
			;
			#delimit cr
			//noi di "`row`num''"
			
			local row=`row' + 1
			local col=`col' + 1

		}
		
		noi di "`row1'"
		noi di "`row2'"
		noi di ""
		
		//Not part of Homework, But nice for discussion during labs	
		noi di "This regression included `e(N)' observations whereas the study dataset has `c(N)' observations in total."
		noi di ""
		
	
	}
			
	log close
	
}
```