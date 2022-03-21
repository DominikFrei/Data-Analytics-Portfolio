###########################
##		ChEMBL V29
###########################

-- find antimalaria drugs that are on the market

-- look at drug_indication table
select * from drug_indication
where mesh_heading like 'Malaria';
-- 81 results
-- mesh_id is the same for all these (D008288)

-- check if all with same mesh heading are included above
select * from drug_indication
where mesh_id = 'D008288';
-- also 81 results => yes

-- have a look at molecule dictionary table for these drugs
select * from molecule_dictionary
where molregno in (select molregno from drug_indication
	where mesh_id = 'D008288');
-- the usan stem definition does not give good information about indication

-- what plasmodium species are in this database?
select distinct organism from target_dictionary
where organism like 'plasmodium%';
-- 26 entries

select * from target_dictionary
where organism like 'plasmodium%';
-- the "organism" field contains some different values for the same organism / strain; all strains have their own tax_id

-- what are the unique tax ids for the plasmodiums
select distinct tax_id from target_dictionary
where organism like 'plasmodium%';
-- 23 results

-- what are the targets those drugs act at (in plasmodium species)
-- cave: this just shows for which targets there is an assay (not if the drug was found to be active against it)
select distinct tar.pref_name, act.molregno 
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tar on ass.tid = tar.tid
where tar.tax_id in (select distinct tax_id from target_dictionary
	where organism like 'plasmodium%')
and act.molregno in (select molregno from drug_indication
	where mesh_id = 'D008288');
-- 251 results (many duplicates)
-- many of the targets are the whole species

-- try with only pref_name
select distinct tar.pref_name
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tar on ass.tid = tar.tid
where tar.tax_id in (select distinct tax_id from target_dictionary
	where organism like 'plasmodium%')
and act.molregno in (select molregno from drug_indication
	where mesh_id = 'D008288');
-- 35 results: about halve of it are the whole organism (17 proteins)

-- look at the mechanism of action
select * from drug_mechanism
where molregno in (select molregno from drug_indication
	where mesh_id = 'D008288');
-- 50 results (81 known drugs!)
-- for some molecules several MOAs are registered (and for some none)

-- look at compound records table
select * from compound_records
where molregno in (select molregno from drug_indication
	where mesh_id = 'D008288');
-- one entry per doc_id (sources?); compound_name is just the standard chemical names

-- find out which molregnno have no known mechanism
select ind.molregno, mech.mechanism_of_action from drug_mechanism mech left join drug_indication ind on mech.molregno = ind.molregno
where ind.mesh_id = 'D008288';
-- only 50 results

-- control, how many molregno have this meshid (indication = malaria)?
select molregno from drug_indication
where mesh_id = 'D008288';
-- 81 => there should be 81 results above

