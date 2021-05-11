#!/bin/bash

# This script will filter based in the Query Coverage optimal for your analysis. In general purposes, 95 it's fine. 
# Also this will collapse every genome into one fasta and select the genomes that passed QC.

# TO DO:
# Colocar un QC para control negativo!


Query_cutoff=$1

cd ../analisis/

mkdir 10_lineages

cd 08_assembly_SARS_CoV2

ls | 
grep .fasta | 
grep -v sequences.fasta | 
while read lines ; 
do 
	echo ">$lines" | 
	sed 's/updated_//g' | 
	sed 's/.sam.fq.sam.fasta//g' ; 
	tail -n 1 $lines ; 
done > sequences.fasta

mv sequences.fasta ../09_qc_genomes

cd ../09_qc_genomes

cat Statistics_Assembly.csv | while read lines ;
do
	query_coverage=`echo $lines | sed 's/,/\t/g' | awk '{print $3}'`
	if [[ $query_coverage > $Query_cutoff ]] ;
	then
		echo $lines 
	fi
done > Statistics_Metadata_QCpassed.csv

cat Statistics_Metadata_QCpassed.csv | sed 's/,/\t/g' | awk '{print $1}'

cat Statistics_Metadata_QCpassed.csv | 
sed 's/,/\t/g' | 
awk '{print $1}' | 
grep BC- | 
while read lines; 
do 
	header=`grep $lines sequences.fasta | sed 's/>//g'` ; 
	sed -n "/$header/,/[AaCcTtGgNn]$/p" sequences.fasta ; 
done > sequences_QCpassed.fasta

cp sequences_QCpassed.fasta ../10_lineages
cp Statistics_Metadata_QCpassed.csv ../10_lineages
