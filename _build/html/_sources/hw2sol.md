## HW2 solution


### 1. Create a .do file
```stata
capture log close 
log using hw2.lastname.firstname.log

// code

log close
```

### 2. Name your `.do` file

- Copy and paste the above `.do` file structure into your `.do` file
- Save it as `hw2.lastname.firstname.do`

### 3. It should create a `.log` file

- Done! (See section 1 above)

### 4. Display only the output of interest

You'd not yet covered the `quietly` command at the time, but here's how to go about it:

```stata
quietly {

   // the rest of your do-file content, indented

}
```

#### Questions 1 & 2

Putting it all together:

```stata
 qui {
   cls 
   capture log close
   log using hw2.lastname.firstname.log, replace
   
   // settings
   global dataset "https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt"
  set timeout1 1000

   // dataset
   import delimited $dataset, clear
   describe //to view your data "dictionary"; initially do so noisily  

   //q1
   sum init_age if female==0, detail
   local age_m_p50: di %2.0f `r(p50)'
   local age_m_p25: di %2.0f `r(p25)'
   local age_m_p75: di %2.0f `r(p75)'

   sum init_age if female==1, detail
   local age_f_p50: di %2.0f `r(p50)'
   local age_f_p25: di %2.0f `r(p25)'
   local age_f_p75: di %2.0f `r(p75)'
   noisily di "Question 1: The median [IQR] age is `age_m_p50' [`age_m_p25'-`age_m_p75'] among males and `age_f_p50' [`age_f_p25'-`age_f_p75'] among females."

   //q2
   sum if female==0 & prev==1, detail
   local male_per: di %2.1f `r(mean)'*100

   sum if female==1 & prev==1, detail
   local female_per: di %2.1f `r(mean)'*100

   noi di "Question 2: `male_per'% among males and `female_per'% among females have history of previous transplant"

   log close
}
```

Read more about [set timeout](https://www.stata.com/support/faqs/web/common-connection-error-messages/)