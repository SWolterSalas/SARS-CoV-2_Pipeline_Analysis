#!/bin/bash

# This script will compile every statistics through FastQC and MultiQC from all .fq files contained in 1_backup 
# and it will colapse every file in 2_fastqc

cd ../analisis/

mkdir 02_fastqc

cd 01_backup

ls > lista.list

cat lista.list | while read lines; do mv ./$lines/$lines*.fastq.gz ./ ; done # This line will make a list and mv it to 01_backup

fastqc ./* -t 8 
multiqc ./*

cd ../

mv ./01_backup/*.html 02_fastqc
mv ./01_backup/*.zip 02_fastqc
