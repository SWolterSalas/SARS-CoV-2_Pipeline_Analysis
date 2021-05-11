#!/bin/bash

# Again, this script can build from the sam file mapped against SARS-CoV2 reference genome to a fq AND fasta 
# assembly.

INPUT=$1 #"updated*.sam"

cd ../analisis/

mkdir 08_assembly_SARS_CoV2
mkdir 09_qc_genomes

cd 07_alignment_SARS_CoV2

for archivo in $INPUT
do
        TEXTO=${archivo}
        samtools view -b -@ 8 $TEXTO | samtools sort -@ 8 > $TEXTO.bam
        samtools index -@ 8 $TEXTO.bam
        bcftools mpileup --threads 8 -f ../../DB/fastas_db/ref_NC_045512.2.fasta $TEXTO.bam > $TEXTO.vcf
        bcftools call --threads 8 -c $TEXTO.vcf | vcfutils.pl vcf2fq > $TEXTO.fq
        seqtk seq -aQ64 $TEXTO.fq > $TEXTO.fasta
done

mv *.fasta ../08_assembly_SARS_CoV2

ls | grep '.*bam$' | 
while read lines ; 
do 
	samtools coverage $lines | 
	awk '{print $1,$5,$6,$7}' | 
	sed 's/ /\t/g' | tail -n 1 | 
	tr '\n' '\t' ; 
	echo $lines ; 
done | awk '{print $5,$2,$3,$4}' | sed 's/updated_//g' | sed 's/.sam.fq.sam.bam//g' | 
sed '1i name Cov_bases Query_Cov Depth_Cov' | sed 's/ /,/g' > Statistics_Assembly.csv

mv Statistics_Assembly.csv ../09_qc_genomes
