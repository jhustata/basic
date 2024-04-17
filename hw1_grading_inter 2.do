qui { // hw1 grading
	
	if 1 {
		cls
		clear all
		set varabbrev on
		capture log close
	}
	
	if 2 {
		noi di as error "Current working directory: "
		noi di in g "`c(pwd)'"
		noi di " "
		noi di "Please hit enter to proceed or enter the new path to change directory"
		noi di "Enter exit to terminate", _request(path_c)
		
		if ("${path_c}" != "") {
			global path_c : di strtrim("${path_c}")
			
			if (strupper("${path_c}") == "EXIT") {
				noi di " "
				noi di as error "Program Terminated"
				noi di in g " "
				exit
			}
			
			// detect entered pathway
			if 1 {
				capture cd "${path_c}"
				while (_rc) {
					noi di " "
					noi di "You have entered an invalid path"
					noi di "Please check and re-enter", _request(path_c)
					
					if ("${path_c}" != "") {
						global path_c : di strtrim("${path_c}")
						
						if (strupper("${path_c}") == "EXIT") {
							noi di " "
							noi di as error "Program Terminated"
							noi di in g " "
							exit
						}
						
						capture cd "${path_c}"
					}
					else {
						global root : di "`c(pwd)'"
						capture cd "${root}"
					}
				}
				
				global root : di "${path_c}"
			}
		}
		else {
			global root : di "`c(pwd)'"
		}
		
		if ("`c(os)'" == "Windows") {
			global slash : di "\"
			global del : di "del"
		}
		else {
			global slash : di "/"
			global del : di "rm"
		}
		
		cd "${root}"
		if ("${path_c}" != "") {
			noi di "Working directory succesffuly changed to: "
			noi di "${root}"
			noi di " "
		}
	}
	
	if 3 { // get the do file list
		/*
		// remove all existing log files
		noi di " "
		noi di "All existing log files under current working directory will be removed"
		noi di "Please hit enter to proceed or enter anything to terminate program", _request(log_rm)
		
		if ("${log_rm}" != "") {
			noi di " "
			noi di "Program Terminated"
			noi di " "
			exit
		}
		
		
		shell ${del} *.log
		shell ${del} *.smcl
		shell ${del} *.txt
		*/
		// ask for the prefix
		noi di " "
		noi di "Please enter the name of this assignment on Courseplus drop box"
		noi di "(e.g.: Assignment 1)", _request(ass_name)
		
		global ass_name : di strtrim("${ass_name}")
		
		if (strupper("${ass_name}") == "EXIT") {
			noi di " "
			noi di as error "Program Terminated"
			noi di in g " "
			exit
		}
		
		local prefix : di subinstr("${ass_name}", " ", "", .)
		
		local do_list_helper : dir . files "`prefix'*.do"
		
		noi di " "
		noi di as error "Do file submissions in folder detected: "
		local count = 0
		foreach i in `do_list_helper' {
			noi di in g "`i'"
			local count = `count' + 1
		}
		local sub_total = `count'
		noi di "Total Counts: `count'"
		noi di " "
		
		noi di "Please hit enter to start running submissions"
		noi di "Enter exit to terminate", _request(proceed)
		global proceed : di strtrim("${proceed}")

		if (strupper("${proceed}") == "EXIT") {
			noi di " "
			noi di as error "Program Terminated"
			noi di " "
			exit
		}

		/*
		noi di "Please enter the dofile name for the solution dofile", _request(solu)
		
		global solu : di strtrim("${solu}")
		
		if (strupper("${solu}") == "EXIT") {
			noi di " "
			noi di as error "Program Terminated"
			noi di in g " "
			exit
		}
		
		noi do ${solu}, nostop
		noi di "Solution Log Created"
		
		noi di " "
		*/
		noi di "Running submissions: "
		
		// now we have answer log files
		// let's run actual submissions
		local sub_fail
		local timern = 0
		local times
		foreach i in `do_list_helper' {
			
			noi di as error "Running Do-file: `i'"
			// noi di "Continue?", _request(xxx)
			/*
			if (strupper("${xxx}") == "EXIT") {
				exit
			}
			*/
			local timern = `timern' + 1
			local time_total = 0
			forvalues j = 1/10 {
				timer clear `j'
				timer on `j'
				capture qui do "`i'"
				
				if (_rc) & (strpos("`sub_fail'", "`i'") == 0) {
					local sub_fail `sub_fail' `i'
				}
				timer off `j'
				
				qui timer list
				local time_total = `time_total' + `r(t`j')'
			}
			local times_avg = `time_total' / 10
			local times `times' `times_avg'
			noi di "Done"
			
		}
		
		noi di " "
		noi di "Below is the running time for each do-file:"
		local timern = 0
		foreach i in `do_list_helper' {
			qui tokenize `times'
			local timern = `timern' + 1
			noi di "`i': " "``timern''"
		}
		noi di as error "Outsdanding shorter running time without failure may indicate suspicious actions within submission."
		noi di as error "Based on internet speed, 0.1 difference may also be considered as outstanding."
		noi di in g " "
		noi di "These following do-files failed running simulation: "
		foreach i in `sub_fail' {
			noi di "`i'"
			doedit "`i'"
		}
		/*
		local logs : dir . files "*.log"
		local txts : dir . files "*.txt"
		local smcl : dir . files "*.smcl"
		
		noi di " "
		noi di "Log files created: "
		local count = 0
		noi di "In .log extension: "
		foreach i in `logs' {
			noi di "`i'"
			local count = `count' + 1
		}
		noi di " "
		noi di "In .txt extension: "
		foreach i in `txts' {
			noi di "`i'"
			local count = `count' + 1
		}
		noi di " "
		noi di "In .smcl extension: "
		foreach i in `smcl' {
			noi di "`i'"
			local count = `count' + 1
		}
		noi di "Total Log Counts: `count' - including the log for solution"
		noi di "(If log matches submissions, the total should be " (`sub_total' + 1) ")" 
		*/
		noi di " "
		noi di as error "Program Finished"
		noi di in g " "
	}
	
}