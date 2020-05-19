library(tidyverse)
library(effsize)
library(xtable)

confNames <- c()
confNames[1] <- "fit_def_sec_def"
confNames[2] <- "fit_def_sec_max"
confNames[3] <- "fit_def_sec_min"
confNames[4] <- "fit_max_min_sec_def"
confNames[5] <- "fit_max_sec_max"
confNames[6] <- "fit_min_sec_min"
confNames[7] <- "nsgaii_max"
confNames[8] <- "nsgaii_min"

confDispNames <- c()
confDispNames[1] <- "f_def_s_def"
confDispNames[2] <- "f_def_s_max"
confDispNames[3] <- "f_def_s_min"
confDispNames[4] <- "f_max_max_s_def"
confDispNames[5] <- "f_max_s_max"
confDispNames[6] <- "f_min_s_min"
confDispNames[7] <- "nsgaii_max"
confDispNames[8] <- "nsgaii_min"

outFolder <- "r-output/latex-tables/number-of-classes/"

computeMetrics <- function(stats, conf1, conf2) {
  compareConf <- function (statsPerClass, conf1, conf2) {
    result <- statsPerClass %>% group_modify((function(rows, key) {
      onlyConf1<- rows %>% filter(conf == conf1)
      onlyConf1Cov <- onlyConf1$val
      
      onlyConf2 <- rows %>% filter(conf == conf2)
      onlyConf2Cov <- onlyConf2$val
      
      if (length(onlyConf1Cov) == 0 | length(onlyConf2Cov) == 0) {
        testResult <- NA
        effectSizeNum <- NA
        effectSizeMag <- NA
      }
      else {
        testResultFull <- wilcox.test(onlyConf1Cov, onlyConf2Cov)
        testResult <- testResultFull$p.value
        
        effectSizeFull <- cliff.delta(onlyConf1Cov, onlyConf2Cov)
        effectSizeNum <- effectSizeFull$estimate
      }
      
      result <- tibble(conf1, conf2, testResult, effectSizeNum)
      return(result)
    }))
    return(result %>% ungroup() %>% filter(!is.na(testResult)))
  }
  
  statsByClass <- stats %>% filter(val >= 0.0) %>% group_by(class)
  return(compareConf(statsByClass, conf1, conf2))
}

countClasses <- function(stats) {
  counts <- tribble(~conf1, ~conf2, ~numberOfClasses)
  counts <- counts %>% add_row(conf1 = confNames[1], conf2 = confNames[1], numberOfClasses = NA)
  
  for (i in 1:length(confNames)) {
    for (j in 1:length(confNames)) {
      if (i == j) {
        next
      }
      comparisonData <- computeMetrics(stats, confNames[i], confNames[j])
      counts <- counts %>%
        add_row(conf1 = confNames[i], conf2 = confNames[j], numberOfClasses = tally(comparisonData))
    }
  }
  return(counts)
}

infileTcStats <- 'r-input/data/tc-data.csv'
tcStats <- read_csv(infileTcStats) %>% rename_all(make.names)
commonalityStats <- tcStats[,c("class", "conf", "run.id", "exec.weight.cov")] %>% rename(val = exec.weight.cov)
commonalityCounts <- countClasses(commonalityStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
commonalityCountsTable <- xtable(commonalityCounts,
                      digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                      display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(commonalityCountsTable, file = str_c(outFolder, "commonality.tex"))

tcLengthStats <- tcStats[,c("class", "conf", "run.id", "length")] %>% rename(val = length)
tcLengthCounts <- countClasses(tcLengthStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
tcLengthCountsTable <- xtable(tcLengthCounts,
                                 digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                                 display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(tcLengthCountsTable, file = str_c(outFolder, "tc-length.tex"))


infileSuiteStats <- 'r-input/data/suite-data.csv'
suiteStats <- read_csv(infileSuiteStats) %>% rename_all(make.names)
pitStats <- suiteStats[,c("class", "conf", "run.id", "pit.score")] %>% rename(val = pit.score)
pitCounts <- countClasses(pitStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
pitCountsTable <- xtable(pitCounts,
                                 digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                                 display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(pitCountsTable, file = str_c(outFolder, "pit.tex"))


branchStats <- suiteStats[,c("class", "conf", "run.id", "branch.coverage")] %>% rename(val = branch.coverage)
branchCounts <- countClasses(branchStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
branchCountsTable <- xtable(branchCounts,
                                 digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                                 display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(branchCountsTable, file = str_c(outFolder, "branch.tex"))

suiteSizeStats <- suiteStats[,c("class", "conf", "run.id", "suite.size")] %>% rename(val = suite.size)
suiteSizeCounts <- countClasses(suiteSizeStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
suiteSizeCountsTable <- xtable(suiteSizeCounts,
                                 digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                                 display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(suiteSizeCountsTable, file = str_c(outFolder, "suite-size.tex"))

numGensStats <- suiteStats[,c("class", "conf", "run.id", "num.generations")] %>% rename(val = num.generations)
numGensCounts <- countClasses(numGensStats) %>%
  pivot_wider(names_from = conf2, values_from = numberOfClasses, values_fill = list(numberOfClasses=NA))
numGensCountsTable <- xtable(numGensCounts,
                                 digits = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
                                 display = c("s", "s", "d", "d", "d", "d", "d", "d", "d", "d"))
print.xtable(numGensCountsTable, file = str_c(outFolder, "num-generations.tex"))
