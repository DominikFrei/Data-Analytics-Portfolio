setwd("C:/Users/domin/Desktop/Dominik/DS/CompChem/ChEMBL/P2_MAlaria_Drugs/20220201_drugs_at_fda")

#read in data
ActionTypes_Lookup <- read.delim("ActionTypes_Lookup.txt", header = TRUE, sep = "\t",
                   quote = "")

ApplicationDocs <- read.delim("ApplicationDocs.txt", header = TRUE, sep = "\t",
                                 quote = "")

Applications <- read.delim("Applications.txt", header = TRUE, sep = "\t",
                                 quote = "")

ApplicationsDocsType_Lookup <- read.delim("ApplicationsDocsType_Lookup.txt", header = TRUE, sep = "\t",
                                 quote = "")

MarketingStatus <- read.delim("MarketingStatus.txt", header = TRUE, sep = "\t",
                                 quote = "")

MarketingStatus_Lookup <- read.delim("MarketingStatus_Lookup.txt", header = TRUE, sep = "\t",
                                 quote = "")

Products <- read.delim("Products.txt", header = TRUE, sep = "\t",
                                 quote = "")

SubmissionClass_Lookup <- read.delim("SubmissionClass_Lookup.txt", header = TRUE, sep = "\t",
                                 quote = "")

SubmissionPropertyType <- read.delim("SubmissionPropertyType.txt", header = TRUE, sep = "\t",
                                     quote = "")

Submissions <- read.delim("Submissions.txt", header = TRUE, sep = "\t",
                                     quote = "")

TE <- read.delim("TE.txt", header = TRUE, sep = "\t",
                                     quote = "")

#save as .csv
write.csv(ActionTypes_Lookup, file = "ActionTypes_Lookup.csv")
write.csv(ApplicationDocs, file = "ApplicationDocs.csv")
write.csv(Applications, file = "Applications.csv")
write.csv(ApplicationsDocsType_Lookup, file = "ApplicationsDocsType_Lookup.csv")
write.csv(MarketingStatus, file = "MarketingStatus.csv")
write.csv(MarketingStatus_Lookup, file = "MarketingStatus_Lookup.csv")
write.csv(Products, file = "Products.csv")
write.csv(SubmissionClass_Lookup, file = "SubmissionClass_Lookup.csv")
write.csv(SubmissionPropertyType, file = "SubmissionPropertyType.csv")
write.csv(Submissions, file = "Submissions.csv")
write.csv(TE, file = "TE.csv")
