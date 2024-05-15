# HW6 (Supplement)

Write a .do file that performs the tasks described below. Your .do file must be called
`hw6sup.lastname.firstname.do`. Make sure your script will run on our machines by handling [filepath ambiguity](https://jhustata.github.io/basic/hw3sol.html?highlight=ambiguity#handling-file-path-ambiguity) in your script. Do **not** submit your log files as part of the assignment.

# 
Use the dataset `pra_hist.dta` and `student_pressure.dta` to perform the required tasks. 

```stata
global repo https://github.com/jhustata/basic/raw/main/
```

Questions 

**Context**: Two students discuss HW6 and comeup with the following solution to **Q1**:

```stata
use ${repo}pra_hist.dta, clear  
l in 1/10
g count=1
bys visit_id: egen Count=sum(count)  
l in 1/10
egen tagvisit = tag(visit)
l visit_id Count if tag==1
```

Focusing on the output rather than the code, you compare this solution with the that posted by the teaching team and find slight differences in output. You then analyze the code and find that the teaching team used the "collapse" command whereas the students used the "egen" and "tag" commands. How would you help these students to remain true to their unique approach, but with accurate output? In other words, modify their code.

The original question is included below for your convenience:

> You are conducting a study that examines the regional variation in the distribution of panel-
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
| **student_pressure.dta**  |                        |                                                              |
| `student_id`              | Hospital ID            | Integers: 1 – 100                                            |
| `session`                 | Region                 | Integers: 1 - 8                                              |
| `sbp`                     | Region                 | Intergers:  "within biological limits"                       |
| `session_date`            | Region                 | Dates: 28mar2024 - 16may2024                                 |

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

**ii)** An eccentric instructor measured the blood pressure of students over an eight week period. Blood pressure was measured before each one of eight weekly sessions, and a record for each student was kept. After analyzing these records, can you print out the following statement, substituting the XXXs with appropriate macros?

"student_id XXX has the highest blood pressure on record, SBP=XXX for session X"

```stata
use ${repo}student_pressure, clear
```



 