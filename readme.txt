This project is a whole pipeline for RNA-seq data analyze.The pipeline recept SRA data from RNA-seq experiment generated from Illumina.The input SRA data will be transformed into FASTA file and recept preprocess.Then it will be aligned to genome with genomic GTF file provided,using HISAT.The alignment result will be used for next step transcript assemble by StringTie.You can choose to merge assembling result from multiple samples,which is recommended.
Then,using these assembling results,we have Ballgown to do the differential expression analyze.The analyze resultswill be saved into a csv file.Ballgown also has visualization funtion to provide figures,so you can see the resultclearly.

To run the pipeline,you should:

1.Download SRA format data that you need

2.Run the bash script Assemble.bash.It does data preprocessing,alignment and transcription assembling.

3.Run the bash script Merge.bash to merge multiple samples' results.

4.Run the script Differential_expression_analyzer.R under R environment.

5.Run the script Visualisation.R to get the figure results.
