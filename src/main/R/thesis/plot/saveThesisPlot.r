library(tidyverse)

saveThesisPlot <- function(outFile, plot = last_plot(), scale = 1) {
  ggsave(plot = plot, filename = outFile, width = 140, height = 105, units = "mm", scale = scale)
}
