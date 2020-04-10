library(tidyverse)
library(xtable)

# Configurations names declaration
confNames <- c()
confNames[1] <- "fit_def_sec_max"
confNames[2] <- "fit_def_sec_min"
confNames[3] <- "fit_max_min_sec_def"
confNames[4] <- "fit_max_sec_max"
confNames[5] <- "fit_min_sec_min"

combineData <- function(diffStatsInputFile, confAvgInputFile, classMetricsInputFile, timesExecutedInputFile, confName1, confName2, outfile) {
  diffStats <- read_csv(diffStatsInputFile)
  confAvg <- read_csv(confAvgInputFile)
  classMetrics <- read_csv(classMetricsInputFile)
  timesExecuted <- read_csv(timesExecutedInputFile)
  
  combined <- left_join(diffStats, confAvg, by="class") %>% left_join(classMetrics, by="class") %>%
    left_join(timesExecuted, by = c("class"="class-name"))
  onlyRelevant <-
    combined %>% select(class, complexity = wmc, loc, max.count = "max-count", matches(confName1), matches(confName2), testResult, effectSizeNum, effectSizeMag)

  outputTable <- xtable(onlyRelevant,
                        digits = c(20, 20, 20, 20, 20, 3, 3, 3, 3, 20),
                        display = c("s", "s", "d", "d", "d", "g", "g", "g", "g", "s"))
  print.xtable(outputTable, file = str_c("r-output/latex-tables/",outfile))
}

createMetricsTableForFolder <- function(infileFolder, outfilePrefix) {
  for (i in 1:length(confNames)) {
    diffStatsInfile <- str_c(infileFolder,"diff-stats-fit_def_sec_def-to-",confNames[i],".csv")
    confAvgInfile <- str_c(infileFolder,"per-class-and-conf-avg-cov.csv")
    classMetricsInfile <- "r-input/table-input/class-metrics.csv"
    timesExecutedInfile <- "r-input/table-input/class-max-counts.csv"
    outfile <- str_c(outfilePrefix,"-fit_def_sec_def-to-",confNames[i],".tex")
    combineData(diffStatsInfile, confAvgInfile, classMetricsInfile, timesExecutedInfile,
                "fit_def_sec_def", confNames[i], outfile)
  }
}

createMetricsTableForFolder("r-input/data/commonality/","commonality")
createMetricsTableForFolder("r-input/data/pit/all/","pit")
createMetricsTableForFolder("r-input/data/standard-metrics/branch-coverage/","branch")
createMetricsTableForFolder("r-input/data/standard-metrics/exception-coverage/","exception")
createMetricsTableForFolder("r-input/data/standard-metrics/input-coverage/","input")
createMetricsTableForFolder("r-input/data/standard-metrics/method-coverage/","method")
createMetricsTableForFolder("r-input/data/standard-metrics/num-generations/","generations")
createMetricsTableForFolder("r-input/data/standard-metrics/output-coverage/","output")
createMetricsTableForFolder("r-input/data/standard-metrics/suite-size/","suite-size")
createMetricsTableForFolder("r-input/data/standard-metrics/tc-length/","tc-length")
createMetricsTableForFolder("r-input/data/standard-metrics/weak-mutation-score/","weak-mutation")


# diffStatsInputFile <- "r-input/table-input/diff-stats.csv"
# confAvgInputFile <- "r-input/table-input/per-class-and-conf-avg-cov.csv"
# classMetricsInputFile <- "r-input/table-input/class-metrics.csv"
# timesExecutedInputFile <- "r-input/table-input/class-max-counts.csv"
# 
# relevant <- combineData(diffStatsInputFile, confAvgInputFile, classMetricsInputFile, timesExecutedInputFile, "fit_def_sec_def", "fit_max_sec_max")
# outputTable <- xtable(relevant,
#                       digits = c(20, 20, 20, 20, 20, 3, 3, 3, 3, 20),
#                       display = c("s", "s", "d", "d", "d", "g", "g", "g", "g", "s"))
# print.xtable(outputTable, file = "r-output/latex-tables/out.tex")
