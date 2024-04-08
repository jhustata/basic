qui {
    if 0 { //Background
		1. Propensity Score Matching
		2. Logistic regression for the scores
		3. Customized .ado program for matching
	}
	noi di "Need some help with the syntax for this command? (Yes, No)" _request(helps)
	global helps: di "$help"
	if "$helps" == "Yes"  { //Settings
	   cls
	   clear
	   capture log close
	   log using match.log, replace
	   noi di "What is the path to your table1.ado?" _request(table1)
	   global table1: di "$table1"
	   noi di "Do you have a matching algorithm?" _request(match)
	   global match: di "match"
	   noi di "What dataset are you going to use?" _request(tx)
	   global tx: di "tx"
	   noi di "What is your working directory?" _request(path) 
	   global path: di "$path"
	}
	else {
	   cls
	   clear
	   capture log close
	   log using match.log, replace
	   global table1: di "https://raw.githubusercontent.com/jhustata/basic/main/table1_fena.ado"
	   global match: di "https://raw.githubusercontent.com/jhustata/basic/main/irmatch.ado"
	   global tx: di "https://jhustata.github.io/basic/_downloads/34a8255f06036b44354b3c36c5583d7e/transplants.dta"
	   noi di "What is your working directory?" _request(path) 
	   global path: di "$path"	
	}
	if 2 { //Data
		cd $path
		use $tx, clear
		save tx, replace 
	}
	if 3 { //Propensity
		ds
		logit prev_ki age i.race bmi wait_yrs peak_pra i.abo gender i.dx 
		predict pr, p
		twoway scatter pr prev_ki, jitter(5) msize(.5)
	}
	if 4 { //Matching
		capture do $match
		capture rm tx_match.dta
		noi irmatch pr(0(.1)1) using tx_match, case(prev_ki) id(fake_id) k(4) seed(340600) without 
		use tx_match, clear
		noi list in 1/10
		preserve 
		   keep fake_id*
		   noi list in 1/10
		   codebook 
		   keep fake_id_case
		   rename fake_id_case fake_id
		   merge m:1 fake_id using $tx, keep(matched)
		   save matched_cases, replace 
		restore 
		keep fake_id*
		noi list in 1/10
		codebook 
		keep fake_id_ctrl
		rename fake_id_ctrl fake_id
		merge 1:1 fake_id using $tx, keep(matched)
		save matched_controls, replace 
	}
	if 5 { //Inspect
		use matched_cases, clear
		g case=1
		append using matched_controls
		replace case=0 if missing(case)
		noi tab case
		do $table1
		table1_fena, ///
		   var("case age race bmi wait_yrs peak_pra abo gender dx") ///
		   by(prev_ki) title("Inspect Matching Performance") ///
		   excel("Table0") ///
		   catt(6) ///
		   missingness
	}
	log close
}
