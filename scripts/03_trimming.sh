#!/bin/bash

# This script will trim every adapter from Illumina (autodected) and all reads that have an averega of Phred Score
# below 25 and a lenght below 50. This output will be passed directly to FastQC and MultiQC for quality control.

# The input is the characteristic name of every file of your analysis

INPUT=$1 # Example: "BC-*.fastq.gz" | Complete name of file: "BC-0345795864.raw__raw_reads.read_1.fastq.gz"

cd ../analisis/

mkdir 03_trimming
mkdir 04_fastqc

cd /01_backup/

for archivo in $INPUT
do
	TEXTO=${archivo%.raw__raw_reads.read_*} # Be careful to change this if you have another name for your file
	trim_galore -q 25 --length 50 -j 16 --trim-n -o ../03_trimming --paired $TEXTO\.raw__raw_reads.read_1.fastq.gz $TEXTO\.raw__raw_reads.read_2.fastq.gz
done

cd ../03_trimming

fastq ./* -t 6
multiqc ./*

cd ../

mv ./03_trimming/*.html 04_fastqc
mv ./03_trimming/*.zip 04_fastqc
