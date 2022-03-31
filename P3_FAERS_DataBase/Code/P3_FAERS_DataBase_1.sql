
# P3_Pharmacovigilance Data

-- I created csv files from XML files provided by the FDA via R ("Pharmacovigilance_Data.Rmd").
-- I now imported the files created for testing ("test2_general", "test2_drugs", "test2_reactions") and 
-- all the look up tables.


-- load in the data (https://dev.mysql.com/doc/refman/8.0/en/load-data.html)

-- is loading local data enabeled?
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';

-- give myself rights
GRANT ALL ON faers.* TO 'root'@'localhost';

-- dont run on strict mode
SET sql_mode = "";

-- find working directory
SHOW VARIABLES LIKE "secure_file_priv";

#########################################
# Create and load in the lookup tables
#########################################

-- create table
DROP TABLE IF EXISTS lu_actiondrug;
CREATE TABLE lu_actiondrug (
    actiondrug INT NOT NULL PRIMARY KEY,
    actiondrug_def VARCHAR(20),
    INDEX `fk_drugs_actiondrug_idx` (actiondrug ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_actiondrug.csv" 
INTO TABLE lu_actiondrug
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(actiondrug, actiondrug_def);

SELECT * FROM faers.lu_actiondrug;

-- create table
DROP TABLE IF EXISTS lu_drugadministrationroute;
CREATE TABLE lu_drugadministrationroute (
    drugadministrationroute INT NOT NULL PRIMARY KEY,
    drugadministrationroute_def VARCHAR(50),
    INDEX `fk_drugs_drugadministrationroute_idx` (drugadministrationroute ASC)
);

-- load in data (here the values are separated by ";" maybe due to it having been created via Excel)
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_drugadministrationroute.csv" 
INTO TABLE lu_drugadministrationroute
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(drugadministrationroute, drugadministrationroute_def);

SELECT * FROM faers.lu_drugadministrationroute;

-- create table
DROP TABLE IF EXISTS lu_drugcharacterization;
CREATE TABLE lu_drugcharacterization (
    drugcharacterization INT NOT NULL PRIMARY KEY,
    drugcharacterization_def VARCHAR(20),
    INDEX `fk_drugs_drugcharacterization_idx` (drugcharacterization ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_drugcharacterization.csv" 
INTO TABLE lu_drugcharacterization
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(drugcharacterization, drugcharacterization_def);

SELECT * FROM faers.lu_drugcharacterization;

-- create table (separated by ";")
DROP TABLE IF EXISTS lu_drugintervaldosagedefinition;
CREATE TABLE lu_drugintervaldosagedefinition (
    drugintervaldosagedefinition INT NOT NULL PRIMARY KEY,
    drugintervaldosagedefinition_def VARCHAR(20),
    INDEX `fk_drugs_drugintervaldosagedefinition_idx` (drugintervaldosagedefinition ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_drugintervaldosagedefinition.csv" 
INTO TABLE lu_drugintervaldosagedefinition
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(drugintervaldosagedefinition, drugintervaldosagedefinition_def);

SELECT * FROM faers.lu_drugintervaldosagedefinition;

-- create table (separated by ";")
DROP TABLE IF EXISTS lu_drugstructuredosageunit;
CREATE TABLE lu_drugstructuredosageunit (
    drugstructuredosageunit INT NOT NULL PRIMARY KEY,
    drugstructuredosageunit_def VARCHAR(20),
    INDEX `fk_drugs_drugstructuredosageunit_idx` (drugstructuredosageunit ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_drugstructuredosageunit.csv" 
INTO TABLE lu_drugstructuredosageunit
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(drugstructuredosageunit, drugstructuredosageunit_def);

SELECT * FROM faers.lu_drugstructuredosageunit;

-- create table
DROP TABLE IF EXISTS lu_patientagegroup;
CREATE TABLE lu_patientagegroup (
    patientagegroup INT NOT NULL PRIMARY KEY,
    patientagegroup_def VARCHAR(20),
    INDEX `fk_general_patientagegroup_idx` (patientagegroup ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_patientagegroup.csv" 
INTO TABLE lu_patientagegroup
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(patientagegroup, patientagegroup_def);

SELECT * FROM faers.lu_patientagegroup;

-- create table
DROP TABLE IF EXISTS lu_patientonsetageunit;
CREATE TABLE lu_patientonsetageunit (
    patientonsetageunit INT NOT NULL PRIMARY KEY,
    patientonsetageunit_def VARCHAR(20),
    INDEX `fk_general_patientonsetageunit_idx` (patientonsetageunit ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_patientonsetageunit.csv" 
INTO TABLE lu_patientonsetageunit
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(patientonsetageunit, patientonsetageunit_def);

SELECT * FROM faers.lu_patientonsetageunit;

-- create table
DROP TABLE IF EXISTS lu_qualification;
CREATE TABLE lu_qualification (
    qualification INT NOT NULL PRIMARY KEY,
    qualification_def VARCHAR(50),
    INDEX `fk_general_qualification_idx` (qualification ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_qualification.csv" 
INTO TABLE lu_qualification
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(qualification, qualification_def);

SELECT * FROM faers.lu_qualification;

-- create table
DROP TABLE IF EXISTS lu_reactionoutcome;
CREATE TABLE lu_reactionoutcome (
    reactionoutcome INT NOT NULL PRIMARY KEY,
    reactionoutcome_def VARCHAR(50),
    INDEX `fk_reactions_reactionoutcome_idx` (reactionoutcome ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_reactionoutcome.csv" 
INTO TABLE lu_reactionoutcome
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(reactionoutcome, reactionoutcome_def);

SELECT * FROM faers.lu_reactionoutcome;

-- create table
DROP TABLE IF EXISTS lu_reporttype;
CREATE TABLE lu_reporttype (
    reporttype INT NOT NULL PRIMARY KEY,
    reporttype_def VARCHAR(50),
    INDEX `fk_general_reporttype_idx` (reporttype ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_reporttype.csv" 
INTO TABLE lu_reporttype
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(reporttype, reporttype_def);

SELECT * FROM faers.lu_reporttype;

-- create table
DROP TABLE IF EXISTS lu_serious;
CREATE TABLE lu_serious (
    serious INT NOT NULL PRIMARY KEY,
    serious_def VARCHAR(10),
    INDEX `fk_general_serious_idx` (serious ASC)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lu_serious.csv" 
INTO TABLE lu_serious
FIELDS TERMINATED BY ',' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(serious, serious_def);

SELECT * FROM faers.lu_serious;

#########################################
# Create and load in the bigger tables
#########################################

-- create table
DROP TABLE IF EXISTS test2_reactions;
CREATE TABLE test2_reactions (
	safetyreportid INT,
    `index` INT, # as index is a reserved word for MySQL, we have to use ``
    reactionmeddraversionpt DOUBLE,
    reactionmeddrapt VARCHAR(100),
    reactionoutcome INT DEFAULT NULL,
    PRIMARY KEY (safetyreportid, `index`)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test2_reactions.csv" 
INTO TABLE test2_reactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(safetyreportid, `index`, reactionmeddraversionpt, reactionmeddrapt, reactionoutcome);
-- some warnings: NULL was tranformed to 0
-- one field of reaction outcome contained a comma 
-- => this was corrected via usin ";" as separator in the R function (already implemented in statement above)

SELECT * FROM faers.test2_reactions;

-- While adding the foreign key constraints I came upon the problem, that because in some cases the NULL values where
-- converted to 0 during the insert, it was unable to connect the value to the lookup table. This is because 0
-- is not defined in the lookup table.

-- Unfortunately I was unable to resolve the issue during the import of the data. Therefore
-- we will just convert the 0s to NULLs in the respective columns and then add the
-- foreign keys
UPDATE test2_reactions SET reactionoutcome = NULL WHERE reactionoutcome = 0;

ALTER TABLE test2_reactions
ADD CONSTRAINT fk_test2_reactions_reactionoutcome
FOREIGN KEY (reactionoutcome) REFERENCES lu_reactionoutcome(reactionoutcome);

-- create table
DROP TABLE IF EXISTS test2_drugs;
CREATE TABLE test2_drugs (
	safetyreportid INT,
	`index` INT,
    drugcharacterization INT,
    medicinalproduct VARCHAR(50),
    drugbatchnumb VARCHAR(50),
    drugauthorizationnumb VARCHAR(50),
    drugadministrationroute INT NULL,
    drugindication VARCHAR(50),
    actiondrug INT NULL,
    drugadditional INT NULL,
    activesubstance VARCHAR(50),
    drugstructuredosagenumb INT NULL,
    drugstructuredosageunit INT NULL,
    drugstartdateformat INT NULL,
    drugstartdate VARCHAR(50),
    drugseparatedosagenumb INT NULL,
    drugintervaldosageunitnumb INT NULL,
    drugintervaldosagedefinition INT NULL,
    drugdosagetext VARCHAR(50),
    drugdosageform VARCHAR(50),
    drugenddateformat INT NULL,
    drugenddate VARCHAR(50),
    drugrecurreadministration INT NULL,
    drugcumulativedosagenumb DOUBLE NULL,
    drugcumulativedosageunit INT NULL,
    drugrecurrence VARCHAR(255),
    PRIMARY KEY (safetyreportid, `index`)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test2_drugs.csv" 
INTO TABLE test2_drugs
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(safetyreportid, `index`, drugcharacterization,	medicinalproduct, drugbatchnumb, drugauthorizationnumb, drugadministrationroute, drugindication, actiondrug,
	drugadditional, activesubstance, drugstructuredosagenumb, drugstructuredosageunit, drugstartdateformat, drugstartdate, drugseparatedosagenumb,
	drugintervaldosageunitnumb, drugintervaldosagedefinition, drugdosagetext, drugdosageform, drugenddateformat, drugenddate, drugrecurreadministration,
	drugcumulativedosagenumb, drugcumulativedosageunit, drugrecurrence
);
-- there are some instances where a datafield contain ; which leads to problems
-- => this would have to be corrected in the R Script

-- transform 0s to null in the columns linked to lookup table
UPDATE test2_drugs SET actiondrug = NULL WHERE actiondrug = 0;
UPDATE test2_drugs SET drugadministrationroute = NULL WHERE drugadministrationroute = 0;
UPDATE test2_drugs SET drugcharacterization = NULL WHERE drugcharacterization = 0;
UPDATE test2_drugs SET drugintervaldosagedefinition = NULL WHERE drugintervaldosagedefinition = 0;
UPDATE test2_drugs SET drugstructuredosageunit = NULL WHERE drugstructuredosageunit = 0;

-- add the foreign keys
ALTER TABLE test2_drugs
ADD CONSTRAINT fk_test2_drugs_actiondrug
FOREIGN KEY (actiondrug) REFERENCES lu_actiondrug(actiondrug);
-- fails
SELECT distinct actiondrug FROM faers.test2_drugs;
-- there are values that is not defined in our lookup table (58)
-- we will replace them with null and try again
UPDATE test2_drugs SET actiondrug = NULL WHERE actiondrug = 58;
-- it worked; this "wrong" value might have been introduced because a datafield in the
-- respective record contained a ";", which then leads to data being inserted into the wrong column.

ALTER TABLE test2_drugs
ADD CONSTRAINT fk_test2_drugs_drugadministrationroute
FOREIGN KEY (drugadministrationroute) REFERENCES lu_drugadministrationroute(drugadministrationroute);
-- fails
SELECT distinct drugadministrationroute FROM faers.test2_drugs;
-- there are values that is not defined in our lookup table (125402)
-- we will replace them with null and try again
UPDATE test2_drugs SET drugadministrationroute = NULL WHERE drugadministrationroute = 125402;
-- it worked

ALTER TABLE test2_drugs
ADD CONSTRAINT fk_test2_drugs_drugcharacterization
FOREIGN KEY (drugcharacterization) REFERENCES lu_drugcharacterization(drugcharacterization);

ALTER TABLE test2_drugs
ADD CONSTRAINT fk_test2_drugs_drugintervaldosagedefinition
FOREIGN KEY (drugintervaldosagedefinition) REFERENCES lu_drugintervaldosagedefinition(drugintervaldosagedefinition);

ALTER TABLE test2_drugs
ADD CONSTRAINT fk_test2_drugs_drugstructuredosageunit
FOREIGN KEY (drugstructuredosageunit) REFERENCES lu_drugstructuredosageunit(drugstructuredosageunit);
-- fails
SELECT distinct drugstructuredosageunit FROM faers.test2_drugs;
-- there are values that is not defined in our lookup table (45, 508)
-- we will replace them with null and try again
UPDATE test2_drugs SET drugstructuredosageunit = NULL WHERE drugstructuredosageunit in (45, 508);
-- it worked

-- create table
DROP TABLE IF EXISTS test2_general;
CREATE TABLE test2_general (
	safetyreportversion INT NOT NULL,
    safetyreportid INT NOT NULL,
    primarysourcecountry VARCHAR(2),
    occurcountry VARCHAR(2),
    transmissiondateformat INT NOT NULL,
    transmissiondate VARCHAR(10),
    reporttype INT NOT NULL,
    serious INT NOT NULL ,
    seriousnessother INT NULL,
    receivedateformat INT NOT NULL,
    receivedate VARCHAR(10),
    receiptdateformat INT NOT NULL,
    receiptdate VARCHAR(10),
    fulfillexpeditecriteria INT NOT NULL,
    companynumb VARCHAR(50),
    `duplicate` INT NOT NULL,
    duplicatesource VARCHAR(50),
    duplicatenumb VARCHAR(50),
    reportercountry VARCHAR(2),
    qualification INT NULL,
    literaturereference VARCHAR(255),
    sendertype INT NOT NULL,
    senderorganization VARCHAR(50),
    receivertype INT NOT NULL,
    receiverorganization VARCHAR(10),
    patientonsetage INT NULL,
    patientonsetageunit INT NULL,
    patientsex INT NULL,
    patientweight INT NULL,
    narrativeincludeclinical VARCHAR(50),
    patientagegroup INT NULL,
    seriousnesshospitalization INT NULL,
    seriousnessdeath INT NULL,
    authoritynumb VARCHAR(50),
    seriousnessdisabling INT NULL,
    seriousnesslifethreatening INT NULL,
    PRIMARY KEY (safetyreportid)
);

-- load in data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test2_general.csv" 
INTO TABLE test2_general
FIELDS TERMINATED BY ';' 
ENCLOSED BY "" 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(safetyreportversion, safetyreportid, primarysourcecountry, occurcountry, transmissiondateformat, transmissiondate, reporttype,
    serious, seriousnessother, receivedateformat, receivedate, receiptdateformat, receiptdate, fulfillexpeditecriteria, companynumb,
    `duplicate`, duplicatesource, duplicatenumb, reportercountry, qualification, literaturereference, sendertype, senderorganization,
    receivertype, receiverorganization, patientonsetage, patientonsetageunit, patientsex, patientweight, narrativeincludeclinical, patientagegroup,
    seriousnesshospitalization, seriousnessdeath, authoritynumb, seriousnessdisabling, seriousnesslifethreatening
);

SELECT * FROM faers.test2_general;

-- transform 0s to null in the columns linked to lookup table
UPDATE test2_general SET patientagegroup = NULL WHERE patientagegroup = 0;
UPDATE test2_general SET patientonsetageunit = NULL WHERE patientonsetageunit = 0;
UPDATE test2_general SET qualification = NULL WHERE qualification = 0;
UPDATE test2_general SET serious = NULL WHERE serious = 0;
UPDATE test2_general SET reporttype = NULL WHERE reporttype = 0;

-- add the foreign keys
ALTER TABLE test2_general
ADD CONSTRAINT fk_test2_general_patientagegroup
FOREIGN KEY (patientagegroup) REFERENCES lu_patientagegroup(patientagegroup);

ALTER TABLE test2_general
ADD CONSTRAINT fk_test2_general_patientonsetageunit
FOREIGN KEY (patientonsetageunit) REFERENCES lu_patientonsetageunit(patientonsetageunit);

ALTER TABLE test2_general
ADD CONSTRAINT fk_test2_general_qualification
FOREIGN KEY (qualification) REFERENCES lu_qualification(qualification);

ALTER TABLE test2_general
ADD CONSTRAINT fk_test2_general_serious
FOREIGN KEY (serious) REFERENCES lu_serious(serious);

ALTER TABLE test2_general
ADD CONSTRAINT fk_test2_general_reporttype
FOREIGN KEY (reporttype) REFERENCES lu_reporttype(reporttype);

-- I used reverse engineer to access the EER for the created data model.
-- I remarked that I had not added the foreign keys to test2_general in test2_drugs and test2_reactions, so
-- I did this in the EER Viewer in the MySQL Workbench. I safed this database as faers_2 and exported an
-- image of the data model.