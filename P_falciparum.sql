##########################################
#				Introduction
##########################################

#Abstract: The contents of the ChEMBL Database was explored using MySQL, with the goal of finding promising leads for a medicine against 
-- P.falciparum (Malaria pathogen). Then an available qHTS (quantitative high throughput screening) assay (assay_id = 752407) was selected to be investigated more closely.
-- Finally certain data were extracted from the database in order to create a dashboard in Tableau, which gives more information on 86 compounds, that showed 
-- a low AC50 value in this assay. The information on the dashboard includes: activity of the respective compounds on other targets, information about 
-- approval and research status, if the respective compounds comply with Lipinski's Rule of Five and the Rule of Three for "Lead-Like" compounds

#Duration of Project: SQL: 13 h / Tableau: 14 h

# ChEMBL Database:
-- About ChEMBL (from their Website: https://www.ebi.ac.uk/chembl/): ChEMBL is a manually curated database of bioactive molecules with 
-- drug-like properties. It brings together chemical, bioactivity and genomic data to aid the translation of genomic information into effective new drugs.

-- DB Schema: https://www.ebi.ac.uk/chembl/db_schema

-- Citation: ChEMBL: towards direct deposition of bioassay data.
-- Mendez D, Gaulton A, Bento AP, Chambers J, De Veij M, Félix E, Magariños MP, Mosquera JF, Mutowo P, Nowotka M, Gordillo-Marañón M, Hunter F, Junco L, 
-- Mugumbate G, Rodriguez-Lopez M, Atkinson F, Bosc N, Radoux CJ, Segura-Cabrera A, Hersey A, Leach AR.
-- — Nucleic Acids Res. 2019; 47(D1):D930-D940. doi: 10.1093/nar/gky1075

#Glossary Drug Discovery Terms / Technical Terms used in this Script (Source: Wikipedia)
-- Lead (Compounds): A lead compound in drug discovery is a chemical compound that has pharmacological or biological activity likely to be therapeutically 
-- 		useful, but may nevertheless have suboptimal structure that requires modification to fit better to the target.
-- Assay: An assay is an investigative (analytic) procedure in [...] pharmacology, [...] for 
-- 		qualitatively assessing or quantitatively measuring the presence, amount, or functional activity of a target entity.
-- (Biological) Target: A biological target is anything within a living organism to which some other entity (like [...] a drug) is 
-- 		directed and/or binds, resulting in a change in its behavior or function.

#Set up
-- ChEMBL (Version 29) was downlaoded and hosted locally on computer.

##########################################
#		Exploratory Data Analysis
##########################################

#(Preclinical) Drug Discovery Process:
-- Target Discovery / Selection
-- Lead discovery / selection / optimization
-- preclinical evalueation

#At first I tried to find a suitable target (as is this is usually the first step in drug discovery)

#Target selection
-- What criteria should target fullfill?
-- 		be effective in killing / harming p falciparum
-- 		target (or an analog thereof) should not exist in Human (to reduce possibility of ADRs, by it acting on the human analog)

-- search for assays for P.falciparum
select * from assays
where assay_organism like '%falciparum%';

-- how many assays are there?
select count(assay_id) from assays
where assay_organism like '%falciparum%';
-- 8019

-- what are the targets?
select distinct pref_name, tid, target_type from target_dictionary
where organism like '%falciparum';

-- how many targets are there?
select count(tid) from target_dictionary
where organism like '%falciparum';
-- 56

-- is there any instance, where there are tid (Target Id) duplets? (e.g. a different pref name is used for the same target)? Count pref_name
select count(pref_name) from target_dictionary
where organism like '%falciparum';
-- 56 => no its always 1 to 1

-- show ordered for tid
select distinct pref_name, tid, target_type from target_dictionary
where organism like '%falciparum' 
order by tid;
-- one target is plasmodium falciparum (the whole organism)

-- what target types are there and how many of which?
select count(pref_name), count(tid), target_type from target_dictionary
where organism like '%falciparum' 
group by target_type;

-- how may of these targets do not exist in humans?
select count(tid) from target_dictionary
where organism like '%falciparum' 
and tid not in (select tid from target_dictionary
	where organism like '%sapiens');  
-- 56 => none of them exist in humans. I know that at least some the targets have analogs in humans (same pref_name) for example Cytochrome b

-- did sub querry show the desired results?
select * from target_dictionary
where organism like '%sapiens'
group by tid;
-- yes

-- manually check if it works / select certain targets to verify
select * from target_dictionary
where organism like '%falciparum' 
and tid not in (select tid from target_dictionary
	where organism like '%sapiens'); 
    
 -- have a closer look at tids: 311, 325, 18044. Do they really not exist in humans?
  select * from target_dictionary
 where tid in (311, 325, 18044);
 -- only returns p falciparum entries
 
 -- see if there are multiples in pref_name
 select * from target_dictionary
 where pref_name = 'Cytochrome b';
 -- yes there are. Not all of them are listed. there is also cytochrome b in humans. There are probably just no assays in the DB that where done on human cytochrome b
 
 -- we cannot filter out targets in p falciparum that have an analog in humans.
 -- We would have done this to reduce the risk of Adverse Drug Reactions via activity on the human analog of the target. 
 
-- how many targets dont have an analog in humans with same pre_name (that is listed in this table)?
select count(tid) from target_dictionary
where organism like '%falciparum' 
and pref_name not in 
	(select pref_name from target_dictionary
	where organism like '%sapiens');  
-- 48 (less then i would have expected)
-- we are not going to use this as exclusion criteria; we can later try to check activity in human for single compounds

-- what kind of proteins are the found targets?
select * from protein_classification
where pref_name in
	(select pref_name from target_dictionary
	where organism like '%falciparum');
-- Data only available for 3 compounds

-- what are the target components
select * from target_components
where tid in
	(select tid from target_dictionary
	where organism like '%falciparum');
-- links tables via different IDs

-- how many activiites where tested with p faliparum
select count(act.activity_id) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_organism = 'Plasmodium falciparum';
-- 714 k

-- how many different molecules where tested
select count(distinct act.molregno) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_organism = 'Plasmodium falciparum';
-- 336 k

-- what kinds of assays where done?
select distinct assay_type from assays
where assay_organism = 'Plasmodium falciparum';
-- F, B, A, P, U what is U?

-- look at description of U
select description from assays
where assay_organism = 'Plasmodium falciparum'
and assay_type = 'U';
-- ?; only one assay with U

-- look at assays of type F
select distinct description from assays
where assay_organism = 'Plasmodium falciparum'
and assay_type = 'F';
-- many different => there seem to be different p falciparum strains (D6, W-2 etc)
-- a lot of what is described here is probably also available in seperate fields: in vivo / in vitro; endpoint of assay etc.

-- show all targets for p falciparum
select * from target_dictionary
where organism = 'Plasmodium falciparum';

#As I was a bit stuck in finding criteria to identify a good target for p falciparum, I decided to search for a compound with high activity against p falciparum
#the idea was then to identify a good target via this compound => if the compound kills p falciparum and is active on a certain protein, this protein might be a good target

-- how many molecules where tested on p falciparum
select count(distinct molregno) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425;
-- 335 039

-- control
select ass.* from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425;
-- descriptions include: inhibitory activity / substrate affinity against p falc neutral proteinase
-- => is it against protein (not whole organism as stated)??

-- look at source (doc_id: 10805)
select * from docs
where doc_id = 10805;
-- seems like the target in the database is incorrect?
-- maybe it will be possible to distinguish later via the activity endpoint (bao endpoint)

-- look at bao endpoints
select distinct bao_endpoint, standard_type from activities
order by bao_endpoint;
-- wide variety of std type for one bao endpoint? not 1 to 1?

-- look at activity types
select count(act.standard_type), act.standard_type from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425
group by act.standard_type
order by count(act.standard_type) desc;

-- look at std type = potency
select act.standard_type, ass.description from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425
and act.standard_type = 'Potency';

-- look at pubchem quant HTS
select act.standard_type, ass.description, ass.assay_id from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425
and act.standard_type = 'Potency';
-- assay id = 736968

-- are there any other 'big' scrrenings?
select count(act.activity_id), ass.assay_id, ass.description from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.TID = 50425
group by ass.assay_id
order by count(act.activity_id) desc;
-- biggest two are pubchem assayswith 96 h incubation time (assay_id = 758407) and 48 h incubation time (assay_id = 758590) 
-- with 170 k and 130 k measured activities respectively

-- look at type for 96 h inc time
select distinct act.type from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;
-- all Potency

-- how many molecules are flagged as active (act comment)?
select count(distinct molregno) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407
and act.activity_comment = 'active';
-- 22 k

-- look at data from activities table from this assay
select act.* from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407
and act.activity_comment = 'active';

-- what does potency / the activity value stand for?
-- when looking up BAO_0000186: AC50 The effective concentration of a perturbagen, which produces 50% of the maximal possible response, 
-- which could mean either activation (EC50) or inhibition (IC50) for that perturbagen.

-- have a look at the publication
-- docid = 51887
select * from docs
where doc_id = 51887;
-- there is no paper to this assay

-- look at data from assay table from this assay
select ass.* from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;
-- descr: [Related pubchem assays (depositor defined):AID488745, AID488752, AID488774, AID504848, AID504850]
-- these ids can be searched for in pubchem

-- AID 504834 (primary qHTS screen 96 h incubation with 300 k substances)
-- AID 504832 (primary qHTS screen 48 h incubation with 300 k substances)

-- look at what data are available in this DB concerning this screening
select act.* from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;

-- Value stands for AC50 => lover concentration values are more active
select act.* from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407
order by act.standard_value;
-- the value does not coincide with active / inactive label

-- are there several activities measured for the same molecule in the same assay?
select count(distinct act.molregno) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;
-- 170 k

select count(act.activity_id) from activities act right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;
-- 170 k as well => so no

-- look at activity properties table
select actprop.* from activity_properties actprop right join activities act on actprop.activity_id = act.activity_id right join assays ass on act.assay_id = ass.assay_id
where ass.assay_id = 752407;
-- all null

-- control 
select * from activity_properties
where activity_id = 6571369;

-- select active compounds with low AC50
select * from activities
where assay_id = 752407
and activity_comment = 'active'
order by standard_value
limit 100;
-- time out

-- how many records are there?
select count(activity_id) from activities
where assay_id = 752407
and activity_comment = 'active';
-- 22 k

-- put limit to 240 s
select * from activities
where assay_id = 752407
and activity_comment = 'active'
order by standard_value
limit 100;
-- still timeout

-- select only records where the values are already small
select count(activity_id) from activities
where assay_id = 752407
and activity_comment = 'active'
and standard_value < 100;
-- 184 records

-- try again
select * from activities
where assay_id = 752407
and activity_comment = 'active'
and standard_value < 100
order by standard_value;
-- still timeout

-- just run without order by and then order afterwards in the result table
select * from activities
where assay_id = 752407
and activity_comment = 'active'
and standard_value < 100;
-- order by standard_value;

-- look at mol dictionary table
select act.standard_value, mol.* from activities act left join molecule_dictionary mol on act.molregno = mol.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 100;
-- many antimalarials included

-- look at compound properties
select act.standard_value, comp.* from activities act left join compound_properties comp on act.molregno = comp.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 100;

-- select even less compounds to look at closer
select count(activity_id) from activities
where assay_id = 752407
and activity_comment = 'active'
and standard_value < 10;
-- 45 compounds

-- now try to identify the targets of these compounds (i.e. if they show activity on some proteins of p falciparum)

-- select activities from all assays against p falc, with these compounds
select act.* from activities act right join assays ass on act.assay_id = ass.assay_id
where act.molregno in (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 10)
and ass.assay_organism = 'Plasmodium falciparum';
-- 800 records

-- exclude activities with inactive/unclear result (eg activity_comment not active or NULL)
select act.* from activities act right join assays ass on act.assay_id = ass.assay_id
where act.molregno in (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 10)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);
-- 777 rows

