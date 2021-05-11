#!/bin/bash

# This script allow to map the reference genome (in this case Wuhan SARS-CoV2 genome). Now, all we hace is a fq per 
# sample (before it was paired).

INPUT=$1 #"updated*.fq"

cd ../analisis/

mkdir 07_alignment_SARS_CoV2

cd 06_pathoscope_id

for archivo in $INPUT
do
    bowtie2 -p 8 -x ../../DB/fastas_db/ref_NC_045512.2.index -U $archivo -S ../07_alignment_SARS_CoV2/$archivo.sam
done
