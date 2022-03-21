
library(tidyverse)
library(rvest)
library(xml2)

#Webpage where we can search for labels via Application Number:
#https://labels.fda.gov/applicationnumber.cfm

#load in data for the selected drugs including Application Number from SQL
setwd("C:/Users/domin/Desktop/Dominik/DS/CompChem/ChEMBL/P2_MAlaria_Drugs/fda_labels")
drugs <- read.csv("P2_exp4_scraping.csv")

#daraprim: Appl No = 8578
#try searching it via website above; error, it needs to be a 6 figure number

#add zeros to fill up ApplNos to 6 figure
for (i in 1:nrow(drugs)) {
        n.0 <- 6-nchar(drugs[i, "ApplNo"])
        output <- paste(strrep(0,n.0), drugs[i, "ApplNo"], sep = "")
        drugs[i, "ApplNo"] <- output
}

#search 008578 instead => 7 results from two companies
#however the content of the labels seems to be the same => we can just take the first

#concerning the URL for the page with the search results; it is still:
#https://labels.fda.gov/getApplicationNumber.cfm

#after some digging I found the URL:
#https://labels.fda.gov/getApplicationNumber.cfm?searchfield=008578&OrderBy=PackageCode&numberperpage=30&beginrow=1
#which includes the searched number

#check if it works with another Appl number: 009768
#https://labels.fda.gov/getApplicationNumber.cfm?searchfield=009768&OrderBy=PackageCode&numberperpage=30&beginrow=1
#yes - use it to cycle through our selection

#get html nodes via "SelectorGadget" plugin

#write function to get URL of the label (of the first search result), 
#the labels seem to be more or less the same => we can later validate that by comparing
#data from the different search results
#ResultNo determines which search result is chosen
#getURL <- function(ApplNo, ResultNr) {
#        URL1 <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "8&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
#        page <- read_html(URL1)
#        URL2 <- page %>% html_nodes(paste("tr:nth-child(", (ResultNr + 1), ") a", sep = "")) %>% html_attr("href")
#        return(URL2)
#}

#test
#getURL(008578, 1)#works
#getURL(008578, 3)#doesnt work
#getURL(009768, 1)#doesnt work
#doesnt seem to work as expected

#retry with a function that always gets the first result
getURL_first <- function(ApplNo) {
        URL1 <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "8&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
        page <- read_html(URL1)
        URL2 <- page %>% html_nodes("tr:nth-child(2) a") %>% html_attr("href")
        return(URL2)
}

#test
getURL_first(008578)
getURL_first(009768) #doesnt work
#the returned links are not correct

#try with other node (returnes all links?)
getURL_all <- function(ApplNo) {
        URL1 <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "8&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
        page <- read_html(URL1)
        URL2 <- page %>% html_nodes("td a") %>% html_attr("href")
        return(URL2)
}

#test
getURL_all(008578)#returns two links, but from wrong drug
getURL_all(009768)#returns nothing

#there must be a problem with getting to the search results
getSearch <- function(ApplNo) {
        URL <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "8&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
        return(URL)
        return(ApplNo)
}

#the problem was that we have to give the number as string, as otherwise the 
#leading zeros are ignored
getSearch("009768")

#=> rewrite the function, there was also a typo in the URL
getURL <- function(ApplNo, ResultNr) {
        URL1 <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
        page <- read_html(URL1)
        URL2 <- page %>% html_nodes(paste("tr:nth-child(", (ResultNr + 1), ") a", sep = "")) %>% html_attr("href")
        return(URL2)
}

#test
getURL("008578", 1)
getURL("008578", 5)
#seems to work now

#write function to get data via html node
getData <- function(node, ApplNo, ResultNr) {
        label <- getURL(ApplNo, ResultNr)
        Data <- label %>% html_nodes(node) %>% html_text()
        return(Data)
}

#test (title)
getData(".DocumentTitle+ h1","008578", 5)
#doesnt work

label <- getURL("008578", 5) %>% read_html()
label %>% html_nodes(".DocumentTitle .DocumentTitle") %>% html_text()
#returns empty string

