#!/bin/bash
#SBATCH -J 3DMM
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta

#tool_path
BWA=/data/MRC1_data4/kysbbubbu/tools/bwa-0.7.17
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.5.0
QUALIMAP=/data/MRC1_data4/kysbbubbu/tools/qualimap_v2.2.1
DB=/data/MRC1_data4/kysbbubbu/genomicdb
FASTQC=/data/MRC1_data4/kysbbubbu/tools/FastQC_v0.11.9
FASTQ_DIR=/data/MRC1_data4/kysbbubbu/Project_Rawdata/3DMM

##OUTPUT
FASTQC_DIR=./01_FastQC
BAM_DIR=./02_BAM
BAMQC_DIR=./03_BAMQC
MT_DIR=./04_MT
for i in 3D
do
$GATK/gatk --java-options "-Xmx4g" FastqToSam -F1 $FASTQ_DIR/$i\_1.fq.gz -F2 $FASTQ_DIR/$i\_2.fq.gz -SO queryname -SM $i -RG $i -O $i\_unmapped.bam
$BWA/bwa mem -t 8 $DB/mouse/b37_mm10.fa $FASTQ_DIR/$i\_1.fq.gz $FASTQ_DIR/$i\_2.fq.gz > $i\.sam
$GATK/gatk --java-options "-Xmx4g" MergeBamAlignment -R $DB/mouse/b37_mm10.fa --CREATE_INDEX -UNMAPPED $i\_unmapped.bam -ALIGNED $i\.sam -O $i\.bam
rm $i\.sam $i\_unmapped.bam
samtools view -h $i\.bam | grep -v $'\t''chr' | grep -v 'SN:chr' | samtools view -b - > $i\_filter.bam
rm $i\.bam $i\.bai
$GATK/gatk SamToFastq -I $i\_filter.bam -F $i\_filter_1.fastq.gz -F2 $i\_filter_2.fastq.gz
rm $i\_filter.bam
$FASTQC/fastqc -o $FASTQC_DIR -t 8 $i\_filter_1.fastq.gz $i\_filter_2.fastq.gz
$GATK/gatk --java-options "-Xmx4g" FastqToSam -F1 $i\_filter_1.fastq.gz -F2 $i\_filter_2.fastq.gz -SO queryname -SM $i -RG $i -O $i\_unmapped.bam
$BWA/bwa mem -t 8 $DB/human_g1k_v37.fasta $i\_filter_1.fastq.gz $i\_filter_2.fastq.gz > $i\.sam
$GATK/gatk --java-options "-Xmx4g" MergeBamAlignment -R $DB/human_g1k_v37.fasta --CREATE_INDEX -UNMAPPED $i\_unmapped.bam -ALIGNED $i\.sam -O $i\.bam
rm $i\.sam $i\_unmapped.bam
$GATK/gatk --java-options "-Xmx4g" AddOrReplaceReadGroups -I $i\.bam -O $i\_RG.bam -SO coordinate --CREATE_INDEX -ID $i -LB $i -PU $i -PL ILLUMINA -SM $i
rm $i\.bam $i\.bai
$GATK/gatk --java-options "-Xmx4g" MarkDuplicates -I $i\_RG.bam -O $i\.bam -M $i\_dup_metrics.txt
rm $i\_RG.bam $i\_RG.bai $i\_dup_metrics.txt
$GATK/gatk --java-options "-Xmx4g" BaseRecalibrator -R $DB/human_g1k_v37.fasta -I $i\.bam --known-sites $DB/dbsnp_138.b37.vcf --known-sites $DB/1000G_phase1.indels.b37.vcf -O $i\_recal_data.table
$GATK/gatk --java-options "-Xmx4g" ApplyBQSR -R $DB/human_g1k_v37.fasta -I $i\.bam -bqsr $i\_recal_data.table -O $BAM_DIR/$i\_b37.bam
rm $i\.bam $i\.bam.bai $i\_recal_data.table
$GATK/gatk --java-options "-Xmx4g" GetPileupSummaries -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$i\_b37.bam -O $MT_DIR/$i\_pileups.table -V $DB/af-only-gnomad.raw.sites.b37.vcf.gz --intervals $DB/SureselectV5.list
$QUALIMAP/qualimap bamqc -bam $BAM_DIR/$i\_b37.bam -gff $DB/SureselectV5.bed -outdir $BAMQC_DIR/$i -c --java-mem-size=4G
$GATK/gatk --java-options "-Xmx4g" HaplotypeCaller -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$i\_b37.bam --intervals $DB/Sensus_v92_exome.list -ERC GVCF -O $MT_DIR/$i\_germline.vcf.gz
done

