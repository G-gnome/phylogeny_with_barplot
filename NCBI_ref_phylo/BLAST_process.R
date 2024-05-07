

#STEP1: Load all necessary packages for analysis


library(plyr)
library(data.table)
library(tidyr)
library(tidyverse)
library(multcompView)
library(readr)


#Filter for high bit score and get accessions


blast = read.table("bestHits.Maarjam.BLASTN.tab",header=FALSE,row.names=1,sep="\t",stringsAsFactors=FALSE)



#Filter for high bit score and get accessions

blast_filter <- filter(blast, V12 > 175)




#Get the unique accessions, as repeats will mess up phylogeny

accessions <- unique(as.data.frame(blast_filter$V2))


#Convert to dataframe and save as tsv

accessions <- as.data.frame(accessions)

write_tsv(
  accessions,
  "top_hits_filtered.tsv",
  na = "NA",
  col_names = TRUE,
  eol = "\n",
  progress = TRUE
)


