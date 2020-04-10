library(tidyverse)
source("src/main/r/thesis/compute-metrics/computeMetrics.r")

inputFile <- 'r-input/filtered/only-used-often/suite-data.csv'
stats <- read_csv(inputFile) %>% rename_all(make.names)
statsPit <- stats[,c("class", "conf", "run.id", "pit.score")] %>% rename(val = pit.score)

outputPath <- "r-output/data/pit/common/"
computeMetrics(statsPit, outputPath)
