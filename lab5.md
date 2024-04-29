# Lab 5

Please use this lab as an opportunity to review the course material and prepare yourself for the homework questions. A sample response to the lab questions will be made available on Friday May 2, 2024. While you are not expected to practice all these examples, you're also reminded that *practice makes perfect*!

Tasks:
1. Walk through as many examples as you can to appreciate the efficiency loops bring to programming.
2. Make a list of the number of macros that are defined throughout this exercize. How many do you come up with? Compare this with your classmates. Post your "exhaustive" list of macros (inlude the total count) in [GitHub Discussions](https://github.com/jhufena/discussions/discussions) and challenges others to identify a longer list.
3. Consider how some of these macros might be used when writing a flexible program. (e.g. `syntax varlist`). Part II of this lab focuses on flexible programs, all of which employ macro "names" to capture user "values" and inputs (i.e., varlists, numlists, varnames, filepaths, etc).
4. Finally, write a script that imports NHANES DEMO.XPT (1999-2000) and iteratively `appends` NHANES `DEMO.XPT` from the next two survey cycles 2001-2002, 2003-2004. Visit the website to see the naming convention for the various years (e.g. [NHANES 2001 - 2002](https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2001)) 

```stata
set timeout1 1000
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
```

5. Convert the above script into a flexible program that can import as many survey cycles as the user wishes. Review the naming conventions for the `DEMO.XPT` files for each cycle.

```stata
capture program drop nhanes_demo
program define nhanes_demo
   //code
end
```


# Part I: Loops (30 min)

## 1. Setting Up the Environment

Let's start by reading in datasets we may need for demos

```stata
qui {
	/*
	1. Kidney Transplant Recipient Data
	2. NHANES 1999-2000 Demographics Data  
	3. Homework 1 Textfile Data
	*/
	if 1 { //Activated 
		cls
	    noi di "How many datasets are you going to use?" _request(N)
	    forvalues i=1/$N {
		    noi di "What is dataset `i'?" _request(data`i')
	    }
	    global repo "https://github.com/jhustata/basic/raw/main/"
	}	
}
```

## Kinds of loops
### `foreach v of varlist {`
```stata
qui {
	/*
	1. Kidney Transplant Recipient Data
	2. NHANES 1999-2000 Demographics Data  
	3. Homework 1 Textfile Data
	*/
	if 0 { //Deactivated  
		cls
	    noi di "How many datasets are you going to use?" _request(N)
	    forvalues i=1/$N {
		    noi di "What is dataset `i'?" _request(data`i')
	    }
	    global repo "https://github.com/jhustata/basic/raw/main/"
	}	
	if $N { //Import Data
        use $repo$data1, clear
		ds 
		//varlist: string of variable names
		foreach v of varlist `r(varlist)' {
			noi di "`v'"
		}
	}
}
```

<Details>
   <Summary></Summary>

The `r(varlist)` can be replaced with a user-defined varlist in a customized program:

```stata
capture program drop myvarlist
    syntax varlist
	foreach v of varlist `varlist' {
	    noi di "`v'"
	}
end 
```


Now the user has flexibility:

```stata
myvarlist age gender race abo bmi
```

</Details>

##### `c(ALPHA)` 
What if you wish to loop over a list of strings that aren't variables?

```stata
 cls 
 //di c(ALPHA)
 foreach v in `c(ALPHA)' {
 	di "`v'"
 } 
```

#### `tokenize`
You may be working within a `forvalues i=1/N` loop and want to loop over some other "list" that is a string:

```stata
tokenize "`c(ALPHA)'" 
forval i = 1/26 {        
    di "``i''"
}
```

<Details>
   <Summary></Summary>

```stata
set timeout1 1000
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
```

Can you write a script that imports NHANES DEMO.XPT (1999-2000) and iteratively `appends` NHANES DEMO.XPT from the next two survey cycles 2001-2002, 2003-2004? Visit the website to see the naming convention for the various years (e.g. [NHANES 2001 - 2002](https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2001))

</Details>

##### `varlist` 
What if you wish to loop over a list of strings that aren't variables?

```stata
 cls 
local varlist "Egypt Portugal Swaziland Ireland"
 foreach v in `varlist' {
 	di "`v'"
 } 
```

### `foreach n of numlist {`
```stata
qui {
	//earlier code
	if $N {
        // earlier code
		levelsof dx, local(dxcat)
		//numlist: list of numbers
		foreach n of numlist `dxcat' {
			noi di `n'
		}
	}
}
```

#### `variable lab`


```stata
qui {
	//earlier code
	//levelsof is a "numlist"
	    levelsof dx, local(dxcat)
		local varlab: var lab dx 
		//later code
}
```

<Details>

   <Summary></Summary>

Variable type determines the parameters you report in Table 1:

| Variable Type                 | Statistic      |
|-------------------------------|----------------|
| Continuous  (Units)           | Median (IQR)   |
| Binary (One is enough)        | %              |
| Multicategory (Each reported) | Variable label |
| Specific or collapsed         | %              |

`dx` is a collapsed version of `extended_dgn`. But for the sake of practice, lets further collapse `dx`:

```stata
tab dx 
recode dx (1/4=1 "Prevalent Overall")(5/8=2 "Common in subgroups")(9=3 "Miscellaneous"),gen(dx_cat)
tab dx_cat
```

   ```stata
   h ds
   ds, has(type string)
   levelsof extended_dgn
   return list
   ds, not(type string)
   ds, has(type int)
   ds, has(varl "*TX*")
   ds, has(varl *TX* *transplant*)
   ds, has(format %t*) 
   ds, has(format *f)  
   ```

   Here's a simple script that classifies each variable:

```stata
qui {
	cls
    ds, not(type string) //otherwise, extended diagnosis is continuous! 
	global threshold 9 //for multicat vs. continuous
    foreach v of varlist `r(varlist)' {
	    levelsof `v', local(numlevels)
	    if r(r) == 2 {  
			noi di "`v' binary"
	    }
	    else if inrange(`r(r)', 3, $threshold) {  
			noi di "`v' multicat"
	    }
	    else {  
			noi di "`v' continuous"
	    }
    }
	
}


