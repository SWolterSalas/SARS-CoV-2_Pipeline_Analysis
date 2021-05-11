#!/bin/bash

# 

# For obtaining the INDISA statistics report, it is necessary to run the script 08_fasta_assembly_stats.sh and
# change the name of this file to Statistics_Assembly_INDISA.tsv. The same is for obtaining the fasta files
# that contains all fasta assembly by running the next lines of code in the folder that contains all assemblies:

#ls | 
#grep .fasta | 
#grep -v sequences.fasta | 
#while read lines ; 
#do 
#	echo ">$lines" | 
#	sed 's/updated_//g' | 
#	sed 's/.sam.fq.sam.fasta//g' ; 
#	tail -n 1 $lines ; 
#done > sequences.fasta

cd ../analisis/12_indisa_genomes

Query_cutoff=$1

cat Statistics_Assembly_INDISA.tsv | while read lines ;
do
	query_coverage=`echo $lines | sed 's/,/\t/g' | awk '{print $3}'`
	if [[ $query_coverage > $Query_cutoff ]] ;
	then
		echo $lines | sed 's/_S.*2_001//g'
	fi
done > Statistics_Metadata_QCpassed_INDISA.csv

cat Statistics_Metadata_QCpassed_INDISA.csv | 
while read lines ; 
do 
	header=`echo $lines | awk '{print $1}'` ; 
	grep -m 1 $header Metadata_INDISA.csv | sed 's/,/./g' | sed 's/;/,/g' ; 
done | sed '1i Retiro;Fecha retiro;Id tubo CM;Ct;Sexo;Edad;Id seguimiento;Id tubo clinica;Fecha toma de muestras;Ubicación CBV;;;;;;;;;;;;;;;;' | sed 's/ //g'  > Metadata_INDISA_QCpassed.csv

cat Metadata_INDISA_QCpassed.csv | 
while read lines; 
do 
	header=`echo $lines | sed 's/,/ /g' | awk '{print $7}'` ; 
	sed -n "/$header/,/[AaCcTtGgNn]$/p" sequences.fasta  ;
done > sequences_QCpassed_INDISA.fasta

#pangolin sequences_QCpassed_INDISA.fasta --outfile pangolin_lineages.csv --write-tree -t 8

cat Metadata_INDISA_QCpassed.csv | 
while read lines; 
do 
	header=`echo $lines | sed 's/,/ /g' | awk '{print $7}'` ; 
	grep -m 1 "$header" Statistics_Metadata_QCpassed_INDISA.csv  ;
done > Statistics_Metadata_QCpassed_INDISA1.csv

mv Statistics_Metadata_QCpassed_INDISA1.csv Statistics_Metadata_QCpassed_INDISA.csv

cat Statistics_Metadata_QCpassed_INDISA.csv | 
grep -v Name | 
while read lines ; 
do 
	name=`echo $lines | sed 's/ /\t/g' | awk '{print $1}'` ; 
	echo $lines | tr '\n' '\t' ; 
	grep $name pangolin_lineages.csv | sed 's/,/\t/g' | awk '{print $2}' ; 
done | sed '1i name,CovBases,QueryCov,DepthCov,pangolin_lineage' | sed 's/ /,/g' | sed 's/\t/,/g' > Statistics_Metadata_QCpassed_INDISA_lineages.csv


cat Statistics_Metadata_QCpassed_INDISA_lineages.csv | 
sed 's/name/strain/g' | 
while read lines ; 
do 
	strain=`echo $lines | sed 's/,/ /g' | awk '{print $1}'` ; 
	echo $lines, | tr -d '\n' ;
	grep $strain Metadata_INDISA_QCpassed.csv | sed 's/,/ /g' | 
	awk '{print $6,$5,$9}' | 
	sed -E 's/([0-9]{2})-([0-9])-([0-9]{4})/\3-0\2-\1/g' | sed 's/ /,/g' ; 
done | sed 's/pangolin_lineage,/pangolin_lineage,age,sex,date,virus,region,country,division,region_exposure,country_exposure\n/g' | 
sed 's/,M,/,Male,/g' | sed 's/,F,/,Female,/g' | 
sed 's/$/,ncov,South America,Chile,Region Metropolitana de Santiago,South America,Chile/g' | 
sed 's/ /_/g' | sed 's/,/\t/g' | awk '{print $1,$9,$10,$8,$11,$12,$2,$3,$4,$5,$6,$7,$13,$14}' | 
sed 's/ /,/g' | sed 's/_/ /g' | sed '1s/ /_/g' > INDISA_Metadata_Nextstrain.csv

cat INDISA_Metadata_Nextstrain.csv | sed 's/,/\t/g' > INDISA_Metadata_Nextstrain.tsv

mv INDISA_Metadata_Nextstrain.tsv ../13_nexstrain_files

cp sequences.fasta ../13_nexstrain_files/INDISA_Sequences_Nextstrain.fasta
