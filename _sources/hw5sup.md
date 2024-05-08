# HW 5 Supplement

This homework makes only a few changes to the original HW5.You're welcome to use any resource to answer the questions,including previous homework solutions. But your solution is expected to be *Sui generis*, that is, "of its own kind."s

```stata
global repo https://github.com/jhustata/basic/raw/main/
import delimited "${repo}transplants.dta", clear
```

**Question 1**. Write a program called `question1` that prints the following table (including `Question 1` in the header). The `XX` values should be replaced with correct values found in the dataset, and should be rounded to the nearest whole number for age and to <u>one decimal place</u> to the right of the decimal point for other variables. Make sure the summary statistics are vertically aligned and justified along the left margin. Run your program and display the table (i.e., in `.log file`). Also, output these results to `Question1.xlsx`

```stata
Question 1                Previous Transplant (N=XX) Previous Transplant (N=XX) 
Age, median (IQR)         XX (XX-XX)                 XX (XX-XX)
Sex, %                    XX.X                       XX.X
Race/Ethnicity, %:
   White                  XX.X                       XX.X
   Black                  XX.X                       XX.X
   Hispanic               XX.X                       XX.X
   Asian                  XX.X                       XX.X
   Other                  XX.X                       XX.X
 
```

**Question 2.** Your research group is investigating demographic characteristics associated with the propensity to receive a donor organ that meets the "expanded donor criteria". You run a logistic regression including the following postestimation commands:

```stata
logistic don_ecd age gender i.race
lincom age
return list

//factor variables
codebook race
lincom _b[4.race]
return list 
```

Print a summary table as shown below (this is how it should appear in your `.log` file), with odds ratios (OR) and 95% confidence intervals (CI). The `XXXX` values should be replaced with the actual values found in the dataset, and should be displayed with <u>**two**</u> decimal places to the right of the decimal point. Also, create a `Question2.xlsx` with this output properly formatted.

```stata
Question 2
Variable            OR    (95% CI)
Age                 X.XX  (X.XX-X.XX)
Female              X.XX  (X.XX-X.XX)
Race/Ethnicity            
   White           Reference
   Black           X.XX  (X.XX-X.XX)
   Hispanic        X.XX  (X.XX-X.XX)
   Asian           X.XX  (X.XX-X.XX)
   Other           X.XX  (X.XX-X.XX)
```
