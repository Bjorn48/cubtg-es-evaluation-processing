library(ggplot2)
source("src/main/r/functions.r")

baseFilePath <- 'r-input/'
complexPath <- 'filtered/only-complex/'
longPath <- 'filtered/only-long/'
usedOftenPath <- 'filtered/only-used-often/'

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
  fullNameAll <- paste(baseFilePath, fileNames[i], sep = "")
  allStats <- read.csv(fullNameAll, header = TRUE)
  allStats$set <- "all"
  
  fullNameComplex <- paste(baseFilePath, complexPath, fileNames[i], sep = "")
  complexStats <- read.csv(fullNameComplex, header = TRUE)
  complexStats$set <- "complex"
  
  fullNameLong <- paste(baseFilePath, longPath, fileNames[i], sep = "")
  longStats <- read.csv(fullNameLong, header = TRUE)
  longStats$set <- "long"
  
  fullNameUsedOften <- paste(baseFilePath, usedOftenPath, fileNames[i], sep = "")
  usedOftenStats <- read.csv(fullNameUsedOften, header = TRUE)
  usedOftenStats$set <- "used-often"
  
  combinedData <- rbind(allStats, complexStats, longStats, usedOftenStats)
  
  boxPlot <- ggplot(combinedData, aes(set, ratio))
  boxPlot <- boxPlot + geom_boxplot() + stat_summary(fun.y = mean, pch=22, size=3, geom="point") +
    labs(title = plotTitles[i]) + xlab("Configuration") + ylab("Ratio")
  print(boxPlot)
  saveSvgPlot(paste("r-output/", tools::file_path_sans_ext(fileNames[i]), "-box.svg", sep = ""))
}