-- show preferred name of molecule and most important data
select mol.pref_name, act.molregno, act.standard_value, act.standard_units, act.standard_type from activities act left join assays ass on act.assay_id = ass.assay_id 
left join molecule_dictionary mol on act.molregno = mol.molregno
where act.molregno in (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 10)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);
-- most of the activities where measured for molecules with a preffered name => e.g. already well studied molecules / molecules on the market

-- try to identify the targets of some of these molecules with the data given here
select mol.pref_name, act.molregno, act.standard_value, act.standard_units, act.standard_type, tdic.pref_name from activities act left join assays ass on act.assay_id = ass.assay_id 
left join molecule_dictionary mol on act.molregno = mol.molregno join target_dictionary tdic on ass.TID = tdic.TID
where act.molregno in (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 10)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);
-- hardly any other targets then p falc (whole organism)

-- see if there is more if we increase the included AC50 to 50
select mol.pref_name, act.molregno, act.standard_value, act.standard_units, act.standard_type, tdic.pref_name from activities act join assays ass on act.assay_id = ass.assay_id 
join molecule_dictionary mol on act.molregno = mol.molregno join target_dictionary tdic on ass.TID = tdic.TID
where act.molregno in (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 50)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);
-- there are some but only for molecules that are on the market

-- this didnt really work here

