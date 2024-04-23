# HW3  

### Solution to HW3

```stata
quietly { 
	cls
	if 0 { //background, purpose. 
		1. HW3 solution
		2. One approach among many
	}
	if 1 { //methods, log, settings, data              
        clear 
		capture log close           
        log using "hw3.lastname.firstname.log", replace          
        set more off          
		//by default, stata times-out at 30 seconds
		//increase if internet is slow, and dataset remote
		set timeout1 1000                      
		//ambiguity of filepaths is a hallmark of collaboration
		//lets set up the paths for local and remote data access
        local local_path "/users/d/downloads/hw1.txt" //change to whatever suits you
		global path "https://github.com/jhustata/basic/raw/main/hw1.txt" //URL or filepath  
        //check if the local file exists
		capture confirm file "`local_path'"
        if _rc == 0 {
           * if the local file exists, use the local path
           global path "`local_path'"
        }
        else {
           * if the local file does not exist, fall back to the URL
           global path "${path}"
        }

        * now proceed to import the data using the defined path
        import delimited "${path}", clear

	}
    if 2 { //results, Q1
        gen htn = dx == "4=Hypertensive"
        replace htn = 0 if missing(htn)
        
        // Label values for hypertension
        label define htn_lab 0 "No" 1 "Yes"
        label values htn htn_lab 
        noi tab htn
		
		// create space between Q1 & Q2
		noi di "" 
		noi di ""
		noi di ""
    }
	if 3 { //results, Q2
		//capture program drop q2
		//program define q2
		   //.xlsx output
		   putexcel set question2, replace 
		   
		   //labels
		   label variable init_age "Age, median (IQR)"
		   label variable prev "Previous transplant, %"
		   
		   //label macros 
		   local agelab: variable label init_age
		   local prevlab: variable label prev 
			  
		   local start_row = 1 //tracking .xlsx output
		   forvalues i = 0/1 {
		   	   
			   //+5 points: for innovative use of loops to avoid repetition
			   //0=Males, 1=Females 
		       //row 1
			   count if female==`i'  
		       local female`i'_n=r(N)
		   
		       //row2
			   sum init_age if female==`i', detail
		       local female`i'_age_p50: di %2.0f r(p50)
		       local female`i'_age_p25: di %2.0f r(p25)
		       local female`i'_age_p75: di %2.0f r(p75)

		       //row3
		       sum prev if female==`i' //Maya debugged this!!
		       local female`i'_prev: di %2.1f r(mean)*100
			   
			             // Output for males and females, assuming they start from row 1
                putexcel A`start_row' = "Question 2" ///
                   B`start_row' = "Males (N=`female0_n')" ///
                   C`start_row' = "Females (N=`female1_n')"

                local age_label = "Age, median (IQR)"
                local age_row = `start_row' + 1 // This will be row 2
                putexcel A`age_row' = "`age_label'" ///
                   B`age_row' = "`female0_age_p50' (`female0_age_p25' - `female0_age_p75')" ///
                   C`age_row' = "`female1_age_p50' (`female1_age_p25' - `female1_age_p75')"

                local prev_label = "Previous transplant, %"
                local prev_row = `age_row' + 1 // This will be row 3
                putexcel A`prev_row' = "`prev_label'" ///
                   B`prev_row' = "`female0_prev'" ///
                   C`prev_row' = "`female1_prev'" 
			 
		   }   
		   
		   
		   //align output for .log file using "_col()"
		    local row1: di "Question 2" ///
		      _col(30) "Males (N=`female0_n')" ///
		      _col(60) "Females (N=`female1_n')"
		   local row2: di "`agelab'"   ///
		      _col(30) "`female0_age_p50' (`female0_age_p25' - `female0_age_p75')" ///
		      _col(60) "`female1_age_p50' (`female1_age_p25' - `female1_age_p75')"
		   local row3: di "`prevlab'"  ///
		      _col(30) "`female0_prev'" ///
			  _col(60) "`female1_prev'"
		   local excel_row=1
		   
	   
		   forvalues i=1/3 {
		      
			  //.log file
			  noi di "`row`i''"	

	       }
 
	}	   
	
	
	log close 
    
	// Restore initial settings
    set more on
	set timeout1 30
}
```

### Annotated Explanation of the HW3 Solution Script

The script is structured to manage data import and analysis with attention to potential variations in file locations and to perform detailed statistical analysis. Here’s a breakdown with annotations to help you understand each part of the code:

#### **Handling File Path Ambiguity**
- **Link to Concept**: The script settings handle [ambiguity](https://en.wikipedia.org/wiki/Sfumato) of file paths, a practical challenge when collaborating in different environments.
- **Advice**: Use different file paths for collaborators and ensure TA compatibility to avoid losing points.

#### **Code Explanation**

```stata
quietly { //first line of code
    cls
    if 0 { //background, purpose. 
        1. HW3 solution
        2. One approach among many
    } //last line of code
```
- **Purpose**: This section, though commented out (`if 0`), serves as a placeholder for background information or script metadata, which can include the script’s purpose or versioning info.

```stata
    if 1 { //methods, log, settings, data  
        cls              
        clear 
        capture log close           
        log using "hw3.lastname.firstname.log", replace          
        set more off          
        set timeout1 1000 // Handling slow network responses
        local local_path "/users/d/downloads/hw1.txt"
        global path "https://github.com/jhustata/basic/raw/main/hw1.txt"  
        
        capture confirm file "`local_path'"
        if _rc == 0 {
            global path "`local_path'"
        } else {
            global path "${path}"
        }
        import delimited "${path}", clear
    }
```
- **Dynamic Path Handling**: This block sets up paths for local and remote data access and uses the `capture confirm file` to check if a local file exists, switching to a remote URL if not. This ensures flexibility depending on the user’s environment (source: [stackoverflow](https://stackoverflow.com/questions/17414357/using-shell-to-check-whether-a-file-exists-and-only-if-it-does-execute-a-set-o)).
- **Logging**: The `log` command starts recording all commands and results, useful for debugging and reviewing the analysis process.

```stata
    if 2 { //results, Q1
        gen htn = dx == "4=Hypertensive"
        replace htn = 0 if missing(htn)
        label define htn_lab 0 "No" 1 "Yes"
        label values htn htn_lab 
        noi tab htn
        noi di "" 
        noi di ""
        noi di ""
    }
```
- **Data Analysis for Q1**: Analyzes hypertension data, creating and labeling a new variable `htn`. Outputs are neatly tabulated and spaced for clarity. If you only wish to run Q2, you can change `if 2` to `if 0`. Never highlight a section of your `.do` file, as you may omit code that defines macros.

```stata
    if 3 { //results, Q2
        putexcel set question2, replace 
        label variable init_age "Age, median (IQR)"
        label variable prev "Previous transplant, %"
        
        local start_row = 1
        forvalues i = 0/1 {
            count if female==`i'  
            local female`i'_n=r(N)
            sum init_age if female==`i', detail
            local female`i'_age_p50: di %2.0f r(p50)
            local female`i'_age_p25: di %2.0f r(p25)
            local female`i'_age_p75: di %2.0f r(p75)
            sum prev if female==`i'
            local female`i'_prev: di %2.1f r(mean)*100
            
            putexcel A`start_row' = "Question 2" B`start_row' = "Males (N=`female0_n')" C`start_row' = "Females (N=`female1_n')"
            local age_row = `start_row' + 1
            putexcel A`age_row' = "Age, median (IQR)" B`age_row' = "`female0_age_p50' (`female0_age_p25' - `female0_age_p75')" C`age_row' = "`female1_age_p50' (`female1_age_p25' - `female1_age_p75')"
            local prev_row = `age_row' + 1
            putexcel A`prev_row' = "Previous transplant, %" B`prev_row' = "`female0_prev'" C`prev_row' = "`female1_prev'"
        }
    }
```
- **Data Analysis for Q2**: More complex, using loops to process gender-specific data. Outputs to Excel, showing innovative data handling and presentation. Labels and macros facilitate dynamic updating of results based on data.

```stata
    log close
    set more on
    set timeout1 30
}
```
- **Cleanup**: Properly closes the log file and restores Stata settings to their default state to avoid impacting

# Version Control

Managing your workflow in Stata effectively, especially when dealing with complex scripts, is crucial for both learning and practical application. Here’s some guidance on this topic:

### **Effective Management of Script Execution in Stata**

**1. Understand Script Sections:**
   - **Familiarize Yourself:** Before running any part of the script, understand what each section does. This will help you avoid running unnecessary parts that might alter your data or results unintentionally.

**2. Use Conditional Blocks Wisely:**
   - **Leverage Conditional `if`:** Instead of manually highlighting and running sections of the code, use the conditional `if` statements to control which parts of the script execute. For example, changing `if 1` to `if 0` will prevent that block from running without needing to delete or comment out potentially large chunks of code.
   - **Modularity:** Organize your script into distinct blocks that can be easily turned on or off. This approach helps in focusing on specific analyses or tasks without interference from other parts of the script.

**3. Advantages of Conditional Execution:**
   - **Reduce Risk of Errors:** By controlling script execution through conditions, you minimize the risk of accidentally running incorrect parts or using outdated data settings.
   - **Save Time:** Running only relevant sections saves time, particularly with large datasets or complex computations.
   - **Keep Everything Intact:** Using conditionals allows you to keep all your code in the script for reference without running it. This is especially useful for educational purposes and when scripts are handed over for grading or collaborative projects.

**4. Script Control Examples:**
   - **Silencing Blocks:** To skip a block, simply change its condition to zero (`if 0`). This effectively "silences" the block without removing it from the script. For instance, if you are currently interested only in the results of `if 3`, you can set `if 1` and `if 2` to `if 0`.
   - **Activating Specific Sections:** To run a specific section, ensure that section’s `if` condition evaluates to true (non-zero). You can manage this dynamically by setting a global or local macro at the beginning of your script and using it in your `if` statements.

**5. Encourage Good Practices:**
   - **Commenting:** Encourage adding comments on why certain blocks are turned off (e.g., `if 0 // temporarily disabled for debugging`).
   - **Version Control:** Teach the use of version control systems like Git. This allows students to experiment with different script versions without fear of losing the original settings or analyses.

**6. Example for Clarity:**

```stata
// Define which sections to run
global run_section1 0  // Do not run section 1
global run_section2 0  // Do not run section 2
global run_section3 1  // Only run section 3

// Section 1: Data Preparation
if $run_section1 {
    // Data cleaning and preparation steps here
}

// Section 2: Initial Analysis
if $run_section2 {
    // Initial exploratory analysis here
}

// Section 3: Detailed Analysis
if $run_section3 {
    // Detailed statistical analysis here
}
```

**7. Continuous Learning:**
   - **Regular Revisions:** Encourage students to regularly revise their scripts, adjusting the conditional flags as their focus shifts between different analyses.

By guiding students to use these practices, they not only learn to manage their scripts more effectively but also build good habits for future programming tasks in Stata or any other language. This structured approach enhances their understanding and keeps their work organized and efficient.