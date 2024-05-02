<Details>
   <Summary>Hardcoding</Summary>

Let's briefly [revisit Week 5](https://jhustata.github.io/basic/chapter5.html): Review of Weeks 1 - 4

View the script we used to guide our review:
```stata
cat https://github.com/jhustata/basic/raw/main/review.do
```

Run the script to see its output:
```stata
do https://github.com/jhustata/basic/raw/main/review.do
```

This script creates output into a `.log` file. But HW5 asks you to additionally direct output into a `.xlsx` file. How may we adapt the script to this purpose? Yes, this is the key question of HW5. Many of you may have missed a tip for [HW3](https://jhustata.github.io/basic/chapter3.html#common-mistakes-from-hw1) that recommended "hardcoding" as a template -- a starting place. You may then gradually replace the hardcoded stuff with appropriate macros.

Hardcoding as a firststep. In this example:
1. We use the `ds` command, `not(type string)` option, and `levelsof`. These were only briefly mentioned in class, but were further discussed in [Lab 5 Section 2.2](https://jhustata.github.io/basic/lab5.html#foreach-n-of-numlist)
2. Nested loops and conditional code-blocks (e.g. `if r(r) == 2`) can be very empowering!
3. Gradually **update** your `.do` file script to replace hardcoded stuff (e.g. `catlab`), or stuff that isn't publication worthy (e.g. `v`, which in this example is a variable name) with more appropriate macros or variable labels
4. The HW5 solution will walk you through such a process
5. Copy and paste your `.do` file script into a program. And adapt it to a more general purpose, beyond any specific dataset or variables

```stata
qui {
	cls
	use ${repo}transplants, clear
    ds, not(type string)  
	global threshold 9  
	putexcel set levelsof, replace 
	local row=2
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			putexcel A`row' = ("`v'") B`row' = ("per")
			local row = `row' + 1
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			putexcel A`row' = ("`v', %") B`row' = ("")
			foreach l of numlist `numlevels' {
				local row = `row' + 1
                putexcel A`row' = ("    catlab") B`row' = ("per")
			}	
	    }
	    else {  
			putexcel A`row' = ("`v'") B`row' = ("m_iqr")
			local row = `row' + 1
	    }
		
    }
	
}
```
##### GPT-4 Session:

**User:** help add comments/annotation [paste the above script into ChatGPTs prompt]

**ChatGPT:** Sure, I can help you add comments and annotations to your Stata code to make it more understandable. Here’s your code with comments explaining each part:

```stata
qui {  // Quietly execute the following block of code
    cls  // Clear the screen
    use ${repo}transplants, clear  // Load dataset from specified repository and clear any previous data in memory
    ds, not(type string)  // List all variables that are not of string type
    global threshold 9  // Set a global threshold value of 9
    putexcel set levelsof, replace  // Set the Excel file for output with the name 'levelsof', replace if exists
    local row=2  // Initialize row variable for Excel output starting at row 2

    foreach v of varlist `r(varlist)' {  // Loop over the variables listed by the previous 'ds' command
        levelsof `v', local(numlevels)  // Get the levels of each variable and store them in local 'numlevels'
        if r(r) == 2 {  // If there are exactly two levels for the variable
            putexcel A`row' = ("`v'") B`row' = ("per")  // Write variable name in column A and 'per' in column B of Excel
            local row = `row' + 1  // Increment the Excel row counter
        }
        else if inrange(`r(r)', 3, $threshold) {  // If the number of levels is between 3 and the threshold
            putexcel A`row' = ("`v', %") B`row' = ("")  // Write variable name with a percent sign in column A, leave column B empty
            foreach l of numlist `numlevels' {  // Loop through each level of the variable
                local row = `row' + 1  // Increment row before writing
                putexcel A`row' = ("    catlab") B`row' = ("per")  // Indent 'catlab' in column A, write 'per' in column B
            }   
        }
        else {  // If the number of levels exceeds the threshold
            putexcel A`row' = ("`v'") B`row' = ("m_iqr")  // Write variable name in column A and 'm_iqr' in column B
            local row = `row' + 1  // Increment the row counter
        }
    }
}
```

In this script, you're using a combination of `putexcel` commands and conditional logic to format and export information about variable levels from Stata to an Excel file. This can be very useful for data review and verification processes.

</Details>