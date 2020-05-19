library(tidyverse)

saveThesisPlot <- function(outFile, plot = last_plot(), scale = 1, plotWidth = 140, plotHeight = 70) {
  ggsave(plot = plot, filename = outFile, width = plotWidth, height = plotHeight, units = "mm", scale = scale)
}
