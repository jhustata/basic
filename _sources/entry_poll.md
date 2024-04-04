

![](survey.jpg)


1. Right-click [this link](https://raw.githubusercontent.com/jhustata/basic/main/entry_poll.csv) to download the .csv entry-poll results to your machine

2. Open Stata's Menu > File > Import > Text data (delimited, *.csv)

```stata
import delimited "/Users/d/Downloads/entry_poll.csv", bindquote(strict) //why this option?

```

3. Inspect your data. Notice anything that needs to be fixed?

```stata
list in 1/3
```

4. Drop the first row since its the variable name

```stata
drop in 1/1
```

5. Now do some basic descriptive stats

```stata
tab v1

tab v2

tab v3
```

6. Something weird going on, but we can address it with a vew lines of code

```
desc
encode v1, g(local)
encode v3, g(skill)
encode v2, g(os)
```

7. Let's see what `encode` achieved

```stata
describe
```

8. Back to data-cleaning

```stata
tab os
tab os, nolab
```

```stata
. tab os

os	Freq.	Percent	Cum.
			
MacOSX	28	51.85	51.85
MacOSX;
Windows	4	7.41	59.26
Windows	22	40.74	100.00
			
Total	54	100.00

.	tab	os, nolab

		os	Freq.	Percent	Cum.
					
		1	28	51.85	51.85
		2	4	7.41	59.26
		3	22	40.74	100.00
					
		Total	54	100.00


```

9. Let's clean up the skill variable

```stata
tab skill
tab skill, nolab
```

```stata
skill	Freq.	Percent	Cum.
			
Advanced User. I can do multivariable r	4	7.41	7.41
Basic Knowledge. I have a general under	21	38.89	46.30
Basic Knowledge. I have a general under	2	3.70	50.00
Competent User. I am proficient in usin	8	14.81	64.81
Competent User. I am proficient in usin	3	5.56	70.37
Expert User. I can write custom program	1	1.85	72.22
No Experience. I have no prior experien	3	5.56	77.78
No Experience. I have no prior experien	1	1.85	79.63
Novice User. I am familiar with basic c	10	18.52	98.15
Novice User. I am familiar with basic c	1	1.85	100.00
			
Total	54	100.00

. tab skill, nolab

      skill |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          4        7.41        7.41
          2 |         21       38.89       46.30
          3 |          2        3.70       50.00
          4 |          8       14.81       64.81
          5 |          3        5.56       70.37
          6 |          1        1.85       72.22
          7 |          3        5.56       77.78
          8 |          1        1.85       79.63
          9 |         10       18.52       98.15
         10 |          1        1.85      100.00
------------+-----------------------------------
      Total |         54      100.00



```





<details>

   <summary><b>GPT-4 Assisted Analysis</b></summary>

   <iframe width="560" height="315" src="https://www.youtube.com/embed/-cH9b5HzF4Y" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

   <iframe width="560" height="315" src="https://www.youtube.com/embed/SKYbqprIy0U" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

</details>