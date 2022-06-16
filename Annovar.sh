#!/bin/bash
#SBATCH -J Annovar
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
ANNO_DIR=./07_Annovar
for i in Annovar
do
/data/MRC1_data4/kysbbubbu/tools/annovar/table_annovar.pl $ANNO_DIR/$i\.txt /data/MRC1_data4/kysbbubbu/genomicdb/humandb -buildver hg19 -out $ANNO_DIR/$i -remove -protocol refGene,cytoBand,cosmic95_coding,cosmic95_noncoding,icgc28,exac03,gnomad211_exome,clinvar_20220320,dbnsfp42a,avsnp150 -operation g,r,f,f,f,f,f,f,f,f -nastring . -otherinfo
done

