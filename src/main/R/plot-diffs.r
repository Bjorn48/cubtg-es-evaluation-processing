library(ggplot2)
source("src/main/r/functions.r")

baseFilePath <- 'r-input/'
fileNames <- vector(mode = "character")
fileNames[1] <- 'ratios-def-to-def-max.csv'
fileNames[2] <- 'ratios-def-to-def-min.csv'
fileNames[3] <- 'ratios-def-to-max-max.csv'
fileNames[4] <- 'ratios-def-to-max-min-def.csv'
fileNames[5] <- 'ratios-def-to-min-min.csv'

plotTitles <- vector(mode = "character")
plotTitles[1] <- 'Commonality factor ratio, from fit_def_sec_def to fit_def_sec_max'
plotTitles[2] <- 'Commonality factor ratio, from fit_def_sec_def to fit_def_sec_min'
plotTitles[3] <- 'Commonality factor ratio, from fit_def_sec_def to fit_max_sec_max'
plotTitles[4] <- 'Commonality factor ratio, from fit_def_sec_def to fit_max_min_sec_def'
plotTitles[5] <- 'Commonality factor ratio, from fit_def_sec_def to fit_min_sec_min'

for (i in 1:length(fileNames)) {
  fullName <- paste(baseFilePath, fileNames[i], sep = "")
  statistics <- read.csv(fullName, header = TRUE)
  
  binPlot <- ggplot(statistics, aes(ratio))
  binPlot <- binPlot + geom_histogram(center = 1.0, binwidth = 0.1) +
    scale_x_continuous(breaks = seq(0, 20, by=0.5)) + labs(title = plotTitles[i]) +
    xlab("Ratio") + ylab("#test suites")
  print(binPlot)
  saveSvgPlot(paste("r-output/", tools::file_path_sans_ext(fileNames[i]), ".svg", sep = ""))
}
