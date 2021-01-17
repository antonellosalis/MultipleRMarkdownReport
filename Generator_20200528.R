#################################################################
# 
# Automatic Report Generator 
# It generates 1 report per every UE (Sample Unit)
# Is composed by two scripts: ReportGenerator.R and paramark.rmd 
# supposed to be in the same directory
# 
# R
# 2020
#                      
# Antonello Salis
# antonello.salis@fao.org
# antonellosalis@gmail.com
# last version 20200528
#
#################################################################
# Next steps:
# 1 - Better organization of the document (more schematic)
# 2 - More information including (NAs, species names etc) and a graphic DBH/Height 
# 3 - General report that includes the link to every sub-report
# 4 - Export in HTML
# 5 - inclusion of a shiny app
# 6 - Outliars automatic identification 
# 7 - Tree proximity check
# 8 - GPS Coordinates checks
# 9 - Structured script by indicators
################################################################
rm(list = ls())
library(rmarkdown)
library(dplyr)
library(rgdal)
library(tufte)
library(tint)
# Working directories
setwd("/home/antonello/R_projects/NFI_RDC/")
Datawd <- ("/home/antonello/R_projects/NFI_RDC/Data/collect-csv-data-export-drc_nfi-ENTRY-2020-05-05T17_27_48/") 
Complementary<-("/home/antonello/R_projects/NFI_RDC/Data/Comp_Data/")
ScriptFolder<-("/home/antonello/R_projects/NFI_RDC/QAQC_Report_Generator/")

# A tree file needs to be prepared including all the parameters for the validation
trees <- read.csv(paste(Datawd,"abres.csv", sep = ""), header=T)
ue <- read.csv(paste(Datawd,"ue.csv", sep=""), header=T)
sos <- read.csv(paste(Datawd,"sos.csv", sep=""), header=T)
parc <- read.csv(paste(Datawd,"parcelle.csv", sep=""), header=T)

# A complementary directory "Comp_Data" contains all the files and info that are necessary
cos_codes <- read.csv(paste(Complementary,"cos_code.csv", sep=""), header=T)
RDC <- readRDS(paste(Complementary,"gadm36_COD_1_sp.rds", sep="")) #RDC carte

 #assign univoque code for each tree
trees$ID<-with(trees,paste(trees$ue_id_ue, trees$parcelle_id_parcelle,trees$n_quandrant,trees$n_arbre,sep='_'))
#reassign some variable names (to internationalize the script)
trees$DBH<-trees$dhp
#Some Blocs numbers are not entered, replacing NA with 0 (to be checked)
trees$n_bloc[is.na(trees$n_bloc)] <- 0

trees$XR[(trees$n_bloc==1)] <- trees$position_x_droite[trees$n_bloc==1]+12.5
trees$XL[(trees$n_bloc==1)] <- 12.5-trees$position_x_gauche[trees$n_bloc==1]

trees$XR[(trees$n_bloc==2)] <- trees$position_x_droite[trees$n_bloc==2]+37.5
trees$XL[(trees$n_bloc==2)] <- 37.5-trees$position_x_gauche[trees$n_bloc==2]

trees$XR[(trees$n_bloc==3)] <- trees$position_x_droite[trees$n_bloc==3]+62.5
trees$XL[(trees$n_bloc==3)] <- 62.5-trees$position_x_gauche[trees$n_bloc==3]

trees$Y[(trees$n_bloc==1)] <- trees$position_y[trees$n_bloc==1]
trees$Y[(trees$n_bloc==2)] <- 75-trees$position_y[trees$n_bloc==2]
trees$Y[(trees$n_bloc==3)] <- trees$position_y[trees$n_bloc==3]

#Include XL and XR in the same X column
trees <- trees %>%  mutate(X = coalesce(XL, XR))
trees$UE<-trees$ue_id_ue

trees$type=ifelse(trees$souche=="true","souche", #pas souches
                   ifelse(trees$palmier=="false",   #pas palmier
                          ifelse(trees$etat_sante %in% c("1","2","3"),"Arbr. Viv.","Arbr. Mor."),
                          ifelse(trees$etat_sante %in% c("1","2","3"),"Palm. Viv.","Palm.")))

#### Height


write.csv(trees,"./Data/Comp_Data/trees.csv")
DRC_UE <- unique(trees$UE) # list of unique UE



# Uncomment to test the generation only in 1 plot
myTrees <- "23"  # UE
render("/home/antonello/R_projects/NFI_RDC/QAQC_Report_Generator/paramark_02.rmd", # the template
       params = list(UE = myTrees), # value of myIris passed to the species parameter
       output_file = paste('Reports/',myTrees, '.pdf', sep = ''), # name of the output file - species name and pdf extension
       quiet = T,
       encoding = 'UTF-8')

render("/home/antonello/R_projects/NFI_RDC/QAQC_Report_Generator/paramark_html.rmd", # the template
         params = list(UE = myTrees), # value of myIris passed to the species parameter
         output_file = paste('Reports/',myTrees, '.html', sep = ''), # name of the output file - species name and pdf extension
         quiet = T,
         encoding = 'UTF-8')

render("/home/antonello/R_projects/NFI_RDC/QAQC_Report_Generator/paramark.rmd", # the template
       params = list(UE = myTrees), # value of myIris passed to the species parameter
       output_file = paste('Reports/',myTrees, '.pdf', sep = ''), # name of the output file - species name and pdf extension
       quiet = T,
       encoding = 'UTF-8')




# myTrees <- "55"  # UE
# render(paste(ScriptFolder,"paramark_01.rmd", sep = T),
#        params = list(UE = myTrees), # value of myIris passed to the species parameter
#        output_file = paste('Reports/',myTrees, '.html', sep = ''), # name of the output file - species name and pdf extension
#        quiet = T,
#        encoding = 'UTF-8')
# 
# for (i in seq_along(DRC_UE)) {
#   myTrees <- DRC_UE[i]  # UE
#   render("./paramark.rmd", # the template
#          params = list(UE = myTrees), # value of myIris passed to the species parameter
#          output_file = paste('Reports/',myTrees, '.pdf', sep = ''), # name of the output file - species name and pdf extension
#          quiet = T,
#          encoding = 'UTF-8')
# }
# 
# 
# 
for (i in seq_along(DRC_UE)) {
  myTrees <- DRC_UE[i]  # UE
  render("/home/antonello/R_projects/NFI_RDC/QAQC_Report_Generator/paramark_html.rmd", # the template
         params = list(UE = myTrees), # value of myIris passed to the species parameter
         output_file = paste('Reports/',myTrees, '.html', sep = ''), # name of the output file - species name and pdf extension
         quiet = T,
         encoding = 'UTF-8')
}
