# 载入必要的R库
library(ballgown)
library(RSkittleBrewer)
library(genefilter)
library(dplyr)
library(devtools)

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

cat("差异表达分析流程已完成。\n")