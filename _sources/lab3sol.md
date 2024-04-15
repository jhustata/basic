## 3.4 Lab (solution)

Use the `transplants.dta` dataset with these practice questions:

1. Calculate the standard deviation of age among patients with blood type O (`abo==4`). Print the following sentence: `The SD of age among patients with blood type O is XX.X`. Replace `XX` with correct values. Round to tenths (e.g. 8.2). 

   ```stata
   sum age if abo==4
   local abo4: di %2.1f r(sd)
   
   di "The SD of age among patients with blood type O is `abo4'."
   ```

2. Regress BMI on age and sex (using `regress bmi age gender`) without displaying the regression output. Print the following sentence: `Per 1-year increase in age, BMI increases by X.XX`. Replace `XX` with the regression coefficient of age. Round to hundredths (e.g. 0.74). 

   ```stata
   quietly regress bmi age gender
   local age_b: di %3.1f _b[age]
   
   di "Per 1-year increase in age, BMI increases by `age_b'."
   ```


3. Now we will do the same thing, but using a program. Define a program named `bmi_age`. This program will regress BMI on age and sex without displaying the regression output, and print: `Per 1-year increase in age, BMI increases by X.XX`. Replace `XX` with the regression coefficient of `age`. Round to hundredths (e.g. 0.74). 

   ```stata
   capture program drop bmi_age
   program define bmi_age
   
       quietly regress bmi age gender
       local age_b: di %3.1f _b[age]
       
       di "Per 1-year increase in age, BMI increases by `age_b'."
       
   end
   ```

4. Let's consider how you may allow the user of `bmi_age` to utilize this program on a dataset with any variable name

```stata
  capture program drop regress_linear
   program define regress_linear
     syntax varlist 
       quietly regress `varlist'
	   local outcome: di word("`varlist'", 1)
	   local coef: di word("`varlist'", 2)
       local coef_b: di %3.1f _b[`coef']
       
       di "Per 1-year increase in `coef', `outcome' increases by `coef_b'."
       
   end
   ```
   
   Now the end-user has flexibility and can chose the variables in the regression:

  ```stata 
   use transplants, clear
   regress_linear bmi age
   regress_linear bmi prev_ki
   ```

5. How may the output be improved?

```stata
   capture program drop regress_linear
   program define regress_linear
     syntax varlist 
       quietly regress `varlist'
	   local outcome: di word("`varlist'", 1)
	   local coef: di word("`varlist'", 2)
       local coef_b: di %3.1f _b[`coef']
	   local coef: variable label `coef'
	   local outcome: variable label `outcome'
       
       di "Per 1-year increase in `coef', `outcome' increases by `coef_b'."
       
   end
   
   
   use transplants, clear
   regress_linear bmi age
```

6. For publication-quality output we may need to relabel the variables and redo question 5:

```stata
label variable age "Age (at Transplant)"
label variable bmi "Body-mass index"
```