link <- "https://www.accessdata.fda.gov/spl/data/d61ffa19-149f-4402-884a-4d16becb80ba/d61ffa19-149f-4402-884a-4d16becb80ba.xml"
page <- read_html(link)
page %>% html_nodes(".Section:nth-child(1) .First") %>% html_text()
#returns empty string

#the problem is probably that this is an XML file, therefore the html node cannot be used

#try to find out how we can extract data from the XML
#try reading with read_xml
page <- read_xml(link)
page
xml_children(page)
xml_contents(page)
xml_length(page)

xml_child(page, search = ".//title")

xml_text(page) #gets all text; hwo to extract certain parts?
xml_text(page, xml_find_all(page, "//title")) #finds nodes that match an xpath expression

#we have to drop namespaces to get result: xml_ns_strip
xml_find_all(xml_ns_strip(page), "//text")
xml_find_all(xml_ns_strip(page), "//paragraph") 
#the number of paragraphs under one title is likely not standardized
#text probably is

xml_find_all(xml_ns_strip(page), "//content")
xml_find_all(xml_ns_strip(page), "//code")# could be interesting, 
#as it contains displayName field, which describes information

#put this into dataframe
code <- data.frame(row.names = c("code", "displayName"))
code <- cbind(code, code = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("code"))
code <- cbind(code, displayName = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("displayName"))
#this might be usefull; it indexes the different sections
#how can we now select the data from these sections?

#these are the corresponding text nodes
textnodes <- xml_find_all(xml_ns_strip(page), "//code") %>% xml_parent() %>% xml_child(., "text")

xml_contents(textnodes[[61]])
#this could be used to extract text in a standardized manner

#check if its the same for other labels
page2 <- read_xml("https://www.accessdata.fda.gov/spl/data/3bde1cbf-4c5e-406b-bb1e-603696668618/3bde1cbf-4c5e-406b-bb1e-603696668618.xml")
textnodes2 <- xml_find_all(xml_ns_strip(page2), "//code") %>% xml_parent() %>% xml_child(., "text")
#no

#write a function where we input the displayName and then get the text out
getText <- function(displayName, page) {
        dn <- data.frame(dn = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("displayName"))
        index <- which(dn$dn == displayName)
        textnodes <- xml_find_all(xml_ns_strip(page), "//code") %>% xml_parent() %>% xml_child(., "text")
        return(xml_text(textnodes[index]))
}

#make a datframe with displayNames and the returned text
extr <- data.frame(section = code[!is.na(code$displayName), "displayName"])

text <- apply(extr, 1, getText, page = page)

#paste together text of sections where there are two text tags
text[(lapply(text, length) == 2) == TRUE] <- lapply(text[(lapply(text, length) == 2) == TRUE], paste, collapse = "")

extr <- text %>% as.data.frame() %>% t() %>% cbind(extr)
row.names(extr) <- c()

colnames(extr) <- c("text", "section")

#exclude NA values
extr <- na.omit(extr)

#replace NANA with NA
extr[extr$text == "NANA", "text"] <- NA

#exclude NA values
extr <- na.omit(extr)

row.names(extr) <- c()

#write function that inludes all of the above
#do this via writing smaller functions for certain tasks first

#find URLs for all selected drugs, always take the first
sapply(drugs[, "ApplNo"], getURL, ResultNr = 1)

getURL <- function(ApplNo, ResultNr) {
        URL1 <- paste("https://labels.fda.gov/getApplicationNumber.cfm?searchfield=", ApplNo, "&OrderBy=PackageCode&numberperpage=30&beginrow=1", sep = "")
        page <- read_html(URL1)
        URL2 <- page %>% html_nodes(paste("tr:nth-child(", (ResultNr + 1), ") a", sep = "")) %>% html_attr("href")
        return(URL2)
}


#no results for c("214756", "209750", "210543", "090249", "207833", "214272")
a <- c("214756", "209750", "210543", "090249", "207833", "214272")
#check by hand => the URLs lead to the search results, saying there is no result
# => exclude them
drugs2 <- drugs[!(drugs$ApplNo %in% a),]

sapply(drugs2[, "ApplNo"], getURL, ResultNr = 1)

URLs <- data.frame(drugs2$ApplNo)
URLs <- cbind(URLs, URL = sapply(drugs2$ApplNo, getURL, ResultNr = 1))
#convert URLs to Strings
URLs$URL <- sapply(URLs$URL, as.character)

