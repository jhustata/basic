capture log close //what does this codeline do?
log using hw1.do, replace //if you do not include the "replace" option, what may happen?
set timeout1 180 //with a poor internet connection (as some of you experienced at Hopkins in wk1), you may need to increase this from the defaul
import delimited "https://jhustata.github.io/book/_downloads/884b9e06eb29f89b1b87da4eab39775d/hw1.txt", clear //and the clear option?
di "Question 1: There are `c(N)' records in the dataset" //this is the homework answer; everything else here is good practice and will earn you points in subsequent homeworks
log close //always close your .do file