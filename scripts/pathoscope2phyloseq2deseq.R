setwd("~/Downloads/metagenome_covid_chile_mac/analisis/7_pathoid/tsv_report")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("phyloseq")
if(!"devtools" %in% installed.packages()){
  install.packages("devtools", dependencies = T, )
}
devtools::install_github("gmteunisse/Fantaxtic")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.12")biocLite("DESeq2")

library( "DESeq2" )
library(DESeq2)
library(phyloseq)
library(taxize)
library(plyr)
library(dplyr)
library(biomformat)
library(DT)
library(ggplot2) 
library(fantaxtic)

#define functions to fetch lineage
uid2lineage<-function(x){
  
  #define the main error in case of the fetch fail
  tmp<-c("Error in FUN(X[[i]], ...) : Gateway Timeout (HTTP 504)")
  
  #define the number of retrys per id in case of fail
  retry<-20
  
  #adding one slice of security
  while (grepl("Gateway Timeout",tmp) && retry>0) {
    tryCatch({tmp<-classification(x, db = 'ncbi')}, error = function(e){
      print(e);print("retrying");tmp<-"Gateway Timeout"})
    retry=retry-1
  }
  
  #get the df that contain the lineage
  tmpdf<-as.data.frame(tmp[[1]])
  if(nrow(tmpdf)>1){
    superk<-ifelse(identical("character(0)",superk<-as.character(tmpdf[which(
      tmpdf[2]=="superkingdom"),][1])),"NA",superk)
    phylum<-ifelse(identical("character(0)",phylum<-as.character(tmpdf[which(
      tmpdf[2]=="phylum"),][1])),"NA",phylum)
    class<-ifelse(identical("character(0)",class<-as.character(tmpdf[which(
      tmpdf[2]=="class"),][1])),"NA",class)
    order<-ifelse(identical("character(0)",order<-as.character(tmpdf[which(
      tmpdf[2]=="order"),][1])),"NA",order)
    family<-ifelse(identical("character(0)",family<-as.character(tmpdf[which(
      tmpdf[2]=="family"),][1])),"NA",family)
    genus<-ifelse(identical("character(0)",genus<-as.character(tmpdf[which(
      tmpdf[2]=="genus"),][1])),"NA",genus)
    species<-ifelse(identical("character(0)",species<-as.character(tmpdf[which(
      tmpdf[2]=="species"),][1])),"NA",species)
    name<-as.character(tmpdf[nrow(tmpdf),][1])
    out<-data.frame(ID=x,Superkingdom=superk,Phylum=phylum,Class=class,
                    Order=order,Family=family,Genus=genus,Species=species,
                    `Last Rank`=name)
  }else{
    out<-data.frame(ID=x,Superkingdom="NA",Phylum="NA",Class="NA",
                    Order="NA",Family="NA",Genus="NA",Species="NA",
                    Last.Rank="NA") 
  }
  return(out)
  
}
dflineage<-function(x){
  print("fetching IDs, please be patient")
  out<-ldply(lapply(x,uid2lineage),data.frame)
  out[out=="NA"]<-NA
  return(out)
}

files = list.files(path = ".",pattern=".tsv.taxa.tsv")
tsvs<-lapply(files, read.table, sep="\t",header=T)
for(i in 1:length(tsvs)){
  colnames(tsvs[[i]])<-c("Taxa",files[i])
}
merged<-tsvs %>% Reduce(function(dtf1,dtf2) left_join(dtf1,dtf2,by="Taxa"), .)
merged[is.na(merged)]<-0
#View(merged)
merged<-merged[rowSums(merged[,c(2:ncol(merged))])>0,]
#View(merged)
#now we have to delete the characters "ti|" of our first column (and move the taxID to rownames)
merged<-as.data.frame(sapply(merged, function(x) gsub("ti\\|", "", x)))
rownames(merged)<-merged[,1]
merged<-merged[,-1]
#View(merged)
#finally convert our table, into a OTU table
#OTU=otu_table(data.matrix(merged),taxa_are_rows = T)
colnames(merged) <- sub(".sam-sam-report.tsv.taxa.tsv", "", colnames(merged))

#to obtain the TAX table, we use only the rownames of the OTU table
#View(OTU)
taxIDs<-rownames(merged)
#Sys.getenv("ENTREZ_KEY")
lineages<-dflineage(taxIDs)
rownames(lineages)<-lineages[,1]
lineages<-lineages[,-1]
#replace the rownames to avoid future match errors
taxa_names(lineages)<-rownames(lineages)
#and finally convert our data frame into TAX table
TAX=tax_table(as.matrix(lineages))

