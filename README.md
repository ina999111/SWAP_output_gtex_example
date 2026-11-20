# SWAP output gtex example

This repository contains script that creates inputs and outputs from the SWAP pipeline.
**The SWAP pipeline itself is not out yet**

## Description

The scripts in this repository use publicly available data from GTEX.
The raw RNAsew count data is first normalized. This, with a metabolic tasklist and a genomic scale metabolic model, are fed into SWAP. 
SWAP finds the optimal pathway (serie of reactions) to complete each task for each sample.
The output from SWAP is a .json file per task and per sample containing information on the reactions used and their "expression" (aka activity)
These .json files are used to create a summary dataframe, with rows being the sample-task combination and columns being the various info in the .json files (notably reactions used and their expression)
The summary is then used to compute task scores.
The scores are computed without considering the expression of GPRless reactions.
The task scores can then be used in different application, for example clustering or looking at sex differences.

## Workflow

![Workflow diagram](docs/workflow.jpeg)

## Scripts details
| script name                       | what it does                                                                                                                                                                               | input                                                                                 | output                                                           |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| 01_download_gtex.Rmd              | downloads raw counts from gtex<br>downloads patients attributes<br>select specific samples                                                                                                 | none                                                                                  | raw count RNAseq data<br>patients attributes data                |
| 02_normalization.Rmd              | filters inactive genes<br>batch correction<br>gene length normalization<br>library size normalization<br>makes sure there are no zeros                                                     | raw count RNAseq data                                                                 | normalized RNAseq data                                           |
| 03_create_summary.py              | reads the .json files produced by SWAP<br>creates a data frame with each row being a task-sample combination<br>contains information on reactions used and their expression                | .json files produced by SWAP                                                          | summary dataframe                                                |
| 04_explore_summary.Rmd            | makes sure all tasks and samples are in the summary<br>makes sure unfeasible tasks are not there                                                                                           | summary dataframe                                                                     | none                                                             |
| 05_get_lists_GPRless_reactions.py | finds GPRless reactions in the model<br>finds transport reactions in the model<br>finds exchange reactions in the model                                                                    | metabolic model                                                                       | R-style lists of GPRless, transport and exchange reactions (ids) |
| 06_calculate_score.Rmd            | calculate a score for each task and sample combination<br>options available are: median, average and minimum                                                                               | R-style lists of GPRless, transport and exchange reactions (ids)<br>summary dataframe | score dataframe                                                  |
| 07_explore_scores.Rmd             | makes sure all tasks and samples are there<br>creates task- and sample-wise summaries of score<br>looks at the distribution of score<br>looks at tasks with very low scores                | score dataframe                                                                       | none                                                             |
| 08_sex_differences.Rmd            | compares task scores between males and females<br>computes fold change and pvalue<br>plots the results                                                                                     | score dataframe<br>patients attributes data                                           | fold changes, pvalues and plots                                  |
| 09_clustering.Rmd                 | performs hierchical clustering with and without PCA<br>looks at the quality of the clusters created<br>looks at the impact of the number of principal components kept<br>plots the results | score dataframe                                                                       | clusters and plots                                               |

## Requirements
R: tidyverse, edgeR, txdbmaker, GenomicFeatures, openxlsx, data.table, GGally, pheatmap, ggrepel, factoextra, cluster, fpc, FactoMineR, tidytext
Python: os, pandas, json, pathlib, time, cobra
