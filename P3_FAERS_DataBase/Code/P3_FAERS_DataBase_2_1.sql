
-- I create a new schema and use the same tabel creation statements as
-- in P3_PharmacovigilanceData_1 SQL Script:

CREATE DATABASE faers_3;
USE faers_3;

-- is loading local data enabeled?
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';

-- give myself rights
GRANT ALL ON faers.* TO 'root'@'localhost';

-- dont run on strict mode
SET sql_mode = "";


-- create table
DROP TABLE IF EXISTS `general`;
CREATE TABLE general (
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
    companynumb VARCHAR(100),
    `duplicate` INT NULL,
    duplicatesource VARCHAR(50),
    duplicatenumb VARCHAR(50),
    reportercountry VARCHAR(2),
    qualification INT NULL,
    literaturereference VARCHAR(255),
    sendertype INT NULL,
    senderorganization VARCHAR(50),
    receivertype INT NULL,
    receiverorganization VARCHAR(10),
    patientonsetage INT NULL,
    patientonsetageunit INT NULL,
    patientsex INT NULL,
    patientweight INT NULL,
    narrativeincludeclinical VARCHAR(50),
    patientagegroup INT NULL,
    seriousnesshospitalization INT NULL,
    seriousnessdeath INT NULL,
    authoritynumb VARCHAR(100),
    seriousnessdisabling INT NULL,
    seriousnesslifethreatening INT NULL,
    PRIMARY KEY (safetyreportid)
    #,FOREIGN KEY (patientagegroup) REFERENCES lu_patientagegroup(patientagegroup),
    #FOREIGN KEY (patientonsetageunit) REFERENCES lu_patientonsetageunit(patientonsetageunit),
    #FOREIGN KEY (qualification) REFERENCES lu_qualification(qualification),
    #FOREIGN KEY (serious) REFERENCES lu_serious(serious),
    #FOREIGN KEY (reporttype) REFERENCES lu_reporttype(reporttype)   
);

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';
-- works - takes ca. 30 seconds, ca 180 k records
-- I made some adaptions to the create table statement above in order to get rid of all error messages

 -- how does this work with the drugs and reactions table?
DROP TABLE IF EXISTS reactions;
CREATE TABLE reactions (
	safetyreportid INT,
    reactionmeddraversionpt DOUBLE,
    reactionmeddrapt VARCHAR(100),
    reactionoutcome INT DEFAULT NULL
    #,PRIMARY KEY (safetyreportid)
);
SHOW VARIABLES LIKE "secure_file_priv";
 -- Do we get several entries per report?
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<safetyreport>';
-- no one per report
-- makes sense as we spefify, that a new row stars at every <safetyreport>

-- specify new row with every <reaction>
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';
-- now there is the problem, that we cannot use safetyreport as primary key, as there are several reports per id
-- we have to use an auto increment ID as primary key

DROP TABLE IF EXISTS reactions;
CREATE TABLE reactions (
	Reaction_id int NOT NULL AUTO_INCREMENT,
	safetyreportid INT,
    reactionmeddraversionpt DOUBLE,
    reactionmeddrapt VARCHAR(100),
    reactionoutcome INT DEFAULT NULL,
    PRIMARY KEY (Reaction_id)
);

-- I will now use the previously set up data model as basis to import data from the XMLs

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
# Create and load big tables
#########################################

 -- create table
DROP TABLE IF EXISTS reactions;
CREATE TABLE reactions (
	Reaction_id int NOT NULL AUTO_INCREMENT,
	safetyreportid INT,
    reactionmeddraversionpt DOUBLE,
    reactionmeddrapt VARCHAR(100),
    reactionoutcome INT DEFAULT NULL,
    PRIMARY KEY (Reaction_id),
    FOREIGN KEY (reactionoutcome) REFERENCES lu_reactionoutcome(reactionoutcome),
    INDEX `fk_general_reactions_idx` (safetyreportid ASC)
);

-- insert data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

