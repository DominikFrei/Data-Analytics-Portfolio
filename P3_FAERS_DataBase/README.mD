# P3 FAERS Database

## Abstract
The aim of this project was to import adverse event data published by the FDA (here: https://fis.fda.gov/extensions/FPD-QDE-FAERS/FPD-QDE-FAERS.html) in the form of XML files into a MySQL Database.
In Part 1 I tried to import the XML files into R, extract the data and save it as CSV files. The reason for this was, that the MySQL workbench supports import of CSV files via the “Table Data Import Wizard”, which does not require to write any statements to set up the tables and import the data. I wrote a function in R that produces a CSV file out of an XML (tested on a small XML file, containing only ca. 30 cases). As there where many problems with using the “Table Data Import Wizard” (e.g. it chooses the wrong datatype etc.) I finally decided to write statements to create the tables and import the data. I was able to set up everything properly. However, when I tested my R function on one of the “big XML” (one out of three that are published each quarter) I realized, that this takes way too long and abandonned this strategy.
In part two I improved the statements for setting up the database and imported the XML files directly into MySQL.

## Resources: I used this blogbost as reference to treat nested XML files: https://medium.com/geekculture/reading-xml-files-in-r-3122c3a2a8d9

## What I learned:
- Extracting data from nested XML files using xml2 package
- Data manipulation using dplyr package
- Setting up and importing data into MySQL database
- Presenting code via R Markdown

## Possible Improvement:
- The function to convert XML to CSV was missing a part where the separator sign (here: ";") used in the CSV would have been replaced in the data
- The Tables in the created Database contain many columns. It might have made sense to set up more but smaller tables.

## Duration:
- MySQL: 13 h
- R: 15 h
- Other (writing/correcting text): 3.5 h

## Links
To view all the code directly in your browser use the link below:

https://rawgit.com/DominikFrei/Data-Analytics-Portfolio/main/P3_FAERS_DataBase/P3_FAERS_DataBase_combined.html
