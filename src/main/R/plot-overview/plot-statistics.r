library(ggplot2)
library(dplyr)
source("src/main/r/functions.r")

inputFile <- 'r-input/suite-data.csv'
statistics <- read.csv(inputFile, header = TRUE)

boxplotColumn(statistics, "line.coverage", "Suite line coverage")
saveSvgPlot("r-output/suite-line.svg")

boxplotColumn(statistics, "branch.coverage", "Suite branch coverage")
saveSvgPlot("r-output/suite-branch.svg")

boxplotColumn(statistics, "exception.coverage", "Suite exception coverage")
saveSvgPlot("r-output/suite-exception.svg")

boxplotColumn(statistics, "weak.mutation.score", "Suite weak mutation score")
saveSvgPlot("r-output/suite-weak-mutation.svg")

boxplotColumn(statistics, "method.coverage", "Suite method coverage")
saveSvgPlot("r-output/suite-method.svg")

boxplotColumn(statistics, "input.coverage", "Suite input coverage")
saveSvgPlot("r-output/suite-input.svg")

boxplotColumn(statistics, "output.coverage", "Suite output coverage")
saveSvgPlot("r-output/suite-output.svg")

boxplotColumn(statistics, "suite.size", "Suite size")
saveSvgPlot("r-output/suite-size.svg")

boxplotColumn(statistics, "num.generations", "Number of evolution generations")
saveSvgPlot("r-output/suite-generations.svg")

boxplotColumn(statistics, "pit.score", "Suite PIT score")
saveSvgPlot("r-output/suite-pit.svg")
