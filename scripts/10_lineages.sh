#!/bin/bash

# This script, by pangolin, will calculate the lineages of SARS-CoV2 present in the fasta. This will automatically
# join the lineage into a new metadata.

cd ../analisis

mkdir 11_metadata

cd 10_lineages

pangolin sequences_QCpassed.fasta --outfile pangolin_lineages.csv --write-tree -t 8

cat Statistics_Metadata_QCpassed.csv | 
grep -v name | 
while read lines ; 
do 
	name=`echo $lines | sed 's/,/\t/g' | awk '{print $1}'` ; 
	echo $lines | tr '\n' ',' ; 
	grep $name pangolin_lineages.csv | sed 's/,/\t/g' | awk '{print $2}' ; 
done | sed '1i name,CovBases,QueryCov,DepthCov,pangolin_lineage' > Statistics_Metadata_QCpassed_lineages.csv

mv Statistics_Metadata_QCpassed_lineages.csv ../11_metadata