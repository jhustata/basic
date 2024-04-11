qui {
	
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
	
	if 3 {
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
		
		// ask for the extension
		noi di " "
		noi di "Please enter the extension for the submissions", _request(ext_name)
		
		global ext_name : di strtrim("${ext_name}")
		
		if (strupper("${ext_name}") == "EXIT") {
			noi di " "
			noi di as error "Program Terminated"
			noi di in g " "
			exit
		}
		
		local do_list_helper : dir . files "`prefix'*${ext_name}"
		
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
	}
	
	if 4 {
		// read in each file
		
		// get the file handle name and read in to display each line
		foreach i in `do_list_helper' {
			noi di as error "Loading File Content For: ", _continue
			noi di in g "`i'"
			
			// get file handle name
			local pos = strpos("`i'", "${ext_name}") - 1
			local fh : di substr("`i'", 1, `pos')
			
			// read in file
			file open `fh' using "`i'", read write text
			
			// read in lines
			local line_count = 0
			file read `fh' line
			while (r(eof) == 0) {
				local line_count = `line_count' + 1
				noi di in g "Line `line_count':" _asis `" `macval(line)'"'
				file read `fh' line
			}
			noi di as error "File End Reached"
			noi di in g " "
			file close `fh'
		}
		
		noi di "All files have been read in!"
		
	}
}