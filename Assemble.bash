#!/bin/bash

# 检查参数数量
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <SRA_FILE> <TRIMMOMATIC_JAR> <TRIMMOMATIC_ADAPTERS> <REFERENCE_GENOME> <REFERENCE_GTF> <SAMPLE_NAME>"
    exit 1
fi

# 从命令行参数读取变量
SRA_FILE="$1"
TRIMMOMATIC_JAR="$2"
TRIMMOMATIC_ADAPTERS="$3"
REFERENCE_GENOME="$4"
REFERENCE_GTF="$5"
SAMPLE_NAME="$6"

FASTQ_FILE="${SAMPLE_NAME}_1.fastq"
TRIMMED_FASTQ_FILE="trimmed_${SAMPLE_NAME}.fastq"
ALIGNMENT_FILE="aligned_${SAMPLE_NAME}.sam"
BAM_FILE="aligned_${SAMPLE_NAME}.bam"
SORTED_BAM_FILE="sorted_${SAMPLE_NAME}.bam"
ASSEMBLED_GTF="assembled_${SAMPLE_NAME}.gtf"
HISAT2_INDEX_PREFIX="Arabidopsis_thaliana_index"

# 1. 提取FASTQ文件
fastq-dump --split-files $SRA_FILE

# 2. 运行FastQC进行质量控制
fastqc $FASTQ_FILE

# 3. 修剪reads
java -jar $TRIMMOMATIC_JAR SE -phred33 $FASTQ_FILE $TRIMMED_FASTQ_FILE ILLUMINACLIP:$TRIMMOMATIC_ADAPTERS:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# 4. 构建Hisat2索引
hisat2-build $REFERENCE_GENOME $HISAT2_INDEX_PREFIX

# 5. 比对reads到参考基因组
hisat2 -x $HISAT2_INDEX_PREFIX -U $TRIMMED_FASTQ_FILE -S $ALIGNMENT_FILE

# 6. 转换SAM文件为BAM文件并排序
samtools view -bS $ALIGNMENT_FILE > $BAM_FILE
samtools sort $BAM_FILE -o $SORTED_BAM_FILE

# 7. 使用StringTie组装转录本
stringtie $SORTED_BAM_FILE -G $REFERENCE_GTF -o $ASSEMBLED_GTF -l $SAMPLE_NAME

echo "RNA-seq分析流程已完成。"
