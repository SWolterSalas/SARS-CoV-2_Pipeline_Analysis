#!/bin/bash

# 

cd ../analisis

mkdir 12_indisa_genomes
mkdir 13_nexstrain_files

cd 11_metadata

mkdir temp

cat Statistics_Metadata_QCpassed_lineages.csv | 
grep BC- | while read lines ; 
do 
	name=`echo $lines | sed 's/,/\t/g' | awk '{print $1}'` ; 
	grep "$name" Santiago_COVID-19_metadata.csv ; 
done | sed '1i strain,Row,Sex,end,sex,Lane,city,HA_ID,Index,Plate,ha_id,index,start,today,Column,object,Control,Index.1,Index.2,OrderID,PFReads,Project,country,project,setting,traffic,FlowCell,Location,Organism,RawReads,SampleID,altitude,comments,latitude,order_id,organism,protocol,username,OrderDate,SampleRef,longitude,precision,volume_ul,SampleType,Volume(ul),decription,well_p-r-c,Application,Conc(ng_ul),Description,Projectname,SampleBatch,Well(P_R_C),geolocation,sample_type,surface_wet,ProjectTitle,date_ordered,ground_level,Description.1,Yield(Mbases),location_name,location_type,object_number,sampling_type,swab_time_sec,internal_index,MetaSUB_PlateID,extraction_date,object_overview,object_specific,surface_material,%of>=Q30Bases(PF),Demultiplex_Index,air_temperature_C,duplicate_swab_yn,location_overview,%PerfectIndexReads,MeanQualityScore(PF),concentration_ng-ul ,%ofrawclustersperlane,%OneMismatchReads(Index),relative_humidity_percent,object_other,object_cleaned,surface_material_other' > Santiago_COVID-19_metadata_QCPassed.csv

# Tratar metadata
# Dejarlo con las columnas de entrada
cat Santiago_COVID-19_metadata_QCPassed.csv | 
sed 's/(i.e. nylon, polyester)//g' | 
sed 's/"//g' | sed 's/ /_/g' | 
sed 's/,/,\t/g' | sed 's/$/,/g' | 
awk '{print $1,$23,$7,$14,$36,$25,$62,$59,$34,$41,$77,$63,$65,$16,$71,$72,$84,$86,$75,$83}' | 
sed 's/ //g' | sed 's/,$//g' | 
sed -e "s/,,/,?,/g" | sed -e "s/,,/,?,/g"| 
sed -e "s/,,/,?,/g" | sed -e "s/,$/,?/g" | 
sed -E 's/(.)\/(.)\/(..)/\320-0\2-0\1/g' | 
sed 's/_,/,/g' | sed -E 's/(....)-(..)-(..)/\3-\2-\1/g' > Santiago_COVID-19_metadata_QCPassed_Depurated.csv

paste Santiago_COVID-19_metadata_QCPassed_Depurated.csv Statistics_Metadata_QCpassed_lineages.csv | 
sed 's/,/ /g' | 
awk '{print $1,$4,$2,$3,$22,$23,$24,$25,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20}'| 
sed 's/ /,/g' | sed -E 's/(BC-..........)(,)/\1,ncov,South_America\2/g' | 
sed 's/strain,/strain,virus,region,/g' | sed 's/today/date/g' | 
sed -E 's/(,Chile)/\1,Region_Metropolitana_de_Santiago/g' | 
sed 's/country,/country,division,/g' | sed 's/_/ /g' |  sed '1s/ /_/g'> Santiago_COVID-19_metadata_temp.csv

cat Santiago_COVID-19_metadata_temp.csv | 
sed 's/ /_/g' | 
sed 's/,/\t/g' | 
awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$3,$5}' | 
sed 's/ /,/g' | sed 's/_/ /g' | sed '1s/ /_/g' | 
sed 's/region,country/region_exposure,country_exposure/g' | sed -E 's/(..)-(..)-(....)/\3-\2-\1/g' > Santiago_COVID-19_Metadata_Nextstrain.csv

sed 's/,/\t/g' Santiago_COVID-19_Metadata_Nextstrain.csv > Santiago_COVID-19_Metadata_Nextstrain.tsv

mv Santiago_COVID-19_metadata_QCPassed_Depurated.csv temp
mv Santiago_COVID-19_metadata_QCPassed.csv temp
mv Santiago_COVID-19_metadata_temp.csv temp
mv Santiago_COVID-19_Metadata_Nextstrain.tsv ../13_nexstrain_files

cp ../10_lineages/sequences_QCpassed.fasta ../13_nexstrain_files
mv ../13_nexstrain_files/sequences_QCpassed.fasta ../13_nexstrain_files/Santiago_COVID-19_Sequences_Nextstrain.fasta

cd ../13_nexstrain_files

mkdir GISAID
