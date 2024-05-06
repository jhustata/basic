# Lab 6

### Part I 


1. Start Stata, open your do-file editor, write the header, and load `transplants.dta`.

```stata
global repo https://github.com/jhustata/basic/raw/main/
use "${repo}transplants", clear 
```

2. `ctr_id` indicates the ID of the transplant center where the patient received the transplant. Count the number of recipients at each center, and store in a new variable `volume`.

3. List `ctr_id` and `volume` to see how many patients each center has. Maybe let's try this:

   `list ctr_id volume`

4. This is **not** what we wanted. Generate a variable `ctr_tag` that "tags" one observation per center. See week 3 [Section 3.3](https://jhustata.github.io/basic/chapter3.html?highlight=tag#tag) for more examples on the function `tag()`

5. Now `list ctr_id` and `volume`, but just for one record per center.

6. Calculate the mean age of the patients at each center, and store in a new variable `mean_age`.

7. For each primary diagnosis subgroup (use variable `dx`), run a regression with age as the predictor and peak PRA (`peak_pra`) as the outcome.

8. Now let's make the output cleaner. Count the number of cases within each diagnosis group. If there are more than 500 cases, run the regression and display the output. If not, display "There are fewer than 500 cases."

9. Define a program called `reg_pra`. This program will perform the same tasks as described in Question 8, but the regression will take one or more variables specified by the user as the predictor.

10. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.

### Part II

Hopefully you spent some time mastering the notes [from week 4](https://jhustata.github.io/basic/chapter4.html#essential-skills-to-master-by-week-s-end). But because you didn't have the incentive in the form of homework, here's an additional opportunity for you.

1. Start Stata, open your do-file editor, and load `transplants.dta` 

```stata
use ${repo}transplants, clear 
```

2. Let's merge this dataset with the donor dataset. First, merge with `donors_recipients.dta`, and then with `donors.dta`, without specifying any options.

   ```stata
   merge 1:1 fake_id using ${repo}donors_recipients
   ```

3. What does Stata say? Interpret the output.

   ```stata
   . merge 1:1 fake_id using ${repo}donors_recipients
   
       Result                           # of obs.
       -----------------------------------------
       not matched                         4,000
           from master                         0  (_merge==1)
           from using                      4,000  (_merge==2)
   
       matched                             6,000  (_merge==3)
       -----------------------------------------
   ```
   > From the bottom: 6000 observations were successfully merged. 4000 observations from the using dataset (= donors_recipients.dta) were NOT matched with the master dataset (= transplants.dta) but brought in anyways. 0 observation from the master dataset were not matched (i.e., all observations from the master dataset were matched.)

4. `transplants.dta` is our study population. We don't want to bring in extra observations by merging. Use the option `keep` and make sure we don't bring in extra observations from `donors_recipients.dta`.

   ```stata
   use ${repo}transplants, clear
   merge 1:1 fake_id using ${repo}donors_recipients, keep(master match) nogen
   ```

5. Let's move forward and merge with `donors.dta`.

   ```stata
   merge m:1 fake_don_id using ${repo}donors, keep(master match)
   ```

6. Now we want to calculate the mean age and the number of patients at each center. Preserve the dataset and collapse it by `ctr_id`. Explore the collapsed dataset using `list`.

   ```stata
   preserve
   collapse (mean) age (count) n=fake_id, by(ctr_id)
   ```

7. Restore the dataset. The plan has changed. We want to calculate these statistics in ECD cases and non-ECD cases separately (use the variable `don_ecd`). Calculate the mean age and the number of ECD patients and non-ECD patients at each center.

   ```stata
   restore
   collapse (mean) age (count) n=fake_id, by(ctr_id don_ecd)
   ```

8. After the collapse, each center has two observations. One for ECD cases and another for non-ECD cases. Reshape the dataset into a wide format (i.e., each center has only one observation).

   ```stata
   reshape wide age n, i(ctr_id) j(don_ecd)
   ```

9. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.