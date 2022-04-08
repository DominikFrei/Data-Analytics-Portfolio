# Abstract

In this project several measures of disproportionality ($\chi^{2}$, RRR, ROR, PRR, Fishers exact test, BCPNN)
where calculated for a selection of adverse events
and the three Covid-19 vaccines on the market in the US. The data for the contingency tables,
these measures where calculated from, was retrieved 
from a previously set up MySQL database, containing data published by the FDA.
This was done via SQL queries written via an R script. Then the actual values for the
contingency tables, as well as the measures of disproportionality and their confidence intervals and
p-values where calculated.

In some cases these calculations where done via functions written by myself. In other cases
preexisting functions where used.

The results where visualized via barcharts and a heatmap and then interpreted.

## Resources:

- Chapter 20 "Quantitative Signal Detection and Analysis in Pharmacovigilance" of "MANN’S PHARMACOVIGILANCE THIRD EDITION" edited by E. ANDREWS and N. MOORE, 2014 by John Wiley & Sons, Ltd.
- "Primer on Disproportionality Analysis" Version: 2018-10-16 by Ruwen Böhm (Uni Kiel)

## What I learned:

- Inserting results from SQL querries into a table, to collect them and retrieve them as a whole
- Accessing a MySQL database via R Markdown
- Using R Markdown to present code, results and mathematic formulas
- Creating plots with ggplot2
- Better command of dplyr functions
- Interpreting statistics (p-value, confidence interval)
- Properties of and how to calculate several measures of disproportionality

## Possible Improvements:
- Use one-sided tests instead of two-sided tests

## Duration:

- MySQL: 15 h
- R: 25 h
- Other (writing, reading literature etc.): 10 h

## Links:
To view all the code directly in your browser use the link below:

https://rawgit.com/DominikFrei/Data-Analytics-Portfolio/main/P4_Quantitative_Signal_Detection_Covid_Vaccines/P4_Signal_Detection_Covid_Vaccines.html
