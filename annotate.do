quietly {
	/*
    1. Picture a scenario in which the codebook of dataset is "unavailable"
    2. It's perhaps too complex and you're not sure the dataset is worth your time
	3. Example: https://wwwn.cdc.gov/nchs/data/nhanes3/1a/ADULT-acc.pdf
	4. How may you quickly review this dataset to look for potential variables of interest?
	5. This script is dedicated to demonstrating a simple approach
	*/
	cls
	global repo "https://github.com/jhustata/basic/raw/main/"
	noi di "Your task is to annotate this script to clarify what it does"
	noi di "What is your working directory?" _request(workdir)
	if "$workdir" == "" {
		noi di as err "You've not defined a working directory"
		exit 340600
	}
	else {
		cd "$workdir"
		capture log close 
		log using annotate.log, replace 
		clear 
		set obs 10
		g id=_n
		save workdir.dta, replace 
		capture confirm file workdir.dta
		rm workdir.dta
		if _rc == 0 {
			noi di "Thanks, working directory confirmed as $workdir"
			noi ls -l 
		}
		else {
			noi di as err `"$workdir not found. Type "pwd" to confirm this"'
			exit 340700
		}
	}
	foreach v in nh3 adult {
		do ${repo}`v'.do
	}
	log close 
}

