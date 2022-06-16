#!/bin/bash
#SBATCH -J 3DMM
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/MRC1_data4/kysbbubbu/genomicdb
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.1.0

##OUTPUT
BAM_DIR=./02_BAM
VARSCAN_DIR=./08_VARSCAN
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s
FUNCO_DIR=./05_FUNCTO
ANNO_DIR=./07_Annovar

N=MM_N
T=3D
samtools mpileup -q 20 -Q 20 -l $DB/SureselectV5.bed -f $DB/human_g1k_v37.fasta $BAM_DIR/$N\_b37.bam > $VARSCAN_DIR/$N\.pileup
samtools mpileup -q 20 -Q 20 -l $DB/SureselectV5.bed -f $DB/human_g1k_v37.fasta $BAM_DIR/$T\_b37.bam > $VARSCAN_DIR/$T\.pileup
java -jar /data/MRC1_data4/kysbbubbu/tools/Varscan2/VarScan.v2.3.9.jar somatic $VARSCAN_DIR/$N\.pileup $VARSCAN_DIR/$T\.pileup $VARSCAN_DIR/$T\_varscan --min-coverage-normal 20 --min-coverage-tumor 20 --min-coverage 20 -strand-filter --output-vcf
rm $VARSCAN_DIR/$N\.pileup $VARSCAN_DIR/$T\.pileup
java -jar /data/MRC1_data4/kysbbubbu/tools/Varscan2/VarScan.v2.3.9.jar processSomatic $VARSCAN_DIR/$T\_varscan.indel.vcf
java -jar /data/MRC1_data4/kysbbubbu/tools/Varscan2/VarScan.v2.3.9.jar processSomatic $VARSCAN_DIR/$T\_varscan.snp.vcf
/data/MRC1_data4/kysbbubbu/tools/annovar/table_annovar.pl $VARSCAN_DIR/$T\_varscan.indel.Somatic.hc.vcf /data/MRC1_data4/kysbbubbu/genomicdb/humandb -buildver hg19 --vcfinput -out $ANNO_DIR/$T\_indel -remove -protocol refGene,cytoBand,cosmic95_coding,cosmic95_noncoding,icgc28,exac03,gnomad211_exome,clinvar_20220320,dbnsfp42a,avsnp150 -operation g,r,f,f,f,f,f,f,f,f -nastring . -otherinfo
$GATK/gatk Funcotator --data-sources-path $FUNCTO -V $VARSCAN_DIR/$T\_varscan.indel.Somatic.hc.vcf --output $FUNCO_DIR/$T\_indel.txt --output-file-format VCF --ref-version hg19 -R $DB/human_g1k_v37.fasta --force-b37-to-hg19-reference-contig-conversion --disable-sequence-dictionary-validation

