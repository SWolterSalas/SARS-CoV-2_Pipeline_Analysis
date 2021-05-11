# SARS-CoV-2_Pipeline_Analysis

## MetaSUB-CoV2 analysis 

### Database

Bibliographic search of human respiratory RNA viruses. Taxas found in the NCBI database:

* SARS (ti|694009)
* SARS CoV-2 (ti|2697049)
* Coronavirus NL63 (ti|277944)
* Coronavirus 229E (ti|11137)
* Rhinovirus A (ti|147711)
* Coronavirus HKU1 (ti|290028)
* Rinhoviurs C (ti|463676)
* Betacoronavirus 1 (ti|694003)	
* Influenza A (ti|11320)
* Influenza C (ti|11552)
* Metapneumovirus (ti|162146)
* Orthorubulavirus 4 (ti|1979161)
* MERS (ti|1335626)

The first database was using the Pathoscope LIB tool, using the taxids: 

pathoscope LIB -genomeFile /path/file/nt.fasta -taxonIds 694009,2697049,277944,11137,147711,290028,463676,694003,11320,11552,162146,1979161,1335626 --subTax -outPre x virus 

In addition, it was checked that the viruses did indeed correspond to human respiratory RNA viruses, looking for headers that contained the names of these viruses. This is because the tax ids were not debugged and they give us genomes that do not correspond to respiratory RNA viruses, which is why the following script was used:

```
01_taxid_DB.sh
```

----------------------------------------------------------------
### Quality Control

All data was downloaded from Pangea (https://pangea.gimmebio.com/sample-groups/8c1fce17-1f4c-4770-bea0-b63660c56957). After downloading the files, a directory was created containing all the "fq" files with the "raw reads". It was analyzed using FastaQC and MultiQC to generate a quality control and determine the trimming parameters, using the following script:

02_quality_control.sh

Trimming was carried out using Trim Galore! and the quality was verified through a new analysis with FastQC and MultiQC. In this way we are left with those reads that passed the quality control using the script:

03_trimming.sh

----------------------------------------------------------------
### Pathoscope

In the first instance, with the Bowtie2 tool, the indexes for the reference genomes of Respiratory RNA Viruses, human genome and phages were generated with the following script:

04_index_DB.sh

Subsequently, the PathoMAP tool of Pathoscope 2.0 was used to map our library of respiratory RNA viruses against the genomes of humans and phages to filter and rule out the possibility of finding the presence of contaminating genomes (human cells or phages) in the samples. In addition, for a more stringent analysis and to find the best parameter estimates for the proportion of mapped readings, PathoID was applied to the samples with a thetaPrior of 30MM, and a TSV report of the mappings was obtained. For all this we used:

05_pathoscope.sh

Obtained SAM files from Pathoscope were converted to fq files with the following script:

06_sam_to_fq.sh

----------------------------------------------------------------
### SARS CoV 2 Alignment

To align the reads, Bowtie2 was used against the Wuhan reference genome described in NCBI and the script was used:

07_alignment.sh
 
Finally the mapping of the reads was obtained in a fasta format. Using Samtools the statistics of the mapped reads were obtained using the script:

08_fasta_assembly_stats.sh

A final quality control was applied, and a consensus was established for a “query coverage” above 90%. Those that meet this condition will be considered as positive samples for SARS-CoV-2, all this with:

09_filter.sh

----------------------------------------------------------------
### Analysis for Phylogeny and Taxonomic Abundance

With the fasta sequences of the samples that passed the control, the corresponding lineages were obtained through pangolin and this column was added to the file with the statistics of the rescued genomes with the script called:

10_lineages.sh

Once our metadata is obtained, the COVID-19 metadata is downloaded directly from Pangea in Santiago, and all the sampling information is obtained only for those samples that approved the final quality control through the following script:

11_management_metadata.sh

With the information of the samples of interest, we have to download the complete metadata of hCoV of Chile and the reference of Wuhan directly from GISAID, and we compile all the necessary information to be able to run the samples in Nextstrain and obtain the phylogeny of these, by means of the following script:

12_management_GISAID_files.sh

Finally, with the lineages obtained from pangolin and GISAID, plus the emerging lineages from Nextstrain, a file of all genomes with their respective lineages is created. In addition, another additional analysis was generated from the INDISA samples, which were adapted to the necessary metadata format to be able to run them in Nextstrain where the lineage obtained from pangolin, the Wuhan and Chile references from GISAID were added, and from there obtain the emerging lineages, all with the following script.

13_management_metadata_INDISA.sh

From the emerging lineages that Nextstrain gives us, a file is created with all the lineages obtained in total, including the emerging ones and the metadata with the information generated by the samples, in files in csv and tsv format. In addition, a graph of emerging lineages in time (months) is created with Rstudio. All of the above was done with the following scripts

14_emerging_lineages.sh
clade_frequencies.R

The metadatas with the emerging lineages that were obtained from Nextstrain using this script were also corrected:

15_correcting_lineages.sh

----------------------------------------------------------------
### Tree file

Finally, an exclusive folder is made to perform phylogenetic analyzes with the tree obtained from Nextstrain:

16_files_for_tree.sh
