library(ggplot2)
library(dplyr)
source("src/main/r/functions.r")

inputFile <- 'r-input/inter-data.csv'
statistics <- read.csv(inputFile, header = TRUE)

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

confNames <- vector(mode = "character")
confNames[1] <- "fit_def_sec_def"
confNames[2] <- "fit_def_sec_max"
confNames[3] <- "fit_def_sec_min"
confNames[4] <- "fit_max_min_sec_def"
confNames[5] <- "fit_max_sec_max"
confNames[6] <- "fit_min_sec_min"
confNames[7] <- "nsgaii_max"
confNames[8] <- "nsgaii_min"

for (i in 1:length(ffNames)) {
  for (j in 1:length(confNames)) {
    filtered <- filter(statistics, ff.name == ffNames[i] & configuration == confNames[j] & ff.value <= 1.0 & ff.value >= 0.0)

    plot <- ggplot(filtered, aes(runtime, ff.value, group = runtime))
    plot <- plot + geom_boxplot() + stat_summary(fun.y = mean, pch=22, size=3, geom="point") +
      labs(title = paste("Coverage value evolution; Fitness function: ", ffNames[i], sep = ""), subtitle = paste("Configuration: ", confNames[j], sep = "")) + 
      xlab("Runtime (ms)") + ylab("Coverage value")
    print(plot)
    saveSvgPlot(paste("r-output/inter-", confNames[j], "-", ffNames[i], ".svg", sep = ""))
  }
}