-- here I looked at other SQL techniques that I hadnt really used and then tried to incorporate them

-- MMMMMMMMMMMMMMMMMMMMMMMMMM
-- 			Theory
-- MMMMMMMMMMMMMMMMMMMMMMMMMM


-- use CTE; e.g.: WITH CTE_Name as (Select ...CTE code...)
-- 				select from CTE_Name
-- reason to use CTEs (instead of subquerries): 
-- 		better readability of code due to meaningfull name of CTE
-- 			especially for nested querries
-- 		reusable within querry

-- Temp Table:
-- drop table if exists #temp_table (to be able to rerun it; if not, there is an error)
-- Create temporary table "name"
-- 		used to query smaller part of very big table more efficiently

-- write the subquerry for selecting the molecules with the highest affinity to a temp table
drop table if exists sel_molregno;
Create temporary table sel_molregno
select molregno from activities
where assay_id = 752407
and activity_comment = 'active'
and standard_value < 50;

-- use temp table in a query (last querry above)
select mol.pref_name, act.molregno, act.standard_value, act.standard_units, act.standard_type, tdic.pref_name from activities act join assays ass on act.assay_id = ass.assay_id 
join molecule_dictionary mol on act.molregno = mol.molregno join target_dictionary tdic on ass.TID = tdic.TID
where act.molregno in (select * from sel_molregno)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);

