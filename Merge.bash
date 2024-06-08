#!/bin/bash

# 检查参数数量
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <REFERENCE_GTF> <OUTPUT_MERGED_GTF> <SAMPLE_BAM_PREFIX> <GTF_FILES...>"
    exit 1
fi

# 从命令行参数读取变量
REFERENCE_GTF="$1"
OUTPUT_MERGED_GTF="$2"
SAMPLE_BAM_PREFIX="$3"
shift 3
GTF_FILES="$@"

MERGELIST_FILE="mergelist.txt"

# 1. 创建mergelist.txt文件并添加GTF文件路径
> $MERGELIST_FILE
for GTF_FILE in $GTF_FILES; do
    echo $GTF_FILE >> $MERGELIST_FILE
done

# 2. 合并GTF文件
stringtie --merge -G $REFERENCE_GTF -o $OUTPUT_MERGED_GTF $MERGELIST_FILE

# 3. 使用合并后的GTF文件进行转录本表达量估计
stringtie ${SAMPLE_BAM_PREFIX}_sorted.bam -e -B -G $OUTPUT_MERGED_GTF -o ${SAMPLE_BAM_PREFIX}_transcripts.gtf

echo "GTF合并和表达量估计已完成。"
