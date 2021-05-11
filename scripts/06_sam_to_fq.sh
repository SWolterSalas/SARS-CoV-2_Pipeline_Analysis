#!/bin/bash

# With all of the above, we have sam files that have all the reads that mapped aggainst the database of interest.
# Now, in this case, we need to identify if we can actually align and map the SARS-CoV2 genome. Thats why we need
# to make a fq files from this sam files. Samtools is the tool that can make a fq file, in this case, for every sam.

INPUT=$1 #"updated*.sam"

cd ../analisis/06_pathoscope_id

for archivo in $INPUT
do
    TEXTO=${archivo}
    samtools view -b -@ 8 $TEXTO | samtools sort -@ 8 > $TEXTO.bam
    samtools index -@ 8 $TEXTO.bam
    samtools fastq -@ 8 $TEXTO.bam > $TEXTO.fq
done