#rename column ApplNo
colnames(URLs) <- c("ApplNo", "URL")

#access the files and get the text and displaynames for each
#bind them together into one table

#write function that accesses files and outputs table with text and displayname (= section)
getInfo <- function(URL, ApplNo) {
        #access URL
        page <- read_xml(URL)
        
        #create dataframe of codes and displaynames
        code <- data.frame(code = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("code"))
        code <- cbind(code, displayName = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("displayName"))
        
        #create datframe, get displaynames
        extr <- data.frame(section = code[!is.na(code$displayName), "displayName"])
        
        #get text
        text <- apply(extr, 1, getText, page = page)
        
        #paste together text of sections where there are two text tags
        text[(lapply(text, length) == 2) == TRUE] <- lapply(text[(lapply(text, length) == 2) == TRUE], paste, collapse = "")
        
        extr <- text %>% as.data.frame() %>% t() %>% cbind(extr)
        row.names(extr) <- c()
        
        colnames(extr) <- c("text", "section")
        
        #exclude NA values
        extr <- na.omit(extr)
        
        #replace NANA with NA
        extr[extr$text == "NANA", "text"] <- NA
        
        #exclude NA values
        extr <- na.omit(extr)
        
        row.names(extr) <- c()
        
        #add Appl NO as identifier
        extr <- cbind(ApplNo, extr)
        
        #return df
        return(extr)
}

#test function
a <- getInfo(URLs[1,"URL"], URLs[1, "ApplNo"])
a[1,]
#works

#set up dataframe
labels_text <- getInfo(URLs[1, "URL"], URLs[1, "ApplNo"])

#there are 38 entries in URLs df
for (i in 2:nrow(URLs)) {
        labels_text <- rbind(getInfo(URLs[i, "URL"], URLs[i, "ApplNo"]))
}
#error

#there is a problem with the output of getInfo
a <- getInfo(URLs[2, "URL"], URLs[2, "ApplNo"])
#wrong result

#go back to getInfo function and test with other then first entry in URL table
#look at the label, as maybe there are just differences in the format
URLs[2,]
#it seems to be the same as for URLs[1,]

#the problem might be that in some sections there are more then two text tags
#in the getInfo function we only specified that all the text in a section should be pasted together
#if there are two text tags, not >=2; => change this
getInfo2 <- function(URL, ApplNo) {
        #access URL
        page <- read_xml(URL)
        
        #create dataframe of codes and displaynames
        code <- data.frame(code = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("code"))
        code <- cbind(code, displayName = xml_find_all(xml_ns_strip(page), "//code") %>% xml_attr("displayName"))
        
        #create datframe, get displaynames
        extr <- data.frame(section = code[!is.na(code$displayName), "displayName"])
        
        #get text
        text <- apply(extr, 1, getText, page = page)
        
        #paste together text of sections where there are two text tags
        text[(lapply(text, length) >= 2) == TRUE] <- lapply(text[(lapply(text, length) >= 2) == TRUE], paste, collapse = "")
        
        extr <- text %>% as.data.frame() %>% t() %>% cbind(extr)
        row.names(extr) <- c()
        
        colnames(extr) <- c("text", "section")
        
        #exclude NA values
        extr <- na.omit(extr)
        
        #replace NANA with NA
        extr[extr$text == "NANA", "text"] <- NA
        
        #exclude NA values
        extr <- na.omit(extr)
        
        row.names(extr) <- c()
        
        #add Appl NO as identifier
        extr <- cbind(ApplNo, extr)
        
        #return df
        return(extr)
}

#test updated function
a <- getInfo2(URLs[2, "URL"], URLs[2, "ApplNo"])
a[2,]
#works as expected

#rerun for loop with updated function
#set up dataframe
labels_text2 <- getInfo2(URLs[1, "URL"], URLs[1, "ApplNo"])

#there are 38 entries in URLs df
for (i in 2:nrow(URLs)) {
        labels_text2 <- rbind(getInfo2(URLs[i, "URL"], URLs[i, "ApplNo"]))
}
#error with xml.read function

