library(tidyverse)
source("src/main/r/thesis/computeMetrics.r")

inputFile <- 'r-input/tc-data.csv'
stats <- read_csv(inputFile) %>% rename_all(make.names)
statsExecweight <- stats[,c(c("class", "conf", "run.id", "exec.weight.cov"))] %>% rename(val = exec.weight.cov)

outputPath <- "r-output/data/commonality/"
computeMetrics(statsExecweight, outputPath)
