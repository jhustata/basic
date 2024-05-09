# lab7  

Please use this lab as an opportunity to review the course material and prepare yourself for `hw7`. Sample responses to the lab questions are provided below.

```stata
global repo https://github.com/jhustata/basic/raw/main/
```
 
1. Start Stata, open your do-file editor, write the header, and load `transplants.dta`.

```stata
use "${repo}transplants", clear
```
 
2. Get a 10% random sample of the dataset. Specifically, follow these steps. (1) Set a seed number. (2) Generate a variable that includes a random number between 0 and 1 following a uniform distribution. (3) Sort by the random variable. (4) Keep the first 10% observations and drop the rest. (5) Drop the random variable.

3. Clear and reload `transplants.dta`.

```stata
use "${repo}transplants", clear
```

4. Generate a variable called `fake_age` which is a normally distributed random variable with mean and standard deviation equal to the mean and standard deviation of the actual age variable.

![kdensity.png](kdensity.png)

5. Make a scatter plot of peak PRA by age in transplant recipients. Does it look like there's a relationship between peak PRA and age, and if so, what is the relationship?

![lab6q5.png](lab6q5.png)

6. The graph of proportion of ECD transplants by age is a little messy. 

![Picture1](collpasebyage.png)

Remake the graph with the age rounded to the nearest ten years.

![Picture2](collpasebyage10.png)
   

7. You have all your commands in your do file, right? Run your do file from the beginning and make sure your do file does exactly the same thing. 