-- now same as CTE
WITH sel_molregno as (select molregno from activities
	where assay_id = 752407
	and activity_comment = 'active'
	and standard_value < 50)
    
select mol.pref_name, act.molregno, act.standard_value, act.standard_units, act.standard_type, tdic.pref_name from activities act join assays ass on act.assay_id = ass.assay_id 
join molecule_dictionary mol on act.molregno = mol.molregno join target_dictionary tdic on ass.TID = tdic.TID
where act.molregno in (select * from sel_molregno)
and ass.assay_organism = 'Plasmodium falciparum'
and (act.activity_comment = 'active' OR act.activity_comment is null);
-- there is no automatic row limit to result

-- lets see what other data is available for the selected molecules (exclude the already known antimalarials)
select moldic.pref_name, moldic.indication_class from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and moldic.pref_name is not null;
-- very slow => use the temp table

select pref_name, indication_class from molecule_dictionary
where molregno in (select * from sel_molregno)
and pref_name is not null;

-- some of these are not labelled properly as antimalarials => update some the column 'Indication_class'
-- Antimalarials are: ('AMODIAQUINE HYDROCHLORIDE', 'ARTEMISININ', 'LUMEFANTRINE', 'ARTEMETHER')
-- we will also exclude: ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE')   (structurally similar to antimalarial drugs => we assume they would not act via a new mechanism of action)
update molecule_dictionary
set indication_class = 'Antimalarial'
where pref_name in ('AMODIAQUINE HYDROCHLORIDE', 'ARTEMISININ', 'LUMEFANTRINE', 'ARTEMETHER');

-- update the temp table for the selected molecules
drop table if exists sel_molregno;
Create temporary table sel_molregno
select moldic.molregno from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null);

-- are there any known mechanisms of action for the slected compounds?
select moldic.pref_name, moa.* from drug_mechanism moa join molecule_dictionary moldic on moa.molregno = moldic.molregno
where moa.molregno in (select * from sel_molregno);
-- only for three drugs, which are already on the market

