## HW3

## 3.5 Homework

### Overview 

Write a `.do file` which imports data from [hw1.txt](https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt) and performs the tasks described below. Name it `hw3.lastname.firstname.do` and it should create a log file called `hw1.lastname.firstname.log`. Please avoid some of the common mistakes we observed in your HW1. While you didn't drop points for those mistakes as beginners, you'll drop some points in HW3 if you repeat these mistakes. Make sure your log file displays only the output of interest. But do not submit your log files as part of the assignment.

Evaluation will be based on the log file produced when we run your script on our machines. 

Codebook

| Variable       | Description                                  | Values           |
| ------------------- | ------------------------------------------------ | -------------------- |
| transplants.dta |                                                  |                      |
| `fake_id`           | Patient ID                                       | Numeric              |
| `bmi`               | Body mass index (kg/m2)                          | Numeric              |
| `dx`                | Primary diagnosis                                | String (see dataset) |
| `init_age`          | Age                                              | Numeric              |
| `prev`              | History of previous transplant                   | 0=No / 1=Yes         |
| `peak_pra`          | Peak PRA                                         | Numeric              |
| `female`            | Sex                                              | 0=No / 1=Yes         |
| `received_kt`       | Patient eventually received a kidney transplant? | 0=No / 1=Yes         |

This dataset contains simulated data on registrants for the deceased donor kidney waitlist.

**Question 1.** Create a new numeric variable named `htn`, which takes a value of 1 if the variable `dx` has a value of `4=Hypertensive`, and `0` otherwise. This variable should have value labels, `Yes` for 1 and `No` for 0. (Hint: what is the data type of this new variable? Is it a numeric or a string?) Run `tab htn` in your assignment do-file so that it would print the following result.

```stata
        htn |       Freq.       Percent       Cum.
------------+-------------------------------------
         No |       XXXX        XXXX          XXXX
        Yes |       XXXX        XXXX          XXXX
------------+-------------------------------------
      Total |       XXXX        XXXX
```

**Question 2**. Create your first automated Table 1! Write a program called `question2` that prints the following table (including `Question 2` in the header). The `XX` values should be replaced with correct values found in the dataset, and should be rounded to the nearest whole number for age and to <u>one decimal place</u> to the right of the decimal point for other variables. Make sure the summary statistics are vertically aligned and justified along the left margin. Run your program and display the table on your results window, in your `.log` file, and in a `question2.xlsx`. (The key challenge: reporting continuous and binary variables. Next week we'll include categorical variables)

```stata
Question 2                Males (N=XX)        Females (N=XX)
Age, median (IQR)         XX (XX-XX)          XX (XX-XX)
Previous transplant, %    XX.X               XX.X
```

To align output on your Stata results window, and thus in your `.log` file, you may use the column `_col()` syntax. Use the example below as a guide

```stata
local study_arms: di _col(30) "Trial" _col(60) "Control"
di "`study_arms'"
```