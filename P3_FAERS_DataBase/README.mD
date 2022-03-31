# P3 FAERS Database

# Abstract
The aim of this project was to import Adverse Event Data published by the FDA (here: https://fis.fda.gov/extensions/FPD-QDE-FAERS/FPD-QDE-FAERS.html) in the form of XML files into a MySQL Database. In Part 1 I tried to import the XML files into R, extract the data and save it as .csv files. The reason for this was, that the MySQL workbench supports import of .csv files via the “Table Data Import Wizard”, which does not require to write any statements to set up the tables and import the data. I wrote a function in R that produces a csv file out of an XML (tested on on a small XML file, containing only ca. 30 cases). As there where many problems with using the “Table Data Import Wizard” (e.g. it chooses the wrong datatype etc.) I decided to write statements to create the tables and import the data. I was able to set up everything properly. However, when I tested my R function on one of the “big XML” (one out of three that are published each quarter) I realized, that this takes way too long and abandonned this strategy.

In part two I improved the statements for setting up the database and imported the XML files directly into MySQL.

Resources: I used this blogbost as reference to treat nested XML files: https://medium.com/geekculture/reading-xml-files-in-r-3122c3a2a8d9

What I learned: - extracting data from nested XML files using xml2 package - data manipulation using dplyr package - setting up and importing data into MySQL database

Duration:\ 
- MySQL: 13 h\ 
- R: 15 h\ 
- Other (writing/correcting text): 3 h\ 

To view all teh written code directly in your browser use the link below:
https://rawgit.com/DominikFrei/Data-Analytics-Portfolio/main/P3_FAERS_DataBase/P3_FAERS_DataBase_combined.html