-- look at indication
select moldic.pref_name, ind.* from drug_indication ind join molecule_dictionary moldic on ind.molregno = moldic.molregno
where ind.molregno in (select * from sel_molregno);
-- only data available for drugs on market

-- look at compound_properties
select moldic.pref_name, prop.* from compound_properties prop join molecule_dictionary moldic on prop.molregno = moldic.molregno
where prop.molregno in (select * from sel_molregno);

-- we can exclude leads that break the rule of 5
select moldic.pref_name, moldic.molregno, act.value from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno join compound_properties prop on moldic.molregno = prop.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null)
and prop.num_ro5_violations < 2;
-- 77 compounds

-- or even only include the ones that pass the rule of three
select moldic.pref_name, moldic.molregno, act.value from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno join compound_properties prop on moldic.molregno = prop.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null)
and prop.ro3_pass = 'Y';
-- only three compounds (2 already on market)

-- look closer at the third one; molregno: 885948
select * from molecule_dictionary
where molregno = '885948';

-- what activities where measured for this molecula other then p falc
select * from activities
where molregno = '885948';

-- only include active ones
select * from activities
where molregno = '885948'
and activity_comment = 'Active';

-- what where the targets
select act.molregno, tdic.pref_name, act.standard_value, act.standard_units, act.standard_type, ass.assay_organism from activities act join assays ass on act.assay_id = ass.assay_id join target_dictionary tdic on ass.TID = tdic.TID
where act.molregno = '885948'
and act.activity_comment = 'Active';
-- some other targets in human, some unknown
-- the IC50 / or AC50 for potency?? are much higher then the one in the assay for P falc (x100)
-- meaning they would probably not pose a problem (cause ADRs in Humans)

-- MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
-- 		Creat a dashboard in Tableau			
-- MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

-- use tableau to create dashboard to give overview over properties of best leads found in selected malaria qHTS
-- what to include:
-- 		targets where there is an assay that shows activity (incl info about species etc) incl. std value etc
-- 		info about RO5 / RO3 violations
-- 		general info about compound: on market? if yes what indication etc.

-- create temp table of selection (same as above)
drop table if exists sel_molregno_tabl;
Create temporary table sel_molregno_tabl
select moldic.molregno from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50;

select moldic.molregno, moldic.pref_name as 'molecule name', tdic.pref_name as target, act.standard_value, act.standard_units, act.standard_type, ass.assay_organism 
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl);
-- there are many assays for the compounds with pref name 
-- => lets exclude known antimalaria drugs / or compounds similar to antimalarials

-- create temp table for selection w/o known antimalarials
drop table if exists sel_molregno_tabl2;
Create temporary table sel_molregno_tabl2
select moldic.molregno from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno join compound_properties prop on moldic.molregno = prop.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null);

select moldic.molregno, moldic.pref_name as 'molecule name', tdic.pref_name as target, act.standard_value, act.standard_units, act.standard_type, ass.assay_organism 
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);

-- how many records are there?
select count(act.activity_id) 
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- ca 7 k => ok

-- only include targets that will more likely to cause ADRs in humans => targets in mammals
-- look at target organism column, compare with target assay column
select moldic.molregno, moldic.pref_name as 'molecule name', tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, ass.assay_organism, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- target organism is NULL for ADME assay while assay organism is homo sapiens 
-- => better to use target organism to filter
-- target organism is null where target = unchecked (missing data, exclude for this)

-- in order to filter for mammals look at the distinct values of target organism
select distinct tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- there is no way to filter for mammals (in this database) => take only the most used mammal models + human

select tdic.organism as target_organism, count(act.activity_id)
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
group by tdic.organism;
-- filter: in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
-- many NULL values => as seen before => missing data / adme trials

-- use filter
select moldic.molregno, moldic.pref_name as 'molecule name', tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus');

-- MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
-- 			Exports to Tableau			
-- MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

drop table if exists sel_molregno_tabl2;
Create temporary table sel_molregno_tabl2
select moldic.molregno from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno join compound_properties prop on moldic.molregno = prop.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null);

-- fetch the whole data
select moldic.molregno, moldic.pref_name as 'molecule name', tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
limit 0, 10000; #before filtering for species, the result contained 6 k records => like this all should be included

