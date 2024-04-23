
# Resource for the Teaching Team

## 1. Lab Solutions
   - [Lab 1 Solution](lab1sol.md)
   - [Lab 2 Solution](lab1sol.md) *(Note: Same link to Lab 1's solution. No error)*
   - [Lab 3 Solution](lab3sol.md)
   - Lab 4 Solution (pending)
   - Lab 5 Solution (pending)

## 2. Homework Solutions
   - [HW 1 Solution](hw1sol.md)
   - [HW 2 Solution](hw2sol.md)
   - [HW 3 Solution](hw3sol.md) This is now available to students
   - <strike>HW 4 Solution </strike>
   - HW 5 Solution (pending)
   - HW 6 Solution (pending)
   - HW 7 Solution (pending)

## 3. Quick References
   - [Stata Commands Quick Reference](https://jhustata.github.io/basic/chapter3.html#commands-that-run-without-additional-syntax)

## 4. GitHub Discussions
   - Link to discussions (pending)

## 5. TA-Student Match
   - [TA-Student Matching for HW3 Grading](tastudentmatch.md)
   - Overview:
     - TAs will grade assigned students for HW3.
     - TAs should provide feedback in the `.do` file and via GradeBook notifications.
     - The matching list will be updated for subsequent homeworks.

## 6. Rubrics for Grading
   - See below for the initial grading rubric for HW3.

### GPT-4 Rubric, First Iteration

The following grading rubric is designed to assess students on HW3. TAs are encouraged to adjust the rubric as they see fit, especially in providing feedback. All students start with 100%, and points are deducted based on the issues noted below, but they may earn up to 5 bonus points for innovation and accuracy of output:

**Note**: If you disagree with any aspect of this rubric, let me know ASAP. Your critique will be regarded in a timely fashion!

#### Total Points: 100 (no student will lose more than 20 points; some students may score as many as 105 points)

1. **Code Structure and Documentation**
   - **Clarity (up to -1 point)**: Deduct if code is disorganized or hard to follow. (`deduct only once, even if several blocks of code are disorganized; use same approach for other issues`)
   - **Comments (up to -2 points)**: Deduct for inadequate comments explaining code blocks, methods, or variables.
   - **Readability (up to -1 point)**: Deduct for poor use of spacing, indentation, or naming conventions.

2. **Execution and Functionality**
   - **Correctness (up to -3 points)**: Deduct if the script has errors or does not produce the expected output.
   - **Efficiency (up to -2 points)**: Deduct if code is inefficient with unnecessary repetitions or calculations. 
      - `Based on this point, our solution below loses about one point; -1 points for repetition in creating the .xlsx file; a loop should make this more efficient`
   - **Completeness (up to -1 point)**: Deduct if any part of the script is missing or non-functional.

3. **Data Handling and Analysis**
   - **Data Import (up to -1 point)**: Deduct if data is incorrectly imported or cleaned.
   - **Variable Creation (up to -2 points)**: Deduct if variable creation or transformation is incorrect.
   - **Descriptive Statistics (up to -2 points)**: Deduct if there are errors in the computation or display of statistics.

4. **Results and Output Quality**
   - **Table Outputs (up to -2 points)**: Deduct if outputs in both `.log` and `.xlsx` formats are incorrect or unclear.
   - **Labeling and Presentation (up to -2 points)**: Deduct if variables and results are improperly labeled or presented.
   - **Interpretation (up to -1 point)**: Deduct if the results are not briefly explained or interpreted correctly.

#### Additional Considerations:
- **Innovation (Bonus up to +5 points)**: Award for creative approaches that enhance the analysis or presentation. Perhaps five innovations earn five points. Three earn three, etc.

### Final Note
Please ensure to email any doubts regarding grading to me and write the final score at the top of the script as shown in the rubric example.


```stata
//Final grade: 99.5%. Outstanding!

//code

//General note: be lenient, since I didn't give the students this rubric early enough (the rubric is really lenient anyway!)
//use comments like this above the code
//-0.5 points: could improve on organization of code

```


