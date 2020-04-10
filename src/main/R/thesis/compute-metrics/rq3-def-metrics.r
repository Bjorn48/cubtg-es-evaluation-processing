library(tidyverse)
source("src/main/r/thesis/compute-metrics/computeMetrics.r")

inputFile <- 'r-input/suite-data.csv'
stats <- read_csv(inputFile) %>% rename_all(make.names)

statsLine <- stats[,c("class", "conf", "run.id", "line.coverage")] %>% rename(val = line.coverage)
statsBranch <- stats[,c("class", "conf", "run.id", "branch.coverage")] %>% rename(val = branch.coverage)
statsException <- stats[,c("class", "conf", "run.id", "exception.coverage")] %>% rename(val = exception.coverage)
statsMutation <- stats[,c("class", "conf", "run.id", "weak.mutation.score")] %>% rename(val = weak.mutation.score)
statsMethod <- stats[,c("class", "conf", "run.id", "method.coverage")] %>% rename(val = method.coverage)
statsInput <- stats[,c("class", "conf", "run.id", "input.coverage")] %>% rename(val = input.coverage)
statsOutput <- stats[,c("class", "conf", "run.id", "output.coverage")] %>% rename(val = output.coverage)
statsSize <- stats[,c("class", "conf", "run.id", "suite.size")] %>% rename(val = suite.size)
statsGens <- stats[,c("class", "conf", "run.id", "num.generations")] %>% rename(val = num.generations)

baseOutputPath <- "r-output/data/standard-metrics/"
computeMetrics(statsLine, str_c(baseOutputPath, "line-coverage/"))
computeMetrics(statsBranch, str_c(baseOutputPath, "branch-coverage/"))
computeMetrics(statsException, str_c(baseOutputPath, "exception-coverage/"))
computeMetrics(statsMutation, str_c(baseOutputPath, "weak-mutation-score/"))
computeMetrics(statsMethod, str_c(baseOutputPath, "method-coverage/"))
computeMetrics(statsInput, str_c(baseOutputPath, "input-coverage/"))
computeMetrics(statsOutput, str_c(baseOutputPath, "output-coverage/"))
computeMetrics(statsSize, str_c(baseOutputPath, "suite-size/"))
computeMetrics(statsGens, str_c(baseOutputPath, "num-generations/"))