-- it seems like for the workflow in tableau it makes more sense to export several tables from sql and then relate them in tableau
-- instead of trying to get as much data as possible into one table to export
-- exptab1
select moldic.molregno, moldic.pref_name as 'molecule name', 
act.standard_value, act.standard_units, act.standard_type
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and act.assay_id = 752407
and activity_comment = 'active'; # included as two records are falsely included otherwise for unknown reason

-- second table containing targets
select moldic.molregno, tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
and act.assay_id <> 752407 #exclude the assay of interest
limit 0, 10000; #before filtering for species, the result contained 6 k records => like this all should be included

-- there are nulls and '*' in the results for standard values => exclude those, as we cannot compare concentrations needed for activity
-- (actually the * is sth that is displayed by tableau in certain situations)
-- only include values in nM, as otherwise would not be comparable
select moldic.molregno, tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
and act.assay_id <> 752407 #exclude the assay of interest
and act.standard_value is not null
and act.standard_value <> '*'
and act.standard_units = 'nM'
limit 0, 10000; #before filtering for species, the result contained 6 k records => like this all should be included
-- over 1 k rows filtered out

-- there are some instances where there are several activities recorded for a molecule on a target => leads to problems in visualization (* is shown instead of one of the values)
-- include assay id
select act.assay_id, moldic.molregno, tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
and act.assay_id <> 752407 #exclude the assay of interest
and act.standard_value is not null
and act.standard_value <> '*'
and act.standard_units = 'nM'
limit 0, 10000;
-- some are also from same assay => use activity id

-- exptab2_targets
select act.activity_id, moldic.molregno, tdic.pref_name as target, 
act.standard_value, act.standard_units, act.standard_type, tdic.organism as target_organism
from activities act 
join assays ass on act.assay_id = ass.assay_id 
join target_dictionary tdic on ass.TID = tdic.TID
join molecule_dictionary moldic on act.molregno = moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2)
and tdic.organism in ('Homo sapiens', 'Rattus norvegicus', 'Mus musculus')
and act.assay_id <> 752407 #exclude the assay of interest
and act.standard_value is not null
and act.standard_value <> '*'
and act.standard_units = 'nM'
limit 0, 10000;
-- worked like this

-- data about molecule
select cprop.molregno, moldic.pref_name, moldic.indication_class, cprop.ro3_pass, cprop.num_lipinski_ro5_violations from compound_properties cprop right join molecule_dictionary moldic on cprop.molregno=moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- returns only 87 instead of 88 rows

-- the temp table contains 88 rows
select * from sel_molregno_tabl2;

select molregno from molecule_dictionary
where molregno in (select * from sel_molregno_tabl2);
-- also only returnes 87 rows

select molregno from compound_properties
where molregno in (select * from sel_molregno_tabl2);
-- same thing

-- is the * sign causing this? (e.g. shows up as additional record at the end?)
select molregno from sel_molregno_tabl2;
-- => no, still 88 records
-- there has to be one molregno, thats missing in these two tables

-- find out which
select moldic.molregno, sel.molregno from molecule_dictionary moldic right join sel_molregno_tabl2 sel on moldic.molregno=sel.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- errror: cant reopen sel

-- make a second instance of the same temp table: sel_molregno_tabl2_copy and use this
Create temporary table sel_molregno_tabl2_copy
select moldic.molregno from activities act join molecule_dictionary moldic on act.molregno = moldic.molregno join compound_properties prop on moldic.molregno = prop.molregno
where act.assay_id = 752407
and act.activity_comment = 'active'
and act.standard_value < 50
and (moldic.pref_name not in ('CINCHONINE', 'ARTEMISIN', 'QUINIDINE') or moldic.pref_name is null)
and (moldic.indication_class <> 'Antimalarial' or moldic.indication_class is null);

select moldic.molregno, sel.molregno from molecule_dictionary moldic right join sel_molregno_tabl2_copy sel on moldic.molregno=sel.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- returns 88 rows and no nulls
-- checked manually: there is a duplicate in the temp table: molregno: 836022
-- what does that mean for the data we already exported => no problem, as the list was alwaysw used via "in statement"
-- in the graph in tableau there are 87 records => ok

-- continue
select cprop.molregno, moldic.pref_name, moldic.indication_class, cprop.ro3_pass, cprop.num_lipinski_ro5_violations from compound_properties cprop right join molecule_dictionary moldic on cprop.molregno=moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);