-- above I mistakingly used left join instead of right join
select mech.mechanism_of_action, ind.molregno from drug_mechanism mech right join drug_indication ind on mech.molregno = ind.molregno
where ind.mesh_id = 'D008288';
-- now there is 90 results (some duplicates in molregnos, as there are several mechanisms of action registered

-- create temp table for antimalarials with molregno and pref name
create temporary table antimalarials (
	select mol.molregno, mol.pref_name 
    from molecule_dictionary mol 
    join drug_indication ind on mol.molregno = ind.molregno
    where ind.mesh_id = 'D008288');
    
-- control    
select * from antimalarials;

-- for which targets in plasmodium is there measured activity of the antimalarials?
select distinct sel.molregno, sel.pref_name, tar.pref_name
from activities act 
join assays ass on act.assay_id = ass.assay_id
join target_dictionary tar on ass.tid = tar.tid
right join antimalarials sel on sel.molregno = act.molregno
where tar.tax_id in (select distinct tax_id from target_dictionary
	where organism like 'plasmodium%');
-- 251 results

-- show all molecules with their respective mechanisms of action
select sel.*, mech.mechanism_of_action
from antimalarials sel
left join drug_mechanism mech on sel.molregno = mech.molregno
order by sel.pref_name;
-- 90 results

-- general information about antimalarials from molecule disctionary table
select molregno, pref_name, molecule_type, first_approval, indication_class from molecule_dictionary
where molregno in (select molregno from antimalarials);

-- look at predicted binding domains
select pred.* from antimalarials sel
left join activities act on sel.molregno = act.molregno
join predicted_binding_domains pred on act.activity_id = pred.activity_id;

-- include name of site and name of molecule
select sel.pref_name, pred.*, site.site_name from antimalarials sel
left join activities act on sel.molregno = act.molregno
join predicted_binding_domains pred on act.activity_id = pred.activity_id
join binding_sites site on pred.site_id = site.site_id
order by sel.pref_name;
-- seems to be a prediction of where the molecule binds on the target (for measured activities)

-- look at confidence score table
SELECT * FROM chembl_29.confidence_score_lookup;
-- confidence assays.score might be used to filter for assays depending on what the kind of target is assigned
-- protein / subcellular fraction etc

-- have a look at targets of assays for plasmodim species where confidence score = 9 (Direct single protein target assigned)
select ass.description, tar.pref_name 
from assays ass join target_dictionary tar on ass.tid = tar.tid
where tar.organism like 'plasmodium%'
and ass.confidence_score = 9;
-- works; only protein names for target pref name

-- include 4:9 (could be all where some kind of protein/complex is assigned as target
select ass.description, tar.pref_name 
from assays ass join target_dictionary tar on ass.tid = tar.tid
where tar.organism like 'plasmodium%'
and ass.confidence_score in (4, 5 , 6, 7, 8, 9);

-- what are the distinct targets
select distinct tar.pref_name 
from assays ass join target_dictionary tar on ass.tid = tar.tid
where tar.organism like 'plasmodium%'
and ass.confidence_score in (4, 5, 6, 7, 8, 9);

-- and for our selected molecules?
select distinct tar.pref_name 
from assays ass 
join target_dictionary tar on ass.tid = tar.tid
join activities act on act.assay_id = ass.assay_id
where tar.organism like 'plasmodium%'
and ass.confidence_score in (4, 5 , 6, 7, 8, 9)
and act.molregno in (select molregno from antimalarials);
-- this is not the same result as in query above (where 17 protein targets where found)

-- now join antimalarials table to get pref name and target name in same table
select distinct sel.pref_name, tar.pref_name 
from assays ass 
join target_dictionary tar on ass.tid = tar.tid
join activities act on act.assay_id = ass.assay_id
join antimalarials sel on act.molregno = sel.molregno
where tar.organism like 'plasmodium%'
and ass.confidence_score between 4 and 9; # so we dont have to type out all the numbers
-- 32 results (13 unique target pref names) => consistent

-- look at metabolism table
select * from metabolism;

-- whats in there for our selection?
select met.* 
from metabolism met
join compound_records rec on met.substrate_record_id = rec.record_id
where rec.molregno in (select molregno from antimalarials);
-- 28 results

-- include pref name of drug
select sel.molregno, sel.pref_name, met.* 
from metabolism met
join compound_records rec on met.substrate_record_id = rec.record_id
join antimalarials sel on rec.molregno = sel.molregno;

-- join on drug_record_id instead substrate_record_id
select sel.molregno, sel.pref_name, met.* 
from metabolism met
join compound_records rec on met.drug_record_id = rec.record_id
join antimalarials sel on rec.molregno = sel.molregno;
-- 23 results (very differnt result)

-- get data from compound structures table for the selected molecules
select * from compound_structures
where molregno in (select molregno from antimalarials);
-- 72 rows (81 in our selection)

-- use smiles to generate images of structure using Rscript: "Smiles_to_Structure.R" (using rcdk library)
-- use right join to see for which compounds the structure info is missing => for macromolecules the smiles is missing, makes sense
select sel.*, str.canonical_smiles from compound_structures str 
right join antimalarials sel on str.molregno = sel.molregno;
-- 81 results: export result as .csv file ("selection_smiles.csv")

-- look at all indications of our selection
select sel.*, ind.* 
from drug_indication ind
join antimalarials sel
order by sel.molregno;
-- Metoprolol has >1000 indications here

-- we have to validate our selection
-- count rows per molregno
select molregno, count(*)
from drug_indication
where molregno in (select molregno from antimalarials)
group by molregno
order by count(*) desc;

-- Include the names of the molecules
select moldic.molregno, moldic.pref_name, count(*)
from drug_indication ind join molecule_dictionary moldic on ind.molregno = moldic.molregno
where ind.molregno in (select molregno from antimalarials)
group by ind.molregno
order by count(*) desc;
-- many of these really are not well known as antimalarials
-- how do we decide which to keep
-- hydroxychloroquin has 79 indications, there are some others that are not really antimalarials, 
-- but have less indications listed here => we canot use number of indications to exclude

-- look again at info in molecule_dictionary
select * from molecule_dictionary
where molregno in (select molregno from antimalarials);
-- the indication class cannot really be used as well (maybe in an OR statement)

-- maybe via ATC classification
select atc.* from molecule_atc_classification mol join atc_classification atc on mol.level5 = atc.level5
where mol.molregno in (select molregno from antimalarials);
-- atovaquone is labelled as "AGENTS AGAINST AMOEBIASIS AND OTHER PROTOZOAL DISEASES" in level 3 descriprion, is also antimalarial
-- otherwise the level 3 description =Antimalarials seems to work well as filter level3 = ('P01B', 'P01A')

select mol.molregno, atc.* from molecule_atc_classification mol join atc_classification atc on mol.level5 = atc.level5
where mol.molregno in (select molregno from antimalarials)
and atc.level3 in ('P01B', 'P01A');
-- 19 results

-- make new temp table with this filter and including molregno and who name
-- the drugs selected have the MeSH (Medical Subject Heading) ="Malaria", and the ATC Level 4 Classification = Antimalarials (with one exception)
-- we can assume that they are relatively well known, if they have these values and a pref_name (not just a chemical name) assigned
create temporary table antimalarials2 (
select mol.molregno, atc.who_name 
from molecule_atc_classification mol 
join atc_classification atc on mol.level5 = atc.level5
join drug_indication ind on mol.molregno = ind.molregno
where ind.mesh_id = 'D008288'
and atc.level3 in ('P01B', 'P01A'));

-- how many indications do these have
select moldic.molregno, moldic.pref_name, count(*)
from drug_indication ind join molecule_dictionary moldic on ind.molregno = moldic.molregno
where ind.molregno in (select molregno from antimalarials2)
group by ind.molregno
order by count(*) desc;

########################
#create tables to export
########################

#P2_exp1_Selection
select * from antimalarials2;

#table with additional info about our selection e.g. are they on the market etc.

-- look at available formulations
select * 
from formulations form 
join products prod on form.product_id = prod.product_id
where form.molregno in (select molregno from antimalarials2);
-- 21 results; 16 thereof are atovaquone => probably lots of missing information

select * from molecule_dictionary
where molregno in (select molregno from antimalarials2);
-- first approval might be helpfull

-- look at MOA
select * from drug_mechanism
where molregno in (select molregno from antimalarials2);
-- only 8 results, 4 with MoA = Unknown

select * from drug_warning
where molregno in (select molregno from antimalarials2);
-- nothing

-- for which proteins from plasmodium species where assays done four our selected compounds 
select distinct sel.who_name, tar.pref_name 
from assays ass 
join target_dictionary tar on ass.tid = tar.tid
join activities act on act.assay_id = ass.assay_id
join antimalarials2 sel on act.molregno = sel.molregno
where tar.organism like 'plasmodium%'
and ass.confidence_score between 4 and 9;
-- 28 results

-- look at IRAC / FRAC / HRAC classifications
select hrac.* from molecule_hrac_classification mol join hrac_classification hrac on mol.hrac_class_id = hrac.hrac_class_id
where mol.molregno in (select molregno from antimalarials2);
-- no results

select irac.* from molecule_irac_classification mol join irac_classification irac on mol.irac_class_id = irac.irac_class_id
where mol.molregno in (select molregno from antimalarials2);
-- no result

select frac.* from molecule_frac_classification mol join frac_classification frac on mol.frac_class_id = frac.frac_class_id
where mol.molregno in (select molregno from antimalarials2);
-- no result

-- atc classification 
select * from atc_classification
where who_name in (select who_name from antimalarials2);
-- level 4 description is usefull

#P2_exp2_general
Select sel.molregno, sel.who_name, moldic.first_approval, mech.mechanism_of_action, atc.level4_description 
from antimalarials2 sel 
left join molecule_dictionary moldic on sel.molregno = moldic.molregno
left join drug_mechanism mech on sel.molregno = mech.molregno
left join atc_classification atc on sel.who_name = atc.who_name;


###################################
#		Drugs@FDA
###################################

-- Since there is not that much Information about the selected drugs / Products on the market containing these compounds in the ChEMBL database
-- I looked for other sources and found that the FDA publishes data about all approved drugs
-- these are available in tab delimited text files here: https://www.fda.gov/drugs/drug-approvals-and-databases/drugsfda-data-files

-- I transformed them to csv files in R (using the "tab_to_csv.R" Script)

-- create database
create database drugs_at_fda;
use drugs_at_fda;

-- create data model

-- ApplicationsDocsType_Lookup
drop table if exists ApplicationsDocsType_Lookup;
CREATE TABLE ApplicationsDocsType_Lookup (
    ApplicationDocsType_Lookup_ID INTEGER NOT NULL,
    ApplicationDocsType_Lookup_Description VARCHAR(100) NOT NULL,
    SupplCategoryLevel1Code VARCHAR(100) NOT NULL,
    SupplCategoryLevel2Code VARCHAR(100) NOT NULL);

-- use the table import wizard to import the data
-- check the result
select * from ApplicationsDocsType_Lookup;

-- for the other data I directly used the wizard

-- check all
select * from ApplicationDocs;
select * from Applications;
select * from ApplicationsDocsType_Lookup;
select * from MarketingStatus;
select * from MarketingStatus_Lookup;
select * from Products;
select * from SubmissionClass_Lookup;
#select * from SubmissionPropertyType; => not used
#select * from Submissions; => not used
select * from TE;

-- look at products table
select * from Products;
-- search via active ingredients

-- look at our selection in products table; two records where not included ("pyrimethamine, combinations", "proguanil, combinations") as combinations will be found anyways
select * from Products
where ActiveIngredient in ("atovaquone", "chloroquine", "hydroxychloroquine", 
"primaquine", "amodiaquine", "tafenoquine", "proguanil", "cycloguanil embonate", 
"quinine", "mefloquine", "pyrimethamine", "artemisinin", "artemether", "artesunate", 
"artemotil", "artenimol", "halofantrine");
-- 16 results (in chembl there where 21 results when querying the formulations table)
-- do we find everything with this query? => try wildcards

select * from Products
where ActiveIngredient like "%arte%";
-- 9 results some out of scope (Cartelol); but also a combination product (artemether / lumefantrine)

select * from Products
where ActiveIngredient like ("%atovaquone%", "%chloroquine%", "%hydroxychloroquine%", 
"%primaquine%", "%amodiaquine%", "%tafenoquine%", "%proguanil%", "%cycloguanil%", 
"%quinine%", "%mefloquine%", "%pyrimethamine%", "%artemisinin%", "%artemether%", "%artesunate%", 
"%artemotil%", "%artenimol%", "%halofantrine%");
-- this doesnt work, as like takes only one string => either use like XX OR like XX, or use regexps

-- use regexp (leave away ebonate from cycloguanil ebonate)
select * from Products
where ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
artemotil|artenimol|halofantrine";
-- 72 results => many salts included (these are not found if we just search for the exact string of the WHO name)

-- as there are duplicates and these are only applications for MA (Market Authorization) we have to check what is actually on the market
-- e.g. are there several generics on the market or is there a new application for every generic?

-- look at our selection in the marketing status table
select * from marketingstatus
where ApplNo in (select ApplNo from Products
	where ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine");

-- to be able to interpret this data, join on marketing status id to the respective lookup table
-- and with the products table
select prod.*, ms_lu.MarketingStatusDescription 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine";
-- 96 results; there are duplicates
-- there are some products that were discontinued => dont include

-- filter for the ones still on the market
select prod.*, ms_lu.MarketingStatusDescription 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";
-- 70 results, still some duplicates
-- there are also some records which are the same except the ApplNo
-- those might be competitor products from different companies (different generics)

-- include sponsor name from Applications table, to identify if the different ApplNo are
-- due to them beeing competitior products
select prod.*, ms_lu.MarketingStatusDescription, app.SponsorName 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";
-- thats correct; for example there are multiple products with
-- HYDROXYCHLOROQUINE SULFATE from different companies => different generics

-- there are still multiples; for example from ApplNo = 21078
-- there are 4 records, 2 duplicates for 2 different dosages

-- check if the multiples are introduced somehow throught the query or if there are multiples in the data
select * from products
where ApplNo = "21078";
-- its due to the query

-- the duplication happens everywhere, where one application includes several dosages of a product
-- the different dosages are numbered via the ProductNo field
-- this must be introduced through the joins

-- avoid it via using distinct
select distinct prod.*, ms_lu.MarketingStatusDescription, app.SponsorName 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";
-- 50 results => makes sense; I checked by hand and there where 20 resords on the previous result, which should not be on the list

-- what other data is there in the application table?
select distinct prod.*, ms_lu.MarketingStatusDescription, app.SponsorName, app.ApplPublicNotes, app.ApplType 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";
-- the field ApplType can be used to distinguish originals from generics 
-- NDA = new drug application (original)
-- ANDA = Abreviated NDA (Generic)

-- only include relevant fields
select distinct prod.Form, prod.Strength, prod.DrugName, prod.ActiveIngredient, app.SponsorName, app.ApplType 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";

-- split the "Form" field => one field for Form (tablet, suspension etc.) and one for administration route (oral, i.v. etc)
select distinct substring_index(prod.Form, ";", 1) as Form, substring_index(prod.Form, ";", -1) as AdministartionRoute, prod.Strength, prod.DrugName, prod.ActiveIngredient, app.SponsorName, app.ApplType 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription";

-- replace ApplType field with Original/Generic Field
-- to do this create a temp table and then replace the strings in there
drop table if exists fda_Antimalarials;
create temporary table fda_Antimalarials (select distinct app.ApplNo, substring_index(prod.Form, ";", 1) as Form, substring_index(prod.Form, ";", -1) as AdministartionRoute, 
prod.Strength, prod.DrugName, prod.ActiveIngredient, app.SponsorName, app.ApplType 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription");

select * from fda_Antimalarials;

Update fda_Antimalarials
set ApplType = replace(ApplType, "NDA", "Original");

Update fda_Antimalarials
set ApplType = replace(ApplType, "AOriginal", "Generic"); #ANDA was converted to AOriginal in previous statement
-- update successfull

-- update the column name
alter table fda_Antimalarials change ApplType Original_Generic varchar(20);
-- worked

########################
#Prepare table to export
########################

-- We need a field on wich we could join it to the other data in tableau (=> Molregno)
-- the first word of the ActiveIngredient can be used to match the who_name, as the the second words are the other part of the salt
-- except for the combination products: Arthemeter / Lumefantrine and atovaquone / proguanil
-- these records should be duplicated, so we can add a molregno for each of the two included compounds
-- these records can be identified by the ";" signal in the ActiveIngredient field

-- we will do this later in the script, as otherwise we will have twice the same record in the table and it would be
-- more tedious to replace a value in just one of them

-- add the molregno column
alter table fda_Antimalarials
add column molregno int(10) first;

-- update for the first substance
Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "HYDROXYCHLOROQUINE")
where ActiveIngredient like "HYDROXYCHLOROQUINE%";

-- check
select * from fda_Antimalarials;
-- worked

-- update for the other substances
Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "ATOVAQUONE")
where ActiveIngredient like "%ATOVAQUONE%";

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "ARTESUNATE")
where ActiveIngredient like "%ARTESUNATE%";

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "CHLOROQUINE")
where ActiveIngredient like "CHLOROQUINE%"; #if we would include a % before chloroquine, the hydroxychloroquine records would be overwritten

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "TAFENOQUINE")
where ActiveIngredient like "%TAFENOQUINE%";

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "MEFLOQUINE")
where ActiveIngredient like "%MEFLOQUINE%";

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "PYRIMETHAMINE")
where ActiveIngredient like "%PYRIMETHAMINE%";

