#!/bin/bash

# This scripts will make a aligment of every fq file against the database of interest (in this case the RNA
# respiratory viruses) and the filter of human and X174 phage, previously indexed. Also, with pathoscope ID
# the reads that are ambiguous will be discarded or matched if the theta prior is ideal for that read.

INPUT=$1 #"BC-*1_val_1.fq.gz"

cd ../analisis/

mkdir 05_pathoscope_map

cd 03_trimming

for archivo in $INPUT
do
	echo $INPUT
	cd ../../DB/fastas_db/
	TEXTO=${archivo%.raw__raw_reads.read_*}
	pathoscope MAP -1 ../../analisis/03_trimming/$TEXTO\.raw__raw_reads.read_1_val_1.fq.gz -2 ../../analisis/03_trimming/$TEXTO\.raw__raw_reads.read_2_val_2.fq.gz -indexDir ./ -targetIndexPrefixes DB_RNA_Respiratory_viruses4 -filterIndexPrefixes filter_human_GCF_000001405.39_GRCh38.p13_genomic,filter_phi-X174_release_7-6-18 -outDir ../../analisis/05_pathoscope_map -outAlign $TEXTO.sam -numThreads 8 -expTag $TEXTO 
done

cd ../

mkdir 06_pathoscope_id

cd 05_pathoscope_map/

for archivo in *.sam
do
	TEXTO=${archivo}
	pathoscope ID -alignFile $TEXTO -outDir ../06_pathoscope_id/ -expTag $TEXTO -thetaPrior 30000000
done

mkdir tsv_report

mv *.tsv ./tsv_report

cd tsv_report

rm *.taxa.tsv

ls | grep 'report.tsv' | while read lines 
do 
	NOMBRE="$lines"
	TAXA="Taxa"
	NOMBRE2="echo $TAXA $NOMBRE"
	#echo '' > $lines.taxa.tsv
	$NOMBRE2 | sed 's/ /\t/g' >> $lines.taxa.tsv
	cat $lines | awk '{print $1,$4}' | 
	grep ti | sed 's/ /\t/g' >> $lines.taxa.tsv
done

# Posterior a hacer los archivos (correr este script), en el primer archivo tsv creado, colocar
# todos los taxon id que faltan y agregarles un 0 en la siguiente columna separada por un tabulado

# Ejemplo

#Taxa	BC-0345795864.sam-sam-report.tsv
#ti|694009	683.0
#ti|277944	49.0
#ti|11137	2.0
#ti|11320	0
#ti|11552	0
#ti|1335626	0
#ti|147711	0
#ti|162145	0
#ti|1979161	0
#ti|290028	0
#ti|463676	0
#ti|694003	0
