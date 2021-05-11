#!/bin/bash

cd ../DB

# It's needed to verify where is the file nt.fasta. This DB contains every genome sequenced on NCBI.

#pathoscope LIB -genomeFile /ruta/archivo/nt.fasta -taxonIds 694009,2697049,277944,11137,147711,290028,463676,694003,11320,11552,162146,1979161,1335626 --subTax -outPre x virus

# Also, if you want to get a depurated DB, it's recomended to verify the names and taxID of every genomes needed
# and put it in a file named "Nombres_Virus_Respiratorios_RNA_claves.txt"

cat Nombres_Virus_Respiratorios_RNA_claves.txt | while read lines; do cat DB_viruses.fasta | grep "$lines" >> DB_RNA_Respiratory_viruses.fasta; done

cat DB_RNA_Respiratory_viruses.fasta | sort | uniq > DB_RNA_Respiratory_viruses2.fasta 

sed 's/\//_/g' DB_viruses.fasta > DB_viruses2.fasta
sed 's/\//_/g' DB_RNA_Respiratory_viruses2.fasta > DB_RNA_Respiratory_viruses3.fasta

cat DB_RNA_Respiratory_viruses3.fasta | while read line; 
do 
	if grep "$line" DB_viruses2.fasta
	then

		sed -n "/$line/,/>/p" DB_viruses2.fasta | sed '$d' >> DB_RNA_Respiratory_viruses4.fasta
	else
		continue
	fi
done

# This loop will take some time, but compiles every genome in the DB from pathoscope LIB that contains the name of
# the species you'll be analyzing
