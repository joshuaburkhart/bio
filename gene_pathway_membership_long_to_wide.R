
# Gene <-> Pathway: Long to Wide R Script
# Author: Joshua Burkhart
# Date: 9/20/2016

# Libraries
library(openxlsx)
library(dplyr)
library(magrittr)
library(reshape2)

# Globals
DATA_DIR <- "/Users/joshuaburkhart/Research/DEET/biting/analysis/"
CONTIG_MAP_FILE <- "DEET_loci_annotation.csv"
CONTIG_MAP_PATH <- paste(DATA_DIR,CONTIG_MAP_FILE,sep="")
PATHWY_MAP_FILE <- "Genes to pathways.csv"
PATHWY_MAP_PATH <- paste(DATA_DIR,PATHWY_MAP_FILE,sep="")
OUT_FILE_1 <- "Genes to pathways.xlsx"
OUT_PATH_1 <- paste(DATA_DIR,OUT_FILE_1,sep="")
OUT_FILE_2 <- "Contigs and Singletons to pathways.xlsx"
OUT_PATH_2 <- paste(DATA_DIR,OUT_FILE_2,sep="")

# Read mapping files
contig.map <- read.delim(CONTIG_MAP_PATH,header=TRUE,sep=",",stringsAsFactors = FALSE) #first use $tail -n +2 DEET\ loci\ annotation.csv to remove first header
pathwy.map <- read.delim(PATHWY_MAP_PATH,header=FALSE,sep=",",stringsAsFactors = FALSE)

# Name pathwy.map columns, remove zero, add contig/singleton id column
colnames(pathwy.map) <- c("zero","gene","pathway")
pathwy.map <- pathwy.map %>% dplyr::select(gene,pathway) %>%
  dplyr::left_join(contig.map,by=c('gene' = 'BLAST_Agam')) %>%
  dplyr::select(gene,
                DEET.output.using.expressin.profiles.from.3.biting.arrays,
                pathway)

# Add pathway numbers as ids and reshape by gene to wide format
wide_gene_pathwy.map <- pathwy.map %>%
  dplyr::select(gene,pathway) %>%
  dplyr::filter(!(is.na(gene))) %>%
  group_by(gene) %>% mutate(id = seq_len(n())) %>%
  group_by(gene) %>% mutate(id = seq_along(pathway)) %>%
  group_by(gene) %>% mutate(id = row_number()) %>%
  as.data.frame() %>%
  reshape(direction = 'wide',
          idvar = 'gene',
          timevar = 'id',
          v.names = 'pathway',
          sep = "_")

wide_gene_pathwy.map %>% openxlsx::write.xlsx(file=OUT_PATH_1)

# Add pathway numbers as ids and reshape by contig/singleton id to wide format
wide_contig_pathwy.map <- pathwy.map %>%
  dplyr::select(DEET.output.using.expressin.profiles.from.3.biting.arrays,gene,pathway) %>%
  dplyr::filter(!(is.na(DEET.output.using.expressin.profiles.from.3.biting.arrays))) %>%
  group_by(DEET.output.using.expressin.profiles.from.3.biting.arrays) %>% mutate(id = seq_len(n())) %>%
  group_by(DEET.output.using.expressin.profiles.from.3.biting.arrays) %>% mutate(id = seq_along(pathway)) %>%
  group_by(DEET.output.using.expressin.profiles.from.3.biting.arrays) %>% mutate(id = row_number()) %>%
  as.data.frame() %>%
  reshape(direction = 'wide',
          idvar = 'DEET.output.using.expressin.profiles.from.3.biting.arrays',
          timevar = 'id',
          v.names = 'pathway',
          sep = "_")

wide_contig_pathwy.map %>% openxlsx::write.xlsx(file=OUT_PATH_2)
