# 载入必要的R库
library(ballgown)
library(RSkittleBrewer)
library(genefilter)
library(dplyr)
library(devtools)
library(ggplot2)
library(pheatmap)

# 读取输入数据并生成pheno_data对象
pheno_data <- read.csv("phenodata.csv")

# 创建ballgown对象
bg <- ballgown(dataDir = "./differential", samplePattern = "SRR", pData = pheno_data)

# 过滤低表达基因
bg_filt <- subset(bg, "rowVars(texpr(bg)) > 1", genomesubset = TRUE)

# 转录本的差异表达分析
results_transcripts <- stattest(bg_filt, feature = "transcript", covariate = "condition", getFC = TRUE, meas = "FPKM")

# 基因的差异表达分析
results_genes <- stattest(bg_filt, feature = "gene", covariate = "condition", getFC = TRUE, meas = "FPKM")

# 添加基因名称和基因ID注释
results_transcripts <- data.frame(geneNames = ballgown::geneNames(bg_filt), geneIDs = ballgown::geneIDs(bg_filt), results_transcripts)

# 按p值排序
results_transcripts <- arrange(results_transcripts, pval)
results_genes <- arrange(results_genes, pval)

# 保存结果到csv文件
write.csv(results_transcripts, "transcript_results.csv", row.names = FALSE)
write.csv(results_genes, "gene_results.csv", row.names = FALSE)

# 获取FPKM值并进行log2转换
fpkm <- texpr(bg, meas = "FPKM")
fpkm <- log2(fpkm + 1)

# 画箱线图
boxplot(fpkm, col = as.numeric(pheno_data$condition), las = 2, ylab = 'log2(FPKM+1)')

# 打印第一个转录本和基因名称
print(ballgown::transcriptNames(bg)[1])
print(ballgown::geneNames(bg)[1])

# 条件转换为因子
pheno_data$condition <- as.factor(pheno_data$condition)

# 去除NA值
fpkm_clean <- na.omit(fpkm[1,])

# 画散点图
plot(log2(fpkm_clean + 1) ~ pheno_data$condition, border = c(1, 2),
     main = paste(ballgown::geneNames(bg)[1], ':', ballgown::transcriptNames(bg)[1]),
     pch = 19, xlab = "Condition", ylab = 'log2(FPKM+1)')
points(log2(fpkm_clean + 1) ~ jitter(as.numeric(pheno_data$condition)), col = as.numeric(pheno_data$condition))

# 添加log2 fold change和- log10 p-value列
results_genes <- results_genes %>% mutate(log2FC = log2(fc), negLog10Pval = -log10(pval))

# 画火山图
ggplot(results_genes, aes(x = log2FC, y = negLog10Pval)) +
  geom_point(aes(color = pval < 0.05)) +
  scale_color_manual(values = c("black", "red")) +
  theme_minimal() +
  labs(title = "Volcano Plot", x = "Log2 Fold Change", y = "-Log10 P-Value")

# 获取基因表达矩阵
gene_expression_matrix <- gexpr(bg_filt)

# 匹配结果基因的索引
matching_indices <- match(results_genes$id, rownames(gene_expression_matrix))

# 计算A值
results_genes$A <- rowMeans(log2(gene_expression_matrix[matching_indices, ] + 1))

# 画MA图
ggplot(results_genes, aes(x = A, y = log2FC)) +
  geom_point(aes(color = pval < 0.05), alpha = 0.4) +
  scale_color_manual(values = c("black", "red")) +
  labs(x = "Average Expression (log2)", y = "Log2 Fold Change", title = "MA Plot of Gene Differential Expression") +
  theme_minimal()

cat("差异表达分析和可视化流程已完成。\n")