metadata = read.table("Metadata_Compilada_Final.csv",header = T,sep = ",", row.names = 1) 

otu = merged
tax = TAX
meta = metadata
#otus ###
class(otu)
summary(otu)
dim(otu)
otu[, 1:36] <- sapply(otu[, 1:36], as.numeric)
t(as.data.frame(otu)) -> otu
otu[1:5,1:5]
as.matrix(otu) -> otu
#tax ####
class(tax)
as.data.frame(tax) -> tax
as.matrix(tax) -> tax
#meta ####
as.data.frame(meta) -> meta
class(meta)
rownames(otu) %in% rownames(meta)
colnames(otu) %in% rownames(tax)

(ps <- phyloseq(otu_table(otu, taxa_are_rows=FALSE),
                sample_data(meta),
                tax_table(tax)))
plot_bar(ps, fill = "Species") +
geom_bar(aes(color=Phylum, fill=Phylum), stat="identity", position="stack")

plot_bar(ps, fill = "Family")
plot_bar(ps, fill = "Genus")
plot_bar(ps, fill = "Species")

plot_heatmap(ps)

class(otu)
dds <- DESeqDataSetFromMatrix(countData=otu, 
                              colData=meta, 
                              design= ~ Setting,
                              tidy = TRUE)

diagdds = phyloseq_to_deseq2(ps, ~ Setting)
diagdds = DESeq(diagdds, test="Wald", fitType="parametric")
res = results(diagdds, cooksCutoff = FALSE)
head(results(diagdds))
res <- res[order(res$padj),]
head(res)

alpha = 0.99
sigtab = res[which(res$padj < alpha), ]
sigtab = cbind(as(sigtab, "data.frame"), as(tax_table(ps)[rownames(sigtab), ], "matrix"))
head(sigtab)

theme_set(theme_bw())
scale_fill_discrete <- function(palname = "Set1", ...) {
  scale_fill_brewer(palette = palname, ...)
}
# Phylum order
x = tapply(sigtab$log2FoldChange, sigtab$Genus, function(x) max(x))
x = sort(x, TRUE)
sigtab$Genus = factor(as.character(sigtab$Genus), levels=names(x))
# Genus order
x = tapply(sigtab$log2FoldChange, sigtab$Species, function(x) max(x))
x = sort(x, TRUE)
sigtab$Species = factor(as.character(sigtab$Species), levels=names(x))
ggplot(sigtab, aes(x=Species, y=log2FoldChange, color=Genus)) + geom_point(size=6) + 
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5))

ps -> ps3_norm #duplicate object
diagdds = phyloseq_to_deseq2(ps3_norm, ~ Setting) # variable of the metadata. You need one to create the DESeq object
# Calculate geometric means
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
geoMeans = apply(counts(diagdds), 1, gm_mean)
# Estimate size factors
diagdds = estimateSizeFactors(diagdds, geoMeans = geoMeans)
# Get Normalized read counts
normcounts <- counts(diagdds, normalized = TRUE)
#View(normcounts)
# Round read counts
round(normcounts, digits = 0) -> normcountsrd
# Transform matrix of normalized counts to phyloseq object
otu_table(normcountsrd, taxa_are_rows = TRUE) -> ncr
# Replace otu_table in original phyloseq object
otu_table(ps3_norm) <- t(ncr)
#write.csv(ncr,file="deseq_file.csv")
ps3_norm@otu_table[1:5,1:10]
#with round some count was zero
(ps3_norm <- prune_taxa(taxa_sums(ps3_norm) > 0, ps3_norm))
#saveRDS(ps3_norm, "~/Desktop/Proyectos/ballena_microbiota_v3/sesiones_R/ps3_norm_04_11_20.rds")

View(ps3_norm)

ps_tmp <- get_top_taxa(physeq_obj = ps3_norm, n = 11, relative = TRUE,
                       discard_other = FALSE, other_label = "Other")

fantaxtic_bar(ps_tmp, color_by = "Phylum", label_by = "Species", 
              other_label = "Other") +
  scale_fill_manual(values=c(
    "#3e4491","#f7a400","#3a9efd", "#44c2fd", "#292a73","#2c698d",
    "#1ac0c6", "#bae8e8", "#e3f6f5",
    "#e3e3e3", "#3c2a4d"))

