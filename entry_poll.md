

![](survey.jpg)


1. Right-click [this link](https://raw.githubusercontent.com/jhustata/basic/main/entry_poll.csv) to download the .csv entry-poll results to your machine

2. Open Stata's `Menu > File > Import > Text data (delimited, *.csv)`

```stata
import delimited "/Users/d/Downloads/entry_poll.csv", bindquote(strict) //edit file path

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

9. Let's clean up the skill variable

```stata
tab skill
tab skill, nolab
```


<details>

   <summary><b>GPT-4 Assisted Analysis</b></summary>

   <iframe width="560" height="315" src="https://www.youtube.com/embed/-cH9b5HzF4Y" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

   <iframe width="560" height="315" src="https://www.youtube.com/embed/SKYbqprIy0U" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

</details>