DROP TABLE IF EXISTS drugs;
CREATE TABLE drugs (
	Drugs_id int NOT NULL AUTO_INCREMENT,
	safetyreportid INT,
    drugcharacterization INT,
    medicinalproduct VARCHAR(255),
    drugbatchnumb VARCHAR(50),
    drugauthorizationnumb VARCHAR(50),
    drugadministrationroute INT NULL,
    drugindication VARCHAR(100),
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
    drugdosagetext VARCHAR(255),
    drugdosageform VARCHAR(50),
    drugenddateformat INT NULL,
    drugenddate VARCHAR(50),
    drugrecurreadministration INT NULL,
    drugcumulativedosagenumb DOUBLE NULL,
    drugcumulativedosageunit INT NULL,
    drugrecurrence VARCHAR(255),
    PRIMARY KEY (Drugs_id),
    FOREIGN KEY (actiondrug) REFERENCES lu_actiondrug(actiondrug),
    FOREIGN KEY (drugadministrationroute) REFERENCES lu_drugadministrationroute(drugadministrationroute),
    FOREIGN KEY (drugcharacterization) REFERENCES lu_drugcharacterization(drugcharacterization),
    FOREIGN KEY (drugintervaldosagedefinition) REFERENCES lu_drugintervaldosagedefinition(drugintervaldosagedefinition),
    FOREIGN KEY (drugstructuredosageunit) REFERENCES lu_drugstructuredosageunit(drugstructuredosageunit),
    INDEX `fk_general_drugs_idx` (safetyreportid ASC)
);

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';
-- I got error 1206 and had to set it to a bigger value
#show variables like '%storage_engine%';
#SET GLOBAL innodb_buffer_pool_size=2147483648;

-- ca 780 k were imported
-- 140 rows where skipped as the drugstructuredosageunit did fail the foreign key constraints
-- these values are probably just wrong in the data.

-- I will just disable the foreig key check to insert the data
SHOW GLOBAL VARIABLES LIKE 'FOREIGN_KEY_CHECKS';
#SET FOREIGN_KEY_CHECKS=0;
#SET FOREIGN_KEY_CHECKS=1;

-- create table
DROP TABLE IF EXISTS `general`;
CREATE TABLE general (
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
    companynumb VARCHAR(100),
    `duplicate` INT NULL,
    duplicatesource VARCHAR(50),
    duplicatenumb VARCHAR(50),
    reportercountry VARCHAR(2),
    qualification INT NULL,
    literaturereference VARCHAR(255),
    sendertype INT NULL,
    senderorganization VARCHAR(50),
    receivertype INT NULL,
    receiverorganization VARCHAR(10),
    patientonsetage INT NULL,
    patientonsetageunit INT NULL,
    patientsex INT NULL,
    patientweight INT NULL,
    narrativeincludeclinical VARCHAR(50),
    patientagegroup INT NULL,
    seriousnesshospitalization INT NULL,
    seriousnessdeath INT NULL,
    authoritynumb VARCHAR(100),
    seriousnessdisabling INT NULL,
    seriousnesslifethreatening INT NULL,
    PRIMARY KEY (safetyreportid),
    FOREIGN KEY (patientagegroup) REFERENCES lu_patientagegroup(patientagegroup),
    FOREIGN KEY (patientonsetageunit) REFERENCES lu_patientonsetageunit(patientonsetageunit),
    FOREIGN KEY (qualification) REFERENCES lu_qualification(qualification),
    FOREIGN KEY (serious) REFERENCES lu_serious(serious),
    FOREIGN KEY (reporttype) REFERENCES lu_reporttype(reporttype),
    FOREIGN KEY (safetyreportid) REFERENCES reactions(safetyreportid),
    FOREIGN KEY (safetyreportid) REFERENCES drugs(safetyreportid)
);

-- insert data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';
-- ca. 180 k imported; 80 skipped as constraints with drug(safetyreportid) where not met
-- those must be records without an associated drug => those probably would not be very usefull anyways

-- Here I disabled the foreign key check as well to import the data

-- the next step will be to insert more data => maybe for the last two years

#########################################
# Load in Data for the years 2021/2020
#########################################

-- the following insert statements where generated via the R Script: P2_PharmacovigilanceData_2.Rmd
-- before running all the statements I droped the tables and created them again 

-- NOTE: as I run the insert staements I realized, that there would be several entries per case
-- => there would be "duplicates" of the primary key (safetyreportid) of the "general" table
-- therefore I modified the create table statement, so the primary key
-- would be safetyreportid and safetyreportversion.

DROP TABLE IF EXISTS reactions;
CREATE TABLE reactions (
	Reaction_id int NOT NULL AUTO_INCREMENT,
    safetyreportversion INT NOT NULL,
	safetyreportid INT,
    reactionmeddraversionpt DOUBLE,
    reactionmeddrapt VARCHAR(100),
    reactionoutcome INT DEFAULT NULL,
    PRIMARY KEY (Reaction_id),
    FOREIGN KEY (reactionoutcome) REFERENCES lu_reactionoutcome(reactionoutcome),
    INDEX `fk_general_reactions_idx` (safetyreportid, safetyreportversion ASC)
);