-- include Ro5 relevant values: HB donors/acceptors, mol mass, logp; also include nr rotatable bonds (from RO3)
select cprop.molregno, moldic.pref_name, moldic.indication_class, cprop.ro3_pass, cprop.num_lipinski_ro5_violations, cprop.hba_lipinski, cprop.hbd_lipinski, cprop.full_mwt, cprop.alogp, cprop.rtb from compound_properties cprop right join molecule_dictionary moldic on cprop.molregno=moldic.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- make several tables:
-- 		-info on previous usage / market authorisation
-- 		-RO5 => indicate which values break it
-- 		-RO3 => indicate which values break it

-- usage market authorisation etc
select  molregno, pref_name, first_approval, black_box_warning, indication_class from molecule_dictionary
where molregno in (select * from sel_molregno_tabl2);

-- add infor about warning
select  moldic.molregno, moldic.pref_name, moldic.first_approval, moldic.black_box_warning, moldic.indication_class, drwa.*
from molecule_dictionary moldic left join drug_warning drwa on moldic.molregno=drwa.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- no info contained

-- look at molecules synonyms table
select  moldic.molregno, moldic.pref_name, moldic.first_approval, moldic.black_box_warning, moldic.indication_class, molsyn.*
from molecule_dictionary moldic left join molecule_synonyms molsyn on moldic.molregno=molsyn.molregno
where moldic.molregno in (select * from sel_molregno_tabl2);
-- some molecules have a research code; some of these dont have a pref name / are not on market

-- find out more via res_stem_id
select  moldic.molregno, moldic.pref_name, moldic.first_approval, moldic.black_box_warning, moldic.indication_class, molsyn.res_stem_id, molsyn.synonyms, rst.*
from molecule_dictionary moldic left join molecule_synonyms molsyn on moldic.molregno=molsyn.molregno 
left join research_stem rst on molsyn.res_stem_id=rst.res_stem_id 
where moldic.molregno in (select * from sel_molregno_tabl2);
-- nothing meaningfull
-- resaertch stems ids = 667, 437, 250

select * from research_companies
where res_stem_id in (667, 437, 250);
-- shows company names

-- include the research synonym => information about which molecules have already been / are researched
select  moldic.molregno, moldic.pref_name, moldic.first_approval, moldic.black_box_warning, moldic.indication_class, molsyn.synonyms, molsyn.syn_type, molsyn.res_stem_id
from molecule_dictionary moldic left join molecule_synonyms molsyn on moldic.molregno=molsyn.molregno 
where moldic.molregno in (select * from sel_molregno_tabl2);
-- duplicates due to severals synonyms per molecule

-- only include reasearch codes
select  moldic.molregno, moldic.pref_name, moldic.first_approval, moldic.black_box_warning, moldic.indication_class, molsyn.synonyms, molsyn.syn_type, molsyn.res_stem_id
from molecule_dictionary moldic left join molecule_synonyms molsyn on moldic.molregno=molsyn.molregno 
where moldic.molregno in (select * from sel_molregno_tabl2)
and (molsyn.syn_type = 'RESEARCH_CODE' or molsyn.syn_type is null);
-- still duplicates, due to typos / small differences in synonyms
-- returns 87 rows even with duplicates?
-- some records that have a synonym other than research code are excluded
-- we need to include all synonyms or make separate tables

-- => separate tables
-- EXPTAB5_approvalinfo
select distinct molregno, pref_name, first_approval, black_box_warning, indication_class
from molecule_dictionary
where molregno in (select * from sel_molregno_tabl2);

-- EXPTAB6_synonyms (only include research codes (others are just null)
select molregno, synonyms
from molecule_synonyms
where molregno in (select * from sel_molregno_tabl2)
and syn_type = 'RESEARCH_CODE';
-- doesnt show all molregnos? => probably only molecules with synonyms have entries here
-- the duplicates lead to a problem in tableau

-- EXPTAB7_RO5RO3
select molregno, ro3_pass, num_lipinski_ro5_violations, hba_lipinski, hbd_lipinski, full_mwt, alogp, rtb from compound_properties
where molregno in (select * from sel_molregno_tabl2);
