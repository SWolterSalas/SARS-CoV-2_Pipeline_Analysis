#!/bin/bash

# 

cd ../analisis

cd 13_nexstrain_files/GISAID

for archivo in *.fasta ; do cat $archivo ; done > GISAID_Sequences.fast | mv GISAID_Sequences.fast GISAID_Sequences.fasta

cat 1620414201821.metadata.tsv >> GISAID_Metadata.tsv
tail -n 1 1620416348952.metadata.tsv >> GISAID_Metadata.tsv
sed -i 's/betacoronavirus/ncov/g' GISAID_Metadata.tsv
sed -i -E 's/(..)-(..)-(....)/\3-\2-\1/g' GISAID_Metadata.tsv

mv GISAID_Metadata.tsv ../
mv GISAID_Sequences.fasta ../