# Lab 5

This lab is optional; you are NOT required to complete these questions. Please use this lab as an opportunity to review the course material and prepare yourself for the homework questions. Sample responses to the lab questions will be on Friday May 2, 2024.

# Part I

1. Start Stata, open your do-file editor, write the header, and load `transplants.dta`.

```stata
use "https://github.com/jhustata/basic/raw/main/transplants.dta", clear
```

2. `ctr_id` indicates the ID of the transplant center where the patient received the transplant. Count the number of recipients at each center, and store in a new variable `volume`.

3. List `ctr_id` and `volume` to see how many patients each center has. Maybe let's try this:

   `list ctr_id volume`

4. This is not what we wanted. Generate a variable `ctr_tag` that "tags" one observation per center.

5. Now `list ctr_id` and `volume`, but just for one record per center.

6. Calculate the mean age of the patients at each center, and store in a new variable `mean_age`.

7. For each primary diagnosis subgroup (use variable `dx`), run a regression with age as the predictor and peak PRA (`peak_pra`) as the outcome.

8. Now let's make the output cleaner. Count the number of cases within each diagnosis group. If there are more than 500 cases, run the regression and display the output. If not, display "There are fewer than 500 cases."

9. Define a program called `reg_pra`. This program will perform the same tasks as described in Question 8, but the regression will take one or more variables specified by the user as the predictor.

10. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.

# Part II

# lab4

1. We discussed how you can define your own “program”. It’s an awesome tool that allows us to automate a specific task. If you think a specific part of your code will be used multiple times, you might as well put that into a program. In this lab, we will practice customizing our programs.

2. Start Stata, open your do-file editor and consider using conditional code-blocks (`if 2` for instance) as you answer each question in this lab. That way each block has some autonomy and you can "silence" it (`if 0`) while you run other code-blocks.

3. Write a program called `mymean`. This program will take `varlist` as a user input, and calculate the mean value of each variable, and display the values.

4. Modify your program `mymean` so that when an `if` argument is supplied, `mymean` would only include the observations that meet the condition specified by the `if` argument. In other words, if the user types `mymean height if age>65`, the program `mymean` will calculate the mean only among patients older than 65.

5. Further modify your program `mymean` to include the option `sd`. When the option `sd` is supplied, `mymean` will display the standard deviation along with the mean. This version of `mymean` should still be able to accommodate the `if` argument.

6. Further modify your program `mymean` to include the option `digits()`, with a number in the parenthesis. When the option `digits()` is supplied, `mymean` will round up the mean (and the standard deviation, if applicable) in units of `digits()`. If `digits()` is NOT supplied, round in units of 0.001. (Hint: use the Stata function `round()`)

7. Did you make `if`, `sd`, and `digits()` optional arguments? That is, your program should run whether or not these arguments are supplied. To do so, simply surround each argument with brackets. For example, `[sd]`

8. I’d like to draw your attention to the merge command. It’s hard to write a question around `merge`, but it’s a really important command in practice. For instance, we used it in the [week 4](https://jhustata.github.io/basic/chapter4.html#merging-files). Reference these notes when necessary in the future.

9. We want to study if death (`died==1`) is associated with several predictor variables: `bmi`, `prev_ki`, `age`, `peak_pra`, or `gender`. Run logistic regression between `died` and each of the predictor variables using `foreach` loop. At each run, save the name and the regression coefficient of the predictor variable into an external Stata dataset file named `output.dta`.

10. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing.
