library(tidyverse)
library(xtable)

# Configurations names declaration
confNames <- c()
confNames[1] <- "fit_def_sec_max"
confNames[2] <- "fit_def_sec_min"
confNames[3] <- "fit_max_min_sec_def"
confNames[4] <- "fit_max_sec_max"
confNames[5] <- "fit_min_sec_min"

combineDataNoPrint <- function(diffStatsInputFile, confAvgInputFile, classMetricsInputFile, timesExecutedInputFile, confName1, confName2) {
  diffStats <- read_csv(diffStatsInputFile)
  confAvg <- read_csv(confAvgInputFile)
  classMetrics <- read_csv(classMetricsInputFile)
  timesExecuted <- read_csv(timesExecutedInputFile)
  
  combined <- left_join(diffStats, confAvg, by="class") %>% left_join(classMetrics, by="class") %>%
    left_join(timesExecuted, by = c("class"="class-name"))
  onlyRelevant <-
    combined %>% select(class, complexity = wmc, loc, max.count = "max-count", matches(confName1), matches(confName2), testResult, effectSizeNum, effectSizeMag)
  return(onlyRelevant)
}

combined <- combineDataNoPrint("r-input/data/standard-metrics/num-generations/diff-stats-fit_def_sec_def-to-fit_max_min_sec_def.csv",
                               "r-input/data/standard-metrics/num-generations/per-class-and-conf-avg-cov.csv",
                               "r-input/table-input/class-metrics.csv",
                               "r-input/table-input/class-max-counts.csv",
                               "fit_def_sec_def", "fit_max_min_sec_def")

conf1Better <- combined %>% filter(testResult < 0.05 & effectSizeNum > 0.5)

complexPlot <- ggplot(combined, aes(complexity, effectSizeNum))
complexPlot + geom_point()

locPlot <- ggplot(combined, aes(loc, effectSizeNum))
locPlot + geom_point()

countPlot <- ggplot(combined, aes(max.count, effectSizeNum))
countPlot + geom_point()
