## HW1 solution


### 1. Create a .do file
```stata
capture log close 
log using hw1.lastname.firstname.log

// code

log close
```

### 2. Name your `.do` file

- Copy and paste the above `.do` file structure into your `.do` file
- Save it as `hw1.lastname.firstname.do`

### 3. It should create a `.log` file

- Done! (See section 1 above)

### 4. Display only the output of interest

You'd not yet covered the `quietly` command at the time, but here's how to go about it:

```stata
quietly {

   // the rest of your do-file content, indented

}
```

#### Question

Putting it all together:

```stata
qui {
   capture log close
   log using hw1.lastname.firstname.log
   
   //settings
   global dataset "https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt"
  set timeout1 1000

   // code
   import delimited $dataset, clear
   noisily di "Question 1: There are `c(N)' records in the dataset"

   log close
}

```

Read more about [set timeout](https://www.stata.com/support/faqs/web/common-connection-error-messages/)