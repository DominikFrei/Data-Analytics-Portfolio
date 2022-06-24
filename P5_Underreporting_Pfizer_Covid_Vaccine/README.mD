# P5 Underreporting Pfizer Covid Vaccine

## Abstract

In this work I tried to find factors that might have influenced how many adverse events 
per dose administered where reported to the FDA that are related with the Pfizer Corona Vaccine.
I looked at the time period since the launch of the vaccine until the end of 2021 in the USA.

I used data from the FAERS database (Database containing information about reported cases of
Adverse Events with Medicinal Products; FDA publishes this
data and I had previously set up a MySQL database with all the reports from 2020 and 2021)
and some datasets concerning covid vaccinations and numbers of cases and deaths, 
which where published by the US government.

First I did some exploratory data analysis, where among other things, I tried to find out if
there where more cases with the second administered dose then with the first one.

Then I fitted some linear regression models (simple, multiple and for an exponential relationship)
to find possible correlations with the number of cases reported per dose administered.

The only finding was that the number of cases reported per dose administered decreased
over time (probably in an exponential decay).

## Resources:

- FAERS Database: years 2020 and 2021
- dataset concerning Covid vaccines in the US: https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-Jurisdi/unsk-b7fc, accessed: 08.04.2022
- dataset concerning Covid cases and deaths in the US: https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36, accessed on 14.04.2022

## What I learned:

- Processing datetime data in R
- Plotting with ggplot2
- Fitting simple and multiple linear models (including transformations before fit, for exponential model)
- Checking model assumptions for simple and multiple linear models

## Duration:

- MySQL: 0.5 h
- R: 37 h
- Other (writing etc.): 7 h

## Links:
To view all the code directly in your browser use the link below:

https://rawgit.com/DominikFrei/Data-Analytics-Portfolio/main/P5_Underreporting_Pfizer_Covid_Vaccine/P5_Underreporting_Pfizer_Covid_Vaccine.html