DROP TABLE IF EXISTS drugs;
CREATE TABLE drugs (
	Drugs_id int NOT NULL AUTO_INCREMENT,
    safetyreportversion INT NOT NULL,
	safetyreportid INT,
    drugcharacterization INT,
    medicinalproduct VARCHAR(255),
    drugbatchnumb VARCHAR(50),
    drugauthorizationnumb VARCHAR(50),
    drugadministrationroute INT NULL,
    drugindication VARCHAR(100),
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
    drugdosagetext VARCHAR(255),
    drugdosageform VARCHAR(50),
    drugenddateformat INT NULL,
    drugenddate VARCHAR(50),
    drugrecurreadministration INT NULL,
    drugcumulativedosagenumb DOUBLE NULL,
    drugcumulativedosageunit INT NULL,
    drugrecurrence VARCHAR(255),
    PRIMARY KEY (Drugs_id),
    FOREIGN KEY (actiondrug) REFERENCES lu_actiondrug(actiondrug),
    FOREIGN KEY (drugadministrationroute) REFERENCES lu_drugadministrationroute(drugadministrationroute),
    FOREIGN KEY (drugcharacterization) REFERENCES lu_drugcharacterization(drugcharacterization),
    FOREIGN KEY (drugintervaldosagedefinition) REFERENCES lu_drugintervaldosagedefinition(drugintervaldosagedefinition),
    FOREIGN KEY (drugstructuredosageunit) REFERENCES lu_drugstructuredosageunit(drugstructuredosageunit),
    INDEX `fk_general_drugs_idx` (safetyreportid, safetyreportversion ASC)
);

DROP TABLE IF EXISTS `general`;
CREATE TABLE general (
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
    companynumb VARCHAR(100),
    `duplicate` INT NULL,
    duplicatesource VARCHAR(50),
    duplicatenumb VARCHAR(50),
    reportercountry VARCHAR(2),
    qualification INT NULL,
    literaturereference VARCHAR(255),
    sendertype INT NULL,
    senderorganization VARCHAR(50),
    receivertype INT NULL,
    receiverorganization VARCHAR(10),
    patientonsetage INT NULL,
    patientonsetageunit INT NULL,
    patientsex INT NULL,
    patientweight INT NULL,
    narrativeincludeclinical VARCHAR(50),
    patientagegroup INT NULL,
    seriousnesshospitalization INT NULL,
    seriousnessdeath INT NULL,
    authoritynumb VARCHAR(100),
    seriousnessdisabling INT NULL,
    seriousnesslifethreatening INT NULL,
    PRIMARY KEY (safetyreportid, safetyreportversion),
    FOREIGN KEY (patientagegroup) REFERENCES lu_patientagegroup(patientagegroup),
    FOREIGN KEY (patientonsetageunit) REFERENCES lu_patientonsetageunit(patientonsetageunit),
    FOREIGN KEY (qualification) REFERENCES lu_qualification(qualification),
    FOREIGN KEY (serious) REFERENCES lu_serious(serious),
    FOREIGN KEY (reporttype) REFERENCES lu_reporttype(reporttype),
    FOREIGN KEY (safetyreportid, safetyreportversion) REFERENCES reactions(safetyreportid, safetyreportversion),
    FOREIGN KEY (safetyreportid, safetyreportversion) REFERENCES drugs(safetyreportid, safetyreportversion)
);

-- I also disabled the foreig key check
#SHOW GLOBAL VARIABLES LIKE 'FOREIGN_KEY_CHECKS';
#SET FOREIGN_KEY_CHECKS=0;
#SET FOREIGN_KEY_CHECKS=1;

-- is loading local data enabeled?
#SHOW GLOBAL VARIABLES LIKE 'local_infile';
#SET GLOBAL local_infile = 'ON';

 -- error messages:
 -- 1263 for reporttype receivedateformat (general) for 1/2/3_ADR21_Q4

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q1.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q2.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q3.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q4.xml'
INTO TABLE `general`
ROWS IDENTIFIED BY '<safetyreport>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q1.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q2.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q3.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q4.xml'
INTO TABLE drugs
ROWS IDENTIFIED BY '<drug>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR20Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR20Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR20Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1_ADR21Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2_ADR21Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q1.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q2.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q3.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';

LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3_ADR21Q4.xml'
INTO TABLE reactions
ROWS IDENTIFIED BY '<reaction>';