#run for less entries (up until 3rd record), there was an error in the rbind function
#as the established datframe was not added to the function => it was just overwritten
#correct this
for (i in 2:3) {
        labels_text2 <- rbind(labels_text2, getInfo2(URLs[i, "URL"], URLs[i, "ApplNo"]))
}
#the result for the third drug seems not correct (there are many duplicates)

#check the 3rd label manually
URLs[2,]
#it seems to be formatted differently then the first two; there is first some sort
#of abstract and then the label, which is more exaustive then for the first two drugs
#I assume this to be the problem

#check if there is a label for this drug, that is formatted the same way as the first two
#https://labels.fda.gov/getApplicationNumber.cfm
# ApplNo = 020500
#there is only this label

#what information is included in our dataframe
Mepron <- labels_text2[labels_text2$ApplNo == "020500",]
#there are just many duplicates of SPL unclassified section
#otherwise it seems more or less complete

#delete duplicates
Mepron2 <- Mepron[!duplicated(Mepron), ]
# => there are 17 records (compared to the 22 rows of the first two drugs)
#seems ok; I will not dig deeper here to solve this

#check the text of SPL unclassified section
Mepron2[1,]
#lots of information that was pasted together in this section incl indication
#it seems that in this format the displayName used to parse the label,
#does not work

#rerun for loop

#set up dataframe
labels_text2 <- getInfo2(URLs[1, "URL"], URLs[1, "ApplNo"])

for (i in 2:38) {
        labels_text2 <- rbind(labels_text2, getInfo2(URLs[i, "URL"], URLs[i, "ApplNo"]))
}
#still error (xml.read etc.)
#this must be a problem with a single label, as the dataframe now contains 1020 rows
#and 3 columns => its possible that we have the output for all drugs

#what ApplNo are included in the output?
unique(labels_text2[,"ApplNo"])
#37, the last one beeing 215506 (this is the highest ApplNo)
#maybe for one of the labels there is a problem
#I will continue and not look into that

#remove the duplicate rows
labels_text3 <- labels_text2[!duplicated(labels_text2), ]
#with duplicates removed the df contains 462 records

#count how many rows for each ApplNo
labels_text3 %>% count(ApplNo, sort = TRUE)
#the number of entries per label differs a lot for the different 
#drugs. It ranges form 9 to 23 records

#look at entries for the drug, where there are only 9 records (201691)
labels_text2[labels_text2$ApplNo == "201691",]


#Formatting the text

#there are still some tags from the XML file included as tex
labels_text3[1, "text"] #tag: \n => seems to stand for new paragraph (Pilcrow)

#find all "\"
ns <- sapply(labels_text3[, "text"], grep, pattern = "\n", ignore.case=FALSE)

#select elements from list where this string was found
which(sapply(ns, function(x) "1" %in% x))

#use the selection to return all the text that contains this string
labels_text3[which(sapply(ns, function(x) "1" %in% x)), "text"]

# => it should be replaced with Pilcrow
#actually I found out that in R \n stands for new line
# => no changes necessary

#to see it printed as such, use cat() function
cat(as.character(labels_text3[1, "text"]))

#we might have to remove leading spaces => every instance of more then one space next to each other
gsub(x = as.character(labels_text3[1, "text"]), pattern = "  ", replacement = "") %>% cat()
#this removes a straight number of spaces, one single space on the new paragraph could be left

#also remove the first space after \n
gsub(x = as.character(labels_text3[1, "text"]), pattern = "  ", replacement = "") %>% gsub(pattern = "\n ", replacement = "\n") %>% cat()

#apply this to all text
a <- labels_text3[1:10, "text"] %>% sapply(., gsub, pattern = "  ", replacement = "") %>% sapply(., gsub, pattern = "\n ", replacement = "\n")

#control
cat(a[[1]])
cat(a[[3]])
cat(a[[6]])
#they print as they should

#do for all the text
labels_text4 <- labels_text3

labels_text4$text <- labels_text3[, "text"] %>% sapply(., gsub, pattern = "  ", replacement = "") %>% sapply(., gsub, pattern = "\n ", replacement = "\n")

cat(labels_text4[266, "text"])
#it all seems to print like it should

#export data
write.csv(labels_text4, file = "P2_exp5_fda_labels.csv")
