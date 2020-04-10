library(tidyverse)
source("src/main/r/thesis/compute-metrics/computeMetrics.r")

inputFile <- 'r-input/data/tc-data.csv'
stats <- read_csv(inputFile) %>% rename_all(make.names)
statsExecweight <- stats[,c("class", "conf", "run.id", "exec.weight.cov")] %>% rename(val = exec.weight.cov)
statsLength <- stats[,c("class", "conf", "run.id", "length")] %>% rename(val = length)

outputPath <- "r-output/data/commonality/"
computeMetrics(statsExecweight, outputPath)
computeMetrics(statsLength, "r-output/data/standard-metrics/tc-length/")
