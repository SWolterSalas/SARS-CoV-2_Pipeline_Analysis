#!/bin/bash

cd ../analisis

mkdir 14_lineages_frequencies

cd 14_lineages_frequencies

cp ../../Nextstrain/ncov/results/MetaSUBCoV_Chile/emerging_lineages.json ./
cp ../../Nextstrain/ncov/results/combined_metadata.tsv ./

cat emerging_lineages.json | 
tr -d '{\n' | 
sed 's/}/\n/g' | 
grep -v 'unassigned' | 
grep -v 'NODE' | 
sed 's/,    "//g' | 
sed 's/":       "emerging_lineage": "/,/g' | 
tr -d '"' | 
sed 's/  nodes://g' | 
sed 's/     //g' > Emerging_Lineages.csv

cat combined_metadata.tsv | 
sed 's/ /_/g' | 
sed 's/\t/,\t/g' | 
awk '{print $1,$4,$11}' | 
sed 's/, /\t/g' > Total_Lineages.tsv

cat Total_Lineages.tsv | 
while read lines ; 
do 
	header=`echo $lines | awk '{print $1}'` ; 
	if grep -q $header Emerging_Lineages.csv; 
	then  
		lineage=`grep $header Emerging_Lineages.csv | sed 's/,/ /g' | awk '{print $2}'` ; 
		main=`grep $header Total_Lineages.tsv | awk '{print $1,$2}'` ; 
		echo "$main $lineage" ; 
	else 
		echo $lines ; 
	fi ; 
done | sed 's/ /,/g' > All_Lineages.csv

