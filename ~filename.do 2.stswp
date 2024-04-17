<<dd_version: 2>>     
<<dd_include: header.txt>>

# How to embed Stata results in .html  

### Abimereki Muzaale

**Background:** 
A <u>user</u> downloads and installs a <u>system</u> of program files, mostly ado-files, which form the foundation of most of the commands 
used in Stata Programming. Using those commands and additional syntax written out sequentially in a do-file, the user creates 
well-formed instruction to Stata called a do-file script. Once the user runs this script, results are generated and displayed
in the results window, in a graph, or in a file (`.xlsx`, `.log`, `.dta`, `.docx`, `.md`, `LaTeX`, `.html`, etc). The `.html` file format is of specific 
interest since its the pathway to self-publication. To illustrate how this may be achieved in Stata, we hereby introduce the `dyndoc`
command. 

**Methods:** 
We created a do-file and populated it with this abstract using [markdown](https://en.wikipedia.org/wiki/Markdown) language. Anything 
in this document that is not ordinary text including `<<dd_version: 2>>`, `<<dd_do:nooutput>>`, `<</dd_do>>`, `<<dd_display: c(N)>>` is a 
[markup](https://en.wikipedia.org/wiki/Markup_language#:~:text=A%20markup%20language%20is%20a,content%20to%20facilitate%20automated%20processing.). 
Results that might be numeric, string, alphanumeric, or formatted as macros are embeded at these markedup points. We then saved this 
document using the file extension .do; however, any text file extension will work (.txt, .md, .do, etc). To the `pwd` where we saved
this text file, we added a cascading style sheet [stmarkdown.css](stmarkdown.css) and [header.txt](header.txt) to enhance the aesthetic of our .html file. Finally, we typed the 
following command into the Stata command window: `dyndoc filename.txt, saving(filename.html)`. 

```
<<dd_do:nooutput>>
webuse lifeexp, clear 
encode country, gen(Country)
quietly sum lexp
qui local lexp_mean: di %3.0f r(mean) 
quietly sum Country
qui local Country_mean: di r(mean)  
twoway scatter lexp Country, ///
   xscale(off) ///
   yline(`lexp_mean', ///
      lc(red) ///
      lp(dash) ///
   ) ///
   text(`lexp_mean' `Country_mean' "Mean life expectancy among countries")
graph export lexp_bycountry.png, replace 
<</dd_do>>
```

<<dd_graph>>

$Y  = \beta_0   +  \beta_1 X$       
Where Y is Life expectancy at birth in years.     
X is the country, the predictor or independent variable.       
And $\beta_0$ is the average life expectancy of all countries.  
Of course $\beta_1$ is zero or meaningless (countries are alphabetically listed)         
  

```
<<dd_do>>
display c(N) 
display c(k)  
list in 1/5  
<</dd_do>>
```

**Results:** 
We identified the newly created .html file in our folder and openned it to compare its format to this markdown file. And we saw all that
we had made, and behold, it was very good. Ghastly looking macros in the original markdown language now appeared as neatly formatted
results. For instance, there were  <<dd_display: c(N)>> observations and <<dd_display: c(k) >> observations in the analyzed dataset. 

**Conclusions:** 
In walking you through syntax, do-file creation, queued commands, generated results, through to embedding neatly formatted output in
.html, we believe you now have a solid sense of all that Stata has to offer you. These ideas can be generalized to embedding results 
in .xlsx, .log, .dta, .docx, etc. 




