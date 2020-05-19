library(tidyverse)
library(effsize)
source("src/main/R/thesis/plot/saveThesisPlot.r")

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

outFolder <- "r-output/plots/"
outWidth <- 297
outHeight <- 210

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
    return(result %>% ungroup() %>% filter(!is.na(testResult)) %>%
             filter(testResult < 0.05 & effectSizeNum >= 0.0))
  }
  
  statsByClass <- stats %>% filter(val >= 0.0) %>% group_by(class)
  return(compareConf(statsByClass, conf1, conf2) %>%
           select(conf1, conf2, effectSize = effectSizeNum))
}

computePlotData <- function(stats) {
  plotData <- tribble(~conf1, ~conf2, ~effectSize)
  
  for (i in 1:length(confNames)) {
    for (j in 1:length(confNames)) {
      if (i == j) {
        next
      }
      comparisonData <- computeMetrics(stats, confNames[i], confNames[j])
      plotData <- plotData %>% bind_rows(comparisonData)
    }
  }
  return(plotData)
}

plotConfCompare <- function(plotData, plotTitle) {
  numObservations <- function(inputData) {
    return(tibble(y=0.95, label = str_c("n = ",length(inputData))))
  }
  
  ggplot(plotData, aes(factor(0), effectSize)) + geom_violin(fill = "#30688e") +
    geom_boxplot(color = "grey", width = 0.1, alpha = 0.2) + 
    facet_grid(cols = vars(conf1), rows = vars(conf2)) +
    scale_y_continuous(limits = c(-0.05,1.05), expand = expand_scale(),
                       minor_breaks = c(0.5), breaks = c(0,1)) +
    scale_x_discrete(expand = expand_scale(add=0.5), breaks = NULL) +
    labs(x = "", y = "Effect size") +
    stat_summary(fun.data = numObservations, geom = "label", size = 3,
                 position = position_nudge(x = 0.35)) +
    labs(title = plotTitle)
}

infileTcStats <- 'r-input/data/tc-data.csv'
tcStats <- read_csv(infileTcStats) %>% rename_all(make.names)
commonalityStats <- tcStats[,c("class", "conf", "run.id", "exec.weight.cov")] %>% rename(val = exec.weight.cov)
commonalityPlotData <- computePlotData(commonalityStats)
plotConfCompare(commonalityPlotData,
                "Commonality score per test case, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-commonality.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)

tcLengthStats <- tcStats[,c("class", "conf", "run.id", "length")] %>% rename(val = length)
tcLengthPlotData <- computePlotData(tcLengthStats)
plotConfCompare(tcLengthPlotData,
                "Test case length, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-tc-length.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)

infileSuiteStats <- 'r-input/data/suite-data.csv'
suiteStats <- read_csv(infileSuiteStats) %>% rename_all(make.names)
pitStats <- suiteStats[,c("class", "conf", "run.id", "pit.score")] %>% rename(val = pit.score)
pitPlotData <- computePlotData(pitStats)
plotConfCompare(pitPlotData,
                "PIT score per test suite, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-pit.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)

branchStats <- suiteStats[,c("class", "conf", "run.id", "branch.coverage")] %>% rename(val = branch.coverage)
branchPlotData <- computePlotData(branchStats)
plotConfCompare(branchPlotData,
                "Branch coverage per test suite, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-branch.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)

suiteSizeStats <- suiteStats[,c("class", "conf", "run.id", "suite.size")] %>% rename(val = suite.size)
suiteSizePlotData <- computePlotData(suiteSizeStats)
plotConfCompare(suiteSizePlotData,
                "Test suite size, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-suite-size.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)

numGensStats <- suiteStats[,c("class", "conf", "run.id", "num.generations")] %>% rename(val = num.generations)
numGensPlotData <- computePlotData(numGensStats)
plotConfCompare(numGensPlotData,
                "Number of EvoSuite generations, difference in effect size across configurations")
saveThesisPlot(str_c(outFolder, "facet-num-generations.pdf"),
               plotWidth = outWidth, plotHeight = outHeight)
