source("src/main/R/thesis/plot/thesisBoxplot.r")
source("src/main/R/thesis/plot/saveThesisPlot.r")

plotEffectSizeAndPValue <- function(metricsFolder, plotTitlePrefix, outfilePrefix) {
  effectSizeData <- tribble(~conf, ~val)
  for (i in 1:length(confNames)) {
    diffFileName <- str_c(metricsFolder,"diff-stats-fit_def_sec_def-to-",
                          confNames[i],".csv")
    diffFileContents <- read_csv(diffFileName) %>% select(val = effectSizeNum) %>% add_column(conf = confNames[i])
    effectSizeData <- effectSizeData %>% bind_rows(diffFileContents)
  }
  
  thesisBoxplot(effectSizeData, "val", str_c(plotTitlePrefix," effect size compared to fit_def_sec_def, per configuration"), ylabel = "Effect size")
  saveThesisPlot(str_c(outfilePrefix,"-effect-size.pdf"), scale = 2)
  
  pValueData <- tribble(~conf, ~val)
  for (i in 1:length(confNames)) {
    diffFileName <- str_c(metricsFolder,"diff-stats-fit_def_sec_def-to-",
                          confNames[i],".csv")
    diffFileContents <- read_csv(diffFileName) %>% select(val = testResult) %>% add_column(conf = confNames[i])
    pValueData <- pValueData %>% bind_rows(diffFileContents)
  }
  
  thesisBoxplot(pValueData, "val", str_c(plotTitlePrefix," p-value for fit_def_sec_def compared to target configuration"), ylabel = "P-value", yLogScale = TRUE)
  saveThesisPlot(str_c(outfilePrefix,"-p-value.pdf"), scale = 2)
}

# Input files
infileTcData <- "r-input/data/tc-data.csv"
infileSuiteData <- "r-input/data/suite-data.csv"
infileInterData <- "r-input/data/inter-data.csv"

# Per class commonality coverage
tcData <- read_csv(infileTcData) %>% rename_all(make.names) %>% filter(exec.weight.cov >= 0.0)
thesisBoxplot(tcData, "exec.weight.cov", "Test case commonality coverage, per configuration")
saveThesisPlot("r-output/plots/commonality-per-configuration.pdf", scale = 2)

# Configurations names declaration
confNames <- c()
confNames[1] <- "fit_def_sec_max"
confNames[2] <- "fit_def_sec_min"
confNames[3] <- "fit_max_min_sec_def"
confNames[4] <- "fit_max_sec_max"
confNames[5] <- "fit_min_sec_min"

# Standard metrics
suiteData <- read_csv(infileSuiteData) %>% rename_all(make.names) %>% filter(pit.score >= 0.0)
thesisBoxplot(suiteData, "pit.score", "Test suite PIT score, per configuration", ylabel = "Score")
saveThesisPlot("r-output/plots/pit-per-configuration.pdf", scale = 2)

thesisBoxplot(suiteData, "branch.coverage", "Test suite branch coverage, per configuration")
saveThesisPlot("r-output/plots/branch-cov-per-configuration.pdf", scale = 2)

thesisBoxplot(suiteData, "num.generations", "Test suite #search generations, per configuration", ylabel = "#Generations", ymax = 600, outlierShape = NA)
saveThesisPlot("r-output/plots/generations-per-configuration.pdf", scale = 2)

thesisBoxplot(suiteData, "suite.size", "Test suite size, per configuration", ylabel = "Size", ymax = 80, outlierShape = NA)
saveThesisPlot("r-output/plots/suite-size-per-configuration.pdf", scale = 2)

thesisBoxplot(tcData, "length", "Test case length, per configuration", ylabel = "Length", ymax = 14, outlierShape = NA)
saveThesisPlot("r-output/plots/tc-length-per-configuration.pdf", scale = 2)

# Effect sizes and p-values
plotEffectSizeAndPValue("r-input/data/commonality/", "Commonality", "r-output/plots/commonality")
plotEffectSizeAndPValue("r-input/data/standard-metrics/num-generations/", "#Generations", "r-output/plots/generations")
plotEffectSizeAndPValue("r-input/data/standard-metrics/suite-size/", "Suite size", "r-output/plots/suite-size")
plotEffectSizeAndPValue("r-input/data/standard-metrics/tc-length/", "Test case length", "r-output/plots/tc-length")
plotEffectSizeAndPValue("r-input/data/pit/all/", "PIT score", "r-output/plots/pit")

# Coverage evolution
interData <- read_csv(infileInterData) %>% rename_all(make.names) %>% filter(ff.value <= 1.0 & ff.value >= 0.0)

ffNames <- vector(mode = "character")
ffNames[1] <- "LineCoverageSuiteFitness"
ffNames[2] <- "BranchCoverageSuiteFitness"
ffNames[3] <- "ExceptionCoverageSuiteFitness"
ffNames[4] <- "WeakMutationSuiteFitness"
ffNames[5] <- "InputCoverageSuiteFitness"
ffNames[6] <- "OutputCoverageSuiteFitness"
ffNames[7] <- "MethodCoverageSuiteFitness"
ffNames[8] <- "MethodNoExceptionCoverageSuiteFitness"
ffNames[9] <- "CBranchSuiteFitness"
ffNames[10] <- "ExecWeightSuiteFitness"

titleSuffixes <- vector(mode = "character")
titleSuffixes[1] <- "line coverage"
titleSuffixes[2] <- "branch coverage"
titleSuffixes[3] <- "exception coverage"
titleSuffixes[4] <- "weak mutation score"
titleSuffixes[5] <- "input coverage"
titleSuffixes[6] <- "output coverage"
titleSuffixes[7] <- "method coverage"
titleSuffixes[8] <- "method (no exception) coverage"
titleSuffixes[9] <- "direct branch coverage"
titleSuffixes[10] <- "commonality coverage"


for (i in 1:length(ffNames)) {
    filtered <- filter(interData, ff.name == ffNames[i] & configuration != "nsgaii_max" & configuration != "nsgaii_min")
    mediansPerConf <- filtered %>% group_by(configuration, runtime) %>% summarise(median = median(ff.value))
    
    plot <- ggplot(mediansPerConf, aes(runtime, median, group = configuration, color = configuration))
    plot <- plot + geom_line() +
      labs(title = str_c("Coverage value evolution for ",titleSuffixes[i])) + 
      xlab("Runtime (ms)") + ylab("Median coverage value") +
      geom_vline(xintercept = 180000)
    print(plot)
    saveThesisPlot(str_c("r-output/plots/inter-summ-", ffNames[i], ".pdf"), scale = 2)
}
