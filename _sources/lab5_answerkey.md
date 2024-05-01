# Lab 5 solution

## Part I 

### 1

Let the students know that there are no shortcuts: the more practice, the better they'll become

### 2

```stata
// 1
_request(N)
$N

// 2
forvalues i=1/$N {
    di `i' //local macro
}


// 3
_request(data`i')
${data`i'}

// 4
global repo "https://github.com/jhustata/basic/raw/main/"
$repo

// 5
global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"
$nhanes

// 6
ds
`r(varlist)'

// 7
foreach v of varlist `r(varlist)' {
    `v'
}

// 8
foreach v in `c(ALPHA)' {
   di  `c(ALPHA)' //c() class macro
   creturn list
}

// etc.
```

### 3

Simple example under `foreach v of varlist {` in Lab 5 Part I Section 2.1:
- Click on the "token"
- `varlist` in the program might have been a list of hardcoded variabes in a `.do` file 
   - e.g. init_age bmi
- But a program generalizes this using `syntax varlist`
   - The user may then choose the  variable list of their preference


### 4.1

```stata
do ${repo}loopxpt.do
```

### 4.2

You can copy and paste this into **ChatGPT** and ask for notes. Encourage students to do this. Please let them use other AIs as well.

```stata
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
	clear 
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
```

Here's an example with the query: **annotate**:

This code appears to be written in Stata, a statistical software package. It's designed to automate the process of downloading, importing, and merging demographic datasets from multiple biennial waves of the National Health and Nutrition Examination Survey (NHANES) hosted by the CDC. Let me annotate each segment for you:

```stata
qui {   // Start a quiet block where outputs are suppressed
    cls   // Clear the screen
    clear // Clear any existing data in memory
    set timeout1 1000  // Set a timeout for potentially slow operations
    global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/" // Define a global variable for the NHANES website URL
    tokenize "`c(ALPHA)'" // This line seems erroneous or out of context
    local y = 1999 // Initialize a local variable 'y' to start from the year 1999

    forvalues i=1/3 { // Loop over three biennial cycles (1999-2000, 2001-2002, 2003-2004)
        local yp1 = `y' + 1 // Calculate the end year of the biennial cycle
        if `y' == 1999 {
            local letter = "" // No letter suffix for the first cycle
        }
        else {
            local letter = "_``i''" // Suffix for file names in subsequent cycles, seems incorrect should be `_` not `_``i''`
        }
        import sasxport5 "${nhanes}`y'-`yp1'/DEMO`letter'.XPT", clear // Import the dataset from a .XPT file
        //tempfile nh`y'_`yp1'  // Define a temporary file, commented out
        g surv = "`i'" // Generate a new variable 'surv' to distinguish each survey wave
        save nh`y'_`yp1', replace  // Save the dataset with a new name
        noi di "`letter'" // Display the suffix letter quietly, for debugging
        local y = `y' + 2 // Increment the start year by 2 for the next biennial cycle
    }

    clear  // Clear the data in memory
    local y = 1999 // Reset the start year for merging process

    forvalues i=1/3 { // Loop over the same three cycles for merging
        local yp1 = `y' + 1 // Calculate the end year for each cycle
        append using nh`y'_`yp1'  // Append each dataset to the master dataset
        rm "nh`y'_`yp1'.dta" // Remove the intermediate Stata data files, wrong extension should be .dta
        local y = `y' + 2 // Increment the start year by 2 for the next cycle
    }

    save nh, replace  // Save the final merged dataset as 'nh'
    //verify at https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.htm // Comment for verification
    noi tab surv  // Tabulate the 'surv' variable quietly to check data consistency
    noi ls // List the files in the current directory quietly
}
```

There are some potential issues and errors in the script that may need addressing, such as file suffix logic and file extensions in the `rm` command.

### 5

I copied the above script into the template below & asked GPT-4 to "help indent". And then I made a few edit to empower the user, as they select the NHANES surveys of interest to them.

```stata
capture program drop nhanes_demo
program define nhanes_demo
    //copy & paste here
end
```

**GPT-4:** Here's a cleaner and more properly indented version of your Stata code for defining the `nhanes_demo` program. I've made sure to align the blocks and structure it to enhance readability:

```stata
capture program drop nhanes_demo
program define nhanes_demo
    syntax, begin(int) end(int)
    qui {
        cls
        clear 
        set timeout1 1000
        global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"
        tokenize "`c(ALPHA)'"
        local y = `begin' //edit, this macro is from the syntax command
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
		clear  
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

```

This revision aligns the commands within loops and conditions, which makes it easier to follow the logic. The indentation helps to visually separate commands from control structures like loops and conditional statements.


# Part II

1. In the first-half of the course, we discussed how you can define your own “program”. It’s an awesome tool that allows us to automate a specific task. If you think a specific part of your code will be used multiple times, you might as well put that into a program. In this lab, we will practice customizing our programs.

2. Start Stata, open your do-file editor, lay out a template for your basic .do file structure using `qui {`, `if 0 {`, and and `if 1`. Load `transplants.dta`  in your `if 2` block or wherever you feel it fits best.

3. Write a program called `mymean`. This program will take `varlist` as a user input, and calculate the mean value of each variable, and display the values.

   ```stata
   capture program drop mymean
   program define mymean
       syntax varlist
       foreach var in `varlist' {   
           quietly sum `var'
           display r(mean)
       }
   end
   
   ```

4. Modify your program `mymean` so that when an `if` argument is supplied, `mymean` would only include the observations that meet the condition specified by the `if` argument. In other words, if the user types `mymean height if age>65`, the program `mymean` will calculate the mean only among patients older than 65.

   ```stata
   capture program drop mymean
   program define mymean
       syntax varlist [if]
       foreach var in `varlist' {
           quietly sum `var' `if'
           display r(mean)
       }
   end
   ```

5. Further modify your program `mymean` to include the option `sd`. When the option `sd` is supplied, `mymean` will display the standard deviation along with the mean. This version of `mymean` should still be able to accommodate the `if` argument.

   ```stata
   capture program drop mymean
   program define mymean
       syntax varlist [if], [sd]
       foreach var in `varlist' {
           quietly sum `var' `if'
           display r(mean)
           if "`sd'" != "" {
                 display r(sd)
           }
       }
   end
   
      // The answer above is in the simplest possible form for clarity. In practice, I will arrange the outputs a little bit better.
   capture program drop mymean
   program define mymean
       syntax varlist [if], [sd]
       foreach var in `varlist' {
           quietly sum `var' `if'
           if "`sd'" != "" {
                 display "`var': " r(mean) " (" r(sd) ")"
           }
           else {
                 display "`var': " r(mean)
           }
       }
   end
   ```

6. Further modify your program `mymean` to include the option `digits()`, with a number in the parenthesis. When the option `digits()` is supplied, `mymean` will round up the mean (and the standard deviation, if applicable) in units of `digits()`. If `digits()` is NOT supplied, round in units of 0.001. (Hint: use the Stata function `round()`)

   ```stata
   capture program drop mymean
   program define mymean
       syntax varlist [if], [sd] [digits(real 0.001)]
       foreach var in `varlist' {
           quietly sum `var' `if'
           display round(r(mean), `digits')
           if "`sd'" != "" {
                 display round(r(sd), `digits')
           }
       }
   end
   ```

7. Did you make `if`, `sd`, and `digits()` optional arguments? That is, your program should run whether or not these arguments are supplied. To do so, simply surround each argument with brackets. For example, `[sd]`

8. I’d like to draw your attention to the merge command. It’s hard to write a question around `merge`, but it’s a really important command in practice. For instance, we used it in [week 4](https://jhustata.github.io/basic/chapter4.html#merging-files). Contrast `merge` with `append`, something we may not get a chance to demonstrate.

   ```stata
   merge 1:1 fake_id using donors_recipients
   ```
   
   ​ This is the code from the lecture. We are merging `transplants.dta` with `donors_recipients.dta`. We are merging observations with the same `fake_id`, and expect that there will be only one observation per `fake_id` in both datasets.
   
9. We want to study if death (`died==1`) is associated with several predictor variables: `bmi`, `prev_ki`, `age`, `peak_pra`, or `gender`. Run logistic regression between `died` and each of the predictor variables using `foreach` loop. At each run, save the name and the regression coefficient of the predictor variable into an external Stata dataset file named `output.dta`.

   ```stata
   postfile output str30 name coef using output
   // you may add ", replace" to allow overwriting output.dta
   
   foreach var in bmi prev_ki age peak_pra gender {
       quietly logistic died `var'
       post output ("`var'") (_b[`var'])
   }
   postclose output
   ```

   OR

     ```stata
   postfile output str30 name coef using output
   // you may add ", replace" to allow overwriting output.dta
   
   foreach var in bmi prev_ki age peak_pra gender {
       quietly logistic died `var'
       quietly lincom `var'
       post output ("`var'") ("`r(estimate)'")
   }
   postclose output
   ```

10. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.
