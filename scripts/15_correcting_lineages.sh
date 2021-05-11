#!/bin/bash

cd ../analisis/15_metadata_nextstrain_compilada

cp ../13_nexstrain_files/GISAID_Metadata.tsv ./
cp ../13_nexstrain_file/INDISA_Metadata_Nextstrain.tsv ./

cat GISAID_Metadata.tsv | 
sed 's/\t/\t,/g' | 
sed 's/\t,\t/\t,?\t/g' | 
sed 's/\t/;/g' | 
sed 's/ /_/g' | 
while read lines ; 
do 
	header=`echo $lines | sed 's/;/\t/g' | awk '{print $1}' | tr -d '\n'` ; 
	#echo $header;
	if grep -q $header Emerging_Lineages.csv; 
	then 
		lineage=`grep $header Emerging_Lineages.csv | sed 's/,/\t/g' | awk '{print $2}'` ; 
		echo "$lineage" | tr '\n' ';' ; 
		echo "$lines" ; 
	else 
		lineage2=`echo $lines | sed 's/;/\t/g' | awk '{print $19}'` ; 
		echo "$lineage2" | tr '\n' ';' ; 
		echo $lines ;
	fi ; 
done | sed 's/;/\t/g' | awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1,$21,$22,$23,$24,$25,$26,$27}' | 
sed 's/ /\t/g' | sed 's/_/ /g' | sed 's/,//g' | sed '1s/ /_/g' > GISAID_Metadata_Correct_Lineages.tsv


cat INDISA_Metadata_Nextstrain.tsv | 
sed 's/\t/\t,/g' | 
sed 's/\t,\t/\t,?\t/g' | 
sed 's/\t/;/g' | 
sed 's/ /_/g' | 
sed 's/,//g' | 
while read lines ; 
do 
	header=`echo $lines | sed 's/;/\t/g' | awk '{print $1}' | tr -d '\n'` ; 
	#echo $header;
	if grep -q $header Emerging_Lineages.csv; 
	then 
		lineage=`grep $header Emerging_Lineages.csv | sed 's/,/\t/g' | awk '{print $2}'` ; 
		echo "$lineage" | tr '\n' ';' ; 
		echo "$lines" ; 
	else 
		lineage2=`echo $lines | sed 's/;/\t/g' | awk '{print $10}'` ; 
		echo "$lineage2" | tr '\n' ';' ; 
		echo $lines ;
	fi ; 
done | sed 's/;/\t/g' | awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$1,$12,$13,$14}' | 
sed 's/ /\t/g' | sed 's/_/ /g' | sed 's/,//g' | sed '1s/ /_/g' > INDISA_Metadata_Nextstrain_Correct_Lineages.tsv

sed -i -E 's/([0-9]{2})-([0-9]{2})-([0-9]{4})/\3-\2-\1/g' INDISA_Metadata_Nextstrain_Correct_Lineages.tsv

cp INDISA_Metadata_Nextstrain_Correct_Lineages. ../13_nexstrain_files
cp GISAID_Metadata_Correct_Lineages.tsv ../13_nexstrain_files
