#!/bin/bash
#SBATCH -J seba
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.1.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
FUNCO_DIR=./05_FUNCTO
for T in MM_T
do
awk -F '\t' '{if($7== NULL) print; else if($7 == "FILTER") print ; else if($7 == "PASS") print}' $MT_DIR/$T\_filt.vcf > $MT_DIR/$T\_filt2.vcf
$GATK/gatk SelectVariants -R $DB/human_g1k_v37.fasta -V $MT_DIR/$T\_filt2.vcf --select-type-to-include SNP -O $MT_DIR/$T\_filt3.vcf
$GATK/gatk Funcotator --data-sources-path $FUNCTO -V $MT_DIR/$T\_filt3.vcf --output $FUNCO_DIR/$T\.txt --output-file-format MAF --ref-version hg19 -R $DB/human_g1k_v37.fasta --force-b37-to-hg19-reference-contig-conversion --sites-only-vcf-output
done



