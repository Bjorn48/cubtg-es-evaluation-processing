library(ggplot2)
library(dplyr)
source("src/main/r/functions.r")

inputFile <- 'r-input/tc-data.csv'
statistics <- read.csv(inputFile, header = TRUE)

boxplotColumn(statistics, "exec.weight.cov", "Test case commonality coverage")
saveSvgPlot("r-output/tc-commonality.svg")

boxplotColumn(statistics, "length", "Test case length", ylabel = "Length")
saveSvgPlot("r-output/tc-length.svg")
