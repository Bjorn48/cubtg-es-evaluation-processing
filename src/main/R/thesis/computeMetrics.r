library(tidyverse)
library(effsize)

computeMetrics <- function(stats, outFolder) {
  perConfSummary <- stats %>% group_by(conf) %>% group_modify(function(rows, key) {
    summ <- summary(rows$val)
    result <- as_tibble(as.list(summ))
    return(result)
  })
  
  perClassAndConfAvgCov <- stats %>% group_by(class, conf) %>%
    summarise(avg = mean(val)) %>% spread(conf, avg)
  
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
        
        effectSizeFull <- VD.A(onlyConf2Cov, onlyConf1Cov)
        effectSizeNum <- effectSizeFull$estimate
        effectSizeMag <- effectSizeFull$magnitude
      }
      
      result <- tibble(testResult, effectSizeNum, effectSizeMag)
      return(result)
    }))
    return(result %>% filter(!is.na(testResult)))
  }
  
  statsByClass <- stats %>% group_by(class)
  defToDefMax <- compareConf(statsByClass, "fit_def_sec_def", "fit_def_sec_max")
  defToMaxMax <- compareConf(statsByClass, "fit_def_sec_def", "fit_max_sec_max")
  defToDefMin <- compareConf(statsByClass, "fit_def_sec_def", "fit_def_sec_min")
  defToMinMin <- compareConf(statsByClass, "fit_def_sec_def", "fit_min_sec_min")
  defToMaxMinDef <- compareConf(statsByClass, "fit_def_sec_def", "fit_max_min_sec_def")
  
  dir.create(outFolder, recursive = TRUE)
  perConfSummary %>% write_csv(str_c(outFolder, "per-conf-summary.csv"))
  perClassAndConfAvgCov %>% write_csv(str_c(outFolder, "per-class-and-conf-avg-cov.csv"))
  defToDefMax %>% write_csv(str_c(outFolder, "diff-stats-fit_def_sec_def-to-fit_def_sec_max.csv"))
  defToMaxMax %>% write_csv(str_c(outFolder, "diff-stats-fit_def_sec_def-to-fit_max_sec_max.csv"))
  defToDefMin %>% write_csv(str_c(outFolder, "diff-stats-fit_def_sec_def-to-fit_def_sec_min.csv"))
  defToMinMin %>% write_csv(str_c(outFolder, "diff-stats-fit_def_sec_def-to-fit_min_sec_min.csv"))
  defToMaxMinDef %>% write_csv(str_c(outFolder, "diff-stats-fit_def_sec_def-to-fit_max_min_sec_def.csv"))
}
