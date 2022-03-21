library(rcdk)

setwd("C:/Users/domin/Desktop/Dominik/DS/CompChem/ChEMBL/P2_MAlaria_Drugs")

#read in the data
sel.smiles <- data.frame(read.csv("selection_smiles.csv"))

#remove records with NULL as smiles
sel.smiles[sel.smiles$canonical_smiles=="NULL",] <- NA
sel.smiles <- na.omit(sel.smiles)

#convert smiles to characters
sel.smiles$canonical_smiles <- lapply(sel.smiles$canonical_smiles, as.character)

#convert to vector
vec.smiles <- sapply(sel.smiles$canonical_smiles, paste0, collapse="")

#load in a smiles
smiles <- parse.smiles(vec.smiles, kekulise=TRUE)

#normally the function view.molecule.2d would be used to produce plots
#there seems to be an issue with it when running it on windows

#function found here https://github.com/CDK-R/cdkr/issues/61, which directly 
#saves the image into the working directory

todepict <- function(mol,pathsd){
        result = tryCatch({
                factory <- .jnew("org.openscience.cdk.depict.DepictionGenerator")$withAtomColors()
                factory$withSize(1000,1000)#$getStyle("cow")
                temp1 <- paste0(pathsd)
                result<-factory$depict(mol)$writeTo(temp1)
        }, warning = function(w) {
                result=NULL
        }, error = function(e) {
                result=NULL
        })
        return(result)
}

#example of usage
mol<-parse.smiles("c1ccccc1", kekulise=TRUE)[[1]]
todepict(mol,paste0(getwd(),"/Benzene.png"))

#test
mol<-smiles[[1]]
todepict(mol,paste0(getwd(),"/structures/",as.character(sel.smiles[1,1]),".png"))

#write for loop for my molecules
for (i in 1:72) {
        mol <- smiles[[i]]
        todepict(mol,paste0(getwd(),"/structures/",as.character(sel.smiles[i,1]),".png"))
}
#72 files produced