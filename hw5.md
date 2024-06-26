﻿# HW 5

This homework revisits `HW3`, but with a few additional challenges. Refer to [lab 5](lab5.md) for hints. 

```stata
global repo https://github.com/jhustata/basic/raw/main/
import delimited "${repo}hw1.txt", clear
```

**Question 1**. Now you have all the skills to create your first automated Table 1! Write a program called `question1` that prints the following table (including `Question 1` in the header). The `XX` values should be replaced with correct values found in the dataset, and should be rounded to the nearest whole number for age and to <u>one decimal place</u> to the right of the decimal point for other variables. Make sure the summary statistics are vertically aligned and justified along the left margin. Run your program and display the table (i.e., in `.log file`). Also, output these results to `Question1.xlsx`

```stata
Question 1                Males (N=XX)       Females (N=XX)
Age, median (IQR)         XX (XX-XX)         XX (XX-XX)
Previous transplant, %    XX.X               XX.X
Cause of ESRD:
Glomerular, %             XX.X               XX.X
Diabetes, %               XX.X               XX.X
PKD, %                    XX.X               XX.X
Hypertensive, %           XX.X               XX.X
Renovascular, %           XX.X               XX.X
Congenital, %             XX.X               XX.X
Tubulo, %                 XX.X               XX.X
Neoplasm, %               XX.X               XX.X
Other, %                  XX.X               XX.X
```

**OR** with indentation for categorical variables:

```stata
Question 1                Males (N=XX)       Females (N=XX)
Age, median (IQR)         XX (XX-XX)         XX (XX-XX)
Previous transplant, %    XX.X               XX.X
Cause of ESRD, %
   Glomerular             XX.X               XX.X
   Diabetes               XX.X               XX.X
   PKD                    XX.X               XX.X
   Hypertensive           XX.X               XX.X
   Renovascular           XX.X               XX.X
   Congenital             XX.X               XX.X
   Tubulo                 XX.X               XX.X
   Neoplasm               XX.X               XX.X
   Other                  XX.X               XX.X
```

**Question 2.** Your research group is investigating demographic characteristics associated with receiving a kidney transplant for waitlisted patients. You run a logistic regression using the following command:

```stata
logistic received_kt init_age female
lincom init_age
return list
```

Print a summary table as shown below (this is how it should appear in your `.log` file), with odds ratios (OR) and 95% confidence intervals (CI). The `XXXX` values should be replaced with the actual values found in the dataset, and should be displayed with <u>**two**</u> decimal places to the right of the decimal point. Also, create a `Question2.xlsx` with this output properly formatted.

```stata
Question 2
Variable         OR    (95% CI)
Age              X.XX  (X.XX-X.XX)
Female           X.XX  (X.XX-X.XX)
```

Hint: If you like, you may these expressions below after logistic regression to obtain the odds ratio and 95% CI. We will use `init_age` as an example.

| Parameters            | Expressions                                          |
| --------------------- | ---------------------------------------------------- |
| Odds ratio            | `r(estimate)`                                        |
| Lower bound of 95% CI | `r(lb)`                                              |
| Upper bound of 95% CI | `r(ub)`                                              |


### Additional Credit (Maximum $+5%$)

This is an optional question that is framed in the investigative spirit of Baltimore's own [Edgar Allan Poe](https://en.wikipedia.org/wiki/Edgar_Allan_Poe)

```stata
global repo https://github.com/jhustata/basic/raw/main/
do ${repo}annotate.do
```

Tasks:
1. Run this remote script to figure out what it does. **Guaranteed 5 points** if you can debug it.
   - Use your knowledge
   - Or the assistance of any GPT
   - Welcome to brainstorm with peers in the [GitHub Discussion Forum](https://github.com/jhufena/discussions/discussions)
2. Then download it and annotate it to explain to yourself and others what it accomplishes
3. Use the ExtraCredit DropBox to hand in your version of `annotate.do` 

One quick way to visualize the `annotate.do` script is by using a Linux `cat` command:

```stata
cat ${repo}annotate.do
```
