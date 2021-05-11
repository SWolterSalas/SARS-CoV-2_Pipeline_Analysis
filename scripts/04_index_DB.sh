#!/bin/bash

# This script will automate the indexing of the fasta files that will map against the fq files trimmed.
# In fasta_db you will need to put all the fasta files that will require the indexing. In this case, it is needed
# the db of all RNA respiratory viruses for mapping, and for filter the human assembly and the X174 phage.

cd ../DB/fastas_db

for archivo in *.fasta
do
	echo "Doing index of file $archivo"
	bowtie2-build --threads 8 $archivo $archivo
done