```

</Details>

#### `value lab`
```stata
qui {
	//earlier code
		//earlier code
		local vallab: value lab dx
		foreach n of numlist `dxcat' {
			//code
		}
}
```

#### `label value lab`
Let's get familiar with variations on the `foreach` command:

##### `forvalues`
Here we are dealing with a sequence of numbers:

```stata
 forvalues i=1/9 {
 	di `i' 
 } 
```

##### `foreach`
In this scenario the numbers are arbitrarily arranged:

```stata
 foreach n of numlist 1 2 3 7 9 {
 	di `n'
 } 
```

##### `numlist`
You can create a macro, whose value is the `numlist` 

```stata
 local numlist "1 2 3 7 9"
 foreach n of numlist `numlist' {
 	di `n'
 } 
```

```stata
qui {
	//earlier code
		foreach n of numlist `dxcat' {
			local dxvarlab: lab `vallab' `n'
			//later code
		}
}
```

##### `tokenize`

```stata
    if 2 { //Int 1-26
        
        egen lastname = seq(), f(1) t(26)
        tostring lastname, replace 
        tokenize "`c(ALPHA)'" 
        
    }

    if 3 { //Tokenize
        
        forval i = 1/26 {
            
            replace lastname = "``i''" if lastname == "`i'" 
            
        }
        
    }

```

###### `putexcel`

Output a `varlist`, `numlist`, and some other list into `.xlsx`

```stata
clear  
putexcel set lab6, replace 
use $repo$data1, clear
qui ds
//nested loops
tokenize "`c(ALPHA)'"
forvalues i = 1/2 {
	local row=2
	foreach v of varlist `r(varlist)' {
		if `i' == 1 {
			qui putexcel ``i''`row' = "`v'"
	        local row=`row'+ 1	
		}
		if `i' == 2 {
			qui sum `v'
			local mean: di %3.2f r(mean)
			qui putexcel ``i''`row' = "`mean'"
	        local row=`row'	+ 1
		}
    } 
} 

ls 
 
```

Review the `.xlsx` file you've just created



# Part II (30 min)

1. We discussed how you can define your own “program”. It’s an awesome tool that allows us to automate a specific task. If you think a specific part of your code will be used multiple times, you might as well put that into a program. In this second half of lab, we will practice customizing our programs.

2. Start Stata, open your do-file editor and consider using conditional code-blocks (`if 2` for instance) as you answer each question in this lab. That way each block has some autonomy and you can "silence" it (`if 0`) while you run other code-blocks. Review Part I for instances where macros replace the `0` and `2` in the `if 0` blocks.

3. Write a program called `mymean`. This program will take `varlist` as a user input, and calculate the mean value of each variable, and display the values.

4. Modify your program `mymean` so that when an `if` argument is supplied, `mymean` would only include the observations that meet the condition specified by the `if` argument. In other words, if the user types `mymean height if age>65`, the program `mymean` will calculate the mean only among patients older than 65.

5. Further modify your program `mymean` to include the option `sd`. When the option `sd` is supplied, `mymean` will display the standard deviation along with the mean. This version of `mymean` should still be able to accommodate the `if` argument.

6. Further modify your program `mymean` to include the option `digits()`, with a number in the parenthesis. When the option `digits()` is supplied, `mymean` will round up the mean (and the standard deviation, if applicable) in units of `digits()`. If `digits()` is NOT supplied, round in units of 0.001. (Hint: use the Stata function `round()`)

7. Did you make `if`, `sd`, and `digits()` optional arguments? That is, your program should run whether or not these arguments are supplied. To do so, simply surround each argument with brackets. For example, `[sd]`

8. I’d like to draw your attention to the merge command. It’s hard to write a question around `merge`, but it’s a really important command in practice. For instance, we used it in the [week 4](https://jhustata.github.io/basic/chapter4.html#merging-files). Reference these notes when necessary in the future. You should also ask your TA and colleagues about the `append` command. Task 4 (see above) requires you to use it.

9. We want to study if death (`died==1`) is associated with several predictor variables: `bmi`, `prev_ki`, `age`, `peak_pra`, or `gender`. Run logistic regression between `died` and each of the predictor variables using `foreach` loop. At each run, save the name and the regression coefficient of the predictor variable into an external Stata dataset file named `output.dta`.

10. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.
