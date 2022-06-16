#!/bin/bash
#SBATCH -J 3DMM
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.5.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT

N=MM_N
T=PDX
$GATK/gatk --java-options "-Xmx4g" Mutect2 -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$N\_b37.bam -I $BAM_DIR/$T\_b37.bam -normal $N -tumor $T --intervals $DB/SureselectV5.list --f1r2-tar-gz $MT_DIR/$T\.tar.gz --germline-resource $DB/af-only-gnomad.raw.sites.b37.vcf.gz -O $MT_DIR/$T\.vcf 
$GATK/gatk --java-options "-Xmx4g" CalculateContamination -I $MT_DIR/$T\_pileups.table -matched $MT_DIR/$N\_pileups.table -O $MT_DIR/$T\_contamination.table
$GATK/gatk --java-options "-Xmx4g" LearnReadOrientationModel -I $MT_DIR/$T\.tar.gz -O $MT_DIR/$T\_cal.tar.gz
$GATK/gatk --java-options "-Xmx4g" FilterMutectCalls -V $MT_DIR/$T\.vcf --ob-priors $MT_DIR/$T\_cal.tar.gz -R $DB/human_g1k_v37.fasta --contamination-table $MT_DIR/$T\_contamination.table --intervals $DB/SureselectV5.list -O $MT_DIR/$T\_filt.vcf

