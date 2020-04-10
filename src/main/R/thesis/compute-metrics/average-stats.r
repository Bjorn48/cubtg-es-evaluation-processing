library(tidyverse)
library(xtable)

# Configurations names declaration
confNames <- c()
confNames[1] <- "fit_def_sec_max"
confNames[2] <- "fit_def_sec_min"
confNames[3] <- "fit_max_min_sec_def"
confNames[4] <- "fit_max_sec_max"
confNames[5] <- "fit_min_sec_min"

# P-values declaration
pVals <- c()
pVals[1] <- 0.05
pVals[2] <- 0.01
pVals[3] <- 0.001

sigStatsForFolder <- function(infileFolder, metricName) {
  sigHigher <- tribble(~metric, ~compConf, ~pVal, ~conf1Higher, ~conf2Higher, ~totalClasses)
  
  for (i in 1:length(confNames)) {
    infile <- str_c(infileFolder,"diff-stats-fit_def_sec_def-to-",confNames[i],".csv")
    diffStats <- read_csv(infile)
    totalClasses <- diffStats %>% tally() %>% first()
    for (p in 1:length(pVals)) {
      numConf2Higher <- diffStats %>% filter(testResult <= pVals[p] & effectSizeNum > 0.5) %>% tally() %>% first()
      numConf1Higher <- diffStats %>% filter(testResult <= pVals[p] & effectSizeNum < 0.5) %>% tally() %>% first()
      
      sigHigher <- sigHigher %>% add_row(metric = metricName, compConf = confNames[i], pVal = pVals[p],
                            conf1Higher = numConf1Higher, conf2Higher = numConf2Higher,
                            totalClasses = totalClasses)
    }
    
    summaryForFile <- sigHigher %>% filter(metric == metricName & pVal == 0.05) %>%
      select("Compared configuration" = compConf,
        "SGFNT default" = conf1Higher, "SGFNT compared" = conf2Higher,
        "Total #classes" = totalClasses)
    outputTable <- xtable(summaryForFile,
                          digits = c(20, 20, 3, 3, 3),
                          display = c("s", "s", "g", "g", "g"))
    print.xtable(outputTable, file = str_c("r-output/latex-tables/significance/",metricName,".tex"))
    
  }
  return(sigHigher)
}

# Compute values for all metric folders
stats <- list()

stats[[1]] <- sigStatsForFolder("r-input/data/commonality/","commonality")
stats[[2]] <- sigStatsForFolder("r-input/data/pit/all/","pit")
stats[[3]] <- sigStatsForFolder("r-input/data/standard-metrics/branch-coverage/","branch")
stats[[4]] <- sigStatsForFolder("r-input/data/standard-metrics/exception-coverage/","exception")
stats[[5]] <- sigStatsForFolder("r-input/data/standard-metrics/input-coverage/","input")
stats[[6]] <- sigStatsForFolder("r-input/data/standard-metrics/method-coverage/","method")
stats[[7]] <- sigStatsForFolder("r-input/data/standard-metrics/num-generations/","generations")
stats[[8]] <- sigStatsForFolder("r-input/data/standard-metrics/output-coverage/","output")
stats[[9]] <- sigStatsForFolder("r-input/data/standard-metrics/suite-size/","suite-size")
stats[[10]] <- sigStatsForFolder("r-input/data/standard-metrics/tc-length/","tc-length")
stats[[11]] <- sigStatsForFolder("r-input/data/standard-metrics/weak-mutation-score/","weak-mutation")

# Combine data
statsCombined <- bind_rows(stats)

write_csv(statsCombined, "r-output/latex-tables/significance/detailed.csv")
