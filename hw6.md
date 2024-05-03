# HW6

Write a .do file that performs the tasks described below. Your .do file must be called
`hw2.lastname.firstname.do`. Make sure your script will run on our machines by handling [filepath ambiguity](https://jhustata.github.io/basic/hw3sol.html?highlight=ambiguity#handling-file-path-ambiguity) in your script. Do **not** submit your log files as part of the assignment.

# Part I
Use the dataset `pra_hist.dta` and `hosp.dta` to perform the required tasks. 

```stata
global repo https://github.com/jhustata/basic/raw/main/
```

Questions

**Context** : You are conducting a study that examines the regional variation in the distribution of panel-
reactive antibody (PRA). You recruited 73 patients (`px_id` = 1, ...., 73 ) from 10 hospitals (`hosp_id`=1, ...,10)
in 3 regions (`region`=A, B, C, ... ), and measured PRA 3 times: visit 1, visit 2, and visit 3. You hear that the
organization that funds your research plans to extend the funding for several more visits (visit 4, visit 5,
..., visit N). Since you do not know how many more visits there will be, you decide to write a .do file that
can work regardless of how many visits the dataset has.


**Codebook**

| Variable                  | Description            | Values/Range                                                 |
| ------------------------- | ---------------------- | ------------------------------------------------------------ |
| **pra_hist.dta** |                        |                                                              |
| `hosp_id`                 | Hospital ID            | Integers: 1 – 10                                             |
| `px_id`                   | Patient ID             | Integers: 1 – 94                                             |
| `visit_id`                | Visit ID               | Integers: 1 – N<br/>1 indicates the first visit. K indicates the K-th visit. |
| `pra`                     | PRA value at the visit | Integers: 0 – 100                                            |
| **hosp.dta**     |                        |                                                              |
| `hosp_id`                 | Hospital ID            | Integers: 1 – 10                                             |
| `Region`                  | Region                 | Alphabets                                                    |

Note: to uniquely identify a patient you'd have to specify both hospital ID **and** patient ID. In other words, patients in different hospitals may have the same Patient ID

**i)** Load `pra_hist.dta`. Print a table as shown below, which displays the number of
patients with a non-missing PRA value at each visit. `N` and `XX` should be replaced with the
correct values from the dataset. (Hint: how do you write a forvalue loop for all values of
`visit_id`?)

```stata
use "${repo}pra_hist", clear
```

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

**iii)** Another dataset provided to you, `hosp.dta`, has information on which region each
hospital is located in. Use the `merge` command to merge the current dataset in memory with `hosp.dta` without
altering the number of observations in memory (see week 3 [Section 3.3](https://jhustata.github.io/basic/chapter3.html?highlight=merge#merge) for syntax or week 4 Section [4.2](https://jhustata.github.io/basic/chapter4.html#merging-files) for notes during a lecture session). Use the command `list` to list the ID of the
patient with the highest peak_pra value for each region as shown below.

```stata
use "${repo}hosp", clear
```

`XX` should be replaced with the correct values from the dataset. If there are ties (i.e., multiple
patients with the highest value), print all tied patients. If region C has ties (while A and B does
not), the table will look like below.

```stata
+------------------------------------+
| region 	px_id 	peak_pra     |
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

## Part II                                                             [.]()





