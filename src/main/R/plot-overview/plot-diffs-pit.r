library(ggplot2)
library(dplyr)
source("src/main/r/functions.r")

inputFile <- 'r-input/ratios-to-pit.csv'
statistics <- read.csv(inputFile, header = TRUE)
statistics <- filter(statistics, max.weight < 400000)

plot <- ggplot(statistics, aes(max.weight,ratio))
plot + geom_point() + geom_quantile()
