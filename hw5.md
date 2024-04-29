# HW 5

This homework revisits `HW3`, but with a few additional challenges. Refer to [lab 5](lab5.md) for hints. 

**Question 1**. Now you have all the skills to create your first automated Table 1! Write a program called `question5` that prints the following table (including `Question 5` in the header). The `XX` values should be replaced with correct values found in the dataset, and should be rounded to the nearest whole number for age and to <u>one decimal place</u> to the right of the decimal point for other variables. Make sure the summary statistics are vertically aligned and justified along the left margin. Run your program and display the table (i.e., in `.log file`). Also, output these results to `Question1.xlsx`

```stata
Question 1                Males (N=XX)        Females (N=XX)
Age, median (IQR)         XX (XX-XX)          XX (XX-XX)
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
| Upper bound of 95% CI | `ub`                                                 |