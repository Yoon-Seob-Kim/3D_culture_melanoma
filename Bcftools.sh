#!/bin/bash
#SBATCH -J count
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
COUNT_DIR=./11_PILEUP
for i in MM_T 3D PDX
do
bcftools mpileup --skip-indels -f $DB/human_g1k_v37.fasta -R $COUNT_DIR/interval.list $BAM_DIR/$i\_b37.bam -o $COUNT_DIR/$i\_depth.txt -a AD,DP
done


