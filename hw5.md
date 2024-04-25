# HW 5

**Note:** This homework will be edited depending on how much ground we cover during session 5 on Thu April 25, 2024.

Write a .do file that performs the tasks described below. Your .do file must be called
`hw5.lastname.firstname.do`. Make sure your script will run on our machines by approaching filepaths with **ambiguity** (i.e., incorporate `if` conditional codeblocks to allow for flexibility). Look at your [HW3](https://jhustata.github.io/basic/hw3sol.html) solution for a nice example. Do **not** submit your log files as part of the assignment.

Evaluation will be based on the log file produced when **we** run your script on our machines. 

For Question 1, use the dataset [hw5_pra_hist.dta](https://github.com/jhustata/basic/raw/main/hw5_pra_hist.dta) and [hw5_hosp.dta](https://github.com/jhustata/basic/raw/main/hw5_hosp.dta) to perform the required tasks. Your .do file may be run on <u>a different dataset</u> with more
visits.

For the other questions, simply define your program. You do not need to run the programs you write in
your .do file. The graders will run your programs using a dataset that will not be released to you.

A successful <u>answer</u> would look like this:

```stata
[insert your header code]

// Question 1
[insert your code]

// Question 2
[insert your code, if necessary]
program define unilogit
		[insert your code]
end

```

Another script called [hw5_test.do](hw5_test.do) is required. We will use a script that
looks like this to grade your responses. Use this script to test your code yourself.

Questions

**Context** : You are conducting a study that examines the regional variation in the distribution of panel-
reactive antibody (PRA). You recruited 73 patients (px_id = 1, ...., 73 ) from 10 hospitals (hosp_id=1, ...,10)
in 3 regions (region=A, B, C, ... ), and measured PRA 3 times: visit 1, visit 2, and visit 3. You hear that the
organization that funds your research plans to extend the funding for several more visits (visit 4, visit 5,
..., visit N). Since you do not know how many more visits there will be, you decide to write a .do file that
can work regardless of how many visits the dataset has.


**Codebook**

| Variable                  | Description            | Values/Range                                                 |
| ------------------------- | ---------------------- | ------------------------------------------------------------ |
| **hw2_pra_hist_2022.dta** |                        |                                                              |
| `hosp_id`                 | Hospital ID            | Integers: 1 – 10                                             |
| `px_id`                   | Patient ID             | Integers: 1 – 94                                             |
| `visit_id`                | Visit ID               | Integers: 1 – N<br/>1 indicates the first visit. K indicates the K-th visit. |
| `pra`                     | PRA value at the visit | Integers: 0 – 100                                            |
| **hw2_hosp_2022.dta**     |                        |                                                              |
| `hosp_id`                 | Hospital ID            | Integers: 1 – 10                                             |
| `Region`                  | Region                 | Alphabets                                                    |

Note: to uniquely identify a patient you'd have to specify both hospital ID **and** patient ID. In other words, patients in different hospitals may have the same Patient ID

**i)** Load `hw5_pra_hist.dta`. Print a table as shown below, which displays the number of
patients with a non-missing PRA value at each visit. `N` and `XX` should be replaced with the
correct values from the dataset. (Hint: how do you write a forvalue loop for all values of
`visit_id`?)

```stata
Question 1.i)
Visit 	Count
1 			XX
2 			XX
		⋮
[omitted, but your .do file should display all variables]
		⋮
N 			XX
```

**ii)** Create a new variable `peak_pra`, which contains the maximum value of PRA within each
participant. Print the median (IQR) of `peak_pra` across the patients as shown below. `XX.X`
should be replaced with the correct values from the dataset and formatted with one digit after
the decimal point (e.g., 12.0 ). (Hint: each patient must be counted only once when calculating
the median and IQR.)

```stata
Question 1.ii): The median (IQR) of peak_pra is xx.x (xx.x-xx.x).
```

**iii)** Another dataset provided to you, `hw5_hosp.dta`, has information on which region each
hospital is located in. Merge the current dataset in memory with hw2_hosp.dta without
altering the number of observations in memory. Use the command `list` to list the ID of the
patient with the highest peak_pra value for each region as shown below.

`XX` should be replaced with the correct values from the dataset. If there are ties (i.e., multiple
patients with the highest value), print all tied patients. If region C has ties (while A and B does
not), the table will look like below.

```stata
+------------------------------------+
| region 	px_id 	peak_pra         |
|------------------------------------|
| A  	        XXXX    XXXX         |
|------------------------------------|
| B  	        XXXX    XXXX         |
|------------------------------------|
| C 	        XXXX    XXXX         |
| C  	        XXXX    XXXX         |
+------------------------------------+
```
Hint: your `list` command should look like this

```stata
list region px_id peak_pra [insert your code here], sepby(region) noobs
```



### Question 2

Define a program called `unilogit`. This program runs a series of univariable (simple) logistic
regressions between each of the predictors supplied by the user and a binary outcome variable
also supplied by the user.

For example, if the user runs
```stata
unilogit var1 var2 var3 var4, outcome(var5)
```

this program will quietly run four univariable logistic regressions on var5,
```stata
logistic var5 var
logistic var5 var
logistic var5 var
logistic var5 var
```

and return the following output, assuming that `var2` and `var4` were significantly (p<0.05)
associated with `var5`.

```stata
Significantly associated with var5:
var2 (p=x.xxx)
var4 (p=x.xxx)
```

P-values should be rounded to the nearest thousandth (i.e., three digits after the decimal point).



<u>This program should also support if subsetting.</u> For example, if the user runs

```stata
unilogit var1 var2 var3 if var4==1, outcome(var5)
```

this program should run only on the observations with `var4==1`.



<u>This program should not alter the dataset in the memory</u>: i.e., if you need to alter the dataset,
`preserve` before making changes and `restore` to the original status after completing your
procedures.



Hint: The program `model` in lecture 4 has some similarities with this question. The p-value after
`logistic` can be obtained using the following code:

```stata
//stata14 & older
(1-normal(abs(_b[var1]/_se[var1])))*2

//stata15 & newer
matrix define m=r(table)

//see `chapter: by` on how to select the p-value

//alternatively: use `lincom`, then `return list`
```