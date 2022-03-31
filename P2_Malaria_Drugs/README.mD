# Malaria Drugs

Abstract:
The ChEMBL database was explored using MySQL to find compounds known to act against Plasmodium species (cause malaria). A number of compounds where selected (they where indexed with: MeSH (Medical Subject Heading) = Malaria; Level 4 ATC Code = Antimalarial) and some information was exported from the database (Table: "Known Malaria Drugs")
The Smiles codes for these compounds where exported as well and an image of the chemical structure was created using R (Table: "Chemical Structure"; R Script: "Smiles_to_Structure.R")

As the ChEMBL database did not contain that much information about products on the market etc. with the selected compounds, the database Drugs@FDA was downloaded and imported to MySQL. The data was then explored and some usefull information was exported after beeing manipulated directly in MySQL. (Table: "Drugs on US Market")

At last the Labels (XML files) for products on the market containing the selected compounds where accessed on the FDA webpage where accessed using R. The text was split into different sections and exported. (Table: "FDA Labels")

A dashboard with all of the exports was created in Tableau.

What I learned:

-Importing tables into MySQL

-Data manipulation in MySQL

-Basics in webscraping using R (rvest)

-getting information from XML (xml2)


Possiblities for improvement:
The parsing of the XML could be improved. As some of the labels had a somewhat different layout, my function did not work perfectly on all of them.
The formating of the text (line breaks) could be improved.



Duration:

-MySQL: 14 h

-R: 14 h

-Tableau: 2 h



Dashboard: https://public.tableau.com/app/profile/dominik7147/viz/P2_Malaria_Drugs/Dashboard1?publish=yes