Update fda_Antimalarials
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "ARTEMETHER")
where ActiveIngredient like "%ARTEMETHER%";

-- select for the records that should be duplicated (combination products)
select * from fda_Antimalarials
where ActiveIngredient like "%;%";
-- 7 records

-- create a temp table for this selection
create temporary table dupl
select * from fda_Antimalarials
where ActiveIngredient like "%;%";

-- update the molrgno values to the molregno of the second substance
Update dupl
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "PROGUANIL")
where ActiveIngredient like "%PROGUANIL%";

Update dupl
set molregno = (select molregno from chembl_29.antimalarials2
	where who_name = "LUMEFANTRINE")
where ActiveIngredient like "%LUMEFANTRINE%";

-- check 
select * from dupl;
-- for lumefantrine there was no molregno added 

-- does it exist in the antimalarials2 table?
select * from chembl_29.antimalarials2;
-- no

-- drop the record form the table
delete from dupl
where ActiveIngredient like "%LUMEFANTRINE%";

-- insert the rows into the fda_Antimalarials table
insert into fda_Antimalarials
select * from dupl;

-- check
select * from fda_Antimalarials;
-- 56 results => correct
-- export the result #P2_exp3_fda


################################
#	Web scraping FDA for label
################################

-- create table with Appl numbers of the same products as above
drop table if exists fda_Antimalarials2;
create temporary table fda_Antimalarials2 (select distinct app.ApplNo, prod.DrugName, app.SponsorName 
from Products prod join marketingstatus ms on prod.ApplNo = ms.ApplNo
join marketingstatus_lookup ms_lu on ms.MarketingStatusID = ms_lu.MarketingStatusID
join applications app on prod.ApplNo = app.ApplNo
where prod.ActiveIngredient regexp "atovaquone|chloroquine|hydroxychloroquine|
	primaquine|amodiaquine|tafenoquine|proguanil|cycloguanil|
	quinine|mefloquine|pyrimethamine|artemisinin|artemether|artesunate|
	artemotil|artenimol|halofantrine"
and ms_lu.MarketingStatusDescription = "Prescription");

-- export data to be used in R for scraping
#P2_exp4_scraping
select * from fda_Antimalarials2;

#See R script "scraper_label.R"
