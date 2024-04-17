```stata
qui {
	if 0 { //Background
		1. do-file structure
		2. control of output
		3. indentation
	}
	if 1 { //Methods
	    cls 
		capture log close
		log using filename.log, replace 
		set more off
		global url
		global path
		global data
	}
	if 2 { //Analysis
		import delimited ${path}${data}, clear 
	}
	if 3 { //Results
		
	}
	log close 
}